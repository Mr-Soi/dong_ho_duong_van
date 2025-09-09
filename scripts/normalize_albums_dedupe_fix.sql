USE dhdv;
SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#g') IS NOT NULL DROP TABLE #g;
SELECT TitleNorm, MinId = MIN(Id)
INTO #g
FROM dbo.Albums
GROUP BY TitleNorm
HAVING COUNT(*)>1;

-- Chuyển ảnh về album chuẩn
UPDATE p SET AlbumId = g.MinId
FROM dbo.Photos p
JOIN dbo.Albums a ON a.Id = p.AlbumId
JOIN #g g ON g.TitleNorm = a.TitleNorm
WHERE p.AlbumId <> g.MinId;

-- Xoá album trùng
DELETE a
FROM dbo.Albums a
JOIN #g g ON g.TitleNorm = a.TitleNorm
WHERE a.Id <> g.MinId;

-- Đảm bảo duy nhất
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_Albums_TitleNorm' AND object_id=OBJECT_ID('dbo.Albums'))
  CREATE UNIQUE INDEX UX_Albums_TitleNorm ON dbo.Albums(TitleNorm);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_Albums_Slug' AND object_id=OBJECT_ID('dbo.Albums'))
  CREATE UNIQUE INDEX UX_Albums_Slug ON dbo.Albums(Slug);
