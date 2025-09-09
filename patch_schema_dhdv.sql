-- Persons: tạo nếu thiếu + bổ sung cột
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Persons')
BEGIN
    CREATE TABLE dbo.Persons(
        PersonId   INT IDENTITY(1,1) PRIMARY KEY,
        LastName   NVARCHAR(50)  NOT NULL,
        MiddleName NVARCHAR(50)  NULL,
        FirstName  NVARCHAR(50)  NOT NULL,
        FullName   NVARCHAR(150) NULL,
        Gender     BIT           NULL,
        BirthDate  DATE          NULL,
        DeathDate  DATE          NULL,
        BirthPlace NVARCHAR(255) NULL,
        FatherId   INT           NULL,
        MotherId   INT           NULL
    );
END;
IF COL_LENGTH('dbo.Persons','FullName')   IS NULL ALTER TABLE dbo.Persons ADD FullName   NVARCHAR(150) NULL;
IF COL_LENGTH('dbo.Persons','BirthPlace') IS NULL ALTER TABLE dbo.Persons ADD BirthPlace NVARCHAR(255) NULL;
IF COL_LENGTH('dbo.Persons','FatherId')   IS NULL ALTER TABLE dbo.Persons ADD FatherId   INT NULL;
IF COL_LENGTH('dbo.Persons','MotherId')   IS NULL ALTER TABLE dbo.Persons ADD MotherId   INT NULL;

-- Categories: tạo nếu thiếu
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Categories')
BEGIN
    CREATE TABLE dbo.Categories(
        CategoryId  INT IDENTITY(1,1) PRIMARY KEY,
        Name        NVARCHAR(100) NOT NULL,
        Description NVARCHAR(255) NULL
    );
END;

-- Albums: tạo nếu thiếu
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Albums')
BEGIN
    CREATE TABLE dbo.Albums(
        AlbumId     INT IDENTITY(1,1) PRIMARY KEY,
        Title       NVARCHAR(200) NOT NULL,
        Description NVARCHAR(500) NULL
    );
END;

-- Photos: tạo nếu thiếu
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Photos')
BEGIN
    CREATE TABLE dbo.Photos(
        PhotoId  INT IDENTITY(1,1) PRIMARY KEY,
        AlbumId  INT           NULL,
        FileName NVARCHAR(255) NOT NULL,
        Caption  NVARCHAR(255) NULL
    );
END;

-- Posts: tạo nếu thiếu + bổ sung cột
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Posts')
BEGIN
    CREATE TABLE dbo.Posts(
        PostId        INT IDENTITY(1,1) PRIMARY KEY,
        Title         NVARCHAR(200) NOT NULL,
        Content       NVARCHAR(MAX) NULL,
        CategoryId    INT           NULL,
        PublishedDate DATETIME      NULL,
        IsDeleted     BIT           NOT NULL DEFAULT(0)
    );
END;
IF COL_LENGTH('dbo.Posts','CategoryId')    IS NULL ALTER TABLE dbo.Posts ADD CategoryId    INT NULL;
IF COL_LENGTH('dbo.Posts','PublishedDate') IS NULL ALTER TABLE dbo.Posts ADD PublishedDate DATETIME NULL;
IF COL_LENGTH('dbo.Posts','IsDeleted')     IS NULL ALTER TABLE dbo.Posts ADD IsDeleted     BIT NOT NULL DEFAULT(0);

-- FK Persons -> Persons (Father/Mother)
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_Persons_Father' AND parent_object_id=OBJECT_ID('dbo.Persons'))
    ALTER TABLE dbo.Persons ADD CONSTRAINT FK_Persons_Father FOREIGN KEY (FatherId) REFERENCES dbo.Persons(PersonId);
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_Persons_Mother' AND parent_object_id=OBJECT_ID('dbo.Persons'))
    ALTER TABLE dbo.Persons ADD CONSTRAINT FK_Persons_Mother FOREIGN KEY (MotherId) REFERENCES dbo.Persons(PersonId);

-- FK Posts -> Categories
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_Posts_Category' AND parent_object_id=OBJECT_ID('dbo.Posts'))
    ALTER TABLE dbo.Posts ADD CONSTRAINT FK_Posts_Category FOREIGN KEY (CategoryId) REFERENCES dbo.Categories(CategoryId);

-- FK Photos -> Albums
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_Photos_Album' AND parent_object_id=OBJECT_ID('dbo.Photos'))
    ALTER TABLE dbo.Photos ADD CONSTRAINT FK_Photos_Album FOREIGN KEY (AlbumId) REFERENCES dbo.Albums(AlbumId);
