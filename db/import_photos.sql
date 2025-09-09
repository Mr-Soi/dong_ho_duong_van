IF OBJECT_ID('tempdb..#PH','U') IS NOT NULL DROP TABLE #PH;
CREATE TABLE #PH(Id NVARCHAR(MAX), AlbumId NVARCHAR(MAX), Url NVARCHAR(MAX), Caption NVARCHAR(MAX), TakenAt NVARCHAR(MAX));
BULK INSERT #PH FROM '/tmp/Photos.real.utf16.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\r\n', DATAFILETYPE='widechar', TABLOCK);

UPDATE #PH SET Url = REPLACE(Url, N'~/uploads/thumbnail/', N'/img/uploads/');
UPDATE #PH SET Url = REPLACE(Url, N'~/uploads/',           N'/img/uploads/');

SET IDENTITY_INSERT dbo.Photos ON;
MERGE dbo.Photos AS T
USING (
  SELECT
    TRY_CONVERT(INT,NULLIF(Id,N''))       AS Id,
    TRY_CONVERT(INT,NULLIF(AlbumId,N''))  AS AlbumId,
    NULLIF(Url,N'')                       AS Path,
    NULLIF(Caption,N'')                   AS Caption
  FROM #PH
  WHERE TRY_CONVERT(INT,NULLIF(AlbumId,N'')) IS NOT NULL
) S
ON T.Id=S.Id
WHEN MATCHED THEN UPDATE SET T.AlbumId=S.AlbumId, T.Path=S.Path, T.Caption=S.Caption
WHEN NOT MATCHED BY TARGET THEN
  INSERT(Id,AlbumId,Path,Caption) VALUES(S.Id,S.AlbumId,S.Path,S.Caption);
SET IDENTITY_INSERT dbo.Photos OFF;
