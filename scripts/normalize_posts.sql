USE dhdv;
SET NOCOUNT ON;

-- Trim & chuẩn hoá nhẹ
UPDATE dbo.Posts
SET Title = LTRIM(RTRIM(Title)),
    Summary = LTRIM(RTRIM(Summary)),
    Slug = LOWER(REPLACE(REPLACE(LTRIM(RTRIM(Slug)),' ','-'),'--','-'));

-- PublishedAt bất hợp lệ -> NULL
UPDATE dbo.Posts SET PublishedAt=NULL WHERE PublishedAt<'1900-01-01';

-- Backfill CreatedAt nếu thiếu
UPDATE dbo.Posts SET CreatedAt = ISNULL(CreatedAt, ISNULL(PublishedAt, SYSDATETIME()));

-- Đồng bộ IsPublished theo PublishedAt
UPDATE dbo.Posts SET IsPublished=1 WHERE PublishedAt IS NOT NULL AND IsPublished<>1;
