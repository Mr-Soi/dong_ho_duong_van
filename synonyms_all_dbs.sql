SET NOCOUNT ON;
DECLARE @db sysname, @sql nvarchar(max);
DECLARE cur CURSOR FOR
SELECT name FROM sys.databases
WHERE name NOT IN ('master','model','msdb','tempdb');  -- gi? c? 'dhdv'

OPEN cur; FETCH NEXT FROM cur INTO @db;
WHILE @@FETCH_STATUS=0
BEGIN
  SET @sql = N'
    USE '+QUOTENAME(@db)+N';
    IF OBJECT_ID(''dbo.Posts'',''SN'') IS NULL      CREATE SYNONYM dbo.Posts      FOR dhdv.dbo.Posts;
    IF OBJECT_ID(''dbo.Categories'',''SN'') IS NULL CREATE SYNONYM dbo.Categories FOR dhdv.dbo.Categories;
    IF OBJECT_ID(''dbo.Persons'',''SN'') IS NULL    CREATE SYNONYM dbo.Persons    FOR dhdv.dbo.Persons;';
  EXEC(@sql);
  FETCH NEXT FROM cur INTO @db;
END
CLOSE cur; DEALLOCATE cur;
