SET NOCOUNT ON;
DECLARE @tbl sysname, @col sysname, @sql nvarchar(max);

DECLARE cur CURSOR FOR
SELECT s.name+'.'+o.name, c.name
FROM sys.columns c
JOIN sys.objects o ON o.object_id=c.object_id AND o.type='U'
JOIN sys.schemas s ON s.schema_id=o.schema_id
JOIN sys.types t ON t.user_type_id=c.user_type_id
WHERE (c.name LIKE '%Date%' OR c.name LIKE '%At%')
  AND t.name NOT IN ('date','datetime','datetime2','smalldatetime','datetimeoffset');

OPEN cur;
FETCH NEXT FROM cur INTO @tbl,@col;
WHILE @@FETCH_STATUS=0
BEGIN
  SET @sql = N'UPDATE '+@tbl+' SET '+QUOTENAME(@col)+'=NULL WHERE TRY_CONVERT(datetime2,'+QUOTENAME(@col)+') IS NULL;';
  EXEC(@sql);
  SET @sql = N'ALTER TABLE '+@tbl+' ALTER COLUMN '+QUOTENAME(@col)+' datetime2 NULL;';
  EXEC(@sql);
  FETCH NEXT FROM cur INTO @tbl,@col;
END
CLOSE cur; DEALLOCATE cur;
