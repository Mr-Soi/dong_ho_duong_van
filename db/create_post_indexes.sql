IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_Posts_Slug' AND object_id=OBJECT_ID('dbo.Posts'))
  CREATE UNIQUE INDEX UX_Posts_Slug ON dbo.Posts(Slug);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Posts_PublishedAt' AND object_id=OBJECT_ID('dbo.Posts'))
  CREATE INDEX IX_Posts_PublishedAt ON dbo.Posts(PublishedAt DESC);
