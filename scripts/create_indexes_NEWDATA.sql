SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;

USE dhdv;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Posts_IsPublished_PublishedAt' AND object_id=OBJECT_ID('dbo.Posts'))
    CREATE INDEX IX_Posts_IsPublished_PublishedAt ON dbo.Posts(IsPublished, PublishedAt DESC);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Posts_Category_PublishedAt' AND object_id=OBJECT_ID('dbo.Posts'))
    CREATE INDEX IX_Posts_Category_PublishedAt ON dbo.Posts(CategoryId, PublishedAt DESC);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Persons_DisplayName' AND object_id=OBJECT_ID('dbo.Persons'))
    CREATE INDEX IX_Persons_DisplayName ON dbo.Persons(DisplayName);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Persons_Alias' AND object_id=OBJECT_ID('dbo.Persons'))
    CREATE INDEX IX_Persons_Alias ON dbo.Persons(Alias) WHERE Alias IS NOT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_PersonRelations_ChildId' AND object_id=OBJECT_ID('dbo.PersonRelations'))
    CREATE INDEX IX_PersonRelations_ChildId ON dbo.PersonRelations(ChildId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Photos_Album_TakenAt' AND object_id=OBJECT_ID('dbo.Photos'))
    CREATE INDEX IX_Photos_Album_TakenAt ON dbo.Photos(AlbumId, TakenAt DESC);

