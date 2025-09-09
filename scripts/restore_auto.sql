DECLARE @bak NVARCHAR(4000) = N''/var/opt/mssql/backup/dongho.bak'';
DECLARE @t TABLE(
  LogicalName sysname, PhysicalName nvarchar(260), [Type] char(1),
  FileGroupName sysname NULL, [Size] bigint, MaxSize bigint, FileId int,
  CreateLSN numeric(25,0) NULL, DropLSN numeric(25,0) NULL,
  UniqueId uniqueidentifier NULL, ReadOnlyLSN numeric(25,0) NULL,
  ReadWriteLSN numeric(25,0) NULL, BackupSizeInBytes bigint NULL,
  SourceBlockSize int NULL, FileGroupId int NULL, LogGroupGUID uniqueidentifier NULL,
  DifferentialBaseLSN numeric(25,0) NULL, DifferentialBaseGUID uniqueidentifier NULL,
  IsReadOnly bit NULL, IsPresent bit NULL, TDEThumbprint varbinary(32) NULL,
  SnapshotUrl nvarchar(360) NULL
);
INSERT INTO @t EXEC(''RESTORE FILELISTONLY FROM DISK = '''''' + @bak + ''''''''');
DECLARE @data sysname = (SELECT TOP 1 LogicalName FROM @t WHERE [Type] = ''D'' ORDER BY FileId);
DECLARE @log  sysname = (SELECT TOP 1 LogicalName FROM @t WHERE [Type] = ''L'' ORDER BY FileId);

IF DB_ID(''don7069c_dongho'') IS NOT NULL
BEGIN
  ALTER DATABASE don7069c_dongho SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE don7069c_dongho;
END

DECLARE @sql nvarchar(max) = N''
RESTORE DATABASE don7069c_dongho
FROM DISK = N'''''' + @bak + N'''''''
WITH MOVE N'''''' + @data + N'''''' TO N''''/var/opt/mssql/data/don7069c_dongho.mdf'''',
     MOVE N'''''' + @log  + N'''''' TO N''''/var/opt/mssql/data/don7069c_dongho_log.ldf'''',
     REPLACE, STATS=5;'';
EXEC (@sql);
