-- Staging: khớp đúng cột theo file Posts.csv
IF OBJECT_ID('dbo.StgPostsCsv','U') IS NOT NULL DROP TABLE dbo.StgPostsCsv;
CREATE TABLE dbo.StgPostsCsv(
  Id            INT NULL,
  Title         NVARCHAR(MAX) NULL,
  Slug          NVARCHAR(512) NULL,
  Summary       NVARCHAR(MAX) NULL,
  Content       NVARCHAR(MAX) NULL,
  PublishedAt   DATETIME2 NULL,
  UpdatedAt     DATETIME2 NULL,
  IsPublished   BIT NULL,
  CategoryId    INT NULL,
  HeroImageUrl  NVARCHAR(1000) NULL,
  ThumbnailUrl  NVARCHAR(1000) NULL,
  ViewCount     INT NULL,
  IsDeleted     BIT NULL,
  CreatedAt     DATETIME2 NULL,
  CreatedBy     NVARCHAR(256) NULL,
  UpdatedBy     NVARCHAR(256) NULL,
  TitleNorm     NVARCHAR(MAX) NULL,
  SlugNorm      NVARCHAR(512) NULL
);

-- BULK INSERT CSV UTF-8, có dấu nháy
BULK INSERT dbo.StgPostsCsv
FROM '/tmp/Posts.csv'
WITH (
  FORMAT='CSV',
  FIELDQUOTE = '"',
  FIRSTROW = 2,
  CODEPAGE = '65001'
);

-- Chuẩn slug
UPDATE s SET s.Slug = LTRIM(RTRIM(LOWER(s.Slug))) FROM dbo.StgPostsCsv s;
UPDATE p SET p.Slug = LTRIM(RTRIM(LOWER(p.Slug))) FROM dbo.Posts p;

-- Danh mục mặc định
DECLARE @CatDefault INT =
  COALESCE(
    (SELECT TOP 1 Id FROM dbo.Categories WHERE Slug IN (N'ban-tin') ORDER BY Id),
    (SELECT TOP 1 Id FROM dbo.Categories WHERE Slug IN (N'tin-tuc') ORDER BY Id)
  );

-- Cập nhật từ CSV → Posts (ưu tiên CSV, giữ giá trị cũ nếu CSV trống)
UPDATE p
SET
  p.Title       = COALESCE(NULLIF(s.Title, N''), p.Title),
  p.Summary     = COALESCE(s.Summary, p.Summary, N''),
  p.Content     = COALESCE(s.Content, p.Content),
  p.PublishedAt = COALESCE(s.PublishedAt, p.PublishedAt),
  p.IsPublished = COALESCE(s.IsPublished, p.IsPublished, 1),
  p.CategoryId  = COALESCE(s.CategoryId, p.CategoryId, @CatDefault),
  p.CoverImage  = COALESCE(NULLIF(p.CoverImage,N''), N'/img/uploads/logo_www.png')
FROM dbo.Posts p
JOIN dbo.StgPostsCsv s ON s.Slug = p.Slug;

-- (tùy chọn) Xoá staging
-- DROP TABLE dbo.StgPostsCsv;

-- Kiểm tra nhanh
SELECT TOP 9 p.Id, p.Title, p.PublishedAt, p.CategoryId
FROM dbo.Posts p
WHERE p.IsPublished=1 AND p.PublishedAt>='1950-01-01' AND (p.IsDeleted=0 OR p.IsDeleted IS NULL)
ORDER BY p.PublishedAt DESC;
