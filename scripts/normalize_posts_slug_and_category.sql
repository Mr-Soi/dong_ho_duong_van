USE dhdv;
SET NOCOUNT ON;

-- Điền Slug nếu trống (khử dấu cơ bản, thay khoảng trắng = '-')
UPDATE dbo.Posts
SET Slug = LOWER(
            REPLACE(REPLACE(REPLACE(REPLACE(
              REPLACE(CONVERT(varchar(300), Title COLLATE Latin1_General_CI_AI), ' ', '-')
            ,'--','-'),'.',''),',',''),'''','')
          )
WHERE Slug IS NULL OR LTRIM(RTRIM(Slug))='';

-- Thu gọn độ dài
UPDATE dbo.Posts SET Slug = LEFT(Slug,160) WHERE LEN(Slug)>160;

-- Khử trùng Slug bằng cách thêm hậu tố -Id
;WITH d AS (
  SELECT Id, Slug, rn = ROW_NUMBER() OVER (PARTITION BY Slug ORDER BY Id)
  FROM dbo.Posts
)
UPDATE p
SET Slug = p.Slug + '-' + CAST(p.Id AS varchar(10))
FROM dbo.Posts p
JOIN d ON d.Id = p.Id
WHERE d.rn > 1;

-- Đảm bảo duy nhất
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_Posts_Slug' AND object_id=OBJECT_ID('dbo.Posts'))
  CREATE UNIQUE INDEX UX_Posts_Slug ON dbo.Posts(Slug);

-- Điền Category rỗng về 'khac'
DECLARE @catId int;
IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Name=N'Khác')
BEGIN
  INSERT dbo.Categories(Name,Slug) VALUES (N'Khác','khac');
END
SELECT @catId = Id FROM dbo.Categories WHERE Slug='khac';

UPDATE dbo.Posts SET CategoryId = @catId WHERE CategoryId IS NULL;
