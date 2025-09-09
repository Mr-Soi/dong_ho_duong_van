SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#p','U') IS NOT NULL DROP TABLE #p;
SELECT * INTO #p
FROM OPENROWSET(
  BULK '/tmp/import/Persons.utf8.csv',
  FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', FIELDQUOTE='"', CODEPAGE='65001'
) WITH (
  Id int,
  DisplayName nvarchar(400),
  Alias nvarchar(400),
  BirthDate nvarchar(50),
  DeathDate nvarchar(50),
  Generation nvarchar(50),
  Branch nvarchar(100),
  FullName nvarchar(400)
) AS S;
UPDATE P
SET P.DisplayName = NULLIF(S.DisplayName,N''),
    P.FullName    = NULLIF(S.FullName,N'')
FROM dbo.Persons P
JOIN #p S ON S.Id=P.Id;
DROP TABLE #p;

IF OBJECT_ID('tempdb..#a','U') IS NOT NULL DROP TABLE #a;
SELECT * INTO #a
FROM OPENROWSET(
  BULK '/tmp/import/Albums.utf8.csv',
  FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', FIELDQUOTE='"', CODEPAGE='65001'
) WITH (
  Id int,
  Title nvarchar(600)
) AS S;
UPDATE A
SET A.Name = COALESCE(NULLIF(S.Title,N''), A.Name)
FROM dbo.Albums A
JOIN #a S ON S.Id=A.Id;
DROP TABLE #a;
