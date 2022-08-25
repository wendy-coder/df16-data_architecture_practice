-- declare variables to hold the start and end date
DECLARE @StartDate datetime
DECLARE @EndDate datetime

--- assign values to the start date and end date we 
-- want our reports to cover (this should also take
-- into account any future reporting needs)
SET @StartDate = '2014-01-01'
-- Amending End Date to cater for Ship Date range
SET @EndDate = '2020-12-31' 

IF EXISTS (SELECT * 
			FROM sysobjects 
			WHERE type = 'U' 
			AND ID = OBJECT_ID('[dbo].[DIMDATE]') )
BEGIN
	DROP TABLE [dbo].[DIMDATE]
	PRINT 'Table dropped'
END
CREATE TABLE [DIMDATE](
 Date_Key int IDENTITY(1, 1) PRIMARY KEY,
 [Date] datetime NOT NULL,
 [Year] int NOT NULL, 
 [Month] int NOT NULL,
 [Day] int NOT NULL,
 [Qtr] int NOT NULL,
 [Week] int NOT NULL,
 [CreateDate] datetime NOT NULL,
 [UpdateDate] datetime NOT NULL

)


-- using a while loop increment from the start date 
-- to the end date
DECLARE @LoopDate datetime
SET @LoopDate = @StartDate

WHILE @LoopDate <= @EndDate
BEGIN
 -- add a record into the date dimension table for this date
 INSERT INTO DIMDATE VALUES (
  @LoopDate,
  Year(@LoopDate),
  Month(@LoopDate), 
  Day(@LoopDate), 
  DATEPART(QUARTER,@LoopDate),
  DATEPART(WEEK,@LoopDate),
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
   
 )  
 
 -- increment the LoopDate by 1 day before
 -- we start the loop again
 SET @LoopDate = DateAdd(d, 1, @LoopDate)
END