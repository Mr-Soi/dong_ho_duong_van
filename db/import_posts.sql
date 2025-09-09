IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'tin-tuc')
  INSERT INTO dbo.Categories(Name,Slug,CreatedAt) VALUES (N'Tin tức',N'tin-tuc',SYSUTCDATETIME());

IF OBJECT_ID('tempdb..#PST','U') IS NOT NULL DROP TABLE #PST;
CREATE TABLE #PST(
  PostId NVARCHAR(MAX), Title NVARCHAR(MAX), Slug NVARCHAR(MAX), Content NVARCHAR(MAX),
  Summary NVARCHAR(MAX), CategoryId NVARCHAR(MAX), CoverImageUrl NVARCHAR(MAX),
  IsPublished NVARCHAR(MAX), CreatedAt NVARCHAR(MAX)
);
BULK INSERT #PST FROM '/tmp/Posts.real.utf16.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\r\n', DATAFILETYPE='widechar', TABLOCK);

DECLARE @CatDefault INT = (SELECT TOP 1 Id FROM dbo.Categories WHERE Slug=N'tin-tuc' ORDER BY Id);

MERGE dbo.Posts AS T
USING (
  SELECT
    NULLIF(Title,N'') AS Title,
    NULLIF(Slug,N'')  AS Slug,
    NULLIF(Content,N'') AS Content,
    CASE WHEN TRY_CONVERT(INT,IsPublished)=1 THEN 1 ELSE 0 END AS IsPublished,
    COALESCE(NULLIF(CoverImageUrl,N''), N'/img/uploads/logo_www.png') AS CoverImage,
    COALESCE(TRY_CONVERT(DATETIME2, NULLIF(CreatedAt,N'')), SYSUTCDATETIME()) AS CreatedAt,
    COALESCE(TRY_CONVERT(INT, NULLIF(CategoryId,N'')), @CatDefault) AS CategoryId
  FROM #PST
  WHERE NULLIF(Slug,N'') IS NOT NULL
) S
ON T.Slug=S.Slug
WHEN MATCHED THEN UPDATE SET
  T.Title=S.Title, T.Content=S.Content, T.IsPublished=S.IsPublished,
  T.CoverImage=S.CoverImage, T.CategoryId=S.CategoryId
WHEN NOT MATCHED BY TARGET THEN
  INSERT(Title,Slug,Content,IsPublished,CategoryId,CoverImage,CreatedAt)
  VALUES(S.Title,S.Slug,S.Content,S.IsPublished,S.CategoryId,S.CoverImage,S.CreatedAt);
