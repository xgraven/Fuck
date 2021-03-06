
/****** Object:  StoredProcedure [dbo].[VKAB_GenRefinInitDoc]    Script Date: 04/09/2015 15:25:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[VKAB_GenRefinDocs] (
      @ContractID NUMERIC(15, 0)
,     @LoanQty MONEY
,     @PrcQty MONEY
,     @OperDate SMALLDATETIME
,     @Status INT
)
AS

SET NOCOUNT ON 



DECLARE @DealID NUMERIC(15, 0)
DECLARE @ClientName VARCHAR(100)
DECLARE 	@Number VARCHAR(100)

DECLARE @AllQty MONEY

SET @AllQty = @LoanQty + @PrcQty

SELECT @DealID = @ContractID, @Number = Number, @ClientName = case when i.PropdealPart = 1 then i.Name else i.Name + ' ' +  i.Name1+ ' ' + i.Name2 END  
FROM tCOntract c WITH (NOLOCK)
INNER JOIN tInstitution i  WITH (NOLOCK) ON i.InstitutionID = c.InstitutionID  
WHERE ContractID = @ContractID

IF ISNULL(@DealID, 0) = 0 RETURN

DECLARE @Acc1 VARCHAR(35)
DECLARE @Acc2 VARCHAR(35)
DECLARE @Acc3 VARCHAR(35)
DECLARE @Acc4 VARCHAR(35)

SELECT @Acc1 = r.Brief FROM 
tConsAccountLInk  al  WITH (NOLOCK) 
INNER JOIN tTypeAccLink tal  WITH (NOLOCK) ON tal.TypeAccLinkID = al.RuleID
INNER JOIN tResource r  WITH (NOLOCK) ON r.ResourceID = al.ResourceID
WHERE al.ContractID = @DealID
AND tal.Brief = 'КуплКрТреб'

SELECT @Acc2 = r.Brief FROM 
tConsAccountLInk  al  WITH (NOLOCK) 
INNER JOIN tTypeAccLink tal  WITH (NOLOCK) ON tal.TypeAccLinkID = al.RuleID
INNER JOIN tResource r  WITH (NOLOCK) ON r.ResourceID = al.ResourceID
WHERE al.ContractID = @DealID
AND tal.Brief = 'Ц_47801_ПРЦ'

SELECT @Acc3 = r.Brief FROM 
tConsAccountLInk  al  WITH (NOLOCK) 
INNER JOIN tTypeAccLink tal  WITH (NOLOCK) ON tal.TypeAccLinkID = al.RuleID
INNER JOIN tResource r  WITH (NOLOCK) ON r.ResourceID = al.ResourceID
WHERE al.ContractID = @DealID
AND tal.Brief = 'КуплСрСсЗд'

SELECT @Acc4 = r.Brief FROM 
tConsAccountLInk  al  WITH (NOLOCK) 
INNER JOIN tTypeAccLink tal  WITH (NOLOCK) ON tal.TypeAccLinkID = al.RuleID
INNER JOIN tResource r  WITH (NOLOCK) ON r.ResourceID = al.ResourceID
WHERE al.ContractID = @DealID
AND tal.Brief = 'КуплСрПрц'

DECLARE @Num VARCHAR(20)



DECLARE @CommentOD VARCHAR(210)
SET @CommentOD = 'выкуп основного долга по кредиту ' + @Number  + ' ' + @ClientName

DECLARE @CommentPrc VARCHAR(210)
SET @CommentPrc = 'выкуп процентов по кредиту ' + @Number  + ' ' + @ClientName


SELECT @Acc1, @Acc2, @Acc3, @Acc4
SELECT @CommentOD


 DECLARE @DtID NUMERIC (15, 0)
 DECLARE @RetMsg VARCHAR(255)
 
 SELECT @Num = RIGHT(RTRIM(LTRIM(@Acc1)), 3)
 EXEC VKAB_1CInsertCashDoc5 @FO = 1558, @DocStatus = @Status
 , @Batch = 'Кр1_Оп1', 
 @DebAcc = @Acc1, 
 @CreAcc = '47422810000000000897', 
 @VidOper = 9, @DocNum = @Num, @DocSum = @AllQty, @OperDate = @OperDate, @Sum1 = @AllQty,
 @NaznText=@CommentOD , @DealTransactID = @DtID OUT, @RetMsg = @RetMsg OUT
 
 SELECT @DtID, @RetMsg
 
 /*
 
 SELECT * FROM tDeal WITH (NOLOCK) WHERE DealID = @DealID
 SELECT * FROM tDealTransact  WITH (NOLOCK)  WHERE DealTransactID = @DtID
 
 
 
 declare
  @RetVal int,
  @ADLinkID DSIDENTIFIER,
  @SignQty int,
  @AccrualDetailID DSIDENTIFIER
  

  
select @SignQty = sign(1)
exec @RetVal = ADLink_Fix_Insert
  @ADLinkID = @ADLinkID output,
  @AccrualDetailID = @AccrualDetailID output,
  @DealID   = @DealID,
  @Mode     = 106,
  @DateFix  = @OperDate,
  @ObjectID = @DtID,
  @Qty      = @LoanQty,
  @Date     = @OperDate,
  @AccrDate = @OperDate,
  @SignQty = @SignQty,
  @PayDate = @OperDate
  
select @RetVal, @ADLinkID, @AccrualDetailID


exec @RetVal = ADLink_Doc_Link
                 @ADLinkID       = @ADLinkID,
                 @DealTransactID = @DtID,
                 @Method         = 2
select @RetVal

*/

/*
declare @RetVal int,
        @DocNeed int

exec @RetVal = ADLink_RestoreLimit
                 @ADLinkID       = 2010001062566,
                 @DealTransactID = 20@Status39419730,
                 @DocNeed        = @DocNeed output
select @RetVal,
       @DocNeed
*/
 
 /*
  SELECT @Num = RIGHT(RTRIM(LTRIM(@Acc2)), 3)
 EXEC VKAB_1CInsertCashDoc5 @FO = 1558, @DocStatus = @Status
 , @Batch = 'Кр1_Оп1', 
 @DebAcc = @Acc2, 
 @CreAcc = '47422810000000000897', 
 @VidOper = 9, @DocNum = @Num, @DocSum = @PrcQty, @OperDate = @OperDate, @Sum1 = @PrcQty, 
 @NaznText=@CommentPrc , @DealTransactID = @DtID OUT, @RetMsg = @RetMsg OUT
 
 SELECT @DtID, @RetMsg
 */
 
 SELECT @Num = RIGHT(RTRIM(LTRIM(@Acc3)), 3)
 EXEC VKAB_1CInsertCashDoc5 @FO = 1303, @DocStatus = @Status
 , @Batch = 'Кр3_Оп1', 
 @DebAcc = @Acc3, 
 @CreAcc = '99999810200000000000', 
 @VidOper = 9, @DocNum = @Num, @DocSum = @LoanQty, @OperDate = @OperDate, @Sum1 = @LoanQty,
 @NaznText=@CommentOD , @DealTransactID = @DtID OUT, @RetMsg = @RetMsg OUT
 
 SELECT @DtID, @RetMsg

 SELECT @Num = RIGHT(RTRIM(LTRIM(@Acc4)), 3)
 EXEC VKAB_1CInsertCashDoc5 @FO = 1303, @DocStatus = @Status
 , @Batch = 'Кр3_Оп1', 
 @DebAcc = @Acc4, 
 @CreAcc = '99999810200000000000', 
 @VidOper = 9, @DocNum = @Num, @DocSum = @PrcQty, @OperDate = @OperDate, @Sum1 = @PrcQty,
 @NaznText=@CommentPrc , @DealTransactID = @DtID OUT, @RetMsg = @RetMsg OUT
 
 SELECT @DtID, @RetMsg
 

GO

GRANT EXEC ON [VKAB_GenRefinDocs] TO public

