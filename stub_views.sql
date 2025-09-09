-- POSTS
IF OBJECT_ID('dbo.vw_PostsForImport','V') IS NOT NULL DROP VIEW dbo.vw_PostsForImport;
GO
CREATE VIEW dbo.vw_PostsForImport AS
SELECT TOP 0
    CAST(NULL AS INT)          AS [Post_ID],
    CAST(NULL AS NVARCHAR(MAX))AS [Title],
    CAST(NULL AS NVARCHAR(MAX))AS [Summary],
    CAST(NULL AS NVARCHAR(MAX))AS [Content],
    CAST(NULL AS DATETIME2)    AS [PublishedAt],
    CAST(NULL AS DATETIME2)    AS [UpdatedAt],
    CAST(NULL AS BIT)          AS [IsPublished],
    CAST(NULL AS NVARCHAR(MAX))AS [Category]
FROM sys.objects;
GO

-- PERSONS
IF OBJECT_ID('dbo.vw_PersonsForImport','V') IS NOT NULL DROP VIEW dbo.vw_PersonsForImport;
GO
CREATE VIEW dbo.vw_PersonsForImport AS
SELECT TOP 0
    CAST(NULL AS INT)          AS [LegacyId],
    CAST(NULL AS NVARCHAR(MAX))AS [DisplayName],
    CAST(NULL AS NVARCHAR(MAX))AS [Alias],
    CAST(NULL AS INT)          AS [Generation],
    CAST(NULL AS NVARCHAR(MAX))AS [Branch],
    CAST(NULL AS DATE)         AS [BirthDate],
    CAST(NULL AS DATE)         AS [DeathDate]
FROM sys.objects;
GO

-- PHOTOS
IF OBJECT_ID('dbo.vw_PhotosForImport','V') IS NOT NULL DROP VIEW dbo.vw_PhotosForImport;
GO
CREATE VIEW dbo.vw_PhotosForImport AS
SELECT TOP 0
    CAST(NULL AS NVARCHAR(MAX))AS [Title],
    CAST(NULL AS NVARCHAR(MAX))AS [Slug],
    CAST(NULL AS NVARCHAR(MAX))AS [Description],
    CAST(NULL AS DATETIME2)    AS [CreatedAt]
FROM sys.objects;
GO
