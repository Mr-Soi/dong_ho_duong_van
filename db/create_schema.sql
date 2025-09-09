IF OBJECT_ID('dbo.Persons','U') IS NULL
BEGIN
  CREATE TABLE dbo.Persons(
    Id INT NOT NULL PRIMARY KEY,
    FullName NVARCHAR(400) NULL,
    Alias NVARCHAR(400) NULL,
    BirthDate NVARCHAR(50) NULL,
    BirthPlace NVARCHAR(400) NULL,
    DeathDate NVARCHAR(50) NULL,
    Generation INT NULL,
    Branch NVARCHAR(50) NULL,
    FatherId INT NULL,
    MotherId INT NULL,
    BirthYear NVARCHAR(10) NULL,
    DeathYear NVARCHAR(10) NULL
  );
  CREATE INDEX IX_Persons_FatherId ON dbo.Persons(FatherId);
  CREATE INDEX IX_Persons_MotherId ON dbo.Persons(MotherId);
END;

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
END;

IF OBJECT_ID('dbo.Albums','U') IS NULL
BEGIN
  CREATE TABLE dbo.Albums(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(300) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
  );
END;

IF OBJECT_ID('dbo.Photos','U') IS NULL
BEGIN
  CREATE TABLE dbo.Photos(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    AlbumId INT NOT NULL,
    Path NVARCHAR(1000) NOT NULL,
    Caption NVARCHAR(500) NULL
  );
  CREATE INDEX IX_Photos_AlbumId ON dbo.Photos(AlbumId);
END;
