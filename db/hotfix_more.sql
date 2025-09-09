SET NOCOUNT ON;
UPDATE dbo.Albums  SET Description = NULL WHERE Description IN ('NULL','null','NaN','N/A','');
UPDATE dbo.Persons SET FullName=DisplayName
WHERE FullName IS NULL OR FullName=N'' OR FullName LIKE N'[0-2][0-9]:[0-5][0-9]%' OR FullName LIKE N'%.0';
