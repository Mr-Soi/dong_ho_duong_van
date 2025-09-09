-- 1) Đọc toàn bộ PSV UTF-16LE vào 1 NVARCHAR(MAX)
IF OBJECT_ID('tempdb..#F') IS NOT NULL DROP TABLE #F;
SELECT BulkColumn AS txt
INTO #F
FROM OPENROWSET(
  BULK '/tmp/Posts.simple.utf16.psv',
  SINGLE_NCLOB
) AS S;

-- 2) Tách dòng (loại CR, BOM) → rid, line
IF OBJECT_ID('tempdb..#L') IS NOT NULL DROP TABLE #L;
SELECT
  ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS rid,
  REPLACE(REPLACE(value, NCHAR(65279), N''), NCHAR(13), N'') AS line
INTO #L
FROM #F
CROSS APPLY STRING_SPLIT(txt, NCHAR(10), 1)
WHERE LEN(REPLACE(value, NCHAR(13), N'')) > 0; -- bỏ dòng trống

-- 3) Tách cột theo '|' → Slug, Title, PublishedAt, IsPublished, CategoryId
IF OBJECT_ID('dbo.StgPostsSimple','U') IS NOT NULL DROP TABLE dbo.StgPostsSimple;
CREATE TABLE dbo.StgPostsSimple(
  Slug        NVARCHAR(512) NULL,
  Title       NVARCHAR(MAX) NULL,
  PublishedAt NVARCHAR(128) NULL,
  IsPublished NVARCHAR(32)  NULL,
  CategoryId  NVARCHAR(64)  NULL
);

WITH S AS (
  SELECT l.rid, s.value, s.ordinal
  FROM #L l
  CROSS APPLY STRING_SPLIT(l.line, N'|', 1) s
)
INSERT INTO dbo.StgPostsSimple(Slug,Title,PublishedAt,IsPublished,CategoryId)
SELECT
  TRIM(LOWER(REPLACE(MAX(CASE WHEN ordinal=1 THEN value END), NCHAR(65279), N''))),
  MAX(CASE WHEN ordinal=2 THEN value END),
  MAX(CASE WHEN ordinal=3 THEN value END),
  MAX(CASE WHEN ordinal=4 THEN value END),
  MAX(CASE WHEN ordinal=5 THEN value END)
FROM S
GROUP BY rid;

-- 4) Cập nhật Posts theo Slug
UPDATE p SET p.Slug = TRIM(LOWER(p.Slug)) FROM dbo.Posts p;

DECLARE @CatDefault INT =
  COALESCE((SELECT TOP 1 Id FROM dbo.Categories WHERE Slug IN (N'ban-tin') ORDER BY Id),
           (SELECT TOP 1 Id FROM dbo.Categories WHERE Slug IN (N'tin-tuc') ORDER BY Id));

WITH X AS (
  SELECT s.*,
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

-- 5) Kiểm tra
SELECT TOP 9 Id,Title,PublishedAt,CategoryId
FROM dbo.Posts
WHERE IsPublished=1 AND (IsDeleted=0 OR IsDeleted IS NULL) AND PublishedAt>='1950-01-01'
ORDER BY PublishedAt DESC;
