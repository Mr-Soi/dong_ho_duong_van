IF COL_LENGTH('dbo.Posts','CoverImage') IS NULL
  ALTER TABLE dbo.Posts ADD CoverImage NVARCHAR(512) NULL;
