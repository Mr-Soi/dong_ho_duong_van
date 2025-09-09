-- /tmp/import_persons_v2.sql
IF OBJECT_ID('tempdb..#P','U') IS NOT NULL DROP TABLE #P;
CREATE TABLE #P(
  Id NVARCHAR(MAX), DisplayName NVARCHAR(MAX), Alias NVARCHAR(MAX),
  BirthDate NVARCHAR(MAX), DeathDate NVARCHAR(MAX), Generation NVARCHAR(MAX),
  Branch NVARCHAR(MAX), CreatedAt NVARCHAR(MAX), UpdatedAt NVARCHAR(MAX),
  CreatedBy NVARCHAR(MAX), UpdatedBy NVARCHAR(MAX), FullNameNorm NVARCHAR(MAX),
  AliasNorm NVARCHAR(MAX), BirthYear NVARCHAR(MAX), DeathYear NVARCHAR(MAX),
  LegacyId NVARCHAR(MAX), DisplayNameNorm NVARCHAR(MAX),
  YearOfBirth NVARCHAR(MAX), YearOfDeath NVARCHAR(MAX),
  IsDeleted NVARCHAR(MAX), NameNorm NVARCHAR(MAX)
);
BULK INSERT #P FROM '/tmp/Persons.real.utf16.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\r\n', DATAFILETYPE='widechar', TABLOCK);

UPDATE #P SET DisplayName = REPLACE(DisplayName,N'Ğ',N'Đ');
UPDATE #P SET DisplayName = REPLACE(DisplayName,N'Ởi',N'ời');

MERGE dbo.Persons AS T
USING (
  SELECT
    TRY_CONVERT(INT, NULLIF(Id,N''))                    AS Id,
    NULLIF(DisplayName,N'')                             AS FullName,
    NULLIF(Alias,N'')                                   AS Alias,
    NULLIF(BirthDate,N'')                               AS BirthDate,
    NULLIF(NULLIF(YearOfBirth,N''),N'0')                AS BirthYear,
    NULLIF(DeathDate,N'')                               AS DeathDate,
    NULLIF(NULLIF(YearOfDeath,N''),N'0')                AS DeathYear,
    TRY_CONVERT(INT, NULLIF(Generation,N''))            AS Generation,
    NULLIF(Branch,N'')                                  AS Branch
  FROM #P
  WHERE TRY_CONVERT(INT, NULLIF(Id,N'')) IS NOT NULL
) S
ON T.Id=S.Id
WHEN MATCHED THEN UPDATE SET
  T.FullName=S.FullName, T.Alias=S.Alias, T.BirthDate=S.BirthDate,
  T.DeathDate=S.DeathDate, T.Generation=S.Generation, T.Branch=S.Branch,
  T.BirthYear=S.BirthYear, T.DeathYear=S.DeathYear
WHEN NOT MATCHED BY TARGET THEN
  INSERT(Id,FullName,Alias,BirthDate,DeathDate,Generation,Branch,BirthYear,DeathYear)
  VALUES(S.Id,S.FullName,S.Alias,S.BirthDate,S.DeathDate,S.Generation,S.Branch,S.BirthYear,S.DeathYear);
