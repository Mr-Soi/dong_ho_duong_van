
SET NOCOUNT ON;
SET XACT_ABORT ON;

------------------------------------------------------------
-- Persons: CSV columns (as provided): 
-- Id, DisplayName, Alias, BirthDate, DeathDate, Generation, Branch,
-- CreatedAt, UpdatedAt, CreatedBy, UpdatedBy, FullNameNorm, AliasNorm,
-- BirthYear, DeathYear, LegacyId, DisplayNameNorm, YearOfBirth, YearOfDeath,
-- IsDeleted, NameNorm
------------------------------------------------------------
IF OBJECT_ID('tempdb..#p','U') IS NOT NULL DROP TABLE #p;

SELECT * INTO #p
FROM OPENROWSET(
  BULK '/tmp/import/Persons.utf8.csv',
  FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', FIELDQUOTE='\"', CODEPAGE='65001'
) WITH (
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
) AS S;

UPDATE P
SET P.DisplayName = NULLIF(S.DisplayName, N''),
    -- CSV không có cột FullName; điền FullName nếu đang rỗng bằng DisplayName
    P.FullName    = CASE WHEN P.FullName IS NULL OR P.FullName = N'' 
                         THEN NULLIF(S.DisplayName, N'') 
                         ELSE P.FullName END
FROM dbo.Persons P
JOIN #p S ON S.Id = P.Id;

DROP TABLE #p;

------------------------------------------------------------
-- Albums: CSV columns (as provided):
-- Id, Title, Slug, Description, CreatedAt, UpdatedAt, IsDeleted, TitleNorm
------------------------------------------------------------
IF OBJECT_ID('tempdb..#a','U') IS NOT NULL DROP TABLE #a;

SELECT * INTO #a
FROM OPENROWSET(
  BULK '/tmp/import/Albums.utf8.csv',
  FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', FIELDQUOTE='\"', CODEPAGE='65001'
) WITH (
  Id           INT,
  Title        NVARCHAR(600),
  Slug         NVARCHAR(600),
  Description  NVARCHAR(MAX),
  CreatedAt    NVARCHAR(50),
  UpdatedAt    NVARCHAR(50),
  IsDeleted    NVARCHAR(10),
  TitleNorm    NVARCHAR(600)
) AS S;

UPDATE A
SET A.Name = COALESCE(NULLIF(S.Title, N''), A.Name)
FROM dbo.Albums A
JOIN #a S ON S.Id = A.Id;

DROP TABLE #a;
