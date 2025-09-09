-- dọn staging
IF OBJECT_ID('dbo.StgPersons','U') IS NULL
  RAISERROR('StgPersons missing',16,1);
DELETE FROM dbo.StgPersons;
GO

-- nạp CSV (UTF-8, có quote, bỏ header)
BULK INSERT dbo.StgPersons
FROM '/tmp/Persons.utf8.csv'
WITH (
  FORMAT='CSV',
  FIRSTROW=2,
  FIELDQUOTE='"',
  CODEPAGE='65001',
  ROWTERMINATOR='0x0a',
  KEEPNULLS,
  TABLOCK,
  MAXERRORS=100000,
  ERRORFILE='/tmp/pers_err'
);
GO

-- normalize + MERGE
UPDATE dbo.StgPersons SET DisplayName=REPLACE(DisplayName,N'Ğ',N'Đ');
UPDATE dbo.StgPersons SET DisplayName=REPLACE(DisplayName,N'Ởi',N'ời');

;MERGE dbo.Persons AS T
USING (
  SELECT
    TRY_CONVERT(INT, NULLIF(Id,N''))         AS Id,
    NULLIF(DisplayName,N'')                  AS FullName,
    NULLIF(Alias,N'')                        AS Alias,
    NULLIF(BirthDate,N'')                    AS BirthDate,
    NULLIF(DeathDate,N'')                    AS DeathDate,
    TRY_CONVERT(INT, NULLIF(Generation,N'')) AS Generation,
    NULLIF(Branch,N'')                       AS Branch,
    NULLIF(NULLIF(BirthYear,N''),N'0')       AS BirthYear,
    NULLIF(NULLIF(DeathYear,N''),N'0')       AS DeathYear
  FROM dbo.StgPersons
  WHERE TRY_CONVERT(INT, NULLIF(Id,N'')) IS NOT NULL
) S
ON T.Id=S.Id
WHEN MATCHED THEN UPDATE SET
  T.FullName=S.FullName, T.Alias=S.Alias, T.BirthDate=S.BirthDate, T.DeathDate=S.DeathDate,
  T.Generation=S.Generation, T.Branch=S.Branch, T.BirthYear=S.BirthYear, T.DeathYear=S.DeathYear
WHEN NOT MATCHED BY TARGET THEN
  INSERT(Id,FullName,Alias,BirthDate,DeathDate,Generation,Branch,BirthYear,DeathYear)
  VALUES(S.Id,S.FullName,S.Alias,S.BirthDate,S.DeathDate,S.Generation,S.Branch,S.BirthYear,S.DeathYear);
GO

SELECT Persons = COUNT(*) FROM dbo.Persons;
