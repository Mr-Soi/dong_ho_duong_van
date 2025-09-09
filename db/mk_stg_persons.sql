IF OBJECT_ID('dbo.StgPersons','U') IS NULL
CREATE TABLE dbo.StgPersons(
  Id NVARCHAR(MAX), DisplayName NVARCHAR(MAX), Alias NVARCHAR(MAX),
  BirthDate NVARCHAR(MAX), DeathDate NVARCHAR(MAX), Generation NVARCHAR(MAX),
  Branch NVARCHAR(MAX), CreatedAt NVARCHAR(MAX), UpdatedAt NVARCHAR(MAX),
  CreatedBy NVARCHAR(MAX), UpdatedBy NVARCHAR(MAX), FullNameNorm NVARCHAR(MAX),
  AliasNorm NVARCHAR(MAX), BirthYear NVARCHAR(MAX), DeathYear NVARCHAR(MAX),
  LegacyId NVARCHAR(MAX), DisplayNameNorm NVARCHAR(MAX),
  YearOfBirth NVARCHAR(MAX), YearOfDeath NVARCHAR(MAX),
  IsDeleted NVARCHAR(MAX), NameNorm NVARCHAR(MAX)
);
