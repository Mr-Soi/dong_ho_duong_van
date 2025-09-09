SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF OBJECT_ID('dbo.Persons','V') IS NOT NULL DROP VIEW dbo.Persons;
DECLARE @cols nvarchar(max) =
  STUFF((
    SELECT ',' +
      CASE WHEN name='Id' THEN 'CAST(Id AS int) AS Id'
           WHEN name IN('FatherId','MotherId') THEN 'CAST('+QUOTENAME(name)+' AS int) AS '+QUOTENAME(name)
           ELSE QUOTENAME(name) END
    FROM sys.columns
    WHERE object_id=OBJECT_ID('dbo.Persons_big')
    ORDER BY column_id
    FOR XML PATH(''),TYPE).value('.','nvarchar(max)'),1,1,'');
DECLARE @sql nvarchar(max)=N'CREATE VIEW dbo.Persons AS SELECT '+@cols+N' FROM dbo.Persons_big;';
EXEC(@sql);
