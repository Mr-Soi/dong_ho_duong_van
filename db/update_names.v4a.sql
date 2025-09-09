
SET NOCOUNT ON;
SET XACT_ABORT ON;

-- Persons staging (UTF-16LE, CRLF)
IF OBJECT_ID('dbo.StgPersons','U') IS NOT NULL DROP TABLE dbo.StgPersons;
CREATE TABLE dbo.StgPersons (
  Id               INT,
  DisplayName      NVARCHAR(400),
  Alias            NVARCHAR(400),
  BirthDate        NVARCHAR(50),
  DeathDate        NVARCHAR(50),
  Generation       NVARCHAR(50),
  Branch           NVARCHAR(50),
  CreatedAt_csv    NVARCHAR(50),
  UpdatedAt_csv    NVARCHAR(50),
  CreatedBy        NVARCHAR(200),
  UpdatedBy        NVARCHAR(200),
  FullNameNorm     NVARCHAR(400),
  AliasNorm        NVARCHAR(400),
  BirthYear        NVARCHAR(10),
  DeathYear        NVARCHAR(10),
  LegacyId         NVARCHAR(50),
  DisplayNameNorm  NVARCHAR(400),
  YearOfBirth      NVARCHAR(10),
  YearOfDeath      NVARCHAR(10),
  IsDeleted        NVARCHAR(10),
  NameNorm         NVARCHAR(400)
);

BULK INSERT dbo.StgPersons
FROM '/tmp/import/Persons.utf16.csv'
WITH (
  FIRSTROW = 2,
  FIELDTERMINATOR = ',',
  ROWTERMINATOR   = '\r\n',
  DATAFILETYPE    = 'widechar',
  TABLOCK
);

UPDATE S
SET DisplayName = LTRIM(RTRIM(REPLACE(S.DisplayName, '\"', ''))),
    Alias       = LTRIM(RTRIM(REPLACE(S.Alias, '\"', '')))
FROM dbo.StgPersons S;

UPDATE P
SET P.DisplayName = S.DisplayName,
    P.FullName    = CASE 
                      WHEN P.FullName IS NULL OR P.FullName = N'' 
                      THEN S.DisplayName 
                      ELSE P.FullName 
                    END
FROM dbo.Persons P
JOIN dbo.StgPersons S ON S.Id = P.Id;

DROP TABLE dbo.StgPersons;

-- Albums staging (UTF-16LE, CRLF)
IF OBJECT_ID('dbo.StgAlbums','U') IS NOT NULL DROP TABLE dbo.StgAlbums;
CREATE TABLE dbo.StgAlbums (
  Id           INT,
  Title        NVARCHAR(600),
  Slug         NVARCHAR(600),
  Description  NVARCHAR(MAX),
  CreatedAt    NVARCHAR(50),
  UpdatedAt    NVARCHAR(50),
  IsDeleted    NVARCHAR(10),
  TitleNorm    NVARCHAR(600)
);

BULK INSERT dbo.StgAlbums
FROM '/tmp/import/Albums.utf16.csv'
WITH (
  FIRSTROW = 2,
  FIELDTERMINATOR = ',',
  ROWTERMINATOR   = '\r\n',
  DATAFILETYPE    = 'widechar',
  TABLOCK
);

UPDATE S
SET Title = LTRIM(RTRIM(REPLACE(S.Title, '\"', '')))
FROM dbo.StgAlbums S;

UPDATE A
SET A.Name = COALESCE(NULLIF(S.Title, N''), A.Name)
FROM dbo.Albums A
JOIN dbo.StgAlbums S ON S.Id = A.Id;

DROP TABLE dbo.StgAlbums;
