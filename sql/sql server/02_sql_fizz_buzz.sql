DECLARE @counter varchar(5)  SET @counter = 1
WHILE @counter < 101  BEGIN
     PRINT case when @counter % 3 = 0
                     and @counter % 5 != 0 THEN 'Fizz'
                WHEN @counter % 3 != 0
                     AND @counter % 5 = 0 THEN 'Buzz'
                when @counter % 3 = 0
                     and @counter % 5 = 0 then 'FizzBuzz'
                else @counter
           end
SET @counter = @counter + 1
END
