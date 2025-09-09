-- db/add_isdeleted_posts.sql
ALTER TABLE dbo.Posts
  ADD IsDeleted bit NOT NULL
      CONSTRAINT DF_Posts_IsDeleted DEFAULT(0) WITH VALUES;
