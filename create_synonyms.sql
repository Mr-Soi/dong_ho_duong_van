SET NOCOUNT ON;
DECLARE @s sysname, @sql nvarchar(max);

DECLARE cur CURSOR FOR
SELECT name
FROM sys.schemas
WHERE name NOT IN (
  'dbo','sys','INFORMATION_SCHEMA',
  'db_owner','db_accessadmin','db_securityadmin','db_ddladmin',
  'db_backupoperator','db_datareader','db_datawriter',
  'db_denydatareader','db_denydatawriter','guest'
);

OPEN cur; FETCH NEXT FROM cur INTO @s;
WHILE @@FETCH_STATUS=0
BEGIN
  IF NOT EXISTS (SELECT 1 FROM sys.synonyms WHERE name='Posts' AND schema_id=SCHEMA_ID(@s))
  BEGIN
    SET @sql = N'CREATE SYNONYM ['+@s+N'].[Posts] FOR [dbo].[Posts];';
    EXEC(@sql);
  END;
  IF NOT EXISTS (SELECT 1 FROM sys.synonyms WHERE name='Persons' AND schema_id=SCHEMA_ID(@s))
  BEGIN
    SET @sql = N'CREATE SYNONYM ['+@s+N'].[Persons] FOR [dbo].[Persons];';
    EXEC(@sql);
  END;
  FETCH NEXT FROM cur INTO @s;
END
CLOSE cur; DEALLOCATE cur;
