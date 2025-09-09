
USE dhdv;
SET NOCOUNT ON;
IF COL_LENGTH('dbo.Albums','CreatedAt') IS NULL
  ALTER TABLE dbo.Albums ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Alb_CreatedAt DEFAULT(SYSDATETIME());
IF COL_LENGTH('dbo.Albums','UpdatedAt') IS NULL
  ALTER TABLE dbo.Albums ADD UpdatedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.Albums','IsDeleted') IS NULL
  ALTER TABLE dbo.Albums ADD IsDeleted BIT NOT NULL CONSTRAINT DF_Alb_IsDeleted DEFAULT(0);
IF COL_LENGTH('dbo.Albums','TitleNorm') IS NULL
  ALTER TABLE dbo.Albums ADD TitleNorm AS LOWER(LTRIM(RTRIM(Title))) PERSISTED;

UPDATE dbo.Albums SET Title=LTRIM(RTRIM(Title)), Slug=LOWER(LTRIM(RTRIM(Slug)));
UPDATE dbo.Albums
SET Slug = LOWER(REPLACE(REPLACE(LTRIM(RTRIM(Title)),' ','-'),'--','-'))
WHERE Slug IS NULL OR LTRIM(RTRIM(Slug))='';

WHILE EXISTS (SELECT 1 FROM dbo.Albums WHERE Slug LIKE '%--%')
  UPDATE dbo.Albums SET Slug=REPLACE(Slug,'--','-') WHERE Slug LIKE '%--%';

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Albums_TitleNorm' AND object_id=OBJECT_ID('dbo.Albums'))
  CREATE INDEX IX_Albums_TitleNorm ON dbo.Albums(TitleNorm);
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
CREATE OR ALTER TRIGGER dbo.trg_Albums_SetUpdated
ON dbo.Albums AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE a SET UpdatedAt = SYSDATETIME()
  FROM dbo.Albums a JOIN inserted i ON i.Id=a.Id;
END
GO
