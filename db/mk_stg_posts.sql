IF OBJECT_ID('dbo.StgPosts','U') IS NULL
CREATE TABLE dbo.StgPosts(
  PostId NVARCHAR(MAX), Title NVARCHAR(MAX), Slug NVARCHAR(MAX), Content NVARCHAR(MAX),
  Summary NVARCHAR(MAX), CategoryId NVARCHAR(MAX),
  FeatureImageUrl NVARCHAR(MAX), HeroImageUrl NVARCHAR(MAX), ThumbnailUrl NVARCHAR(MAX),
  Status NVARCHAR(MAX), IsPublished NVARCHAR(MAX),
  PublishDate NVARCHAR(MAX), PublishTime NVARCHAR(MAX),
  CreatedAt NVARCHAR(MAX), CreatedBy NVARCHAR(MAX), UpdatedBy NVARCHAR(MAX),
  TitleNorm NVARCHAR(MAX), SlugNorm NVARCHAR(MAX)
);
