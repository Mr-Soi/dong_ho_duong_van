IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'tin-tuc')
  INSERT INTO dbo.Categories(Name,Slug,CreatedAt) VALUES (N'Tin tức',N'tin-tuc',SYSUTCDATETIME());
DECLARE @CatDefault int=(SELECT TOP 1 Id FROM dbo.Categories WHERE Slug=N'tin-tuc');

UPDATE p SET
  p.PublishedAt = CASE WHEN p.PublishedAt<'1950-01-01' OR p.PublishedAt IS NULL THEN COALESCE(p.CreatedAt,SYSUTCDATETIME()) ELSE p.PublishedAt END,
  p.CategoryId  = COALESCE(p.CategoryId,@CatDefault),
  p.Summary     = COALESCE(p.Summary,N''),
  p.CoverImage  = COALESCE(NULLIF(p.CoverImage,N''),N'/img/uploads/logo_www.png')
FROM dbo.Posts p;

-- Tùy chọn: thêm cột năm hiển thị nếu cần
IF COL_LENGTH('dbo.Persons','BirthYear') IS NULL ALTER TABLE dbo.Persons ADD BirthYear INT NULL, DeathYear INT NULL;
UPDATE dbo.Persons SET
  BirthYear = CASE WHEN BirthDate IS NULL THEN NULL ELSE YEAR(BirthDate) END,
  DeathYear = CASE WHEN DeathDate IS NULL THEN NULL ELSE YEAR(DeathDate) END;
