DECLARE @CatDefault INT =
    COALESCE(
      (SELECT TOP 1 Id FROM dbo.Categories WHERE Slug IN (N'ban-tin') ORDER BY Id),
      (SELECT TOP 1 Id FROM dbo.Categories WHERE Slug IN (N'tin-tuc') ORDER BY Id)
    );

UPDATE p
SET p.PublishedAt =
    CASE
      WHEN p.PublishedAt IS NULL OR p.PublishedAt < '1950-01-01'
           THEN COALESCE(NULLIF(p.CreatedAt,'1900-01-01'), SYSUTCDATETIME())
      ELSE p.PublishedAt
    END
FROM dbo.Posts p;

UPDATE p
SET p.IsPublished = 1
FROM dbo.Posts p
WHERE p.PublishedAt >= '1950-01-01' AND (p.IsDeleted = 0 OR p.IsDeleted IS NULL);

IF @CatDefault IS NOT NULL
UPDATE p SET p.CategoryId = @CatDefault
FROM dbo.Posts p
WHERE p.CategoryId IS NULL;

UPDATE p SET
  p.Summary    = COALESCE(p.Summary, N''),
  p.CoverImage = COALESCE(NULLIF(p.CoverImage, N''), N'/img/uploads/logo_www.png')
FROM dbo.Posts p;
