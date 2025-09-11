SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ARITHABORT ON;
SET NUMERIC_ROUNDABORT OFF;

-- .jpeg
UPDATE p SET CoverImage = LEFT(CoverImage, CHARINDEX('.jpeg', CoverImage)+5-1)
FROM Posts p
WHERE CHARINDEX('.jpeg', CoverImage) > 0
  AND LEN(CoverImage) > CHARINDEX('.jpeg', CoverImage)+5-1;

-- .jpg
UPDATE p SET CoverImage = LEFT(CoverImage, CHARINDEX('.jpg', CoverImage)+4-1)
FROM Posts p
WHERE CHARINDEX('.jpg', CoverImage) > 0
  AND LEN(CoverImage) > CHARINDEX('.jpg', CoverImage)+4-1;

-- .png
UPDATE p SET CoverImage = LEFT(CoverImage, CHARINDEX('.png', CoverImage)+4-1)
FROM Posts p
WHERE CHARINDEX('.png', CoverImage) > 0
  AND LEN(CoverImage) > CHARINDEX('.png', CoverImage)+4-1;

-- .webp
UPDATE p SET CoverImage = LEFT(CoverImage, CHARINDEX('.webp', CoverImage)+5-1)
FROM Posts p
WHERE CHARINDEX('.webp', CoverImage) > 0
  AND LEN(CoverImage) > CHARINDEX('.webp', CoverImage)+5-1;
