SET NOCOUNT ON; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON; SET ARITHABORT ON;

-- drop FKs self (father/mother)
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_Persons_Father' AND parent_object_id=OBJECT_ID('dbo.Persons'))
  ALTER TABLE dbo.Persons DROP CONSTRAINT FK_Persons_Father;
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_Persons_Mother' AND parent_object_id=OBJECT_ID('dbo.Persons'))
  ALTER TABLE dbo.Persons DROP CONSTRAINT FK_Persons_Mother;

-- drop PK Persons
DECLARE @pkP sysname=(SELECT kc.name FROM sys.key_constraints kc
                      WHERE kc.parent_object_id=OBJECT_ID(N'dbo.Persons') AND kc.type='PK');
IF @pkP IS NOT NULL
BEGIN
  DECLARE @s nvarchar(max)=N'ALTER TABLE dbo.Persons DROP CONSTRAINT ['+REPLACE(@pkP,']',']]')+N'];';
  EXEC(@s);
END

-- swap Id -> int
ALTER TABLE dbo.Persons ADD Id_new int NULL;
UPDATE dbo.Persons SET Id_new = CAST(Id AS int);
ALTER TABLE dbo.Persons DROP COLUMN Id;
EXEC sp_rename N'dbo.Persons.Id_new', N'Id', N'COLUMN';
ALTER TABLE dbo.Persons ALTER COLUMN Id int NOT NULL;

-- father/mother -> int
ALTER TABLE dbo.Persons ALTER COLUMN FatherId int NULL;
ALTER TABLE dbo.Persons ALTER COLUMN MotherId int NULL;

-- recreate PK + FKs
IF @pkP IS NULL SET @pkP=N'PK_Persons';
DECLARE @s2 nvarchar(max)=N'ALTER TABLE dbo.Persons ADD CONSTRAINT ['+REPLACE(@pkP,']',']]')+N'] PRIMARY KEY CLUSTERED (Id);';
EXEC(@s2);
ALTER TABLE dbo.Persons ADD CONSTRAINT FK_Persons_Father FOREIGN KEY (FatherId) REFERENCES dbo.Persons(Id);
ALTER TABLE dbo.Persons ADD CONSTRAINT FK_Persons_Mother FOREIGN KEY (MotherId) REFERENCES dbo.Persons(Id);
