
USE dhdv;
IF COL_LENGTH('dbo.Posts','HeroImageUrl') IS NULL  ALTER TABLE dbo.Posts ADD HeroImageUrl NVARCHAR(500) NULL;
IF COL_LENGTH('dbo.Posts','ThumbnailUrl') IS NULL  ALTER TABLE dbo.Posts ADD ThumbnailUrl NVARCHAR(500) NULL;
IF COL_LENGTH('dbo.Posts','ViewCount')   IS NULL  ALTER TABLE dbo.Posts ADD ViewCount INT NOT NULL CONSTRAINT DF_Posts_ViewCount DEFAULT(0);
IF COL_LENGTH('dbo.Posts','IsDeleted')   IS NULL  ALTER TABLE dbo.Posts ADD IsDeleted BIT NOT NULL CONSTRAINT DF_Posts_IsDeleted DEFAULT(0);
IF COL_LENGTH('dbo.Posts','CreatedAt')   IS NULL  ALTER TABLE dbo.Posts ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Posts_CreatedAt DEFAULT(SYSDATETIME());
IF COL_LENGTH('dbo.Posts','CreatedBy')   IS NULL  ALTER TABLE dbo.Posts ADD CreatedBy NVARCHAR(100) NULL;
IF COL_LENGTH('dbo.Posts','UpdatedAt')   IS NULL  ALTER TABLE dbo.Posts ADD UpdatedAt DATETIME2 NULL;
IF COL_LENGTH('dbo.Posts','UpdatedBy')   IS NULL  ALTER TABLE dbo.Posts ADD UpdatedBy NVARCHAR(100) NULL;

IF COL_LENGTH('dbo.Posts','TitleNorm') IS NULL ALTER TABLE dbo.Posts ADD TitleNorm AS LOWER(LTRIM(RTRIM(Title)));
IF COL_LENGTH('dbo.Posts','SlugNorm')  IS NULL ALTER TABLE dbo.Posts ADD SlugNorm  AS LOWER(LTRIM(RTRIM(Slug)));

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_Posts_Title_NotBlank')
  ALTER TABLE dbo.Posts ADD CONSTRAINT CK_Posts_Title_NotBlank CHECK (LEN(LTRIM(RTRIM(Title)))>0);
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_Posts_Slug_Valid')
  ALTER TABLE dbo.Posts ADD CONSTRAINT CK_Posts_Slug_Valid  CHECK (Slug NOT LIKE N'% %' AND LEN(Slug)<=160);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Posts_TitleNorm' AND object_id=OBJECT_ID('dbo.Posts'))
  CREATE INDEX IX_Posts_TitleNorm ON dbo.Posts(TitleNorm);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Posts_SlugNorm'  AND object_id=OBJECT_ID('dbo.Posts'))
  CREATE INDEX IX_Posts_SlugNorm  ON dbo.Posts(SlugNorm);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_PersonRelations_ParentId' AND object_id=OBJECT_ID('dbo.PersonRelations'))
  CREATE INDEX IX_PersonRelations_ParentId ON dbo.PersonRelations(ParentId);

GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
CREATE OR ALTER TRIGGER dbo.trg_Posts_SetUpdated
ON dbo.Posts AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE p SET UpdatedAt = SYSDATETIME()
  FROM dbo.Posts p JOIN inserted i ON i.Id=p.Id;
END
GO
