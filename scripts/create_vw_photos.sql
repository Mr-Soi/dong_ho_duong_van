
USE don7069c_dongho;
GO
CREATE OR ALTER VIEW dbo.vw_AlbumsForImport AS
SELECT DISTINCT
  Title = LTRIM(RTRIM(an.AlbumName)),
  Slug  = LOWER(REPLACE(REPLACE(LTRIM(RTRIM(an.AlbumName)),' ','-'),'--','-')),
  Description = an.Note,
  CreatedAt = NULL
FROM dbo.AlbumName an
WHERE an.AlbumName IS NOT NULL AND LTRIM(RTRIM(an.AlbumName))<>N'';
GO
CREATE OR ALTER VIEW dbo.vw_PhotosForImport AS
SELECT
  AlbumSlug = LOWER(REPLACE(REPLACE(LTRIM(RTRIM(an.AlbumName)),' ','-'),'--','-')),
  Url       = COALESCE(NULLIF(a.URL,N''), NULLIF(a.thumbnailPath,N''), NULLIF(a.ImagePath,N'')),
  Caption   = a.ImageNote,
  TakenAt   = NULL
FROM dbo.Album a
LEFT JOIN dbo.AlbumName an ON an.TreeID = a.TreeID
WHERE COALESCE(NULLIF(a.URL,N''), NULLIF(a.thumbnailPath,N''), NULLIF(a.ImagePath,N'')) IS NOT NULL;
