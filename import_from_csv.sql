/* import_from_csv.sql */
SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

/* 0) Làm sạch staging */
TRUNCATE TABLE dbo._stg_Persons;
TRUNCATE TABLE dbo._stg_Albums;
TRUNCATE TABLE dbo._stg_Photos;

/* 1) Persons.csv
   Header thực tế: Id,DisplayName,Alias,BirthDate,DeathDate,Generation,Branch,CreatedAt,...
   -> FullName = ưu tiên DisplayName / DisplayNameNorm / NameNorm / FullNameNorm
   -> FatherId, MotherId, BirthPlace chưa có trong CSV -> để NULL
*/
INSERT dbo._stg_Persons (Id, FullName, FatherId, MotherId, BirthDate, BirthPlace)
SELECT
    TRY_CONVERT(int, [Id]) AS Id,
    NULLIF(
      COALESCE([DisplayName], [DisplayNameNorm], [NameNorm], [FullNameNorm]), ''
    ) AS FullName,
    CAST(NULL AS int)  AS FatherId,
    CAST(NULL AS int)  AS MotherId,
    TRY_CONVERT(date, [BirthDate]) AS BirthDate,
    CAST(NULL AS nvarchar(200)) AS BirthPlace
FROM OPENROWSET(
    BULK '/tmp/import/Persons.csv',
    FORMAT = 'CSV',
    PARSER_VERSION = '2.0',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    FIELDQUOTE = '"'
) WITH (
    [Id]              nvarchar(50),
    [DisplayName]     nvarchar(200),
    [Alias]           nvarchar(200),
    [BirthDate]       nvarchar(50),
    [DeathDate]       nvarchar(50),
    [Generation]      nvarchar(50),
    [Branch]          nvarchar(50),
    [CreatedAt]       nvarchar(50),
    [UpdatedAt]       nvarchar(50),
    [CreatedBy]       nvarchar(100),
    [UpdatedBy]       nvarchar(100),
    [FullNameNorm]    nvarchar(200),
    [AliasNorm]       nvarchar(200),
    [BiirthYear]      nvarchar(50),      -- đúng chính tả header hiện có
    [DeathYear]       nvarchar(50),
    [LegacyId]        nvarchar(50),
    [DisplayNameNorm] nvarchar(200),
    [YearOfBirth]     nvarchar(50),
    [YearOfDeath]     nvarchar(50),
    [IsDeleted]       nvarchar(50),
    [NameNorm]        nvarchar(200)
) AS R;

/* 2) Albums.csv
   Header: Id,Title,Slug,Description,CreatedAt,UpdatedAt,IsDeleted,TitleNorm
   -> Lấy 4 cột cần thiết cho staging
*/
INSERT dbo._stg_Albums (Id, Title, Slug, Description)
SELECT
    TRY_CONVERT(int, [Id]) AS Id,
    NULLIF([Title], '') AS Title,
    NULLIF([Slug],  '') AS Slug,
    NULLIF([Description], '') AS Description
FROM OPENROWSET(
    BULK '/tmp/import/Albums.csv',
    FORMAT = 'CSV',
    PARSER_VERSION = '2.0',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    FIELDQUOTE = '"'
) WITH (
    [Id]          nvarchar(50),
    [Title]       nvarchar(300),
    [Slug]        nvarchar(160),
    [Description] nvarchar(1000),
    [CreatedAt]   nvarchar(50),
    [UpdatedAt]   nvarchar(50),
    [IsDeleted]   nvarchar(50),
    [TitleNorm]   nvarchar(300)
) AS R;

/* 3) Photos.csv
   Header: Id,AlbumId,Url,Caption,TakenAt
   -> Map Url -> FileName trong staging (khi MERGE có thể dùng làm Url)
*/
INSERT dbo._stg_Photos (Id, AlbumId, FileName, Caption, TakenAt)
SELECT
    TRY_CONVERT(int, [Id])      AS Id,
    TRY_CONVERT(int, [AlbumId]) AS AlbumId,
    NULLIF([Url], '')           AS FileName,
    NULLIF([Caption], '')       AS Caption,
    TRY_CONVERT(datetime, [TakenAt]) AS TakenAt
FROM OPENROWSET(
    BULK '/tmp/import/Photos.csv',
    FORMAT = 'CSV',
    PARSER_VERSION = '2.0',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    FIELDQUOTE = '"'
) WITH (
    [Id]       nvarchar(50),
    [AlbumId]  nvarchar(50),
    [Url]      nvarchar(500),
    [Caption]  nvarchar(500),
    [TakenAt]  nvarchar(50)
) AS R;

/* kiểm tra nhanh */
SELECT (SELECT COUNT(*) FROM dbo._stg_Persons) AS _Persons,
       (SELECT COUNT(*) FROM dbo._stg_Albums)  AS _Albums,
       (SELECT COUNT(*) FROM dbo._stg_Photos)  AS _Photos;
