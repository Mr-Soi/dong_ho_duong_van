
USE dhdv;
GO
CREATE OR ALTER VIEW dbo.vw_CategoryStats AS
SELECT c.Id, c.Name, c.Slug,
       PostCount = COUNT(p.Id),
       LastPublishedAt = MAX(p.PublishedAt)
FROM dbo.Categories c
LEFT JOIN dbo.Posts p
  ON p.CategoryId=c.Id AND p.IsPublished=1 AND ISNULL(p.IsDeleted,0)=0
GROUP BY c.Id, c.Name, c.Slug;
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetPostBySlug @slug NVARCHAR(160)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT p.*, c.Name AS Category
  FROM dbo.Posts p LEFT JOIN dbo.Categories c ON c.Id=p.CategoryId
  WHERE p.Slug=@slug AND ISNULL(p.IsDeleted,0)=0;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_SearchPersons @q NVARCHAR(200), @take INT=20
AS
BEGIN
  SET NOCOUNT ON;
  SELECT TOP (@take) Id, DisplayName, Generation, Branch, BirthDate, DeathDate
  FROM dbo.Persons
  WHERE DisplayName LIKE N'%'+@q+N'%' COLLATE Vietnamese_100_CI_AI
  ORDER BY DisplayName;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_SearchPosts
  @q NVARCHAR(200),
  @page INT = 1,
  @pageSize INT = 20
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @off INT = (@page-1)*@pageSize;
  SELECT p.Id, p.Title, p.Slug, p.PublishedAt, c.Name AS Category
  FROM dbo.Posts p
  LEFT JOIN dbo.Categories c ON c.Id=p.CategoryId
  WHERE (p.Title LIKE N'%'+@q+N'%' COLLATE Vietnamese_100_CI_AI OR p.Content LIKE N'%'+@q+N'%' COLLATE Vietnamese_100_CI_AI)
    AND ISNULL(p.IsDeleted,0)=0 AND p.IsPublished=1
  ORDER BY ISNULL(p.PublishedAt,'1900-01-01') DESC, p.Id DESC
  OFFSET @off ROWS FETCH NEXT @pageSize ROWS ONLY;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Post_AddView @postId BIGINT
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE dbo.Posts SET ViewCount = ViewCount + 1 WHERE Id=@postId;
  SELECT ViewCount FROM dbo.Posts WHERE Id=@postId;
END
GO
