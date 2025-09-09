IF OBJECT_ID('dbo.Categories','U') IS NULL
BEGIN
  CREATE TABLE dbo.Categories(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(200) NOT NULL,
    Slug NVARCHAR(200) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
  );
  CREATE UNIQUE INDEX UX_Categories_Slug ON dbo.Categories(Slug);
END;
IF OBJECT_ID('dbo.Posts','U') IS NULL
BEGIN
  CREATE TABLE dbo.Posts(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(500) NOT NULL,
    Slug NVARCHAR(300) NOT NULL,
    Content NVARCHAR(MAX) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    IsPublished BIT NOT NULL DEFAULT(0),
    CategoryId INT NULL,
    CoverImage NVARCHAR(500) NULL
  );
  CREATE UNIQUE INDEX UX_Posts_Slug ON dbo.Posts(Slug);
  CREATE INDEX IX_Posts_CreatedAt ON dbo.Posts(CreatedAt DESC);
  IF OBJECT_ID('dbo.Categories','U') IS NOT NULL
    ALTER TABLE dbo.Posts ADD CONSTRAINT FK_Posts_Categories FOREIGN KEY (CategoryId) REFERENCES dbo.Categories(Id);
END;
