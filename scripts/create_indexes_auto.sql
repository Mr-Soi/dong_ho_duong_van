USE [DHDV];
GO
-- People/Persons  FullName|Name
DECLARE @sch sysname,@tbl sysname,@col sysname,@sql nvarchar(max);
SELECT TOP 1 @sch=s.name,@tbl=t.name FROM sys.tables t JOIN sys.schemas s ON s.schema_id=t.schema_id WHERE t.name IN (N'Persons',N'People');
IF @tbl IS NOT NULL
BEGIN
  SELECT TOP 1 @col=c.name FROM sys.columns c WHERE c.object_id=OBJECT_ID(QUOTENAME(@sch)+N'.'+QUOTENAME(@tbl)) AND c.name IN (N'FullName',N'Name');
  IF @col IS NOT NULL AND NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=N'IX_'+@tbl+'_'+@col AND object_id=OBJECT_ID(QUOTENAME(@sch)+N'.'+QUOTENAME(@tbl)))
  BEGIN
    SET @sql=N'CREATE INDEX '+QUOTENAME('IX_'+@tbl+'_'+@col)+N' ON '+QUOTENAME(@sch)+N'.'+QUOTENAME(@tbl)+N'('+QUOTENAME(@col)+N');';
    EXEC sp_executesql @sql;
  END
END
GO
-- Posts  CreatedAt|CreatedOn|PublishedAt
SET @sch=NULL; SET @tbl=NULL; SET @col=NULL; SET @sql=NULL;
SELECT TOP 1 @sch=s.name,@tbl=t.name FROM sys.tables t JOIN sys.schemas s ON s.schema_id=t.schema_id WHERE t.name IN (N'Posts',N'Post');
IF @tbl IS NOT NULL
BEGIN
  SELECT TOP 1 @col=c.name FROM sys.columns c WHERE c.object_id=OBJECT_ID(QUOTENAME(@sch)+N'.'+QUOTENAME(@tbl)) AND c.name IN (N'CreatedAt',N'CreatedOn',N'PublishedAt');
  IF @col IS NOT NULL AND NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=N'IX_'+@tbl+'_'+@col AND object_id=OBJECT_ID(QUOTENAME(@sch)+N'.'+QUOTENAME(@tbl)))
  BEGIN
    SET @sql=N'CREATE INDEX '+QUOTENAME('IX_'+@tbl+'_'+@col)+N' ON '+QUOTENAME(@sch)+N'.'+QUOTENAME(@tbl)+N'('+QUOTENAME(@col)+N');';
    EXEC sp_executesql @sql;
  END
END
GO
-- Photos  AlbumId|AlbumID|Album_Id
SET @sch=NULL; SET @tbl=NULL; SET @col=NULL; SET @sql=NULL;
SELECT TOP 1 @sch=s.name,@tbl=t.name FROM sys.tables t JOIN sys.schemas s ON s.schema_id=t.schema_id WHERE t.name IN (N'Photos',N'Images');
IF @tbl IS NOT NULL
BEGIN
  SELECT TOP 1 @col=c.name FROM sys.columns c WHERE c.object_id=OBJECT_ID(QUOTENAME(@sch)+N'.'+QUOTENAME(@tbl)) AND c.name IN (N'AlbumId',N'AlbumID',N'Album_Id');
  IF @col IS NOT NULL AND NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name=N'IX_'+@tbl+'_'+@col AND object_id=OBJECT_ID(QUOTENAME(@sch)+N'.'+QUOTENAME(@tbl)))
  BEGIN
    SET @sql=N'CREATE INDEX '+QUOTENAME('IX_'+@tbl+'_'+@col)+N' ON '+QUOTENAME(@sch)+N'.'+QUOTENAME(@tbl)+N'('+QUOTENAME(@col)+N');';
    EXEC sp_executesql @sql;
  END
END
GO
