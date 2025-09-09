SET NOCOUNT ON; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON; SET ARITHABORT ON;

-- drop FKs tham chiếu dbo.Posts (nếu có)
DECLARE @sql nvarchar(max)=N'';
SELECT @sql += N'ALTER TABLE ['+SCHEMA_NAME(OBJECTPROPERTY(parent_object_id,'SchemaId'))+N'].['
              +OBJECT_NAME(parent_object_id)+N'] DROP CONSTRAINT ['+REPLACE(name,']',']]')+N'];'+CHAR(10)
FROM sys.foreign_keys
WHERE referenced_object_id = OBJECT_ID(N'dbo.Posts');
IF (@sql<>N'') EXEC(@sql);

-- drop PK trên dbo.Posts
DECLARE @pk sysname = (SELECT kc.name FROM sys.key_constraints kc
                       WHERE kc.parent_object_id=OBJECT_ID(N'dbo.Posts') AND kc.type='PK');
IF @pk IS NOT NULL
BEGIN
  DECLARE @sql2 nvarchar(max)=N'ALTER TABLE dbo.Posts DROP CONSTRAINT ['+REPLACE(@pk,']',']]')+N'];';
  EXEC(@sql2);
END

-- thêm Id_new int, copy, swap
ALTER TABLE dbo.Posts ADD Id_new int NULL;
UPDATE dbo.Posts SET Id_new = CAST(Id AS int);
ALTER TABLE dbo.Posts DROP COLUMN Id;
EXEC sp_rename N'dbo.Posts.Id_new', N'Id', N'COLUMN';

-- tạo lại PK
IF @pk IS NULL SET @pk = N'PK_Posts';
DECLARE @sql3 nvarchar(max)=N'ALTER TABLE dbo.Posts ADD CONSTRAINT ['+REPLACE(@pk,']',']]')+N'] PRIMARY KEY CLUSTERED (Id);';
EXEC(@sql3);
