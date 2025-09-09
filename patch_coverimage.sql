SET NUMERIC_ROUNDABORT OFF;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;

IF COL_LENGTH('dbo.Posts','CoverImage') IS NULL
    ALTER TABLE dbo.Posts ADD CoverImage NVARCHAR(512) NULL;

UPDATE p
SET CoverImage = COALESCE(NULLIF(p.CoverImage,N''),
                          NULLIF(p.HeroImageUrl,N''),
                          NULLIF(p.ThumbnailUrl,N''),
                          N'/img/uploads/logo_www.png')
FROM dbo.Posts p
WHERE p.CoverImage IS NULL;

-- kiểm tra
SELECT TOP 5 Id, Title, CoverImage FROM dbo.Posts ORDER BY PublishedAt DESC;
