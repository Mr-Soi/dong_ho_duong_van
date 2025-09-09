IF OBJECT_ID('dbo.Posts','U') IS NOT NULL
INSERT INTO dbo.Posts(Title,Slug,Content,CreatedAt,IsPublished)
VALUES (N'Khai trương trang web dòng họ', N'khai-truong', N'Bản tin đầu tiên.', SYSUTCDATETIME(), 1);
