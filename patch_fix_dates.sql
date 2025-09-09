SET NUMERIC_ROUNDABORT OFF; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON; SET ANSI_PADDING ON; SET ANSI_WARNINGS ON; SET ARITHABORT ON; SET CONCAT_NULL_YIELDS_NULL ON;

-- A) PublishedAt: nếu KHÔNG phải datetime*
IF EXISTS (
  SELECT 1
  FROM sys.columns c JOIN sys.types t ON c.user_type_id=t.user_type_id
  WHERE c.object_id=OBJECT_ID('dbo.Posts') AND c.name='PublishedAt'
    AND t.name NOT IN ('datetime','datetime2','smalldatetime','date','datetimeoffset')
)
BEGIN
  -- set NULL các giá trị không chuyển được
  UPDATE dbo.Posts
    SET PublishedAt = NULL
  WHERE PublishedAt IS NOT NULL
    AND TRY_CONVERT(datetime2, PublishedAt) IS NULL;

  ALTER TABLE dbo.Posts ALTER COLUMN PublishedAt datetime2 NULL;
END;

-- B) IsPublished: nếu KHÔNG phải bit
IF EXISTS (
  SELECT 1
  FROM sys.columns c JOIN sys.types t ON c.user_type_id=t.user_type_id
  WHERE c.object_id=OBJECT_ID('dbo.Posts') AND c.name='IsPublished'
    AND t.name <> 'bit'
)
BEGIN
  UPDATE dbo.Posts
    SET IsPublished =
      CASE
        WHEN TRY_CONVERT(int, IsPublished)=1 THEN 1
        WHEN LOWER(LTRIM(RTRIM(CAST(IsPublished AS nvarchar(10))))) IN (N'true',N'yes',N'y') THEN 1
        ELSE 0
      END;
  ALTER TABLE dbo.Posts ALTER COLUMN IsPublished bit NOT NULL;
END;

-- C) Index theo ngày đăng (nếu thiếu)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Posts_PublishedAt' AND object_id=OBJECT_ID('dbo.Posts'))
  CREATE INDEX IX_Posts_PublishedAt ON dbo.Posts(PublishedAt DESC);
