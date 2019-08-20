GO
DECLARE @title_ids varchar( 150), @delimiter char
SET @delimiter = ','
SELECT @title_ids = COALESCE(@title_ids + @delimiter, '') + title_id FROM titles
SELECT @title_ids AS [List of Title IDs]