CREATE PROC VKAB_CalcCtrPrcSumOnDate
(
	@ContractID NUMERIC(15, 0),
	@ReportDate SMALLDATETIME = NULL,
	@PrcSum MONEY OUT
)

AS

SET NOCOUNT ON 

DECLARE @s SMALLDATETIME

DECLARE @r SMALLDATETIME

DECLARE @Today SMALLDATETIME
SELECT @Today = CONVERT(SMALLDATETIME, CONVERT(VARCHAR(10), GETDATE(), 112))

 

SET @r = isnull(@ReportDate, @Today)

SELECT @s=dateadd(d, 1, MAX(DatePayModified2)) 
FROM tPaySchedule tps WITH(NOLOCK)
WHERE tps.ContractID = @ContractID
AND version = 0
AND tps.DatePayModified2 < @r
AND tps.ActionType = 4

SELECT @s = ISNULL(@s, @r)



SELECT @PrcSum = sum(ROUND((DATEDIFF(dd, pse.DateStart, case when pse.DateEnd < @r THEN pse.DateEnd ELSE @r END)+1) * pse.Interest / pse.InterestDays * pse.[Value] / 100, 2)) 
FROM tPaySchedule tps WITH(NOLOCK)
INNER JOIN tPayScheduleExt pse WITH(NOLOCK) ON pse.PayScheduleID = tps.PayScheduleID
WHERE tps.ContractID = @ContractID
AND version = 0
AND tps.ActionType = 4
AND tps.DatePayModified2 >= @s
AND pse.DateStart <= @r


GO


GRANT EXEC ON VKAB_CalcCtrPrcSumOnDate TO public

DECLARE @PrcSum MONEY

EXEC VKAB_CalcCtrPrcSumOnDate @ContractID = 2010007422048, @PrcSum = @PrcSum OUT, @ReportDate = '20150421'

SELECT @PrcSum







	
	