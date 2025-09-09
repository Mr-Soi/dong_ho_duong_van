-- 1) Thêm cột tạm kiểu DATETIME2
IF COL_LENGTH('dbo.Persons','BirthDate2') IS NULL ALTER TABLE dbo.Persons ADD BirthDate2 DATETIME2 NULL;
IF COL_LENGTH('dbo.Persons','DeathDate2') IS NULL ALTER TABLE dbo.Persons ADD DeathDate2 DATETIME2 NULL;

-- 2) Đổ dữ liệu: parse được thì lấy, không được thì dùng '1900-01-01' (tránh null nếu model không nullable)
UPDATE dbo.Persons
SET BirthDate2 = COALESCE(TRY_CONVERT(datetime2, NULLIF(REPLACE(BirthDate ,N'NULL',N''),N'')), CONVERT(datetime2,'1900-01-01')),
    DeathDate2 = COALESCE(TRY_CONVERT(datetime2, NULLIF(REPLACE(DeathDate ,N'NULL',N''),N'')), CONVERT(datetime2,'1900-01-01'));

-- 3) Đổi cột: drop cũ, rename mới sang tên gốc
ALTER TABLE dbo.Persons DROP COLUMN BirthDate, DeathDate;
EXEC sp_rename 'dbo.Persons.BirthDate2','BirthDate','COLUMN';
EXEC sp_rename 'dbo.Persons.DeathDate2','DeathDate','COLUMN';

-- 4) Sanity check
SELECT TOP 3 Id, FullName, BirthDate, DeathDate FROM dbo.Persons ORDER BY Id;
