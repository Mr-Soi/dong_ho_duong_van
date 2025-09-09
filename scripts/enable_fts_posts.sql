USE dhdv;
IF SERVERPROPERTY('IsFullTextInstalled')=1
BEGIN
  IF NOT EXISTS (SELECT 1 FROM sys.fulltext_catalogs WHERE name='ft') CREATE FULLTEXT CATALOG ft AS DEFAULT;
  IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_Posts_Id_FTS' AND object_id=OBJECT_ID('dbo.Posts'))
    CREATE UNIQUE INDEX UX_Posts_Id_FTS ON dbo.Posts(Id);
  IF NOT EXISTS (SELECT 1 FROM sys.fulltext_indexes WHERE object_id=OBJECT_ID('dbo.Posts'))
    CREATE FULLTEXT INDEX ON dbo.Posts
      (Title LANGUAGE 1066, Summary LANGUAGE 1066, Content LANGUAGE 1066)
    KEY INDEX UX_Posts_Id_FTS ON ft WITH CHANGE_TRACKING AUTO;
END
