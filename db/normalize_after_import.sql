UPDATE dbo.Persons
SET  BirthDate = NULLIF(BirthDate ,N'NULL'),
     DeathDate = NULLIF(DeathDate ,N'NULL'),
     BirthYear = NULLIF(BirthYear ,N'NULL'),
     DeathYear = NULLIF(DeathYear ,N'NULL');

UPDATE dbo.Posts
SET  CreatedAt = ISNULL(CreatedAt, SYSUTCDATETIME());
