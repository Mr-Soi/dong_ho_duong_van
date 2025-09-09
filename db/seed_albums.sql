INSERT INTO dbo.Albums(Name,Description) VALUES (N'Kỷ yếu gia đình', N'Ảnh mẫu');
DECLARE @aid INT = SCOPE_IDENTITY();
INSERT INTO dbo.Photos(AlbumId,Path,Caption) VALUES
(@aid, N'https://picsum.photos/id/1015/1200/800', N'Ảnh 1'),
(@aid, N'https://picsum.photos/id/1025/1200/800', N'Ảnh 2');
