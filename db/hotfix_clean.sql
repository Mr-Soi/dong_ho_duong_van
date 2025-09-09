-- Persons: cho phép NULL, bỏ ngày 1900-01-01 và dọn Alias/BirthPlace
ALTER TABLE dbo.Persons ALTER COLUMN BirthDate DATETIME2 NULL;
ALTER TABLE dbo.Persons ALTER COLUMN DeathDate DATETIME2 NULL;

UPDATE dbo.Persons SET BirthDate = NULL WHERE TRY_CONVERT(date, BirthDate)='1900-01-01';
UPDATE dbo.Persons SET DeathDate = NULL WHERE TRY_CONVERT(date, DeathDate)='1900-01-01';
UPDATE dbo.Persons SET Alias      = NULLIF(LTRIM(RTRIM(Alias)), N'...');
UPDATE dbo.Persons SET BirthPlace = NULLIF(LTRIM(RTRIM(BirthPlace)), N'NULL');

-- Albums: ẩn mô tả rác (NULL, rỗng hoặc bắt đầu bằng 'NULL,NULL,NULL,0')
UPDATE dbo.Albums
SET Description = NULL
WHERE Description IS NULL OR Description IN ('', 'NULL', 'null', 'N/A')
   OR Description LIKE 'NULL,NULL,NULL,0%';

-- Posts: đảm bảo Summary/CoverImage/CategoryId
IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'tin-tuc')
    INSERT INTO dbo.Categories(Name,Slug,CreatedAt) VALUES (N'Tin tức',N'tin-tuc',SYSUTCDATETIME());
DECLARE @CatDefault INT = (SELECT TOP 1 Id FROM dbo.Categories WHERE Slug=N'tin-tuc');

UPDATE p
SET  p.Summary    = COALESCE(p.Summary, N''),
     p.CoverImage = COALESCE(NULLIF(p.CoverImage, N''), N'/img/uploads/logo_www.png'),
     p.CategoryId = COALESCE(p.CategoryId, @CatDefault)
FROM dbo.Posts p;

UPDATE p
SET p.CategoryId = @CatDefault
FROM dbo.Posts p LEFT JOIN dbo.Categories c ON c.Id = p.CategoryId
WHERE p.CategoryId IS NULL OR c.Id IS NULL;
