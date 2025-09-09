IF OBJECT_ID('dbo.StgPostsCsv','U') IS NOT NULL DROP TABLE dbo.StgPostsCsv;
CREATE TABLE dbo.StgPostsCsv(          -- tất cả dạng NVARCHAR để tránh lỗi convert
  Id            NVARCHAR(64) NULL,
  Title         NVARCHAR(MAX) NULL,
  Slug          NVARCHAR(512) NULL,
  Summary       NVARCHAR(MAX) NULL,
  Content       NVARCHAR(MAX) NULL,
  PublishedAt   NVARCHAR(128) NULL,
  UpdatedAt     NVARCHAR(128) NULL,
  IsPublished   NVARCHAR(16)  NULL,
  CategoryId    NVARCHAR(64)  NULL,
  HeroImageUrl  NVARCHAR(1000) NULL,
  ThumbnailUrl  NVARCHAR(1000) NULL,
  ViewCount     NVARCHAR(64) NULL,
  IsDeleted     NVARCHAR(16) NULL,
  CreatedAt     NVARCHAR(128) NULL,
  CreatedBy     NVARCHAR(256) NULL,
  UpdatedBy     NVARCHAR(256) NULL,
  TitleNorm     NVARCHAR(MAX) NULL,
  SlugNorm      NVARCHAR(512) NULL
);

-- Linux: CSV UTF-8, LF
BULK INSERT dbo.StgPostsCsv
FROM '/tmp/Posts.csv'
WITH (
  FIRSTROW = 2,
  FIELDTERMINATOR = ',',
  ROWTERMINATOR  = '0x0a',
  FIELDQUOTE = '"',
  TABLOCK
);

-- Chuẩn slug về lower/trim
UPDATE s SET s.Slug = LTRIM(RTRIM(LOWER(s.Slug))) FROM dbo.StgPostsCsv s;
UPDATE p SET p.Slug = LTRIM(RTRIM(LOWER(p.Slug))) FROM dbo.Posts p;

DECLARE @CatDefault INT =
  COALESCE((SELECT TOP 1 Id FROM dbo.Categories WHERE Slug IN (N'ban-tin') ORDER BY Id),
           (SELECT TOP 1 Id FROM dbo.Categories WHERE Slug IN (N'tin-tuc') ORDER BY Id));

-- Hàm chuyển NVARCHAR -> INT an toàn
WITH X AS (
  SELECT
    s.*,
    CAST(NULLIF(LTRIM(RTRIM(s.Id)), '') AS INT) AS IdInt,
    CAST(NULLIF(LTRIM(RTRIM(s.CategoryId)), '') AS INT) AS CatInt,
    -- PublishedAt: thử nhiều style: 126(ISO),120(yyyy-mm-dd hh:mi:ss),103(dd/mm/yyyy)
    COALESCE(
      TRY_CONVERT(DATETIME2, NULLIF(s.PublishedAt,''), 126),
      TRY_CONVERT(DATETIME2, NULLIF(s.PublishedAt,''), 120),
      TRY_CONVERT(DATETIME2, NULLIF(s.PublishedAt,''), 103)
    ) AS PubDt,
    CASE WHEN NULLIF(LOWER(LTRIM(RTRIM(s.IsPublished))),'') IN ('1','true','yes') THEN 1
         WHEN NULLIF(LOWER(LTRIM(RTRIM(s.IsPublished))),'') IN ('0','false','no') THEN 0
         ELSE NULL END AS IsPubBit,
    CASE WHEN NULLIF(LOWER(LTRIM(RTRIM(s.IsDeleted))),'') IN ('1','true','yes') THEN 1
         WHEN NULLIF(LOWER(LTRIM(RTRIM(s.IsDeleted))),'') IN ('0','false','no') THEN 0
         ELSE NULL END AS IsDelBit
  FROM dbo.StgPostsCsv s
)
UPDATE p
SET
  p.Title       = COALESCE(NULLIF(x.Title, N''), p.Title),
  p.Summary     = COALESCE(x.Summary, p.Summary, N''),
  p.Content     = COALESCE(x.Content, p.Content),
  p.PublishedAt = COALESCE(x.PubDt, p.PublishedAt),
  p.IsPublished = COALESCE(x.IsPubBit, p.IsPublished, 1),
  p.IsDeleted   = COALESCE(x.IsDelBit, p.IsDeleted, 0),
  p.CategoryId  = COALESCE(x.CatInt, p.CategoryId, @CatDefault),
  p.CoverImage  = COALESCE(NULLIF(p.CoverImage,N''), N'/img/uploads/logo_www.png')
FROM dbo.Posts p
JOIN X ON X.Slug = p.Slug;

-- Kiểm tra
SELECT TOP 9 p.Id, p.Title, p.PublishedAt, p.CategoryId
FROM dbo.Posts p
WHERE p.IsPublished=1 AND (p.IsDeleted=0 OR p.IsDeleted IS NULL) AND p.PublishedAt>='1950-01-01'
ORDER BY p.PublishedAt DESC;
