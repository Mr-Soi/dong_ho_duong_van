
USE dhdv;
SET NOCOUNT ON;
IF COL_LENGTH('dbo.Categories','CreatedAt') IS NULL
  ALTER TABLE dbo.Categories ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Cat_CreatedAt DEFAULT(SYSDATETIME());
IF COL_LENGTH('dbo.Categories','UpdatedAt') IS NULL
  ALTER TABLE dbo.Categories ADD UpdatedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.Categories','IsDeleted') IS NULL
  ALTER TABLE dbo.Categories ADD IsDeleted BIT NOT NULL CONSTRAINT DF_Cat_IsDeleted DEFAULT(0);
IF COL_LENGTH('dbo.Categories','NameNorm') IS NULL
  ALTER TABLE dbo.Categories ADD NameNorm AS LOWER(LTRIM(RTRIM(Name))) PERSISTED;

UPDATE dbo.Categories SET Name=LTRIM(RTRIM(Name)), Slug=LOWER(LTRIM(RTRIM(Slug)));
UPDATE dbo.Categories
SET Slug = LOWER(REPLACE(REPLACE(LTRIM(RTRIM(Name)),' ','-'),'--','-'))
WHERE Slug IS NULL OR LTRIM(RTRIM(Slug))='';

WHILE EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug LIKE '%--%')
  UPDATE dbo.Categories SET Slug=REPLACE(Slug,'--','-') WHERE Slug LIKE '%--%';

IF OBJECT_ID('tempdb..#g') IS NOT NULL DROP TABLE #g;
SELECT NameNorm, MinId = MIN(Id)
INTO #g
FROM dbo.Categories
GROUP BY NameNorm
HAVING COUNT(*)>1;

UPDATE p SET CategoryId = g.MinId
FROM dbo.Posts p
JOIN dbo.Categories c ON c.Id=p.CategoryId
JOIN #g g ON g.NameNorm=c.NameNorm
WHERE p.CategoryId<>g.MinId;

DELETE c
FROM dbo.Categories c
JOIN #g g ON g.NameNorm=c.NameNorm
WHERE c.Id<>g.MinId;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Categories_NameNorm' AND object_id=OBJECT_ID('dbo.Categories'))
  CREATE INDEX IX_Categories_NameNorm ON dbo.Categories(NameNorm);
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
CREATE OR ALTER TRIGGER dbo.trg_Categories_SetUpdated
ON dbo.Categories AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE c SET UpdatedAt = SYSDATETIME()
  FROM dbo.Categories c JOIN inserted i ON i.Id=c.Id;
END
GO
