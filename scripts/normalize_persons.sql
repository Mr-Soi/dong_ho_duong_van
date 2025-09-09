USE dhdv;
SET NOCOUNT ON;
IF COL_LENGTH('dbo.Persons','NameNorm') IS NULL
  ALTER TABLE dbo.Persons ADD NameNorm AS LOWER(LTRIM(RTRIM(DisplayName))) PERSISTED;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Persons_NameNorm' AND object_id=OBJECT_ID('dbo.Persons'))
  CREATE INDEX IX_Persons_NameNorm ON dbo.Persons(NameNorm);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_Persons_LegacyId' AND object_id=OBJECT_ID('dbo.Persons'))
  CREATE UNIQUE INDEX UX_Persons_LegacyId ON dbo.Persons(LegacyId) WHERE LegacyId IS NOT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Persons_Gen_Branch' AND object_id=OBJECT_ID('dbo.Persons'))
  CREATE INDEX IX_Persons_Gen_Branch ON dbo.Persons(Generation, Branch);
