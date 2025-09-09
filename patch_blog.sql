IF OBJECT_ID('dbo.Categories','U') IS NULL
BEGIN
  CREATE TABLE dbo.Categories(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(200) NOT NULL,
    Slug NVARCHAR(200) NOT NULL UNIQUE,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
  );
END

IF OBJECT_ID('dbo.Posts','U') IS NULL
BEGIN
  CREATE TABLE dbo.Posts(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    CategoryId INT NULL,
    Title NVARCHAR(300) NOT NULL,
    Slug NVARCHAR(200) NOT NULL UNIQUE,
    Summary NVARCHAR(500) NULL,
    Content NVARCHAR(MAX) NULL,
    CoverImage NVARCHAR(512) NULL,
    IsPublished BIT NOT NULL DEFAULT 0,
    PublishedAt DATETIME2 NULL,
    IsDeleted BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
  );
END

IF OBJECT_ID('dbo.Posts','U') IS NOT NULL
AND OBJECT_ID('dbo.Categories','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_Posts_Categories')
  ALTER TABLE dbo.Posts ADD CONSTRAINT FK_Posts_Categories
    FOREIGN KEY (CategoryId) REFERENCES dbo.Categories(Id);

-- seed t?i thi?u
IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug='tin-tuc')
  INSERT dbo.Categories(Name,Slug) VALUES (N'Tin t?c',N'tin-tuc');

IF NOT EXISTS (SELECT 1 FROM dbo.Posts WHERE Slug='welcome')
  INSERT dbo.Posts(CategoryId,Title,Slug,Summary,Content,IsPublished,PublishedAt,CoverImage)
  VALUES ((SELECT TOP 1 Id FROM dbo.Categories ORDER BY Id),
          N'Ch?o m?ng',N'welcome',
          N'Ra m?t D?ng h? D??ng V?n',
          N'N?i dung m?u',1,SYSUTCDATETIME(),N'/img/uploads/default-cover.jpg');
