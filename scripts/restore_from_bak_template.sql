-- RESTORE TEMPLATE for SQL Server (run inside container or SSMS)
-- 1) Put .bak at /var/opt/mssql/backup/dongho.bak (Docker) or a local path (SSMS)
-- 2) Get logical file names:
--    RESTORE FILELISTONLY FROM DISK = '/var/opt/mssql/backup/dongho.bak';
-- 3) Replace LOGICAL_DATA_NAME and LOGICAL_LOG_NAME below, then run:

-- Drop if exists
IF DB_ID('don7069c_dongho') IS NOT NULL
BEGIN
  ALTER DATABASE don7069c_dongho SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE don7069c_dongho;
END

RESTORE DATABASE don7069c_dongho
FROM DISK = '/var/opt/mssql/backup/dongho.bak'
WITH MOVE 'LOGICAL_DATA_NAME' TO '/var/opt/mssql/data/don7069c_dongho.mdf',
     MOVE 'LOGICAL_LOG_NAME'  TO '/var/opt/mssql/data/don7069c_dongho_log.ldf',
     REPLACE;
