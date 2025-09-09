IF OBJECT_ID('dbo.StgPostsSimple','U') IS NOT NULL DROP TABLE dbo.StgPostsSimple;
CREATE TABLE dbo.StgPostsSimple(
  Slug        NVARCHAR(512) NULL,
  Title       NVARCHAR(MAX) NULL,
  PublishedAt NVARCHAR(128) NULL,
  IsPublished NVARCHAR(32)  NULL,
  CategoryId  NVARCHAR(64)  NULL
);

BULK INSERT dbo.StgPostsSimple
FROM '/tmp/Posts.simple.utf16.tsv'
WITH (
  DATAFILETYPE = 'widechar',
  FIELDTERMINATOR = '\t',
  ROWTERMINATOR  = '0x0d0a',
  FIRSTROW = 1,
  TABLOCK
);

UPDATE s SET s.Slug = LTRIM(RTRIM(LOWER(s.Slug))) FROM dbo.StgPostsSimple s;
UPDATE p SET p.Slug = LTRIM(RTRIM(LOWER(p.Slug))) FROM dbo.Posts p;

DECLARE @CatDefault INT =
  COALESCE((SELECT TOP 1 Id FROM dbo.Categories WHERE Slug IN (N'ban-tin') ORDER BY Id),
           (SELECT TOP 1 Id FROM dbo.Categories WHERE Slug IN (N'tin-tuc') ORDER BY Id));

WITH X AS (
  SELECT
    s.*,
    COALESCE(
      TRY_CONVERT(DATETIME2, NULLIF(s.PublishedAt,''), 126),
      TRY_CONVERT(DATETIME2, NULLIF(s.PublishedAt,''), 120),
      TRY_CONVERT(DATETIME2, NULLIF(s.PublishedAt,''), 103)
    ) AS PubDt,
    CASE WHEN NULLIF(LOWER(LTRIM(RTRIM(s.IsPublished))),'') IN ('1','true','yes') THEN 1
         WHEN NULLIF(LOWER(LTRIM(RTRIM(s.IsPublished))),'') IN ('0','false','no')  THEN 0
         ELSE NULL END AS IsPubBit,
    TRY_CAST(NULLIF(LTRIM(RTRIM(s.CategoryId)),'') AS INT) AS CatInt
  FROM dbo.StgPostsSimple s
)
UPDATE p
SET p.Title       = COALESCE(NULLIF(x.Title,N''), p.Title),
    p.PublishedAt = COALESCE(x.PubDt, p.PublishedAt),
    p.IsPublished = COALESCE(x.IsPubBit, p.IsPublished, 1),
    p.CategoryId  = COALESCE(x.CatInt, p.CategoryId, @CatDefault),
    p.CoverImage  = COALESCE(NULLIF(p.CoverImage,N''), N'/img/uploads/logo_www.png')
FROM dbo.Posts p
JOIN X ON X.Slug = p.Slug;

SELECT TOP 9 p.Id,p.Title,p.PublishedAt,p.CategoryId
FROM dbo.Posts p
WHERE p.IsPublished=1 AND (p.IsDeleted=0 OR p.IsDeleted IS NULL) AND p.PublishedAt>='1950-01-01'
ORDER BY p.PublishedAt DESC;
