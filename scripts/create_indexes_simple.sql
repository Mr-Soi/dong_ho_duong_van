IF OBJECT_ID(N'dbo.Persons','U') IS NOT NULL AND COL_LENGTH(N'dbo.Persons','FullName') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Persons_FullName' AND object_id=OBJECT_ID(N'dbo.Persons'))
    CREATE INDEX IX_Persons_FullName ON dbo.Persons(FullName);

IF OBJECT_ID(N'dbo.People','U') IS NOT NULL AND COL_LENGTH(N'dbo.People','FullName') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_People_FullName' AND object_id=OBJECT_ID(N'dbo.People'))
    CREATE INDEX IX_People_FullName ON dbo.People(FullName);

IF OBJECT_ID(N'dbo.People','U') IS NOT NULL AND COL_LENGTH(N'dbo.People','Name') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_People_Name' AND object_id=OBJECT_ID(N'dbo.People'))
    CREATE INDEX IX_People_Name ON dbo.People(Name);

IF OBJECT_ID(N'dbo.Posts','U') IS NOT NULL AND COL_LENGTH(N'dbo.Posts','CreatedAt') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Posts_CreatedAt' AND object_id=OBJECT_ID(N'dbo.Posts'))
    CREATE INDEX IX_Posts_CreatedAt ON dbo.Posts(CreatedAt);

IF OBJECT_ID(N'dbo.Posts','U') IS NOT NULL AND COL_LENGTH(N'dbo.Posts','CreatedOn') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Posts_CreatedOn' AND object_id=OBJECT_ID(N'dbo.Posts'))
    CREATE INDEX IX_Posts_CreatedOn ON dbo.Posts(CreatedOn);

IF OBJECT_ID(N'dbo.Posts','U') IS NOT NULL AND COL_LENGTH(N'dbo.Posts','PublishedAt') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Posts_PublishedAt' AND object_id=OBJECT_ID(N'dbo.Posts'))
    CREATE INDEX IX_Posts_PublishedAt ON dbo.Posts(PublishedAt);

IF OBJECT_ID(N'dbo.Photos','U') IS NOT NULL AND COL_LENGTH(N'dbo.Photos','AlbumId') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Photos_AlbumId' AND object_id=OBJECT_ID(N'dbo.Photos'))
    CREATE INDEX IX_Photos_AlbumId ON dbo.Photos(AlbumId);

IF OBJECT_ID(N'dbo.Photos','U') IS NOT NULL AND COL_LENGTH(N'dbo.Photos','AlbumID') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Photos_AlbumID' AND object_id=OBJECT_ID(N'dbo.Photos'))
    CREATE INDEX IX_Photos_AlbumID ON dbo.Photos(AlbumID);

IF OBJECT_ID(N'dbo.Images','U') IS NOT NULL AND COL_LENGTH(N'dbo.Images','AlbumId') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Images_AlbumId' AND object_id=OBJECT_ID(N'dbo.Images'))
    CREATE INDEX IX_Images_AlbumId ON dbo.Images(AlbumId);
