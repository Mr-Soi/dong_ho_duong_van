SET NOCOUNT ON;

-- 1) Vá mojibake
UPDATE dbo.Persons SET DisplayName = REPLACE(DisplayName,N'Ğ',N'Đ') WHERE DisplayName LIKE N'%Ğ%';
UPDATE dbo.Persons SET FullName    = REPLACE(FullName,   N'Ğ',N'Đ') WHERE FullName    LIKE N'%Ğ%';
UPDATE dbo.Persons SET DisplayName = REPLACE(DisplayName,N'Ởi',N'ời') WHERE DisplayName LIKE N'%Ởi%';
UPDATE dbo.Persons SET FullName    = REPLACE(FullName,   N'Ởi',N'ời') WHERE FullName    LIKE N'%Ởi%';

UPDATE dbo.Albums  SET Name = REPLACE(Name,N'hỞc',N'học') WHERE Name LIKE N'%hỞc%';
UPDATE dbo.Albums  SET Name = REPLACE(Name,N' thỞ',N' thờ') WHERE Name LIKE N'% thỞ%';

-- 2) Xóa 'NULL' hiển thị dưới tiêu đề album
UPDATE dbo.Albums SET Description = NULL WHERE Description IN ('NULL','null','NaN','N/A','');

-- 3) Ghi đè FullName nếu là rác dạng giờ
UPDATE dbo.Persons
SET FullName = DisplayName
WHERE FullName IS NULL OR FullName=N''
   OR FullName LIKE N'[0-2][0-9]:[0-5][0-9]%'  -- ví dụ 17:56.0
   OR FullName LIKE N'%.0';
