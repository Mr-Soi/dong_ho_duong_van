
SET NOCOUNT ON;
SET XACT_ABORT ON;

-- Persons
IF OBJECT_ID('dbo.StgPersons','U') IS NOT NULL DROP TABLE dbo.StgPersons;
CREATE TABLE dbo.StgPersons (
  Id               INT,
  DisplayName      NVARCHAR(MAX),
  Alias            NVARCHAR(MAX),
  BirthDate        NVARCHAR(MAX),
  DeathDate        NVARCHAR(MAX),
  Generation       NVARCHAR(MAX),
  Branch           NVARCHAR(MAX),
  CreatedAt_csv    NVARCHAR(MAX),
  UpdatedAt_csv    NVARCHAR(MAX),
  CreatedBy        NVARCHAR(MAX),
  UpdatedBy        NVARCHAR(MAX),
  FullNameNorm     NVARCHAR(MAX),
  AliasNorm        NVARCHAR(MAX),
  BirthYear        NVARCHAR(MAX),
  DeathYear        NVARCHAR(MAX),
  LegacyId         NVARCHAR(MAX),
  DisplayNameNorm  NVARCHAR(MAX),
  YearOfBirth      NVARCHAR(MAX),
  YearOfDeath      NVARCHAR(MAX),
  IsDeleted        NVARCHAR(MAX),
  NameNorm         NVARCHAR(MAX)
);
BULK INSERT dbo.StgPersons
FROM '/tmp/import/Persons.utf16.fixed.csv'
WITH (
  FIRSTROW = 2,
  FIELDTERMINATOR = ',',
  ROWTERMINATOR   = '\r\n',
  DATAFILETYPE    = 'widechar',
  TABLOCK
);

UPDATE P
SET P.DisplayName = S.DisplayName,
    P.FullName    = CASE WHEN P.FullName IS NULL OR P.FullName = N'' THEN S.DisplayName ELSE P.FullName END
FROM dbo.Persons P
JOIN dbo.StgPersons S ON TRY_CAST(S.Id AS INT) = P.Id;

DROP TABLE dbo.StgPersons;

-- Albums
IF OBJECT_ID('dbo.StgAlbums','U') IS NOT NULL DROP TABLE dbo.StgAlbums;
CREATE TABLE dbo.StgAlbums (
  Id           INT,
  Title        NVARCHAR(MAX),
  Slug         NVARCHAR(MAX),
  Description  NVARCHAR(MAX),
  CreatedAt    NVARCHAR(MAX),
  UpdatedAt    NVARCHAR(MAX),
  IsDeleted    NVARCHAR(MAX),
  TitleNorm    NVARCHAR(MAX)
);
BULK INSERT dbo.StgAlbums
FROM '/tmp/import/Albums.utf16.fixed.csv'
WITH (
  FIRSTROW = 2,
  FIELDTERMINATOR = ',',
  ROWTERMINATOR   = '\r\n',
  DATAFILETYPE    = 'widechar',
  TABLOCK
);
UPDATE A
SET A.Name = COALESCE(NULLIF(S.Title, N''), A.Name)
FROM dbo.Albums A
JOIN dbo.StgAlbums S ON TRY_CAST(S.Id AS INT) = A.Id;

DROP TABLE dbo.StgAlbums;
