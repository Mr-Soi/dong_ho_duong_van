-- === Base: Categories ===
IF OBJECT_ID(N'dbo.Categories', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.Categories (
    Id   INT IDENTITY(1,1) PRIMARY KEY,
    Slug NVARCHAR(128) NOT NULL UNIQUE,
    Name NVARCHAR(256) NOT NULL
  );
END;

-- === Base: Persons ===
IF OBJECT_ID(N'dbo.Persons', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.Persons (
    Id          INT IDENTITY(1,1) PRIMARY KEY,
    DisplayName NVARCHAR(256) NULL,
    FullName    NVARCHAR(256) NULL,
    Alias       NVARCHAR(128) NULL,
    Generation  INT NULL,
    Branch      NVARCHAR(128) NULL,
    BirthDate   DATE NULL,
    DeathDate   DATE NULL,
    IsDeleted   BIT  NOT NULL CONSTRAINT DF_Persons_IsDeleted DEFAULT(0),
    FatherId    INT  NULL,
    MotherId    INT  NULL
  );
END;

-- Bổ sung cột nếu bảng đã tồn tại
IF COL_LENGTH('dbo.Persons','DisplayName') IS NULL ALTER TABLE dbo.Persons ADD DisplayName NVARCHAR(256) NULL;
IF COL_LENGTH('dbo.Persons','FullName')    IS NULL ALTER TABLE dbo.Persons ADD FullName    NVARCHAR(256) NULL;
IF COL_LENGTH('dbo.Persons','FatherId')    IS NULL ALTER TABLE dbo.Persons ADD FatherId    INT NULL;
IF COL_LENGTH('dbo.Persons','MotherId')    IS NULL ALTER TABLE dbo.Persons ADD MotherId    INT NULL;

-- Backfill FullName
UPDATE dbo.Persons
SET FullName = COALESCE(NULLIF(LTRIM(RTRIM(DisplayName)),''), Alias)
WHERE (FullName IS NULL OR FullName='') AND (DisplayName IS NOT NULL OR Alias IS NOT NULL);

-- Indexes
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Persons_GenBranch' AND object_id=OBJECT_ID('dbo.Persons'))
  CREATE INDEX IX_Persons_GenBranch ON dbo.Persons(Generation, Branch);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Persons_FatherId' AND object_id=OBJECT_ID('dbo.Persons'))
  CREATE INDEX IX_Persons_FatherId ON dbo.Persons(FatherId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Persons_MotherId' AND object_id=OBJECT_ID('dbo.Persons'))
  CREATE INDEX IX_Persons_MotherId ON dbo.Persons(MotherId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Persons_FullName' AND object_id=OBJECT_ID('dbo.Persons'))
  CREATE INDEX IX_Persons_FullName ON dbo.Persons(FullName) INCLUDE(Id);
