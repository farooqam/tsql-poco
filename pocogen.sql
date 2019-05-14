declare @tableName varchar(200)
declare @columnName varchar(200)
declare @nullable varchar(50)
declare @datatype varchar(50)
declare @maxlen int

declare @sType varchar(50)
declare @sProperty varchar(200)

DECLARE table_cursor CURSOR FOR 
SELECT TABLE_NAME
FROM [INFORMATION_SCHEMA].[TABLES]
WHERE TABLE_NAME = 'ModelScoreSensorXPhantomValidationAnalysisResult_View'

OPEN table_cursor

FETCH NEXT FROM table_cursor 
INTO @tableName

WHILE @@FETCH_STATUS = 0
BEGIN

PRINT 'public class ' + @tableName + ' {'

    DECLARE column_cursor CURSOR FOR 
    SELECT COLUMN_NAME, IS_NULLABLE, DATA_TYPE, isnull(CHARACTER_MAXIMUM_LENGTH,'-1') 
  from [INFORMATION_SCHEMA].[COLUMNS] 
       WHERE [TABLE_NAME] = @tableName
       order by [ORDINAL_POSITION]

    OPEN column_cursor
    FETCH NEXT FROM column_cursor INTO @columnName, @nullable, @datatype, @maxlen

    WHILE @@FETCH_STATUS = 0
    BEGIN

       -- datatype
       select @sType = case @datatype
       when 'int' then 'int'
       when 'decimal' then 'decimal'
       when 'money' then 'decimal'
       when 'char' then 'char'
       when 'nchar' then 'char'
       when 'varchar' then 'string'
       when 'nvarchar' then 'string'
       when 'uniqueidentifier' then 'Guid'
       when 'datetime' then 'DateTime'
       when 'datetime2' then 'DateTime'
       when 'bit' then 'bool'
       when 'float' then 'double'
       else 'string'
       END

              --If (@nullable = 'NO')
              --       PRINT '[Required]'
              --if (@sType = 'string' and @maxLen <> '-1')
              --       Print '[MaxLength(' +  convert(varchar(4),@maxLen) + ')]'
			  declare @q varchar(2) = ' ';
			  If (@sType <> 'string' and @nullable = 'YES')
				SET @q = '? '
              
			  SELECT @sProperty = 'public ' + @sType + @q + @columnName + ' { get; set;}'
              PRINT @sProperty

              --print ''
              FETCH NEXT FROM column_cursor INTO @columnName, @nullable, @datatype, @maxlen
       END
    CLOSE column_cursor
    DEALLOCATE column_cursor

       print '}'
       print ''
    FETCH NEXT FROM table_cursor 
    INTO @tableName
END
CLOSE table_cursor
DEALLOCATE table_cursor
