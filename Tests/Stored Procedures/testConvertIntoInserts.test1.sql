create procedure testConvertIntoInserts.test1
as
begin
    SET NOCOUNT ON;
--- Arrange
    delete from stt.invoice;
	insert into stt.invoice (inv_id, inv_type, inv_cust_id, inv_amount, inv_date, inv_error) values
    (1, 'FV', 'ABCDE12345', 100.00, '2021-11-27', NULL),
    (2, 'FV1', 'Zażółć gęślą jaźń', -1.00, '2021-11-28', NULL),
    (3, 'FV2', 'qwerty asdfgh zxcvb', 1234.56, '2021-11-29', '?'),
    (4, 'A', 'ABCDE12345', 0.00, NULL, 'An error occurred');

--- Act
	declare @Actual nvarchar(max);

	exec tSQLtHelper.ConvertIntoInserts
		@TableName = 'stt.invoice',
		@Query = 'select inv_id, inv_type, inv_cust_id, inv_amount, inv_date, inv_error from stt.invoice',
		@Result = @Actual output;

--- Assert
	declare @expected nvarchar(max) = 'insert into stt.invoice (inv_id, inv_type, inv_cust_id, inv_amount, inv_date, inv_error) values
    (1, ''FV '',          ''ABCDE12345'',  100.00, ''2021-11-27'', NULL),
    (2, ''FV1'',   ''Zażółć gęślą jaźń'',   -1.00, ''2021-11-28'', NULL),
    (3, ''FV2'', ''qwerty asdfgh zxcvb'', 1234.56, ''2021-11-29'', ''?''),
    (4, ''A  '',          ''ABCDE12345'',    0.00,         NULL, ''An error occurred'');';

    set @expected = replace(@expected, char(13) + char(10), char(10));
    set @Actual = replace(@Actual, char(13) + char(10), char(10));

	if not((@expected = @Actual) or (@Actual is null and @expected is null))
    begin
        DECLARE @Msg NVARCHAR(MAX) = CHAR(13)+CHAR(10)+
                  'Expected: ' + ISNULL('<'+@Expected+'>', 'NULL') +
                  CHAR(13)+CHAR(10)+
                  'but was : ' + ISNULL('<'+@Actual+'>', 'NULL');
        PRINT @Msg;
        RAISERROR('testConvertIntoInserts.test1 - failed!', 16, 10);
    end
    else
    begin
        print 'testConvertIntoInserts.test1 - passed'
    end
end;
go