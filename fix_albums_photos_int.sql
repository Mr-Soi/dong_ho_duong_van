-- Fix Albums/Photos: chuyển BIGINT -> INT nếu cần
SET NOCOUNT ON;

-- Photos: drop FK nếu có
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_Photos_Album')
  ALTER TABLE dbo.Photos DROP CONSTRAINT FK_Photos_Album;

-- Albums: tạo bảng INT nếu cột Id hiện là BIGINT
IF EXISTS (SELECT 1 FROM sys.columns 
           WHERE object_id = OBJECT_ID('dbo.Albums')
             AND name='Id' AND system_type_id = TYPE_ID('bigint'))
BEGIN
  PRINT 'Rebuild dbo.Albums -> INT';
  CREATE TABLE dbo.Albums_fix (
    Id         INT NOT NULL PRIMARY KEY,
    Title      NVARCHAR(300) NOT NULL,
    Slug       NVARCHAR(160) NOT NULL,
    Description NVARCHAR(1000) NULL,
    CreatedAt  DATETIME NULL,
    UpdatedAt  DATETIME2 NULL,
    IsDeleted  BIT NOT NULL DEFAULT(0),
    TitleNorm  NVARCHAR(300) NULL
  );
  SET IDENTITY_INSERT dbo.Albums_fix ON;
  INSERT dbo.Albums_fix (Id,Title,Slug,Description,CreatedAt,UpdatedAt,IsDeleted,TitleNorm)
    SELECT CAST(Id AS INT),Title,Slug,Description,CreatedAt,UpdatedAt,IsDeleted,TitleNorm
    FROM dbo.Albums;
  SET IDENTITY_INSERT dbo.Albums_fix OFF;

  DROP TABLE dbo.Albums;
  EXEC sp_rename 'dbo.Albums_fix','Albums';
END

-- Photos: tạo bảng INT nếu Id/AlbumId là BIGINT
IF EXISTS (SELECT 1 FROM sys.columns 
           WHERE object_id = OBJECT_ID('dbo.Photos')
             AND name='Id' AND system_type_id = TYPE_ID('bigint'))
   OR EXISTS (SELECT 1 FROM sys.columns 
              WHERE object_id = OBJECT_ID('dbo.Photos')
                AND name='AlbumId' AND system_type_id = TYPE_ID('bigint'))
BEGIN
  PRINT 'Rebuild dbo.Photos -> INT';
  CREATE TABLE dbo.Photos_fix (
    Id        INT NOT NULL PRIMARY KEY,
    AlbumId   INT NOT NULL,
    Url       NVARCHAR(500) NOT NULL,
    Caption   NVARCHAR(500) NULL,
    TakenAt   DATETIME NULL
  );
  SET IDENTITY_INSERT dbo.Photos_fix ON;
  INSERT dbo.Photos_fix (Id,AlbumId,Url,Caption,TakenAt)
    SELECT CAST(Id AS INT), CAST(AlbumId AS INT), Url, Caption, TakenAt
    FROM dbo.Photos;
  SET IDENTITY_INSERT dbo.Photos_fix OFF;

  DROP TABLE dbo.Photos;
  EXEC sp_rename 'dbo.Photos_fix','Photos';
END

-- Tạo lại FK Photos -> Albums nếu chưa có
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_Photos_Album')
  ALTER TABLE dbo.Photos ADD CONSTRAINT FK_Photos_Album
    FOREIGN KEY (AlbumId) REFERENCES dbo.Albums(Id);
