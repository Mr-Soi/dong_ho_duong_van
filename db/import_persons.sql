IF OBJECT_ID('tempdb..#P','U') IS NOT NULL DROP TABLE #P;
CREATE TABLE #P(
  Id NVARCHAR(MAX), DisplayName NVARCHAR(MAX), Alias NVARCHAR(MAX),
  BirthDate NVARCHAR(MAX), BirthPlace NVARCHAR(MAX), DeathDate NVARCHAR(MAX),
  Generation NVARCHAR(MAX), Branch NVARCHAR(MAX), FatherId NVARCHAR(MAX), MotherId NVARCHAR(MAX),
  BirthYear NVARCHAR(MAX), DeathYear NVARCHAR(MAX)
);
BULK INSERT #P FROM '/tmp/Persons.real.utf16.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\r\n', DATAFILETYPE='widechar', TABLOCK);

UPDATE #P SET DisplayName = REPLACE(DisplayName,N'Ğ',N'Đ');
UPDATE #P SET DisplayName = REPLACE(DisplayName,N'Ởi',N'ời');

MERGE dbo.Persons AS T
USING (
  SELECT
    TRY_CONVERT(INT, NULLIF(Id,N''))                AS Id,
    NULLIF(DisplayName,N'')                         AS FullName,
    NULLIF(Alias,N'')                               AS Alias,
    NULLIF(BirthDate,N'')                           AS BirthDate,
    NULLIF(BirthPlace,N'')                          AS BirthPlace,
    NULLIF(DeathDate,N'')                           AS DeathDate,
    TRY_CONVERT(INT, NULLIF(Generation,N''))        AS Generation,
    NULLIF(Branch,N'')                              AS Branch,
    TRY_CONVERT(INT, NULLIF(FatherId,N''))          AS FatherId,
    TRY_CONVERT(INT, NULLIF(MotherId,N''))          AS MotherId,
    NULLIF(BirthYear,N'')                           AS BirthYear,
    NULLIF(DeathYear,N'')                           AS DeathYear
  FROM #P
  WHERE TRY_CONVERT(INT, NULLIF(Id,N'')) IS NOT NULL
) S
ON T.Id = S.Id
WHEN MATCHED THEN UPDATE SET
  T.FullName=S.FullName, T.Alias=S.Alias, T.BirthDate=S.BirthDate, T.BirthPlace=S.BirthPlace,
  T.DeathDate=S.DeathDate, T.Generation=S.Generation, T.Branch=S.Branch,
  T.FatherId=S.FatherId, T.MotherId=S.MotherId, T.BirthYear=S.BirthYear, T.DeathYear=S.DeathYear
WHEN NOT MATCHED BY TARGET THEN
  INSERT(Id,FullName,Alias,BirthDate,BirthPlace,DeathDate,Generation,Branch,FatherId,MotherId,BirthYear,DeathYear)
  VALUES(S.Id,S.FullName,S.Alias,S.BirthDate,S.BirthPlace,S.DeathDate,S.Generation,S.Branch,S.FatherId,S.MotherId,S.BirthYear,S.DeathYear);
