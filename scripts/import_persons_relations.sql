
SET NOCOUNT ON;
USE dhdv;
IF COL_LENGTH('dbo.Persons','LegacyId') IS NULL
  ALTER TABLE dbo.Persons ADD LegacyId INT NULL;

MERGE dhdv.dbo.Persons AS T
USING (
  SELECT LegacyId, DisplayName, Alias, Generation, Branch, BirthDate, DeathDate
  FROM don7069c_dongho.dbo.vw_PersonsForImport
) AS S
ON T.LegacyId = S.LegacyId
WHEN MATCHED THEN UPDATE SET
  T.DisplayName = S.DisplayName,
  T.Alias       = S.Alias,
  T.Generation  = S.Generation,
  T.Branch      = S.Branch,
  T.BirthDate   = S.BirthDate,
  T.DeathDate   = S.DeathDate
WHEN NOT MATCHED BY TARGET THEN
  INSERT(DisplayName, Alias, Generation, Branch, BirthDate, DeathDate, LegacyId)
  VALUES(S.DisplayName, S.Alias, S.Generation, S.Branch, S.BirthDate, S.DeathDate, S.LegacyId);

;WITH src AS (
  SELECT ParentLegacy = cg.ParentID, ChildLegacy = cg.TreeID
  FROM don7069c_dongho.dbo.CayGiaPha cg
  WHERE cg.ParentID IS NOT NULL AND cg.ParentID<>0
)
INSERT INTO dhdv.dbo.PersonRelations(ParentId, ChildId, RelationType)
SELECT p.Id, c.Id, 1
FROM src s
JOIN dhdv.dbo.Persons p ON p.LegacyId = s.ParentLegacy
JOIN dhdv.dbo.Persons c ON c.LegacyId = s.ChildLegacy
WHERE p.Id<>c.Id
  AND NOT EXISTS (SELECT 1 FROM dhdv.dbo.PersonRelations r WHERE r.ParentId=p.Id AND r.ChildId=c.Id);
