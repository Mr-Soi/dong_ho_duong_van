BEGIN TRY
  BEGIN TRAN;

  -- gỡ FK nếu có
  IF OBJECT_ID('FK_Photos_Album','F') IS NOT NULL
    ALTER TABLE dbo.Photos DROP CONSTRAINT FK_Photos_Album;

  /*----------------- Albums -> INT -----------------*/
  CREATE TABLE dbo.Albums_fix(
    Id         INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Title       NVARCHAR(300) NULL,
    Slug        NVARCHAR(160) NULL,
    Description NVARCHAR(1000) NULL,
    CreatedAt   DATETIME NULL,
    UpdatedAt   DATETIME2 NULL,
    IsDeleted   BIT NULL,
    TitleNorm   NVARCHAR(300) NULL
  );

  SET IDENTITY_INSERT dbo.Albums_fix ON;
  INSERT dbo.Albums_fix (Id,Title,Slug,Description,CreatedAt,UpdatedAt,IsDeleted,TitleNorm)
  SELECT
    CAST(Id AS INT),
    CASE WHEN COL_LENGTH('dbo.Albums','Title')       IS NOT NULL THEN Title       ELSE NULL END,
    CASE WHEN COL_LENGTH('dbo.Albums','Slug')        IS NOT NULL THEN Slug        ELSE NULL END,
    CASE WHEN COL_LENGTH('dbo.Albums','Description') IS NOT NULL THEN Description ELSE NULL END,
    CASE WHEN COL_LENGTH('dbo.Albums','CreatedAt')   IS NOT NULL THEN CreatedAt   ELSE NULL END,
    CASE WHEN COL_LENGTH('dbo.Albums','UpdatedAt')   IS NOT NULL THEN UpdatedAt   ELSE NULL END,
    CASE WHEN COL_LENGTH('dbo.Albums','IsDeleted')   IS NOT NULL THEN IsDeleted   ELSE NULL END,
    CASE WHEN COL_LENGTH('dbo.Albums','TitleNorm')   IS NOT NULL THEN TitleNorm   ELSE NULL END
  FROM dbo.Albums;
  SET IDENTITY_INSERT dbo.Albums_fix OFF;

  DROP TABLE dbo.Albums;
  EXEC sp_rename 'dbo.Albums_fix','Albums';

  -- cột computed cho EF
  IF COL_LENGTH('dbo.Albums','Name') IS NULL AND COL_LENGTH('dbo.Albums','Title') IS NOT NULL
    ALTER TABLE dbo.Albums ADD [Name] AS ([Title]) PERSISTED;

  /*----------------- Photos -> INT -----------------*/
  CREATE TABLE dbo.Photos_fix(
    Id      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    AlbumId INT NOT NULL,
    Url     NVARCHAR(500) NULL,
    Caption NVARCHAR(500) NULL,
    TakenAt DATETIME NULL
  );

  SET IDENTITY_INSERT dbo.Photos_fix ON;
  INSERT dbo.Photos_fix (Id,AlbumId,Url,Caption,TakenAt)
  SELECT
    CAST(Id AS INT),
    CAST(AlbumId AS INT),
    CASE WHEN COL_LENGTH('dbo.Photos','Url')     IS NOT NULL THEN Url     ELSE NULL END,
    CASE WHEN COL_LENGTH('dbo.Photos','Caption') IS NOT NULL THEN Caption ELSE NULL END,
    CASE WHEN COL_LENGTH('dbo.Photos','TakenAt') IS NOT NULL THEN TakenAt ELSE NULL END
  FROM dbo.Photos;
  SET IDENTITY_INSERT dbo.Photos_fix OFF;

  DROP TABLE dbo.Photos;
  EXEC sp_rename 'dbo.Photos_fix','Photos';

  -- cột computed cho EF
  IF COL_LENGTH('dbo.Photos','Path') IS NULL AND COL_LENGTH('dbo.Photos','Url') IS NOT NULL
    ALTER TABLE dbo.Photos ADD [Path] AS ([Url]) PERSISTED;

  -- FK lại
  ALTER TABLE dbo.Photos ADD CONSTRAINT FK_Photos_Album FOREIGN KEY (AlbumId) REFERENCES dbo.Albums(Id);

  COMMIT TRAN;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK TRAN;
  THROW;
END CATCH;
