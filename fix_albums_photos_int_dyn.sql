BEGIN TRY
  BEGIN TRAN;

  /* gỡ FK nếu có */
  IF OBJECT_ID('FK_Photos_Album','F') IS NOT NULL
    ALTER TABLE dbo.Photos DROP CONSTRAINT FK_Photos_Album;

  /* ==================== Albums -> INT (chỉ copy cột đang có) ==================== */
  IF OBJECT_ID('dbo.Albums','U') IS NOT NULL
  BEGIN
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

    DECLARE @cols NVARCHAR(MAX)='Id', @src NVARCHAR(MAX)='CAST(Id AS INT)', @sql NVARCHAR(MAX);

    IF COL_LENGTH('dbo.Albums','Title')       IS NOT NULL BEGIN SET @cols+=',Title'       ; SET @src+=',Title'       ; END
    IF COL_LENGTH('dbo.Albums','Slug')        IS NOT NULL BEGIN SET @cols+=',Slug'        ; SET @src+=',Slug'        ; END
    IF COL_LENGTH('dbo.Albums','Description') IS NOT NULL BEGIN SET @cols+=',Description' ; SET @src+=',Description' ; END
    IF COL_LENGTH('dbo.Albums','CreatedAt')   IS NOT NULL BEGIN SET @cols+=',CreatedAt'   ; SET @src+=',CreatedAt'   ; END
    IF COL_LENGTH('dbo.Albums','UpdatedAt')   IS NOT NULL BEGIN SET @cols+=',UpdatedAt'   ; SET @src+=',UpdatedAt'   ; END
    IF COL_LENGTH('dbo.Albums','IsDeleted')   IS NOT NULL BEGIN SET @cols+=',IsDeleted'   ; SET @src+=',IsDeleted'   ; END
    IF COL_LENGTH('dbo.Albums','TitleNorm')   IS NOT NULL BEGIN SET @cols+=',TitleNorm'   ; SET @src+=',TitleNorm'   ; END

    SET @sql = N'SET IDENTITY_INSERT dbo.Albums_fix ON;
                 INSERT dbo.Albums_fix ('+@cols+') SELECT '+@src+' FROM dbo.Albums;
                 SET IDENTITY_INSERT dbo.Albums_fix OFF;';
    EXEC (@sql);

    DROP TABLE dbo.Albums;
    EXEC sp_rename 'dbo.Albums_fix','Albums';

    IF COL_LENGTH('dbo.Albums','Name') IS NULL AND COL_LENGTH('dbo.Albums','Title') IS NOT NULL
      ALTER TABLE dbo.Albums ADD [Name] AS ([Title]) PERSISTED;
  END

  /* ==================== Photos -> INT (chỉ copy cột đang có) ==================== */
  IF OBJECT_ID('dbo.Photos','U') IS NOT NULL
  BEGIN
    CREATE TABLE dbo.Photos_fix(
      Id      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
      AlbumId INT NOT NULL,
      Url     NVARCHAR(500) NULL,
      Caption NVARCHAR(500) NULL,
      TakenAt DATETIME NULL
    );

    DECLARE @pcols NVARCHAR(MAX)='Id,AlbumId',
            @psrc  NVARCHAR(MAX)='CAST(Id AS INT), CAST(AlbumId AS INT)',
            @psql  NVARCHAR(MAX);

    IF COL_LENGTH('dbo.Photos','Url')     IS NOT NULL BEGIN SET @pcols+=',Url'     ; SET @psrc+=',Url'     ; END
    IF COL_LENGTH('dbo.Photos','Caption') IS NOT NULL BEGIN SET @pcols+=',Caption' ; SET @psrc+=',Caption' ; END
    IF COL_LENGTH('dbo.Photos','TakenAt') IS NOT NULL BEGIN SET @pcols+=',TakenAt' ; SET @psrc+=',TakenAt' ; END

    SET @psql = N'SET IDENTITY_INSERT dbo.Photos_fix ON;
                  INSERT dbo.Photos_fix ('+@pcols+') SELECT '+@psrc+' FROM dbo.Photos;
                  SET IDENTITY_INSERT dbo.Photos_fix OFF;';
    EXEC (@psql);

    DROP TABLE dbo.Photos;
    EXEC sp_rename 'dbo.Photos_fix','Photos';

    IF COL_LENGTH('dbo.Photos','Path') IS NULL AND COL_LENGTH('dbo.Photos','Url') IS NOT NULL
      ALTER TABLE dbo.Photos ADD [Path] AS ([Url]) PERSISTED;

    ALTER TABLE dbo.Photos ADD CONSTRAINT FK_Photos_Album
      FOREIGN KEY (AlbumId) REFERENCES dbo.Albums(Id);
  END

  COMMIT TRAN;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK TRAN;
  THROW;
END CATCH;
