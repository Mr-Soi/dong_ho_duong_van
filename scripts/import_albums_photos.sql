
USE dhdv;
MERGE dbo.Albums AS T
USING (SELECT Title,Slug,Description,CreatedAt FROM don7069c_dongho.dbo.vw_AlbumsForImport) AS S
ON T.Slug=S.Slug
WHEN MATCHED THEN UPDATE SET T.Title=S.Title, T.Description=S.Description, T.CreatedAt=ISNULL(T.CreatedAt,S.CreatedAt)
WHEN NOT MATCHED BY TARGET THEN INSERT(Title,Slug,Description,CreatedAt) VALUES(S.Title,S.Slug,S.Description,S.CreatedAt);

INSERT INTO dbo.Photos(AlbumId,Url,Caption,TakenAt)
SELECT a.Id, p.Url, p.Caption, p.TakenAt
FROM don7069c_dongho.dbo.vw_PhotosForImport p
JOIN dbo.Albums a ON a.Slug=p.AlbumSlug
WHERE NOT EXISTS (SELECT 1 FROM dbo.Photos x WHERE x.AlbumId=a.Id AND x.Url=p.Url);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Photos_Album_Url' AND object_id=OBJECT_ID('dbo.Photos'))
  CREATE UNIQUE INDEX IX_Photos_Album_Url ON dbo.Photos(AlbumId,Url);
