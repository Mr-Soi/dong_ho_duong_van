USE dhdv;
GO
-- Khoá duy nhất dùng cho FTS
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_Posts_Id' AND object_id=OBJECT_ID('dbo.Posts'))
  CREATE UNIQUE INDEX UX_Posts_Id ON dbo.Posts(Id);
GO
IF SERVERPROPERTY('IsFullTextInstalled')=1
BEGIN
  IF NOT EXISTS (SELECT 1 FROM sys.fulltext_catalogs WHERE name='ft') CREATE FULLTEXT CATALOG ft AS DEFAULT;
  IF NOT EXISTS (SELECT 1 FROM sys.fulltext_indexes WHERE object_id=OBJECT_ID('dbo.Posts'))
    CREATE FULLTEXT INDEX ON dbo.Posts
      (Title LANGUAGE 1066, Summary LANGUAGE 1066, Content LANGUAGE 1066)
      KEY INDEX UX_Posts_Id ON ft WITH STOPLIST = SYSTEM;
END
GO
CREATE OR ALTER PROC dbo.sp_SearchPosts
  @q nvarchar(200)=NULL,
  @categorySlug nvarchar(160)=NULL,
  @page int=1,
  @pageSize int=10
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @ofs int = (@page-1)*@pageSize;
  DECLARE @useFTS bit = CASE WHEN SERVERPROPERTY('IsFullTextInstalled')=1 AND EXISTS(SELECT 1 FROM sys.fulltext_indexes WHERE object_id=OBJECT_ID('dbo.Posts')) THEN 1 ELSE 0 END;

  IF @useFTS=1 AND NULLIF(LTRIM(RTRIM(@q)),N'') IS NOT NULL
  BEGIN
    DECLARE @sql nvarchar(max)=N'
      SELECT p.Id,p.Title,p.Slug,p.PublishedAt,c.Name AS Category
      FROM dbo.Posts p LEFT JOIN dbo.Categories c ON c.Id=p.CategoryId
      WHERE (@cat IS NULL OR c.Slug=@cat)
        AND CONTAINS((p.Title,p.Summary,p.Content), @search)
      ORDER BY ISNULL(p.PublishedAt,''1900-01-01'') DESC
      OFFSET @ofs ROWS FETCH NEXT @ps ROWS ONLY;';
    DECLARE @search nvarchar(400) = '"' + REPLACE(@q,'"','""') + '*"';
    EXEC sp_executesql @sql, N'@cat nvarchar(160), @search nvarchar(400), @ofs int, @ps int',
         @cat=@categorySlug, @search=@search, @ofs=@ofs, @ps=@pageSize;
    RETURN;
  END

  -- Fallback LIKE (không FTS)
  SELECT p.Id,p.Title,p.Slug,p.PublishedAt,c.Name AS Category
  FROM dbo.Posts p LEFT JOIN dbo.Categories c ON c.Id=p.CategoryId
  WHERE (@categorySlug IS NULL OR c.Slug=@categorySlug)
    AND (@q IS NULL OR (
      p.Title   COLLATE Vietnamese_100_CI_AI LIKE '%'+@q+'%' OR
      p.Summary COLLATE Vietnamese_100_CI_AI LIKE '%'+@q+'%' OR
      p.Content COLLATE Vietnamese_100_CI_AI LIKE '%'+@q+'%'
    ))
  ORDER BY ISNULL(p.PublishedAt,'1900-01-01') DESC
  OFFSET @ofs ROWS FETCH NEXT @pageSize ROWS ONLY;
END
GO
