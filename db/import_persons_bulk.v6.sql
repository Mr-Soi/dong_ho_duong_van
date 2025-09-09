DELETE FROM dbo.StgPersons;
GO
BULK INSERT dbo.StgPersons
FROM '/tmp/Persons.clean.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDQUOTE='\"', KEEPNULLS, TABLOCK, MAXERRORS=100000);
GO
UPDATE dbo.StgPersons SET DisplayName=REPLACE(DisplayName,N'Ğ',N'Đ');
UPDATE dbo.StgPersons SET DisplayName=REPLACE(DisplayName,N'Ởi',N'ời');

;MERGE dbo.Persons AS T
USING (
  SELECT
    TRY_CONVERT(INT, NULLIF(Id,N'')) AS Id,
    NULLIF(DisplayName,N'') AS FullName,
    NULLIF(Alias,N'') AS Alias,
    NULLIF(BirthDate,N'') AS BirthDate,
    NULLIF(DeathDate,N'') AS DeathDate,
    TRY_CONVERT(INT, NULLIF(Generation,N'')) AS Generation,
    NULLIF(Branch,N'') AS Branch,
    NULLIF(NULLIF(BirthYear,N''),N'0') AS BirthYear,
    NULLIF(NULLIF(DeathYear,N''),N'0') AS DeathYear
  FROM dbo.StgPersons
  WHERE TRY_CONVERT(INT, NULLIF(Id,N'')) IS NOT NULL
) S
ON T.Id=S.Id
WHEN MATCHED THEN UPDATE SET
  T.FullName=S.FullName,T.Alias=S.Alias,T.BirthDate=S.BirthDate,T.DeathDate=S.DeathDate,
  T.Generation=S.Generation,T.Branch=S.Branch,T.BirthYear=S.BirthYear,T.DeathYear=S.DeathYear
WHEN NOT MATCHED BY TARGET THEN
  INSERT(Id,FullName,Alias,BirthDate,DeathDate,Generation,Branch,BirthYear,DeathYear)
  VALUES(S.Id,S.FullName,S.Alias,S.BirthDate,S.DeathDate,S.Generation,S.Branch,S.BirthYear,S.DeathYear);
GO
SELECT StgRows=COUNT(*) FROM dbo.StgPersons; SELECT Persons=COUNT(*) FROM dbo.Persons;
