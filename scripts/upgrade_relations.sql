USE dhdv;

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_PersonRelations_NoSelf')
  ALTER TABLE dbo.PersonRelations ADD CONSTRAINT CK_PersonRelations_NoSelf CHECK (ParentId<>ChildId);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_PersonRelations_ParentId' AND object_id=OBJECT_ID('dbo.PersonRelations'))
  CREATE INDEX IX_PersonRelations_ParentId ON dbo.PersonRelations(ParentId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_PersonRelations_ChildId' AND object_id=OBJECT_ID('dbo.PersonRelations'))
  CREATE INDEX IX_PersonRelations_ChildId  ON dbo.PersonRelations(ChildId);
