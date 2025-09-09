SET NUMERIC_ROUNDABORT OFF; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON; SET ANSI_WARNINGS ON; SET ARITHABORT ON; SET CONCAT_NULL_YIELDS_NULL ON;

-- A) Xoá mọi index đang bám PublishedAt
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Posts_IsPublished_PublishedAt' AND object_id=OBJECT_ID('dbo.Posts'))
  DROP INDEX IX_Posts_IsPublished_PublishedAt ON dbo.Posts;
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Posts_Category_PublishedAt' AND object_id=OBJECT_ID('dbo.Posts'))
  DROP INDEX IX_Posts_Category_PublishedAt ON dbo.Posts;
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Posts_PublishedAt' AND object_id=OBJECT_ID('dbo.Posts'))
  DROP INDEX IX_Posts_PublishedAt ON dbo.Posts;

-- B) Dọn rác rồi ép kiểu PublishedAt -> datetime2
UPDATE dbo.Posts SET PublishedAt=NULL WHERE TRY_CONVERT(datetime2, PublishedAt) IS NULL;
ALTER TABLE dbo.Posts ALTER COLUMN PublishedAt datetime2 NULL;

-- (phòng hờ) ép UpdatedAt về datetime2 luôn
UPDATE dbo.Posts SET UpdatedAt=NULL WHERE TRY_CONVERT(datetime2, UpdatedAt) IS NULL;
ALTER TABLE dbo.Posts ALTER COLUMN UpdatedAt datetime2 NULL;

-- C) Tạo lại index phục vụ truy vấn
CREATE INDEX IX_Posts_PublishedAt             ON dbo.Posts(PublishedAt DESC);
CREATE INDEX IX_Posts_IsPublished_PublishedAt  ON dbo.Posts(IsPublished, PublishedAt DESC);
CREATE INDEX IX_Posts_Category_PublishedAt     ON dbo.Posts(CategoryId, PublishedAt DESC);
