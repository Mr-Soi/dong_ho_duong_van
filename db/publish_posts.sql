IF COL_LENGTH('dbo.Posts','IsPublished') IS NOT NULL
  UPDATE dbo.Posts SET IsPublished=1 WHERE IsPublished<>1 OR IsPublished IS NULL;
IF COL_LENGTH('dbo.Posts','PublishedAt') IS NOT NULL
  UPDATE dbo.Posts SET PublishedAt=COALESCE(PublishedAt,SYSUTCDATETIME());
