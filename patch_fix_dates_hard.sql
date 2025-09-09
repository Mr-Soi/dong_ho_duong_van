SET NUMERIC_ROUNDABORT OFF; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON; SET ANSI_PADDING ON; SET ANSI_WARNINGS ON; SET ARITHABORT ON; SET CONCAT_NULL_YIELDS_NULL ON;

-- A) Chuẩn hóa PublishedAt -> datetime2
DECLARE @pt sysname;
SELECT @pt=t.name
FROM sys.columns c JOIN sys.types t ON c.user_type_id=t.user_type_id
WHERE c.object_id=OBJECT_ID('dbo.Posts') AND c.name='PublishedAt';

IF @pt NOT IN ('datetime','datetime2','smalldatetime','date','datetimeoffset')
BEGIN
  IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Posts_PublishedAt' AND object_id=OBJECT_ID('dbo.Posts'))
    DROP INDEX IX_Posts_PublishedAt ON dbo.Posts;

  ALTER TABLE dbo.Posts ADD PublishedAt_tmp datetime2 NULL;
  UPDATE dbo.Posts SET PublishedAt_tmp = TRY_CONVERT(datetime2, PublishedAt);
  ALTER TABLE dbo.Posts DROP COLUMN PublishedAt;
  EXEC sp_rename 'dbo.Posts.PublishedAt_tmp','PublishedAt','COLUMN';
END
ELSE
BEGIN
  -- dọn rác nếu cột đã là datetime* (phòng khi dữ liệu lạ do implicit convert)
  UPDATE dbo.Posts SET PublishedAt = NULL WHERE TRY_CONVERT(datetime2, PublishedAt) IS NULL;
END;

-- B) Chuẩn hóa IsPublished -> bit
DECLARE @it sysname;
SELECT @it=t.name
FROM sys.columns c JOIN sys.types t ON c.user_type_id=t.user_type_id
WHERE c.object_id=OBJECT_ID('dbo.Posts') AND c.name='IsPublished';

IF @it <> 'bit'
BEGIN
  ALTER TABLE dbo.Posts ADD IsPublished_tmp bit NOT NULL CONSTRAINT DF_Posts_IsPublished_tmp DEFAULT(0);
  UPDATE dbo.Posts
     SET IsPublished_tmp =
       CASE
         WHEN TRY_CONVERT(int, IsPublished)=1 THEN 1
         WHEN LOWER(LTRIM(RTRIM(CAST(IsPublished AS nvarchar(20))))) IN (N'true',N'yes',N'y') THEN 1
         ELSE 0
       END;
  ALTER TABLE dbo.Posts DROP COLUMN IsPublished;
  EXEC sp_rename 'dbo.Posts.IsPublished_tmp','IsPublished','COLUMN';
END;

-- C) Tạo lại index ngày đăng (nếu thiếu)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Posts_PublishedAt' AND object_id=OBJECT_ID('dbo.Posts'))
  CREATE INDEX IX_Posts_PublishedAt ON dbo.Posts(PublishedAt DESC);
