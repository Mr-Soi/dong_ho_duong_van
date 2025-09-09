IF OBJECT_ID('dbo.Persons','U') IS NULL
BEGIN
  CREATE TABLE dbo.Persons(
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    DisplayName NVARCHAR(200) NOT NULL,
    Alias NVARCHAR(200) NULL,
    BirthDate DATE NULL,
    DeathDate DATE NULL,
    Generation INT NULL,
    Branch NVARCHAR(100) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2 NULL,
    CreatedBy NVARCHAR(100) NULL,
    UpdatedBy NVARCHAR(100) NULL,
    FullNameNorm NVARCHAR(200) NULL,
    AliasNorm NVARCHAR(200) NULL,
    BirthYear INT NULL,
    DeathYear INT NULL,
    LegacyId INT NULL,
    DisplayNameNorm NVARCHAR(200) NULL,
    YearOfBirth INT NULL,
    YearOfDeath INT NULL,
    IsDeleted BIT NOT NULL DEFAULT 0,
    NameNorm NVARCHAR(200) NULL
  );
END
