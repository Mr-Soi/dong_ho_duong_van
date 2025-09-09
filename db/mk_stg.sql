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
IF COL_LENGTH('dbo.StgPersons','FatherId')  IS NULL ALTER TABLE dbo.StgPersons ADD FatherId  NVARCHAR(MAX) NULL;
IF COL_LENGTH('dbo.StgPersons','MotherId')  IS NULL ALTER TABLE dbo.StgPersons ADD MotherId  NVARCHAR(MAX) NULL;

IF OBJECT_ID('dbo.StgPosts','U') IS NULL
CREATE TABLE dbo.StgPosts(
  PostId NVARCHAR(MAX), Title NVARCHAR(MAX), Slug NVARCHAR(MAX), Content NVARCHAR(MAX),
  Summary NVARCHAR(MAX), CategoryId NVARCHAR(MAX),
  FeatureImageUrl NVARCHAR(MAX), HeroImageUrl NVARCHAR(MAX), ThumbnailUrl NVARCHAR(MAX),
  Status NVARCHAR(MAX), IsPublished NVARCHAR(MAX),
  PublishDate NVARCHAR(MAX), PublishTime NVARCHAR(MAX),
  CreatedAt NVARCHAR(MAX), CreatedBy NVARCHAR(MAX), UpdatedBy NVARCHAR(MAX),
  TitleNorm NVARCHAR(MAX), SlugNorm NVARCHAR(MAX)
);
