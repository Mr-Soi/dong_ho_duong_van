IF OBJECT_ID('dbo.StgLines','U') IS NOT NULL DROP TABLE dbo.StgLines;
CREATE TABLE dbo.StgLines(Id INT IDENTITY(1,1) PRIMARY KEY, Line NVARCHAR(MAX) NOT NULL);

-- UTF-16LE: terminator phải là 2-byte mỗi ký tự
BULK INSERT dbo.StgLines
FROM '/tmp/Posts.simple.utf16.psv'
WITH (
  DATAFILETYPE = 'widechar',
  ROWTERMINATOR = '0x000d000a',  -- CRLF (widechar)
  TABLOCK
);

-- Tách 5 cột bằng ký tự '|' (PSV)
IF OBJECT_ID('dbo.StgPostsSimple','U') IS NOT NULL DROP TABLE dbo.StgPostsSimple;
CREATE TABLE dbo.StgPostsSimple(
  Slug        NVARCHAR(512) NULL,
  Title       NVARCHAR(MAX) NULL,
  PublishedAt NVARCHAR(128) NULL,
  IsPublished NVARCHAR(32)  NULL,
  CategoryId  NVARCHAR(64)  NULL
);

INSERT INTO dbo.StgPostsSimple(Slug,Title,PublishedAt,IsPublished,CategoryId)
SELECT
  TRIM(LOWER(REPLACE(MAX(CASE WHEN s.ordinal=1 THEN s.value END), NCHAR(65279), N''))),
  MAX(CASE WHEN s.ordinal=2 THEN s.value END),
  MAX(CASE WHEN s.ordinal=3 THEN s.value END),
  MAX(CASE WHEN s.ordinal=4 THEN s.value END),
  MAX(CASE WHEN s.ordinal=5 THEN s.value END)
FROM dbo.StgLines l
CROSS APPLY STRING_SPLIT(l.Line, N'|', 1) s
GROUP BY l.Id;

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
         WHEN NULLIF(LOWER(LTRIM(RTRIM(s.IsPublished))),'') IN ('0','false','no') THEN 0
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

SELECT TOP 3 * FROM dbo.StgLines;  -- soi nhanh dòng nạp
SELECT TOP 9 Id,Title,PublishedAt,CategoryId
FROM dbo.Posts
WHERE IsPublished=1 AND (IsDeleted=0 OR IsDeleted IS NULL) AND PublishedAt>='1950-01-01'
ORDER BY PublishedAt DESC;
