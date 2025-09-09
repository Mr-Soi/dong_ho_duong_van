IF COL_LENGTH('dbo.Persons','BirthPlace') IS NULL
  ALTER TABLE dbo.Persons ADD BirthPlace NVARCHAR(400) NULL;
IF COL_LENGTH('dbo.Posts','Summary') IS NULL
  ALTER TABLE dbo.Posts ADD Summary NVARCHAR(MAX) NULL;
