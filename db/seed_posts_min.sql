IF NOT EXISTS (SELECT 1 FROM dbo.Categories)
  INSERT INTO dbo.Categories(Name,Slug) VALUES (N'Tin tức',N'tin-tuc');
IF NOT EXISTS (SELECT 1 FROM dbo.Posts WHERE Slug=N'khai-truong')
  INSERT INTO dbo.Posts(Title,Slug,Content,IsPublished,CategoryId,CoverImage)
  VALUES (N'Khai trương trang web dòng họ',N'khai-truong',N'Bản tin đầu tiên.',1,(SELECT TOP 1 Id FROM dbo.Categories ORDER BY Id),N'/img/uploads/logo_www.png');
