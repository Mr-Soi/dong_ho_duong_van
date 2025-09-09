SET NUMERIC_ROUNDABORT OFF; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON; SET ANSI_WARNINGS ON; SET ARITHABORT ON; SET CONCAT_NULL_YIELDS_NULL ON;

-- A) Drop FK/phụ thuộc (nếu có)
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_Persons_Father' AND parent_object_id=OBJECT_ID('dbo.Persons'))
  ALTER TABLE dbo.Persons DROP CONSTRAINT FK_Persons_Father;
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_Persons_Mother' AND parent_object_id=OBJECT_ID('dbo.Persons'))
  ALTER TABLE dbo.Persons DROP CONSTRAINT FK_Persons_Mother;

IF OBJECT_ID('dbo.PostPersons','U') IS NOT NULL
BEGIN
  DECLARE @fk nvarchar(128);
  DECLARE cur CURSOR FOR
    SELECT name FROM sys.foreign_keys WHERE parent_object_id=OBJECT_ID('dbo.PostPersons');
  OPEN cur; FETCH NEXT FROM cur INTO @fk;
  WHILE @@FETCH_STATUS=0 BEGIN
    EXEC('ALTER TABLE dbo.PostPersons DROP CONSTRAINT '+QUOTENAME(@fk)+';');
    FETCH NEXT FROM cur INTO @fk;
  END
  CLOSE cur; DEALLOCATE cur;
END

-- B) Persons: ép FatherId/MotherId về INT (chỉ khi đang BIGINT)
IF EXISTS (SELECT 1 FROM sys.columns c JOIN sys.types t ON c.user_type_id=t.user_type_id
          WHERE c.object_id=OBJECT_ID('dbo.Persons') AND c.name='FatherId' AND t.name='bigint')
BEGIN
  ALTER TABLE dbo.Persons ALTER COLUMN FatherId int NULL;
END
IF EXISTS (SELECT 1 FROM sys.columns c JOIN sys.types t ON c.user_type_id=t.user_type_id
          WHERE c.object_id=OBJECT_ID('dbo.Persons') AND c.name='MotherId' AND t.name='bigint')
BEGIN
  ALTER TABLE dbo.Persons ALTER COLUMN MotherId int NULL;
END

-- (tuỳ) Nếu Persons.Id là bigint thì đổi về INT (khi giá trị nằm trong INT)
IF EXISTS (SELECT 1 FROM sys.columns c JOIN sys.types t ON c.user_type_id=t.user_type_id
          WHERE c.object_id=OBJECT_ID('dbo.Persons') AND c.name='Id' AND t.name='bigint')
BEGIN
  -- đảm bảo không vượt INT
  IF NOT EXISTS (SELECT 1 FROM dbo.Persons WHERE Id > 2147483647)
  BEGIN
    -- Drop PK
    DECLARE @pk nvarchar(128)=(SELECT kc.name
                                FROM sys.key_constraints kc
                                WHERE kc.parent_object_id=OBJECT_ID('dbo.Persons') AND kc.type='PK');
    IF @pk IS NOT NULL EXEC('ALTER TABLE dbo.Persons DROP CONSTRAINT '+QUOTENAME(@pk)+';');
    ALTER TABLE dbo.Persons ALTER COLUMN Id int NOT NULL;
    IF @pk IS NOT NULL EXEC('ALTER TABLE dbo.Persons ADD CONSTRAINT '+QUOTENAME(@pk)+' PRIMARY KEY CLUSTERED (Id);');
  END
END

-- C) PostPersons: bảo đảm PostId/PersonId là INT
IF OBJECT_ID('dbo.PostPersons','U') IS NOT NULL
BEGIN
  IF EXISTS (SELECT 1 FROM sys.columns c JOIN sys.types t ON c.user_type_id=t.user_type_id
            WHERE c.object_id=OBJECT_ID('dbo.PostPersons') AND c.name='PostId' AND t.name='bigint')
    ALTER TABLE dbo.PostPersons ALTER COLUMN PostId int NULL;

  IF EXISTS (SELECT 1 FROM sys.columns c JOIN sys.types t ON c.user_type_id=t.user_type_id
            WHERE c.object_id=OBJECT_ID('dbo.PostPersons') AND c.name='PersonId' AND t.name='bigint')
    ALTER TABLE dbo.PostPersons ALTER COLUMN PersonId int NULL;
END

-- D) Recreate FK đã drop
IF COL_LENGTH('dbo.Persons','FatherId') IS NOT NULL
  ALTER TABLE dbo.Persons ADD CONSTRAINT FK_Persons_Father FOREIGN KEY (FatherId) REFERENCES dbo.Persons(Id);
IF COL_LENGTH('dbo.Persons','MotherId') IS NOT NULL
  ALTER TABLE dbo.Persons ADD CONSTRAINT FK_Persons_Mother FOREIGN KEY (MotherId) REFERENCES dbo.Persons(Id);

-- Nếu có PostPersons thì thêm lại FK tới Posts/Persons (nếu cần)
IF OBJECT_ID('dbo.PostPersons','U') IS NOT NULL
BEGIN
  IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_PostPersons_Posts' AND parent_object_id=OBJECT_ID('dbo.PostPersons'))
    ALTER TABLE dbo.PostPersons ADD CONSTRAINT FK_PostPersons_Posts   FOREIGN KEY (PostId)   REFERENCES dbo.Posts(Id);
  IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_PostPersons_Persons' AND parent_object_id=OBJECT_ID('dbo.PostPersons'))
    ALTER TABLE dbo.PostPersons ADD CONSTRAINT FK_PostPersons_Persons FOREIGN KEY (PersonId) REFERENCES dbo.Persons(Id);
END
