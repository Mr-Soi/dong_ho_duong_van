IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'tin-tuc')
  INSERT INTO dbo.Categories(Name,Slug,CreatedAt) VALUES (N'Tin tức',N'tin-tuc',SYSUTCDATETIME());
DECLARE @CatDefault INT = (SELECT TOP 1 Id FROM dbo.Categories WHERE Slug=N'tin-tuc');

WITH S0 AS (
  SELECT
    LEFT(NULLIF(p.Title,N''),1000) AS Title,
    -- chuẩn hoá slug và clamp 300
    LEFT(COALESCE(NULLIF(p.Slug,N''),NULLIF(p.SlugNorm,N''),NULLIF(p.TitleNorm,N''),NULLIF(p.Title,N'')),300) AS SlugNorm,
    NULLIF(p.Content,N'') AS Content,
    CASE WHEN LOWER(NULLIF(p.Status,N'')) IN (N'published',N'1',N'true')
         OR TRY_CONVERT(INT,p.IsPublished)=1 THEN 1 ELSE 0 END AS IsPublished,
    COALESCE(NULLIF(p.HeroImageUrl,N''),NULLIF(p.ThumbnailUrl,N''),NULLIF(p.FeatureImageUrl,N''),
             N'/img/uploads/logo_www.png') AS CoverImage,
    COALESCE(
      TRY_CONVERT(DATETIME2, NULLIF(p.CreatedAt,N'')),
      TRY_CONVERT(DATETIME2, CONCAT(NULLIF(p.PublishDate,N''), N' ', NULLIF(p.PublishTime,N''))),
      SYSUTCDATETIME()
    ) AS CreatedAt,
    COALESCE(c.Id, @CatDefault) AS CategoryId,
    TRY_CONVERT(INT, NULLIF(p.PostId,N'')) AS PostId
  FROM dbo.StgPosts p
  OUTER APPLY (SELECT TRY_CONVERT(INT, NULLIF(p.CategoryId,N'')) AS CatIdRaw) x
  LEFT JOIN dbo.Categories c ON c.Id = x.CatIdRaw
  WHERE NULLIF(p.Title,N'') IS NOT NULL
),
Dedup AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY SlugNorm ORDER BY CreatedAt DESC, PostId DESC) AS rn
  FROM S0
  WHERE NULLIF(SlugNorm,N'') IS NOT NULL
)
MERGE dbo.Posts AS T
USING (SELECT Title, SlugNorm, Content, IsPublished, CoverImage, CreatedAt, CategoryId
       FROM Dedup WHERE rn=1) AS S
ON T.Slug = S.SlugNorm
WHEN MATCHED THEN UPDATE SET
  T.Title=S.Title, T.Content=S.Content, T.IsPublished=S.IsPublished,
  T.CoverImage=S.CoverImage, T.CategoryId=S.CategoryId
WHEN NOT MATCHED BY TARGET THEN
  INSERT(Title,Slug,Content,IsPublished,CategoryId,CoverImage,CreatedAt)
  VALUES(S.Title,S.SlugNorm,S.Content,S.IsPublished,S.CategoryId,S.CoverImage,S.CreatedAt);

SELECT StgRows=COUNT(*) FROM dbo.StgPosts;
SELECT Posts  =COUNT(*) FROM dbo.Posts;
