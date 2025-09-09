-- Chuẩn hóa CreatedAt trước
UPDATE p
SET p.CreatedAt = SYSUTCDATETIME()
FROM dbo.Posts p
WHERE p.CreatedAt IS NULL OR p.CreatedAt < '1950-01-01';

-- Sau đó chuẩn hóa PublishedAt
UPDATE p
SET p.PublishedAt = COALESCE(NULLIF(p.PublishedAt,'1900-01-01'), p.CreatedAt, SYSUTCDATETIME())
FROM dbo.Posts p
WHERE p.PublishedAt IS NULL OR p.PublishedAt < '1950-01-01';

-- Kiểm tra nhanh
SELECT TOP 3 Id, Title, PublishedAt, CreatedAt FROM dbo.Posts ORDER BY CreatedAt DESC;
