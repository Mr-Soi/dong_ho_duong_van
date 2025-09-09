IF COL_LENGTH('dbo.Persons','Alias')      IS NULL ALTER TABLE dbo.Persons ADD Alias NVARCHAR(400) NULL;
IF COL_LENGTH('dbo.Persons','BirthDate')  IS NULL ALTER TABLE dbo.Persons ADD BirthDate NVARCHAR(50) NULL;
IF COL_LENGTH('dbo.Persons','BirthPlace') IS NULL ALTER TABLE dbo.Persons ADD BirthPlace NVARCHAR(400) NULL;
IF COL_LENGTH('dbo.Persons','DeathDate')  IS NULL ALTER TABLE dbo.Persons ADD DeathDate NVARCHAR(50) NULL;
IF COL_LENGTH('dbo.Persons','FatherId')   IS NULL ALTER TABLE dbo.Persons ADD FatherId INT NULL;
IF COL_LENGTH('dbo.Persons','MotherId')   IS NULL ALTER TABLE dbo.Persons ADD MotherId INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_Persons_Father')
  ALTER TABLE dbo.Persons ADD CONSTRAINT FK_Persons_Father FOREIGN KEY (FatherId) REFERENCES dbo.Persons(Id);
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_Persons_Mother')
  ALTER TABLE dbo.Persons ADD CONSTRAINT FK_Persons_Mother FOREIGN KEY (MotherId) REFERENCES dbo.Persons(Id);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Persons_FatherId')
  CREATE INDEX IX_Persons_FatherId ON dbo.Persons(FatherId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Persons_MotherId')
  CREATE INDEX IX_Persons_MotherId ON dbo.Persons(MotherId);
