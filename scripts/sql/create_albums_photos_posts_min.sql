-- A1) Albums & Photos
IF OBJECT_ID('Albums','U') IS NULL
BEGIN
  CREATE TABLE dbo.Albums(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(255) NULL,
    Description NVARCHAR(MAX) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
  );
END

IF OBJECT_ID('Photos','U') IS NULL
BEGIN
  CREATE TABLE dbo.Photos(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    AlbumId INT NOT NULL,
    Url NVARCHAR(500) NOT NULL,
    ThumbUrl NVARCHAR(500) NULL,
    Caption NVARCHAR(500) NULL
  );
  CREATE INDEX IX_Photos_AlbumId ON dbo.Photos(AlbumId);
  ALTER TABLE dbo.Photos
    ADD CONSTRAINT FK_Photos_Albums
    FOREIGN KEY(AlbumId) REFERENCES dbo.Albums(Id);
END
GO

-- Seed mẫu (nếu chưa có)
IF NOT EXISTS (SELECT 1 FROM dbo.Albums)
BEGIN
  INSERT INTO dbo.Albums(Title,Description) VALUES (N'Album mẫu',N'Ảnh kiểm thử');
  DECLARE @aid INT = SCOPE_IDENTITY();
  INSERT INTO dbo.Photos(AlbumId,Url,ThumbUrl,Caption) VALUES
  (@aid, N'/img/sample1.jpg', N'/img/sample1.jpg', N'Ảnh 1'),
  (@aid, N'/img/sample2.jpg', N'/img/sample2.jpg', N'Ảnh 2');
END
GO

-- A2) Posts
IF OBJECT_ID('Posts','U') IS NULL
BEGIN
  CREATE TABLE dbo.Posts(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(255) NULL,
    Content NVARCHAR(MAX) NULL,
    PublishedAt DATETIME2 NULL,
    IsDeleted BIT NOT NULL DEFAULT 0
  );
END
GO

IF NOT EXISTS(SELECT 1 FROM dbo.Posts)
  INSERT INTO dbo.Posts(Title,Content,PublishedAt)
  VALUES (N'Bản tin dòng họ', N'Nội dung bài viết mẫu', SYSUTCDATETIME());
GO
