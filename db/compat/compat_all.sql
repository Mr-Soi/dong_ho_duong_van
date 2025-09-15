/* db/compat/compat_all.sql  — chuẩn hoá schema cho DHDV
   An toàn: chỉ swap khi kiểu lệch; thêm cột thiếu; siết CreatedAt; vá thumb/cover.
*/
USE dhdv;
SET XACT_ABORT ON; SET NOCOUNT ON; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;

/* -------- Persons -------- */
DECLARE @needSwapPersons bit =
  CASE WHEN EXISTS (
    SELECT 1 FROM sys.columns c JOIN sys.types t ON c.user_type_id=t.user_type_id
    WHERE c.object_id=OBJECT_ID('dbo.Persons') AND c.name='Id' AND t.name<>'int'
  ) THEN 1 ELSE 0 END;

IF @needSwapPersons=1
BEGIN
  /* drop FT/idx/pk/fk phụ thuộc */
  IF EXISTS (SELECT 1 FROM sys.fulltext_indexes WHERE object_id=OBJECT_ID('dbo.Persons')) DROP FULLTEXT INDEX ON dbo.Persons;
  IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.Persons') AND name='UX_Persons_FT') DROP INDEX UX_Persons_FT ON dbo.Persons;
  DECLARE @pkP sysname=(SELECT kc.name FROM sys.key_constraints kc WHERE kc.parent_object_id=OBJECT_ID('dbo.Persons') AND kc.type='PK');
  IF @pkP IS NOT NULL EXEC('ALTER TABLE dbo.Persons DROP CONSTRAINT ['+@pkP+']');

  IF OBJECT_ID('tempdb..#fk_p') IS NOT NULL DROP TABLE #fk_p;
  CREATE TABLE #fk_p (fk sysname, sch sysname, tbl sysname, parent_col sysname);
  INSERT INTO #fk_p
  SELECT fk.name, OBJECT_SCHEMA_NAME(fk.parent_object_id), OBJECT_NAME(fk.parent_object_id),
         COL_NAME(fkc.parent_object_id,fkc.parent_column_id)
  FROM sys.foreign_keys fk JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id=fk.object_id
  WHERE fkc.referenced_object_id=OBJECT_ID('dbo.Persons');

  DECLARE @s nvarchar(max)=(SELECT STRING_AGG('ALTER TABLE '+QUOTENAME(sch)+'.'+QUOTENAME(tbl)+' DROP CONSTRAINT '+QUOTENAME(fk)+';',' ') FROM #fk_p);
  IF @s IS NOT NULL EXEC(@s);

  IF OBJECT_ID('dbo.Persons_new','U') IS NOT NULL DROP TABLE dbo.Persons_new;
  CREATE TABLE dbo.Persons_new(
    Id INT NOT NULL,
    DisplayName NVARCHAR(255) NULL,
    Alias NVARCHAR(255) NULL,
    Generation INT NULL,
    Branch NVARCHAR(255) NULL,
    BirthDate DATETIME NULL,
    DeathDate DATETIME NULL,
    IsDeleted BIT NOT NULL DEFAULT(0),
    FatherId INT NULL,
    MotherId INT NULL
  );
  INSERT INTO dbo.Persons_new SELECT
    CAST(Id AS INT), DisplayName, Alias, TRY_CAST(Generation AS INT), Branch, BirthDate, DeathDate,
    ISNULL(IsDeleted,0), TRY_CAST(FatherId AS INT), TRY_CAST(MotherId AS INT)
  FROM dbo.Persons;

  ALTER TABLE dbo.Persons_new ADD CONSTRAINT PK_Persons_new PRIMARY KEY CLUSTERED (Id);
  IF OBJECT_ID('dbo.Persons_bak','U') IS NOT NULL DROP TABLE dbo.Persons_bak;
  EXEC sp_rename 'dbo.Persons','Persons_bak';
  EXEC sp_rename 'dbo.Persons_new','Persons';

  /* khôi phục FK */
  SET @s=(SELECT STRING_AGG('ALTER TABLE '+QUOTENAME(sch)+'.'+QUOTENAME(tbl)+' ADD CONSTRAINT '+QUOTENAME(fk)+' FOREIGN KEY('+QUOTENAME(parent_col)+') REFERENCES dbo.Persons(Id);',' ') FROM #fk_p);
  IF @s IS NOT NULL EXEC(@s);
END

/* đảm bảo cột */
IF COL_LENGTH('dbo.Persons','IsDeleted') IS NULL ALTER TABLE dbo.Persons ADD IsDeleted BIT NOT NULL DEFAULT(0);
IF COL_LENGTH('dbo.Persons','DisplayName') IS NULL ALTER TABLE dbo.Persons ADD DisplayName NVARCHAR(255) NULL;
IF COL_LENGTH('dbo.Persons','FatherId') IS NULL ALTER TABLE dbo.Persons ADD FatherId INT NULL;
IF COL_LENGTH('dbo.Persons','MotherId') IS NULL ALTER TABLE dbo.Persons ADD MotherId INT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID('dbo.Persons') AND name='IX_Persons_IsDeleted_DisplayName')
  CREATE INDEX IX_Persons_IsDeleted_DisplayName ON dbo.Persons(IsDeleted, DisplayName, Id);
UPDATE dbo.Persons SET DisplayName = ISNULL(DisplayName, Alias) WHERE DisplayName IS NULL;

/* -------- Photos (cột cho cover album) -------- */
IF COL_LENGTH('dbo.Photos','Url')      IS NULL ALTER TABLE dbo.Photos ADD Url NVARCHAR(500) NULL;
IF COL_LENGTH('dbo.Photos','ThumbUrl') IS NULL ALTER TABLE dbo.Photos ADD ThumbUrl NVARCHAR(500) NULL;
IF COL_LENGTH('dbo.Photos','AlbumId')  IS NULL ALTER TABLE dbo.Photos ADD AlbumId INT NULL;
UPDATE dbo.Photos SET ThumbUrl = ISNULL(ThumbUrl, Url) WHERE ThumbUrl IS NULL;

/* -------- Albums -------- */
IF COL_LENGTH('dbo.Albums','Title')       IS NULL ALTER TABLE dbo.Albums ADD Title NVARCHAR(255) NULL;
IF COL_LENGTH('dbo.Albums','Slug')        IS NULL ALTER TABLE dbo.Albums ADD Slug NVARCHAR(256) NULL;
IF COL_LENGTH('dbo.Albums','Description') IS NULL ALTER TABLE dbo.Albums ADD Description NVARCHAR(1000) NULL;
IF COL_LENGTH('dbo.Albums','CoverImage')  IS NULL ALTER TABLE dbo.Albums ADD CoverImage NVARCHAR(500) NULL;
IF COL_LENGTH('dbo.Albums','ThumbUrl')    IS NULL ALTER TABLE dbo.Albums ADD ThumbUrl NVARCHAR(500) NULL;
IF COL_LENGTH('dbo.Albums','CreatedAt')   IS NULL ALTER TABLE dbo.Albums ADD CreatedAt DATETIME2(0) NULL;
IF COL_LENGTH('dbo.Albums','UpdatedAt')   IS NULL ALTER TABLE dbo.Albums ADD UpdatedAt DATETIME2(0) NULL;
IF COL_LENGTH('dbo.Albums','IsDeleted')   IS NULL ALTER TABLE dbo.Albums ADD IsDeleted BIT NOT NULL DEFAULT(0);
UPDATE dbo.Albums SET CreatedAt = ISNULL(CreatedAt, SYSUTCDATETIME());

/* -------- Posts -------- */
DECLARE @needSwapPosts bit =
  CASE WHEN EXISTS (
    SELECT 1 FROM sys.columns c JOIN sys.types t ON c.user_type_id=t.user_type_id
    WHERE c.object_id=OBJECT_ID('dbo.Posts') AND c.name='Id' AND t.name<>'int'
  ) OR EXISTS(
    SELECT 1 FROM sys.columns c JOIN sys.types t ON c.user_type_id=t.user_type_id
    WHERE c.object_id=OBJECT_ID('dbo.Posts') AND c.name='Summary' AND t.name<>'nvarchar'
  ) THEN 1 ELSE 0 END;

IF @needSwapPosts=1
BEGIN
  IF EXISTS(SELECT 1 FROM sys.fulltext_indexes WHERE object_id=OBJECT_ID('dbo.Posts')) DROP FULLTEXT INDEX ON dbo.Posts;
  DECLARE @pkPo sysname=(SELECT kc.name FROM sys.key_constraints kc WHERE kc.parent_object_id=OBJECT_ID('dbo.Posts') AND kc.type='PK');
  IF @pkPo IS NOT NULL EXEC('ALTER TABLE dbo.Posts DROP CONSTRAINT ['+@pkPo+']');

  IF OBJECT_ID('dbo.Posts_new','U') IS NOT NULL DROP TABLE dbo.Posts_new;
  CREATE TABLE dbo.Posts_new(
    Id INT NOT NULL,
    Title NVARCHAR(500) NULL,
    Slug NVARCHAR(256) NULL,
    Summary NVARCHAR(MAX) NULL,
    Content NVARCHAR(MAX) NULL,
    IsPublished BIT NOT NULL DEFAULT(1),
    CategoryId INT NULL,
    CoverImage NVARCHAR(500) NULL,
    HeroImageUrl NVARCHAR(500) NULL,
    ThumbnailUrl NVARCHAR(500) NULL,
    CreatedAt DATETIME2(0) NULL,
    UpdatedAt DATETIME2(0) NULL,
    PublishedAt DATETIME NULL,
    CreatedBy NVARCHAR(255) NULL,
    UpdatedBy NVARCHAR(255) NULL,
    TitleNorm NVARCHAR(500) NULL,
    SlugNorm  NVARCHAR(256) NULL,
    ViewCount INT NULL,
    IsDeleted BIT NOT NULL DEFAULT(0)
  );
  INSERT INTO dbo.Posts_new
  SELECT CAST(Id AS INT), Title, Slug, Summary, Content, ISNULL(IsPublished,1), CategoryId, CoverImage, HeroImageUrl, ThumbnailUrl,
         TRY_CONVERT(DATETIME2(0),CreatedAt), UpdatedAt, PublishedAt, CreatedBy, UpdatedBy, TitleNorm, SlugNorm, ViewCount, ISNULL(IsDeleted,0)
  FROM dbo.Posts;
  ALTER TABLE dbo.Posts_new ADD CONSTRAINT PK_Posts_new PRIMARY KEY CLUSTERED(Id);

  IF OBJECT_ID('dbo.Posts_bak','U') IS NOT NULL DROP TABLE dbo.Posts_bak;
  EXEC sp_rename 'dbo.Posts','Posts_bak';
  EXEC sp_rename 'dbo.Posts_new','Posts';
END

/* bảo đảm CreatedAt NOT NULL */
UPDATE dbo.Posts SET CreatedAt = ISNULL(CreatedAt, SYSUTCDATETIME());
ALTER TABLE dbo.Posts ALTER COLUMN CreatedAt DATETIME2(0) NOT NULL;
