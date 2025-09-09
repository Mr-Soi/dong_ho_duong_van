-- 1) Bổ sung cột còn thiếu (mỗi ALTER ở batch riêng)
IF COL_LENGTH('dbo.Posts','PublishedAt') IS NULL
    ALTER TABLE dbo.Posts ADD PublishedAt DATETIME2 NULL;
GO
IF COL_LENGTH('dbo.Posts','Summary') IS NULL
    ALTER TABLE dbo.Posts ADD Summary NVARCHAR(MAX) NULL;
GO
IF COL_LENGTH('dbo.Posts','CoverImage') IS NULL
    ALTER TABLE dbo.Posts ADD CoverImage NVARCHAR(512) NULL;
GO
IF COL_LENGTH('dbo.Posts','CategoryId') IS NULL
    ALTER TABLE dbo.Posts ADD CategoryId INT NULL;
GO
IF COL_LENGTH('dbo.Posts','CreatedAt') IS NULL
    ALTER TABLE dbo.Posts ADD CreatedAt DATETIME2 NOT NULL
        CONSTRAINT DF_Posts_CreatedAt DEFAULT SYSUTCDATETIME() WITH VALUES;
GO

-- 2) Category mặc định
IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'tin-tuc')
    INSERT INTO dbo.Categories(Name,Slug,CreatedAt) VALUES (N'Tin tức',N'tin-tuc',SYSUTCDATETIME());
GO

-- 3) Chuẩn hóa PublishedAt bằng dynamic SQL để tránh lỗi parse-time
DECLARE @hasPubl bit = CASE WHEN COL_LENGTH('dbo.Posts','PublishedAt') IS NOT NULL THEN 1 ELSE 0 END;
DECLARE @hasCreated bit = CASE WHEN COL_LENGTH('dbo.Posts','CreatedAt')  IS NOT NULL THEN 1 ELSE 0 END;
IF @hasPubl = 1
BEGIN
    DECLARE @sql nvarchar(max) =
    N'UPDATE p SET p.PublishedAt = CASE WHEN p.PublishedAt IS NULL OR p.PublishedAt<''1950-01-01''
       THEN ' + CASE WHEN @hasCreated=1 THEN N'COALESCE(p.CreatedAt,SYSUTCDATETIME())' ELSE N'SYSUTCDATETIME()' END +
    N' ELSE p.PublishedAt END FROM dbo.Posts p;';
    EXEC(@sql);
END
GO

-- 4) Chuẩn hóa CategoryId/Summary/CoverImage
DECLARE @CatDefault int = (SELECT TOP 1 Id FROM dbo.Categories WHERE Slug=N'tin-tuc');
UPDATE p SET
  p.CategoryId = COALESCE(p.CategoryId,@CatDefault),
  p.Summary    = COALESCE(p.Summary,N''),
  p.CoverImage = COALESCE(NULLIF(p.CoverImage,N''),N'/img/uploads/logo_www.png')
FROM dbo.Posts p;
GO

-- 5) Chỉ mục nếu thiếu
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_Posts_Slug' AND object_id=OBJECT_ID('dbo.Posts'))
    CREATE UNIQUE INDEX UX_Posts_Slug ON dbo.Posts(Slug);
GO
IF COL_LENGTH('dbo.Posts','CreatedAt') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Posts_CreatedAt' AND object_id=OBJECT_ID('dbo.Posts'))
    CREATE INDEX IX_Posts_CreatedAt ON dbo.Posts(CreatedAt DESC);
GO

-- 6) Kiểm tra nhanh
SELECT TOP 3 Id, Title, PublishedAt, CreatedAt, CategoryId, LEFT(Summary,80) AS Summary, CoverImage
FROM dbo.Posts ORDER BY CreatedAt DESC;
