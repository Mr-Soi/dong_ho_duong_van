IF OBJECT_ID('tempdb..#P','U') IS NOT NULL DROP TABLE #P;
SELECT *
INTO #P
FROM OPENROWSET(
  BULK '/tmp/Persons.utf8.csv',
  FORMAT='CSV',
  PARSER_VERSION='2.0',
  FIELDTERMINATOR = ',',
  FIELDQUOTE = '\"',
  HEADER_ROW = TRUE
) AS R(
  Id NVARCHAR(50), DisplayName NVARCHAR(MAX), Alias NVARCHAR(MAX),
  BirthDate NVARCHAR(MAX), DeathDate NVARCHAR(MAX), Generation NVARCHAR(50),
  Branch NVARCHAR(MAX), CreatedAt NVARCHAR(MAX), UpdatedAt NVARCHAR(MAX),
  CreatedBy NVARCHAR(MAX), UpdatedBy NVARCHAR(MAX), FullNameNorm NVARCHAR(MAX),
  AliasNorm NVARCHAR(MAX), BirthYear NVARCHAR(50), DeathYear NVARCHAR(50),
  LegacyId NVARCHAR(MAX), DisplayNameNorm NVARCHAR(MAX),
  YearOfBirth NVARCHAR(MAX), YearOfDeath NVARCHAR(MAX),
  IsDeleted NVARCHAR(MAX), NameNorm NVARCHAR(MAX)
);

UPDATE #P SET DisplayName = REPLACE(DisplayName,N'Ğ',N'Đ');
UPDATE #P SET DisplayName = REPLACE(DisplayName,N'Ởi',N'ời');

MERGE dbo.Persons AS T
USING (
  SELECT
    TRY_CONVERT(INT, NULLIF(Id,N''))                AS Id,
    NULLIF(DisplayName,N'')                         AS FullName,
    NULLIF(Alias,N'')                               AS Alias,
    NULLIF(BirthDate,N'')                           AS BirthDate,
    NULLIF(DeathDate,N'')                           AS DeathDate,
    TRY_CONVERT(INT, NULLIF(Generation,N''))        AS Generation,
    NULLIF(Branch,N'')                              AS Branch,
    TRY_CONVERT(INT, NULLIF([FatherId],N''))        AS FatherId,
    TRY_CONVERT(INT, NULLIF([MotherId],N''))        AS MotherId,
    NULLIF(NULLIF(BirthYear,N''),N'0')              AS BirthYear,
    NULLIF(NULLIF(DeathYear,N''),N'0')              AS DeathYear
  FROM #P
  WHERE TRY_CONVERT(INT, NULLIF(Id,N'')) IS NOT NULL
) S
ON T.Id=S.Id
WHEN MATCHED THEN UPDATE SET
  T.FullName=S.FullName, T.Alias=S.Alias, T.BirthDate=S.BirthDate, T.DeathDate=S.DeathDate,
  T.Generation=S.Generation, T.Branch=S.Branch, T.FatherId=S.FatherId, T.MotherId=S.MotherId,
  T.BirthYear=S.BirthYear, T.DeathYear=S.DeathYear
WHEN NOT MATCHED BY TARGET THEN
  INSERT(Id,FullName,Alias,BirthDate,DeathDate,Generation,Branch,FatherId,MotherId,BirthYear,DeathYear)
  VALUES(S.Id,S.FullName,S.Alias,S.BirthDate,S.DeathDate,S.Generation,S.Branch,S.FatherId,S.MotherId,S.BirthYear,S.DeathYear);
