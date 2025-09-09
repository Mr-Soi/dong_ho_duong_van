-- Bổ sung cột còn thiếu (an toàn nếu đã tồn tại thì bỏ qua)
IF COL_LENGTH('dbo.Posts','PublishedAt') IS NULL
    ALTER TABLE dbo.Posts ADD PublishedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.Posts','Summary') IS NULL
    ALTER TABLE dbo.Posts ADD Summary NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.Posts','CoverImage') IS NULL
    ALTER TABLE dbo.Posts ADD CoverImage NVARCHAR(512) NULL;
IF COL_LENGTH('dbo.Posts','CategoryId') IS NULL
    ALTER TABLE dbo.Posts ADD CategoryId INT NULL;

-- Category mặc định
IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'tin-tuc')
    INSERT INTO dbo.Categories(Name,Slug,CreatedAt) VALUES (N'Tin tức',N'tin-tuc',SYSUTCDATETIME());
DECLARE @CatDefault int=(SELECT TOP 1 Id FROM dbo.Categories WHERE Slug=N'tin-tuc');

-- Chuẩn hóa dữ liệu bài viết
UPDATE p SET
  p.PublishedAt = CASE WHEN p.PublishedAt IS NULL OR p.PublishedAt<'1950-01-01' THEN COALESCE(p.CreatedAt,SYSUTCDATETIME()) ELSE p.PublishedAt END,
  p.CategoryId  = COALESCE(p.CategoryId,@CatDefault),
  p.Summary     = COALESCE(p.Summary,N''),
  p.CoverImage  = COALESCE(NULLIF(p.CoverImage,N''),N'/img/uploads/logo_www.png')
FROM dbo.Posts p;

-- Chỉ mục nếu thiếu
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_Posts_Slug' AND object_id=OBJECT_ID('dbo.Posts'))
    CREATE UNIQUE INDEX UX_Posts_Slug ON dbo.Posts(Slug);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Posts_CreatedAt' AND object_id=OBJECT_ID('dbo.Posts'))
    CREATE INDEX IX_Posts_CreatedAt ON dbo.Posts(CreatedAt DESC);
