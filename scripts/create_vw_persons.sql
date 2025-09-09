
USE don7069c_dongho;
GO
CREATE OR ALTER VIEW dbo.vw_PersonsForImport AS
SELECT
  LegacyId = cg.TreeID,
  DisplayName = LTRIM(RTRIM(cg.Ten)),
  Alias = NULLIF(LTRIM(RTRIM(cg.TenKhac)), N''),
  Generation = cg.Doi,
  Branch = NULLIF(LTRIM(RTRIM(cg.Nganh)), N''),
  BirthDate = COALESCE(
    CASE WHEN cg.NgaySinh LIKE '[0-3][0-9]/[0-1][0-9]/[12][0-9][0-9][0-9]' THEN CONVERT(date,cg.NgaySinh,103) END,
    CASE WHEN cg.NgaySinh LIKE '[0-3][0-9]-[0-1][0-9]-[12][0-9][0-9][0-9]' THEN CONVERT(date,cg.NgaySinh,105) END,
    CASE WHEN cg.NgaySinh LIKE '[12][0-9][0-9][0-9]%' THEN CONVERT(date,LEFT(cg.NgaySinh,4)+'-01-01',120) END
  ),
  DeathDate = COALESCE(
    CASE WHEN cg.NgayMat LIKE '[0-3][0-9]/[0-1][0-9]/[12][0-9][0-9][0-9]' THEN CONVERT(date,cg.NgayMat,103) END,
    CASE WHEN cg.NgayMat LIKE '[0-3][0-1][0-9]-[12][0-9][0-9][0-9]' THEN CONVERT(date,cg.NgayMat,105) END,
    CASE WHEN cg.NgayMat LIKE '[12][0-9][0-9][0-9]%' THEN CONVERT(date,LEFT(cg.NgayMat,4)+'-01-01',120) END
  )
FROM dbo.CayGiaPha cg
WHERE cg.Ten IS NOT NULL AND LTRIM(RTRIM(cg.Ten))<>N'';
