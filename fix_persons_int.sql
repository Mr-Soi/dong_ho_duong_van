BEGIN TRY
  BEGIN TRAN;

  -- Gỡ FK nếu có
  IF OBJECT_ID('FK_Persons_Father','F') IS NOT NULL ALTER TABLE dbo.Persons DROP CONSTRAINT FK_Persons_Father;
  IF OBJECT_ID('FK_Persons_Mother','F') IS NOT NULL ALTER TABLE dbo.Persons DROP CONSTRAINT FK_Persons_Mother;
  IF OBJECT_ID('FK_PR_Parent','F')     IS NOT NULL ALTER TABLE dbo.PersonRelations DROP CONSTRAINT FK_PR_Parent;
  IF OBJECT_ID('FK_PR_Child','F')      IS NOT NULL ALTER TABLE dbo.PersonRelations DROP CONSTRAINT FK_PR_Child;

  -- PersonRelations -> INT
  IF EXISTS (SELECT 1 FROM sys.tables WHERE name='PersonRelations')
  BEGIN
    CREATE TABLE dbo.PersonRelations_fix(
      ParentId     INT     NOT NULL,
      ChildId      INT     NOT NULL,
      RelationType TINYINT NOT NULL
    );
    INSERT dbo.PersonRelations_fix(ParentId,ChildId,RelationType)
      SELECT CAST(ParentId AS INT), CAST(ChildId AS INT), RelationType
      FROM dbo.PersonRelations;
    DROP TABLE dbo.PersonRelations;
    EXEC sp_rename 'dbo.PersonRelations_fix','PersonRelations';
  END

  -- Persons -> INT (có IDENTITY để dùng IDENTITY_INSERT)
  CREATE TABLE dbo.Persons_fix(
    Id          INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    DisplayName NVARCHAR(200) NOT NULL,
    Alias       NVARCHAR(200) NULL,
    BirthDate   DATE NULL,
    DeathDate   DATE NULL,
    Generation  INT NULL,
    Branch      NVARCHAR(50) NULL,
    LegacyId    INT NULL,
    FullName    NVARCHAR(200) NULL,
    BirthPlace  NVARCHAR(200) NULL,
    FatherId    INT NULL,
    MotherId    INT NULL
  );

  SET IDENTITY_INSERT dbo.Persons_fix ON;
  INSERT dbo.Persons_fix (Id,DisplayName,Alias,BirthDate,DeathDate,Generation,Branch,LegacyId,FullName,BirthPlace,FatherId,MotherId)
    SELECT CAST(Id AS INT), DisplayName, Alias, BirthDate, DeathDate, Generation, Branch, LegacyId, FullName, BirthPlace,
           CAST(FatherId AS INT), CAST(MotherId AS INT)
    FROM dbo.Persons;
  SET IDENTITY_INSERT dbo.Persons_fix OFF;

  DROP TABLE dbo.Persons;
  EXEC sp_rename 'dbo.Persons_fix','Persons';

  -- FK lại
  IF COL_LENGTH('dbo.Persons','FatherId') IS NOT NULL
    ALTER TABLE dbo.Persons ADD CONSTRAINT FK_Persons_Father FOREIGN KEY(FatherId) REFERENCES dbo.Persons(Id);
  IF COL_LENGTH('dbo.Persons','MotherId') IS NOT NULL
    ALTER TABLE dbo.Persons ADD CONSTRAINT FK_Persons_Mother FOREIGN KEY(MotherId) REFERENCES dbo.Persons(Id);

  ALTER TABLE dbo.PersonRelations ADD CONSTRAINT FK_PR_Parent FOREIGN KEY(ParentId) REFERENCES dbo.Persons(Id);
  ALTER TABLE dbo.PersonRelations ADD CONSTRAINT FK_PR_Child  FOREIGN KEY(ChildId)  REFERENCES dbo.Persons(Id);

  COMMIT TRAN;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK TRAN;
  THROW;
END CATCH;
