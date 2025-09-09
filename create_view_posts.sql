SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
IF OBJECT_ID('dbo.Posts','V') IS NOT NULL DROP VIEW dbo.Posts;
DECLARE @cols nvarchar(max)=
  STUFF((SELECT ','+QUOTENAME(name)
         FROM sys.columns
         WHERE object_id=OBJECT_ID('dbo.Posts_big') AND name<>'Id'
         ORDER BY column_id
         FOR XML PATH(''),TYPE).value('.','nvarchar(max)'),1,1,'');
DECLARE @sql nvarchar(max)=N'CREATE VIEW dbo.Posts AS SELECT CAST(Id AS int) AS Id,'+@cols+N' FROM dbo.Posts_big;';
EXEC(@sql);
