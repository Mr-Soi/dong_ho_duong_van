
USE don7069c_dongho;
GO
CREATE OR ALTER VIEW dbo.vw_PostsForImport AS
SELECT
  p.Post_ID,
  Title       = LTRIM(RTRIM(p.Tenbai)),
  Summary     = p.TrichYeu,
  Content     = p.Noidung,
  PublishedAt = p.Ngaydang,
  UpdatedAt   = p.Ngaydang,
  IsPublished = CAST(CASE WHEN p.Ngaydang IS NULL THEN 0 ELSE 1 END AS bit),
  Category    = lt.Loaitin
FROM dbo.Post p
LEFT JOIN dbo.LoaiTin lt ON lt.Loaitin_ID = p.Loaitin_ID
WHERE p.Tenbai IS NOT NULL AND LTRIM(RTRIM(p.Tenbai)) <> '';
