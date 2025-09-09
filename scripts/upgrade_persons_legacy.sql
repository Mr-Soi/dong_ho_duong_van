IF COL_LENGTH('dbo.Persons','LegacyId') IS NULL
BEGIN
  ALTER TABLE dbo.Persons ADD LegacyId INT NULL;
END;

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'UX_Persons_LegacyId'
    AND object_id = OBJECT_ID('dbo.Persons')
)
BEGIN
  EXEC('CREATE UNIQUE INDEX UX_Persons_LegacyId ON dbo.Persons(LegacyId) WHERE LegacyId IS NOT NULL;');
END;
