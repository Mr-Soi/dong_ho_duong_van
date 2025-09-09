IF DB_ID('dhdv') IS NULL BEGIN CREATE DATABASE dhdv; END
GO
USE dhdv;
GO
IF OBJECT_ID('dbo.Persons','U') IS NULL
CREATE TABLE dbo.Persons(
  Id INT IDENTITY PRIMARY KEY,
  FullName NVARCHAR(256) NOT NULL,
  Branch NVARCHAR(128) NULL,
  Gen INT NULL,
  AvatarUrl NVARCHAR(512) NULL,
  CreatedAt DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
  UpdatedAt DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME()
);
IF OBJECT_ID('dbo.Categories','U') IS NULL
CREATE TABLE dbo.Categories(
  Id INT IDENTITY PRIMARY KEY,
  Name NVARCHAR(128) NOT NULL
);
IF OBJECT_ID('dbo.Posts','U') IS NULL
CREATE TABLE dbo.Posts(
  Id INT IDENTITY PRIMARY KEY,
  Title NVARCHAR(256) NOT NULL,
  Content NVARCHAR(MAX) NULL,
  CoverImage NVARCHAR(512) NULL,
  CategoryId INT NOT NULL,
  CreatedAt DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
  CONSTRAINT FK_Posts_Cat FOREIGN KEY(CategoryId) REFERENCES dbo.Categories(Id)
);
IF OBJECT_ID('dbo.Albums','U') IS NULL
CREATE TABLE dbo.Albums(
  Id INT IDENTITY PRIMARY KEY,
  Name NVARCHAR(256) NOT NULL,
  CreatedAt DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
  UpdatedAt DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME()
);
IF NOT EXISTS(SELECT 1 FROM dbo.Categories)
INSERT dbo.Categories(Name) VALUES (N'Bản tin'),(N'Văn thơ'),(N'Gia phả');
IF NOT EXISTS(SELECT 1 FROM dbo.Persons)
INSERT dbo.Persons(FullName,Branch,Gen) VALUES
 (N'Dương Văn A',N'Chi 1',2),(N'Dương Văn B',N'Chi 1',3),(N'Dương Văn C',N'Chi 2',3);
IF NOT EXISTS(SELECT 1 FROM dbo.Albums)
INSERT dbo.Albums(Name) VALUES (N'Lễ hội khuyến học'),(N'Ảnh gia phả');
IF NOT EXISTS(SELECT 1 FROM dbo.Posts)
INSERT dbo.Posts(Title,Content,CategoryId)
SELECT N'Thông báo khởi động site',N'Bản tin thử nghiệm',(SELECT TOP 1 Id FROM dbo.Categories ORDER BY Id);
