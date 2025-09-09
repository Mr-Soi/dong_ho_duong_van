/* db/fix_2025-09-06.sql
   Consolidated hotfix for DHDV DB on 2025-09-06
   - Normalize IDs to INT, rebuild PK/FK
   - Add Albums.Name, Photos.Path
   - Backfill Path from Url/FileName
   - Ensure CreatedAt/UpdatedAt
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER ON;
SET NUMERIC_ROUNDABORT OFF;

BEGIN TRY
BEGIN TRAN;

/* -----------------------------------------------------------
   0) Ensure common audit columns
----------------------------------------------------------- */
IF COL_LENGTH('dbo.Persons','CreatedAt')   IS NULL ALTER TABLE dbo.Persons          ADD CreatedAt datetime2 NOT NULL CONSTRAINT DF_Persons_CreatedAt DEFAULT (getdate());
IF COL_LENGTH('dbo.Persons','UpdatedAt')   IS NULL ALTER TABLE dbo.Persons          ADD UpdatedAt datetime2 NULL;

IF COL_LENGTH('dbo.PersonRelations','CreatedAt') IS NULL ALTER TABLE dbo.PersonRelations ADD CreatedAt datetime2 NOT NULL CONSTRAINT DF_PersonRelations_CreatedAt DEFAULT (getdate());
IF COL_LENGTH('dbo.PersonRelations','UpdatedAt') IS NULL ALTER TABLE dbo.PersonRelations ADD UpdatedAt datetime2 NULL;

IF COL_LENGTH('dbo.Albums','CreatedAt')    IS NULL ALTER TABLE dbo.Albums           ADD CreatedAt datetime NULL;
IF COL_LENGTH('dbo.Albums','UpdatedAt')    IS NULL ALTER TABLE dbo.Albums           ADD UpdatedAt datetime NULL; -- optional

IF COL_LENGTH('dbo.Photos','CreatedAt')    IS NULL ALTER TABLE dbo.Photos           ADD CreatedAt datetime2 NOT NULL CONSTRAINT DF_Photos_CreatedAt DEFAULT (getdate());
IF COL_LENGTH('dbo.Photos','UpdatedAt')    IS NULL ALTER TABLE dbo.Photos           ADD UpdatedAt datetime2 NULL;

IF COL_LENGTH('dbo.Posts','CreatedAt')     IS NULL ALTER TABLE dbo.Posts            ADD CreatedAt datetime2 NOT NULL CONSTRAINT DF_Posts_CreatedAt DEFAULT (getdate());
IF COL_LENGTH('dbo.Posts','UpdatedAt')     IS NULL ALTER TABLE dbo.Posts            ADD UpdatedAt datetime2 NULL;

/* -----------------------------------------------------------
   1) Persons: BIGINT -> INT by swap (safe)
----------------------------------------------------------- */
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.Persons') AND name='Id' AND system_type_id=127) -- bigint
BEGIN
    IF COL_LENGTH('dbo.Persons','Id2') IS NULL
        ALTER TABLE dbo.Persons ADD Id2 INT NULL;

    UPDATE dbo.Persons SET Id2 = CAST(Id AS INT);

    DECLARE @pk_persons sysname = (SELECT TOP(1) name FROM sys.key_constraints WHERE parent_object_id=OBJECT_ID('dbo.Persons') AND type='PK');
    IF @pk_persons IS NOT NULL
        EXEC('ALTER TABLE dbo.Persons DROP CONSTRAINT ' + QUOTENAME(@pk_persons) + ';');

    EXEC sp_rename 'dbo.Persons.Id',  'Id_big', 'COLUMN';
    EXEC sp_rename 'dbo.Persons.Id2', 'Id',     'COLUMN';

    ALTER TABLE dbo.Persons ALTER COLUMN Id INT NOT NULL;

    IF COL_LENGTH('dbo.Persons','Id_big') IS NOT NULL
        ALTER TABLE dbo.Persons DROP COLUMN Id_big;
END;

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id=OBJECT_ID('dbo.Persons') AND type='PK')
    ALTER TABLE dbo.Persons ADD CONSTRAINT PK_Persons_Id PRIMARY KEY CLUSTERED (Id);

/* -----------------------------------------------------------
   2) PersonRelations: INT, PK, FK -> Persons(Id)
----------------------------------------------------------- */
-- Drop any FK from PersonRelations to Persons (defensive)
DECLARE @sql nvarchar(max) = N'';
SELECT @sql = STRING_AGG(
  'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id))
  + ' DROP CONSTRAINT ' + QUOTENAME(name), ';' + CHAR(10))
FROM sys.foreign_keys
WHERE parent_object_id = OBJECT_ID('dbo.PersonRelations');
IF @sql IS NOT NULL AND LEN(@sql)>0 EXEC(@sql);

-- Drop PK if exists (to allow type change)
DECLARE @pk_pr sysname = (SELECT TOP(1) name FROM sys.key_constraints WHERE parent_object_id=OBJECT_ID('dbo.PersonRelations') AND type='PK');
IF @pk_pr IS NOT NULL EXEC('ALTER TABLE dbo.PersonRelations DROP CONSTRAINT ' + QUOTENAME(@pk_pr) + ';');

-- Ensure INT NOT NULL
IF COL_LENGTH('dbo.PersonRelations','ParentId') IS NOT NULL ALTER TABLE dbo.PersonRelations ALTER COLUMN ParentId INT NOT NULL;
IF COL_LENGTH('dbo.PersonRelations','ChildId')  IS NOT NULL ALTER TABLE dbo.PersonRelations ALTER COLUMN ChildId  INT NOT NULL;

-- Recreate PK and FKs
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id=OBJECT_ID('dbo.PersonRelations') AND type='PK')
    ALTER TABLE dbo.PersonRelations ADD CONSTRAINT PK_PersonRelations PRIMARY KEY CLUSTERED (ParentId, ChildId);

ALTER TABLE dbo.PersonRelations ADD CONSTRAINT FK_PersonRelations_Parent FOREIGN KEY (ParentId) REFERENCES dbo.Persons(Id);
ALTER TABLE dbo.PersonRelations ADD CONSTRAINT FK_PersonRelations_Child  FOREIGN KEY (ChildId)  REFERENCES dbo.Persons(Id);

-- Helpful index
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_PersonRelations_ChildId' AND object_id=OBJECT_ID('dbo.PersonRelations'))
    CREATE INDEX IX_PersonRelations_ChildId ON dbo.PersonRelations(ChildId);

/* -----------------------------------------------------------
   3) Albums: ensure Id INT, Name NVARCHAR(150) NOT NULL, PK
----------------------------------------------------------- */
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.Albums') AND name='Id' AND system_type_id=127)
    ALTER TABLE dbo.Albums ALTER COLUMN Id INT NOT NULL;

IF COL_LENGTH('dbo.Albums','Name') IS NULL
    ALTER TABLE dbo.Albums ADD Name nvarchar(150) NULL;

UPDATE dbo.Albums SET Name = COALESCE(NULLIF(Name,N''), NULLIF(Title,N''), Slug);
ALTER TABLE dbo.Albums ALTER COLUMN Name nvarchar(150) NOT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id=OBJECT_ID('dbo.Albums') AND type='PK')
    ALTER TABLE dbo.Albums ADD CONSTRAINT PK_Albums_Id PRIMARY KEY CLUSTERED (Id);

/* -----------------------------------------------------------
   4) Photos: ensure Id/AlbumId INT, Path NVARCHAR(500) NOT NULL, FK, index
----------------------------------------------------------- */
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.Photos') AND name='Id' AND system_type_id=127)
    ALTER TABLE dbo.Photos ALTER COLUMN Id INT NOT NULL;

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.Photos') AND name='AlbumId' AND system_type_id=127)
    ALTER TABLE dbo.Photos ALTER COLUMN AlbumId INT NULL;

IF COL_LENGTH('dbo.Photos','Path') IS NULL
    ALTER TABLE dbo.Photos ADD Path nvarchar(500) NULL;

UPDATE dbo.Photos SET Path =
  CASE
    WHEN Url IS NOT NULL AND Url<>''          THEN Url
    WHEN FileName LIKE '~/uploads/%'          THEN '/img/uploads/'+SUBSTRING(FileName,12,4000)  -- '~/uploads/' = 11 chars
    WHEN FileName LIKE '/uploads/%'           THEN '/img/uploads/'+SUBSTRING(FileName,10,4000)  -- '/uploads/'  = 9
    WHEN FileName LIKE 'uploads/%'            THEN '/img/uploads/'+SUBSTRING(FileName,9,4000)   -- 'uploads/'   = 8
    WHEN FileName LIKE '/img/uploads/%'       THEN FileName
    WHEN FileName LIKE 'img/uploads/%'        THEN '/img/uploads/'+SUBSTRING(FileName,13,4000)  -- 'img/uploads/' = 12
    WHEN LEFT(FileName,2)='~/'                THEN '/img/uploads/'+SUBSTRING(FileName,3,4000)
    WHEN LEFT(FileName,1)='/'                 THEN '/img'+FileName
    ELSE '/img/uploads/'+FileName
  END
WHERE (Path IS NULL OR Path='') AND FileName IS NOT NULL;

ALTER TABLE dbo.Photos ALTER COLUMN Path nvarchar(500) NOT NULL;

-- PK & FK
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id=OBJECT_ID('dbo.Photos') AND type='PK')
    ALTER TABLE dbo.Photos ADD CONSTRAINT PK_Photos_Id PRIMARY KEY CLUSTERED (Id);

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE parent_object_id=OBJECT_ID('dbo.Photos') AND name='FK_Photos_Albums_AlbumId')
    ALTER TABLE dbo.Photos ADD CONSTRAINT FK_Photos_Albums_AlbumId FOREIGN KEY (AlbumId) REFERENCES dbo.Albums(Id);

-- Optional index if TakenAt exists
IF COL_LENGTH('dbo.Photos','TakenAt') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Photos_Album_TakenAt' AND object_id=OBJECT_ID('dbo.Photos'))
    CREATE INDEX IX_Photos_Album_TakenAt ON dbo.Photos(AlbumId, TakenAt);

/* -----------------------------------------------------------
   5) Posts: ensure Id INT & PK (safety)
----------------------------------------------------------- */
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.Posts') AND name='Id' AND system_type_id=127)
    ALTER TABLE dbo.Posts ALTER COLUMN Id INT NOT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id=OBJECT_ID('dbo.Posts') AND type='PK')
    ALTER TABLE dbo.Posts ADD CONSTRAINT PK_Posts_Id PRIMARY KEY CLUSTERED (Id);

/* -----------------------------------------------------------
   Done
----------------------------------------------------------- */
COMMIT;
PRINT 'fix_2025-09-06 completed successfully';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT>0 ROLLBACK;
    DECLARE @msg nvarchar(4000) = ERROR_MESSAGE();
    RAISERROR(@msg,16,1);
END CATCH;

