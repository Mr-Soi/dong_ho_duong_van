SET NOCOUNT ON;
IF DB_ID('dhdv') IS NOT NULL
BEGIN
  ALTER DATABASE [dhdv] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
END

DECLARE @bak nvarchar(4000)=N'/var/opt/mssql/backup/dhdv.bak';
IF OBJECT_ID('tempdb..#f') IS NOT NULL DROP TABLE #f;
CREATE TABLE #f(
  LogicalName sysname, PhysicalName nvarchar(260), Type char(1),
  FileGroupName sysname NULL, Size numeric(20,0) NULL, MaxSize numeric(20,0) NULL,
  FileId int NULL, CreateLSN numeric(25,0) NULL, DropLSN numeric(25,0) NULL,
  UniqueId uniqueidentifier NULL, ReadOnlyLSN numeric(25,0) NULL, ReadWriteLSN numeric(25,0) NULL,
  BackupSizeInBytes bigint NULL, SourceBlockSize int NULL, FileGroupId int NULL,
  LogGroupGUID uniqueidentifier NULL, DifferentialBaseLSN numeric(25,0) NULL,
  DifferentialBaseGUID uniqueidentifier NULL, IsReadOnly bit NULL, IsPresent bit NULL,
  TDEThumbprint varbinary(32) NULL, SnapshotUrl nvarchar(360) NULL
);
INSERT INTO #f EXEC('RESTORE FILELISTONLY FROM DISK = ''' + @bak + ''';');

DECLARE @d sysname=(SELECT TOP 1 LogicalName FROM #f WHERE Type='D' ORDER BY FileId);
DECLARE @l sysname=(SELECT TOP 1 LogicalName FROM #f WHERE Type='L' ORDER BY FileId);

RESTORE DATABASE [dhdv]
  FROM DISK = @bak
  WITH REPLACE,
       MOVE @d TO N'/var/opt/mssql/data/dhdv.mdf',
       MOVE @l TO N'/var/opt/mssql/data/dhdv_log.ldf';

ALTER DATABASE [dhdv] SET MULTI_USER;
SELECT name, state_desc FROM sys.databases WHERE name='dhdv';
