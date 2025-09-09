USE dhdv;
SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#g') IS NOT NULL DROP TABLE #g;
SELECT NameNorm, MinId = MIN(Id)
INTO #g
FROM dbo.Categories
GROUP BY NameNorm
HAVING COUNT(*)>1;

-- Chuyển tham chiếu Post về id nhỏ nhất
UPDATE p SET CategoryId = g.MinId
FROM dbo.Posts p
JOIN dbo.Categories c ON c.Id = p.CategoryId
JOIN #g g ON g.NameNorm = c.NameNorm
WHERE p.CategoryId <> g.MinId;

-- Xoá bản ghi Category trùng
DELETE c
FROM dbo.Categories c
JOIN #g g ON g.NameNorm = c.NameNorm
WHERE c.Id <> g.MinId;

-- (tuỳ chọn) chặn trùng trong tương lai theo NameNorm
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_Categories_NameNorm' AND object_id=OBJECT_ID('dbo.Categories'))
  CREATE UNIQUE INDEX UX_Categories_NameNorm ON dbo.Categories(NameNorm);
