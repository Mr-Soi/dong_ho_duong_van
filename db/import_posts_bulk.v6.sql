IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'tin-tuc')
  INSERT INTO dbo.Categories(Name,Slug,CreatedAt) VALUES (N'Tin tức',N'tin-tuc',SYSUTCDATETIME());
GO
DELETE FROM dbo.StgPosts;
GO
BULK INSERT dbo.StgPosts
FROM '/tmp/Posts.clean.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDQUOTE='\"', KEEPNULLS, TABLOCK, MAXERRORS=100000);
GO
DECLARE @CatDefault INT = (SELECT TOP 1 Id FROM dbo.Categories WHERE Slug=N'tin-tuc');
;MERGE dbo.Posts AS T
USING (
  SELECT
    NULLIF(Title,N'') AS Title,
    LEFT(COALESCE(NULLIF(Slug,N''),NULLIF(SlugNorm,N''),NULLIF(TitleNorm,N''),NULLIF(Title,N'')),300) AS Slug,
    NULLIF(Content,N'') AS Content,
    CASE WHEN LOWER(NULLIF(Status,N'')) IN (N'published',N'1',N'true') OR TRY_CONVERT(INT,IsPublished)=1 THEN 1 ELSE 0 END AS IsPublished,
    COALESCE(NULLIF(HeroImageUrl,N''),NULLIF(ThumbnailUrl,N''),NULLIF(FeatureImageUrl,N''),N'/img/uploads/logo_www.png') AS CoverImage,
    COALESCE(
      TRY_CONVERT(DATETIME2,NULLIF(CreatedAt,N'')),
      TRY_CONVERT(DATETIME2,CONCAT(NULLIF(PublishDate,N''),N' ',NULLIF(PublishTime,N''))),
      SYSUTCDATETIME()
    ) AS CreatedAt,
    COALESCE(TRY_CONVERT(INT,NULLIF(CategoryId,N'')),@CatDefault) AS CategoryId
  FROM dbo.StgPosts
  WHERE NULLIF(Title,N'') IS NOT NULL
) S
ON T.Slug=S.Slug
WHEN MATCHED THEN UPDATE SET
  T.Title=S.Title,T.Content=S.Content,T.IsPublished=S.IsPublished,
  T.CoverImage=S.CoverImage,T.CategoryId=S.CategoryId
WHEN NOT MATCHED BY TARGET THEN
  INSERT(Title,Slug,Content,IsPublished,CategoryId,CoverImage,CreatedAt)
  VALUES(S.Title,S.Slug,S.Content,S.IsPublished,S.CategoryId,S.CoverImage,S.CreatedAt);
GO
SELECT StgRows=COUNT(*) FROM dbo.StgPosts; SELECT Posts=COUNT(*) FROM dbo.Posts;
