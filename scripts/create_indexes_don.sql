IF OBJECT_ID(N'dbo.Post','U') IS NOT NULL AND COL_LENGTH(N'dbo.Post','NgayTao') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Post_NgayTao' AND object_id=OBJECT_ID(N'dbo.Post'))
  CREATE INDEX IX_Post_NgayTao ON dbo.Post(NgayTao);

IF OBJECT_ID(N'dbo.Post','U') IS NOT NULL AND COL_LENGTH(N'dbo.Post','LoaiTinId') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Post_LoaiTinId' AND object_id=OBJECT_ID(N'dbo.Post'))
  CREATE INDEX IX_Post_LoaiTinId ON dbo.Post(LoaiTinId);
