SET NOCOUNT ON; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON; SET ARITHABORT ON;

-- drop mọi FK đang tham chiếu dbo.Posts
DECLARE @sql nvarchar(max)=N'';
SELECT @sql += N'ALTER TABLE '+QUOTENAME(SCHEMA_NAME(OBJECTPROPERTY(parent_object_id,'SchemaId')))
            + N'.'+QUOTENAME(OBJECT_NAME(parent_object_id))
            + N' DROP CONSTRAINT '+QUOTENAME(name)+';'+CHAR(10)
FROM sys.foreign_keys
WHERE referenced_object_id = OBJECT_ID(N'dbo.Posts');
IF (@sql<>'') EXEC(@sql);

-- drop PK trên dbo.Posts
DECLARE @pk sysname =
  (SELECT kc.name FROM sys.key_constraints kc
   WHERE kc.parent_object_id=OBJECT_ID(N'dbo.Posts') AND kc.type='PK');
IF @pk IS NOT NULL
  EXEC(N'ALTER TABLE dbo.Posts DROP CONSTRAINT '+QUOTENAME(@pk)+';');

-- thêm Id2 int, copy giá trị, swap thành Id
ALTER TABLE dbo.Posts ADD Id2 int NULL;
UPDATE dbo.Posts SET Id2 = CAST(Id AS int);
ALTER TABLE dbo.Posts DROP COLUMN Id;
EXEC sp_rename N'dbo.Posts.Id2', N'Id', N'COLUMN';

-- tạo lại PK
IF @pk IS NULL SET @pk = N'PK_Posts';
EXEC(N'ALTER TABLE dbo.Posts ADD CONSTRAINT '+QUOTENAME(@pk)+' PRIMARY KEY CLUSTERED (Id);');
