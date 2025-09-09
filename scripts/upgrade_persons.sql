USE dhdv;

-- ===== CỘT BỔ SUNG =====
IF COL_LENGTH('dbo.Persons','CreatedAt') IS NULL
  ALTER TABLE dbo.Persons ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Persons_CreatedAt DEFAULT(SYSDATETIME());
IF COL_LENGTH('dbo.Persons','UpdatedAt') IS NULL
  ALTER TABLE dbo.Persons ADD UpdatedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.Persons','CreatedBy') IS NULL
  ALTER TABLE dbo.Persons ADD CreatedBy NVARCHAR(100) NULL;
IF COL_LENGTH('dbo.Persons','UpdatedBy') IS NULL
  ALTER TABLE dbo.Persons ADD UpdatedBy NVARCHAR(100) NULL;

-- Cột tính chuẩn hóa
IF COL_LENGTH('dbo.Persons','FullNameNorm') IS NULL
  ALTER TABLE dbo.Persons ADD FullNameNorm AS LOWER(LTRIM(RTRIM(DisplayName))) PERSISTED;
IF COL_LENGTH('dbo.Persons','AliasNorm') IS NULL
  ALTER TABLE dbo.Persons ADD AliasNorm  AS LOWER(LTRIM(RTRIM(Alias)))       PERSISTED;
IF COL_LENGTH('dbo.Persons','BirthYear') IS NULL
  ALTER TABLE dbo.Persons ADD BirthYear  AS (CASE WHEN BirthDate IS NULL THEN NULL ELSE YEAR(BirthDate) END) PERSISTED;
IF COL_LENGTH('dbo.Persons','DeathYear') IS NULL
  ALTER TABLE dbo.Persons ADD DeathYear  AS (CASE WHEN DeathDate IS NULL THEN NULL ELSE YEAR(DeathDate) END) PERSISTED;

-- Ràng buộc
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_Person_Dates')
  ALTER TABLE dbo.Persons WITH CHECK ADD CONSTRAINT CK_Person_Dates CHECK (BirthDate IS NULL OR DeathDate IS NULL OR BirthDate<=DeathDate);

-- Chỉ mục
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Persons_FullNameNorm' AND object_id=OBJECT_ID('dbo.Persons'))
  CREATE INDEX IX_Persons_FullNameNorm ON dbo.Persons(FullNameNorm);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Persons_AliasNorm' AND object_id=OBJECT_ID('dbo.Persons'))
  CREATE INDEX IX_Persons_AliasNorm ON dbo.Persons(AliasNorm) WHERE Alias IS NOT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Persons_Gen_Branch' AND object_id=OBJECT_ID('dbo.Persons'))
  CREATE INDEX IX_Persons_Gen_Branch ON dbo.Persons(Generation, Branch);

GO
-- Trigger cập nhật UpdatedAt
CREATE OR ALTER TRIGGER dbo.trg_Persons_SetUpdated ON dbo.Persons
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE p SET UpdatedAt = SYSDATETIME()
  FROM dbo.Persons p JOIN inserted i ON i.Id = p.Id;
END
GO

-- Full-Text (nếu có FTS)
IF SERVERPROPERTY('IsFullTextInstalled') = 1
BEGIN
  IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_Persons_FT' AND object_id=OBJECT_ID('dbo.Persons'))
    CREATE UNIQUE INDEX UX_Persons_FT ON dbo.Persons(Id);
  IF NOT EXISTS (SELECT 1 FROM sys.fulltext_catalogs WHERE name='ft')
    CREATE FULLTEXT CATALOG ft AS DEFAULT;
  IF NOT EXISTS (SELECT 1 FROM sys.fulltext_indexes WHERE object_id=OBJECT_ID('dbo.Persons'))
    CREATE FULLTEXT INDEX ON dbo.Persons
      (DisplayName LANGUAGE 1066, Alias LANGUAGE 1066)
      KEY INDEX UX_Persons_FT ON ft WITH STOPLIST = SYSTEM;
END
