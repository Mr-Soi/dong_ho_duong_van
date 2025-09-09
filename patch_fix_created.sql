SET NUMERIC_ROUNDABORT OFF; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON; SET ANSI_PADDING ON; 
SET ANSI_WARNINGS ON; SET ARITHABORT ON; SET CONCAT_NULL_YIELDS_NULL ON;

-- helper: đổi cột NVARCHAR -> datetime2 (nếu không phải datetime*)
DECLARE @tbl sysname, @col sysname;

-- Posts.CreatedAt
SET @tbl=N'dbo.Posts'; SET @col=N'CreatedAt';
IF EXISTS (
  SELECT 1 FROM sys.columns c JOIN sys.types t ON c.user_type_id=t.user_type_id
  WHERE c.object_id=OBJECT_ID(@tbl) AND c.name=@col AND t.name NOT IN ('datetime','datetime2','smalldatetime','date','datetimeoffset')
)
BEGIN
  EXEC('ALTER TABLE '+@tbl+' ADD '+@col+'_tmp datetime2 NULL;');
  EXEC('UPDATE '+@tbl+' SET '+@col+'_tmp = TRY_CONVERT(datetime2,'+@col+');');
  EXEC('ALTER TABLE '+@tbl+' DROP COLUMN '+@col+';');
  EXEC('EXEC sp_rename '''+@tbl+'.'+@col+'_tmp'','''+@col+''',''COLUMN'';');
END;

-- Posts.UpdatedAt
SET @col=N'UpdatedAt';
IF EXISTS (
  SELECT 1 FROM sys.columns c JOIN sys.types t ON c.user_type_id=t.user_type_id
  WHERE c.object_id=OBJECT_ID(@tbl) AND c.name=@col AND t.name NOT IN ('datetime','datetime2','smalldatetime','date','datetimeoffset')
)
BEGIN
  EXEC('ALTER TABLE '+@tbl+' ADD '+@col+'_tmp datetime2 NULL;');
  EXEC('UPDATE '+@tbl+' SET '+@col+'_tmp = TRY_CONVERT(datetime2,'+@col+');');
  EXEC('ALTER TABLE '+@tbl+' DROP COLUMN '+@col+';');
  EXEC('EXEC sp_rename '''+@tbl+'.'+@col+'_tmp'','''+@col+''',''COLUMN'';');
END;

-- Categories.CreatedAt
SET @tbl=N'dbo.Categories'; SET @col=N'CreatedAt';
IF OBJECT_ID(@tbl) IS NOT NULL AND EXISTS (
  SELECT 1 FROM sys.columns c JOIN sys.types t ON c.user_type_id=t.user_type_id
  WHERE c.object_id=OBJECT_ID(@tbl) AND c.name=@col AND t.name NOT IN ('datetime','datetime2','smalldatetime','date','datetimeoffset')
)
BEGIN
  EXEC('ALTER TABLE '+@tbl+' ADD '+@col+'_tmp datetime2 NULL;');
  EXEC('UPDATE '+@tbl+' SET '+@col+'_tmp = TRY_CONVERT(datetime2,'+@col+');');
  EXEC('ALTER TABLE '+@tbl+' DROP COLUMN '+@col+';');
  EXEC('EXEC sp_rename '''+@tbl+'.'+@col+'_tmp'','''+@col+''',''COLUMN'';');
END;
