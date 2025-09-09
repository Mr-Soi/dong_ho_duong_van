SET NUMERIC_ROUNDABORT OFF; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON; 
SET ANSI_PADDING ON; SET ANSI_WARNINGS ON; SET ARITHABORT ON; SET CONCAT_NULL_YIELDS_NULL ON;

-- Dọn PublishedAt không convert được -> NULL rồi ép kiểu
UPDATE dbo.Posts SET PublishedAt = NULL WHERE TRY_CONVERT(datetime2, PublishedAt) IS NULL;
ALTER TABLE dbo.Posts ALTER COLUMN PublishedAt datetime2 NULL;

-- Dọn CreatedAt/UpdatedAt (phòng hờ) rồi ép kiểu
UPDATE dbo.Posts SET CreatedAt  = NULL WHERE TRY_CONVERT(datetime2, CreatedAt)  IS NULL;
ALTER TABLE dbo.Posts ALTER COLUMN CreatedAt  datetime2 NULL;

UPDATE dbo.Posts SET UpdatedAt  = NULL WHERE TRY_CONVERT(datetime2, UpdatedAt)  IS NULL;
ALTER TABLE dbo.Posts ALTER COLUMN UpdatedAt  datetime2 NULL;

-- Categories.CreatedAt (phòng hờ)
IF OBJECT_ID('dbo.Categories') IS NOT NULL
BEGIN
  UPDATE dbo.Categories SET CreatedAt = NULL WHERE TRY_CONVERT(datetime2, CreatedAt) IS NULL;
  ALTER TABLE dbo.Categories ALTER COLUMN CreatedAt datetime2 NULL;
END
