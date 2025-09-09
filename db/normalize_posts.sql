IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Slug=N'tin-tuc')
  INSERT INTO dbo.Categories(Name,Slug,CreatedAt) VALUES (N'Tin tức',N'tin-tuc',SYSUTCDATETIME());

DECLARE @CatDefault INT = (SELECT TOP 1 Id FROM dbo.Categories WHERE Slug=N'tin-tuc');

-- đảm bảo Categories.Name không NULL/rỗng
UPDATE dbo.Categories SET Name=N'Tin tức'
WHERE Name IS NULL OR LTRIM(RTRIM(Name))=N'';

-- khử NULL/"" các cột chuỗi thường được đọc
UPDATE p
SET  p.CoverImage = COALESCE(NULLIF(p.CoverImage,N''), N'/img/uploads/logo_www.png'),
     p.Content    = COALESCE(p.Content, N''),
     p.Summary    = COALESCE(p.Summary, N'')
FROM dbo.Posts p;

-- bảo đảm CategoryId hợp lệ
UPDATE p
SET  p.CategoryId = @CatDefault
FROM dbo.Posts p
LEFT JOIN dbo.Categories c ON c.Id = p.CategoryId
WHERE p.CategoryId IS NULL OR c.Id IS NULL;

-- sanity check
SELECT TOP 5 Id,Title,Slug,CategoryId,CoverImage,LEFT(Content,40) AS ContentHead,LEFT(Summary,40) AS SummaryHead
FROM dbo.Posts ORDER BY Id;
