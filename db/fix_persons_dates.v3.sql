SET XACT_ABORT ON;
BEGIN TRAN;

-- Tạo cột tạm (viết 1 dòng, tránh gãy tên)
IF COL_LENGTH('dbo.Persons','BirthDate2') IS NULL EXEC('ALTER TABLE dbo.Persons ADD BirthDate2 DATETIME2 NULL');
IF COL_LENGTH('dbo.Persons','DeathDate2') IS NULL EXEC('ALTER TABLE dbo.Persons ADD DeathDate2 DATETIME2 NULL');

-- Đổ dữ liệu từ cột cũ (kể cả NVARCHAR lẫn DATETIME)
UPDATE dbo.Persons
SET BirthDate2 =
      COALESCE(
        TRY_CONVERT(datetime2, NULLIF(REPLACE(CAST(BirthDate AS nvarchar(4000)),N'NULL',N''),N'')),
        CONVERT(datetime2,'1900-01-01')
      ),
    DeathDate2 =
      COALESCE(
        TRY_CONVERT(datetime2, NULLIF(REPLACE(CAST(DeathDate AS nvarchar(4000)),N'NULL',N''),N'')),
        CONVERT(datetime2,'1900-01-01')
      );

-- Ép NOT NULL (nếu model không nullable)
ALTER TABLE dbo.Persons ALTER COLUMN BirthDate2 DATETIME2 NOT NULL;
ALTER TABLE dbo.Persons ALTER COLUMN DeathDate2 DATETIME2 NOT NULL;

-- Bỏ cột cũ và đổi tên cột mới về tên gốc
IF COL_LENGTH('dbo.Persons','BirthDate') IS NOT NULL ALTER TABLE dbo.Persons DROP COLUMN BirthDate;
IF COL_LENGTH('dbo.Persons','DeathDate') IS NOT NULL ALTER TABLE dbo.Persons DROP COLUMN DeathDate;

EXEC sp_rename 'dbo.Persons.BirthDate2','BirthDate','COLUMN';
EXEC sp_rename 'dbo.Persons.DeathDate2','DeathDate','COLUMN';

COMMIT;

-- Kiểm tra
SELECT TOP 3 Id, FullName, BirthDate, DeathDate FROM dbo.Persons ORDER BY Id;
