USE dhdv;
SET NOCOUNT ON;

IF COL_LENGTH('dbo.Persons','LegacyId') IS NULL
  ALTER TABLE dbo.Persons ADD LegacyId INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UIX_Persons_LegacyId' AND object_id=OBJECT_ID('dbo.Persons'))
  CREATE UNIQUE INDEX UIX_Persons_LegacyId ON dbo.Persons(LegacyId) WHERE LegacyId IS NOT NULL;

IF COL_LENGTH('dbo.Persons','DisplayNameNorm') IS NULL
  ALTER TABLE dbo.Persons ADD DisplayNameNorm AS LOWER(LTRIM(RTRIM(DisplayName))) PERSISTED;

IF COL_LENGTH('dbo.Persons','YearOfBirth') IS NULL
  ALTER TABLE dbo.Persons ADD YearOfBirth AS YEAR(BirthDate) PERSISTED;

IF COL_LENGTH('dbo.Persons','YearOfDeath') IS NULL
  ALTER TABLE dbo.Persons ADD YearOfDeath AS YEAR(DeathDate) PERSISTED;

IF COL_LENGTH('dbo.Persons','IsDeleted') IS NULL
  ALTER TABLE dbo.Persons ADD IsDeleted BIT NOT NULL CONSTRAINT DF_Persons_IsDeleted DEFAULT(0);

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_Person_Generation_Range')
  ALTER TABLE dbo.Persons ADD CONSTRAINT CK_Person_Generation_Range CHECK (Generation IS NULL OR Generation BETWEEN 0 AND 200);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Persons_DisplayNameNorm' AND object_id=OBJECT_ID('dbo.Persons'))
  CREATE INDEX IX_Persons_DisplayNameNorm ON dbo.Persons(DisplayNameNorm);
