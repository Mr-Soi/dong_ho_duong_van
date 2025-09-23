-- Persons bảo đảm cột và index
IF COL_LENGTH('dbo.Persons','DisplayName') IS NULL ALTER TABLE dbo.Persons ADD DisplayName NVARCHAR(256) NULL;
IF COL_LENGTH('dbo.Persons','FatherId')    IS NULL ALTER TABLE dbo.Persons ADD FatherId INT NULL;
IF COL_LENGTH('dbo.Persons','MotherId')    IS NULL ALTER TABLE dbo.Persons ADD MotherId INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Persons_FatherId' AND object_id=OBJECT_ID('dbo.Persons'))
  CREATE INDEX IX_Persons_FatherId ON dbo.Persons(FatherId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Persons_MotherId' AND object_id=OBJECT_ID('dbo.Persons'))
  CREATE INDEX IX_Persons_MotherId ON dbo.Persons(MotherId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Persons_FullName' AND object_id=OBJECT_ID('dbo.Persons'))
  CREATE INDEX IX_Persons_FullName ON dbo.Persons(FullName) INCLUDE(Id);

-- Posts
IF OBJECT_ID('dbo.Posts','U') IS NULL
BEGIN
  CREATE TABLE dbo.Posts (
    Id          INT IDENTITY(1,1) PRIMARY KEY,
    CategoryId  INT NULL,
    Title       NVARCHAR(512) NOT NULL,
    Slug        NVARCHAR(256) NOT NULL,
    Summary     NVARCHAR(1024) NULL,
    Content     NVARCHAR(MAX) NULL,
    CoverImage  NVARCHAR(512) NULL,
    IsPublished BIT NOT NULL DEFAULT 0,
    IsDeleted   BIT NOT NULL DEFAULT 0,
    CreatedAt   DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    PublishedAt DATETIME2 NULL
  );
  CREATE UNIQUE INDEX UX_Posts_Slug ON dbo.Posts(Slug);
END;

-- Albums
IF OBJECT_ID('dbo.Albums','U') IS NULL
BEGIN
  CREATE TABLE dbo.Albums (
    Id        INT IDENTITY(1,1) PRIMARY KEY,
    Title     NVARCHAR(512) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
  );
END;

-- Photos: chuẩn hóa về INT cả Id và AlbumId
IF OBJECT_ID('dbo.Photos','U') IS NULL
BEGIN
  CREATE TABLE dbo.Photos (
    Id        INT IDENTITY(1,1) PRIMARY KEY,
    AlbumId   INT NOT NULL,
    Title     NVARCHAR(512) NULL,
    FilePath  NVARCHAR(512) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
  );
  CREATE INDEX IX_Photos_AlbumId ON dbo.Photos(AlbumId);
  ALTER TABLE dbo.Photos ADD CONSTRAINT FK_Photos_Albums_AlbumId FOREIGN KEY (AlbumId) REFERENCES dbo.Albums(Id);
END
ELSE
BEGIN
  -- Drop FK nếu có
  DECLARE @fk sysname;
  SELECT TOP 1 @fk = fk.name
  FROM sys.foreign_keys fk
  WHERE fk.parent_object_id = OBJECT_ID('dbo.Photos');
  IF @fk IS NOT NULL
  BEGIN
    DECLARE @sql1 nvarchar(max) = N'ALTER TABLE dbo.Photos DROP CONSTRAINT ' + QUOTENAME(@fk) + N';';
    EXEC sp_executesql @sql1;
  END;

  -- Nếu Id là BIGINT thì rebuild
  IF EXISTS (
    SELECT 1
    FROM sys.columns c JOIN sys.types t ON c.user_type_id=t.user_type_id
    WHERE c.object_id=OBJECT_ID('dbo.Photos') AND c.name='Id' AND t.name='bigint'
  )
  BEGIN
    EXEC sp_rename 'dbo.Photos', 'Photos_big';
    CREATE TABLE dbo.Photos (
      Id        INT IDENTITY(1,1) PRIMARY KEY,
      AlbumId   INT NOT NULL,
      Title     NVARCHAR(512) NULL,
      FilePath  NVARCHAR(512) NULL,
      CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
    SET IDENTITY_INSERT dbo.Photos ON;
    INSERT dbo.Photos (Id, AlbumId, Title, FilePath, CreatedAt)
    SELECT CAST(Id AS INT), CAST(AlbumId AS INT), Title, FilePath, CreatedAt
    FROM dbo.Photos_big;
    SET IDENTITY_INSERT dbo.Photos OFF;
    DROP TABLE dbo.Photos_big;
  END
  ELSE
  BEGIN
    -- Nếu AlbumId là BIGINT thì ALTER
    IF EXISTS (
      SELECT 1
      FROM sys.columns c JOIN sys.types t ON c.user_type_id=t.user_type_id
      WHERE c.object_id=OBJECT_ID('dbo.Photos') AND c.name='AlbumId' AND t.name='bigint'
    )
      ALTER TABLE dbo.Photos ALTER COLUMN AlbumId INT NOT NULL;
  END;

  IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Photos_AlbumId' AND object_id=OBJECT_ID('dbo.Photos'))
    CREATE INDEX IX_Photos_AlbumId ON dbo.Photos(AlbumId);
  ALTER TABLE dbo.Photos ADD CONSTRAINT FK_Photos_Albums_AlbumId FOREIGN KEY (AlbumId) REFERENCES dbo.Albums(Id);
END;
