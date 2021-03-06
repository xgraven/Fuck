
GO
/****** Object:  StoredProcedure [dbo].[VKAB_CreateRefinContractIpoteka]    Script Date: 04/08/2015 15:50:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/************************************************************
 * Code formatted by SoftTree SQL Assistant © v6.2.107
 * Time: 16.01.2013 15:06:00
 ************************************************************/

ALTER PROC [dbo].[VKAB_CreateRefinContract](
                                                       @pCreditNumber VARCHAR(50)
                                                      ,@pInstrumentID NUMERIC(15 ,0)
                                                      ,@pBranchID  NUMERIC(15 ,0)
										    ,@pOperDate SMALLDATETIME	 
                                                      ,@pClientID  NUMERIC(15 ,0)
                                                      ,@pDateFrom SMALLDATETIME
                                                      ,@pDateTo SMALLDATETIME
                                                      ,@pPayDay INT
                                                      ,@pAmount MONEY
                                                      ,@pAmountPrc MONEY
                                                      ,@pAnnQty MONEY
                                                      ,@pPrcRate MONEY
                                                      ,@pFineRateLoan MONEY
                                                      ,@pFineRatePrc MONEY

                                                      ,@pRetMessage VARCHAR(255) OUTPUT
                                                      ,@pContractID NUMERIC(15 ,0) OUTPUT
                                                   )

AS 

SET NOCOUNT ON 


/*DECLARE @pCreditNumber VARCHAR(50)

DECLARE @pProduct      VARCHAR(50)
       ,@pDateFrom     SMALLDATETIME
       ,@pDateTo       SMALLDATETIME

       ,@pPayDay       INT
       ,@pAmount       MONEY
       ,@pAnnQty       MONEY
       ,@pPrcRate      MONEY
       ,@pBaloon       MONEY*/

--@pDate = '20141205', @pNumber = 'КПФ/46/03-11/02', @pTerm = 0, @pFinalDate = '20310830', @pQty = 724722.01, @pAnnQty = 8127.83, @pPrcQty = 1100, @pPrcRate = 11.50
--, @pLoanFineRate = 730, @pPrcFineRate = 73

/*
SELECT 
	@pCreditNumber = 'КПФ/61/05-06/02'
       
SELECT @pDateFrom = '20141130'
SELECT @pDateTo = '20180831'
SELECT @pAmount = 176700.64
SELECT @pPrcRate = 12
SELECT @pPayDay = 31 
SELECT @pAnnQty = 4894.89
     
SELECT @pBaloon = 0  
*/

DECLARE        @pTerm         INT
SELECT @pTerm = DATEDIFF(dd, @pDateFrom, @pDateTo)
DECLARE @pBaloon MONEY
SET @pBaloon = 0 


DECLARE @OldID NUMERIC(15, 0)
, @ClientID NUMERIC(15, 0)
, @ClientID2 NUMERIC(15, 0)
, @ContractGroupID NUMERIC(15, 0)
, @DealID NUMERIC(15, 0)
, @ProductID NUMERIC(15, 0)

--SELECT @OldID = ContractID, @ClientID = c.InstitutionID, @ContractGroupID = c.ContractGroupID, @ProductID = c.BankProductID
--FROM tContract c  WITH (NOLOCK)  WHERE c.Number = @pCreditNumber

SELECT @ProductID = 2010000000141
SELECT @ClientID = @pClientID

--SELECT @DealID = DealID FROM tDeal WITH (NOLOCK) WHERE Number = @pCreditNumber AND InstrumentID = 2010000000186
  
--SELECT @OldID, @ClientID, @ContractGroupID, @ProductID, @DealID  

/*
DECLARE @pRetMessage NVARCHAR(255)
,@pContractID NUMERIC(15,0)

*/

DECLARE @RetVal     INT
,       @ID         DSIDENTIFIER



SELECT @ID = 0, @pContractID = 0, @RetVal = 0, @pRetMessage = ''

-- поиски, настройка параметров
DECLARE 
        @BranchID      NUMERIC(15 , 0)

,       @DateFrom      SMALLDATETIME
,       @DateTo        SMALLDATETIME
,       @Term          INT
,       @PayDay        SMALLDATETIME
,       @Amount        MONEY
,       @PrcRate       MONEY
,       @Baloon        MONEY


SELECT @DateFrom = @pDateFrom
,      @Term        = @pTerm
,      @PayDay      = DATEADD(dd , @pPayDay- 1 , '19000101')
,      @DateTo      = DATEADD(dd , @pTerm , @pDateFrom)
,      @Amount      = @pAmount
,      @PrcRate     = @pPrcRate
,      @Baloon      = @pBaloon


/*
SELECT @ProductID = BankProductID
FROM   tBankProduct tbp(NOLOCK)
WHERE  tbp.InstrumentID = 2010000001762
       AND LTRIM(RTRIM(tbp.Brief)) = LTRIM(RTRIM(@pProduct))



IF ISNULL(@ProductID , 0)=0
BEGIN
    SELECT @pRetMessage = 'Не найден продукт Diasoft Fa#'
           PRINT @pRetMessage
    
    GOTO ERROR
END
*/


SELECT @BranchID = @pBranchID



IF ISNULL(@BranchID , 0)=0
BEGIN
    SELECT @pRetMessage = 'Не найдено отделение Diasoft Fa#'
           PRINT @pRetMessage
    
    GOTO ERROR
END	


-- параметры

DELETE pConsParamValue
FROM   pConsParamValue WITH (INDEX=XPKpConsParamValue)
WHERE  SPID = @@spid

INSERT pConsParamValue
  (
    spid
,   ParamValue
,   SYSNAME
  )
VALUES
  (
    @@spid
,   2
,   'Fund'
  )

INSERT pConsParamValue
  (
    spid
,   ParamValue
,   SYSNAME
  )
VALUES
  (
    @@spid
,   @Amount
,   'Base'
  )

INSERT pConsParamValue
  (
    spid
,   ParamValue
,   SYSNAME
  )
VALUES
  (
    @@spid
,   @Term
,   'Period'
  )

INSERT pConsParamValue
  (
    spid
,   ParamValue
,   SYSNAME
  )
VALUES
  (
    @@spid
,   0
,   'PrimaryPeriod'
  )

INSERT pConsParamValue
  (
    spid
,   ParamValue
,   SYSNAME
  )
VALUES
  (
    @@spid
,   0
,   'BaseSum'
  )

INSERT pConsParamValue
  (
    spid
,   ParamValue
,   SYSNAME
  )
VALUES
  (
    @@spid
,   0
,   'CondTerm'
  )



        
-- ставки по договору 

DECLARE @BankProductID       DSIDENTIFIER
,       @ContractID          DSIDENTIFIER
,       @FundID              DSIDENTIFIER
,       @PercentType         DSIDENTIFIER
,       @SubjectID           DSIDENTIFIER
,       @GroupAccrServID     DSIDENTIFIER
,       @AccrServID          DSIDENTIFIER
,       @FlagCrd             DSINT_KEY
,       @Prc                 DSFLOAT
,       @BriefScale          DSBRIEFNAME
,       @ParentID            DSIDENTIFIER
,       @PrcBase             DSMONEY


SELECT @BankProductID = @ProductID
,      @ContractID      = 0
,      @FundID          = 2
,      @PercentType     = 201
,      @Amount          = @Amount
,      @DateFrom        = @DateFrom
,      @FlagCrd         = 128
,      @BranchID        = @BranchID

SELECT @FundID = ISNULL(@FundID , 0)
IF ISNULL(@DateFrom , '19000101')='19000101'
    SELECT @DateFrom = GETDATE()

 DELETE pUserCtrRelation WHERE SPID = @@spid	   

INSERT INTO pUserCtrRelation
(
	ID,
	SPID,
	UserCtrRelationID,
	ContractID,
	UserID,
	ObjectType,
	[Type],
	DateFrom,
	DateTo,
	Comment,
	Amount,
	PayInstructID1,
	PayInstructID2,
	InstRelationID,
	Flag,
	FundID
)
VALUES
(
	0,
	@@Spid ,
	0,
	0,
	@ClientID,
	151,
	1,
	@pDateFrom,
	'19000101',
	'',
	0,
	0,
	0,
	0,
	0,
	0
)


IF ISNULL(@ClientID2,0) <> 0
INSERT INTO pUserCtrRelation
(
	ID,
	SPID,
	UserCtrRelationID,
	ContractID,
	UserID,
	ObjectType,
	[Type],
	DateFrom,
	DateTo,
	Comment,
	Amount,
	PayInstructID1,
	PayInstructID2,
	InstRelationID,
	Flag,
	FundID
)
VALUES
(
	0,
	@@Spid ,
	0,
	0,
	@ClientID2,
	151,
	2,
	@pDateFrom,
	'19000101',
	'',
	0,
	0,
	0,
	0,
	0,
	0
)


DECLARE @AimID NUMERIC(15, 0), @AimBrief VARCHAR(30), @AimName VARCHAR(250)

DECLARE @AimCntID NUMERIC(15, 0)

--SELECT @AimID = AimID, @AimBrief = Brief, @AimName = NAME FROM tAimContent tac WITH(NOLOCK) WHERE tac.DealID = @OldID

IF isnull(@AimID, 0) = 0 
    SELECT @AimID = 8, @AimBrief = '6', @AimName = 'Покупка автотранспорта'
    

 
EXEC @RetVal = [Cons_AimCnt_Insert] @AimCntID = @AimCntID OUT
	, @DealID = NULL
	, @Flag = 0
	, @AimID = @AimID
	, @Brief = @AimBrief
	, @Name = @AimName
	, @Mode = 0
	, @Comment = ''
	, @Comment1 = ''
	, @DateStart = @DateFrom
	, @DateEnd = '19000101'
	
IF @RetVal!=0
BEGIN
    SELECT @pRetMessage = 'Ошибка Cons_AimCnt_Insert'
           PRINT @pRetMessage
    
    GOTO ERROR
END	



EXEC @RetVal=ConsPrc_Copy
     @BankProductID=@BankProductID
,    @ContractID=0
,    @Direction=2
,    @FundID=2
,    @Date=@DateFrom

IF @RetVal!=0
BEGIN
    SELECT @pRetMessage = 'Ошибка ConsPrc_Copy'
           PRINT @pRetMessage
    
    GOTO ERROR
END 


EXEC @RetVal=CheckWorkCardState @WorkCardID=0





SELECT 'Ставка =', @PrcRate

EXEC @RetVal=ConsInterestValue_Update
     @PercentType=201 -- ставка процентов
,    @Prcnt=@PrcRate
,    @ParentID=0
,    @OnDate=@DateFrom
,    @PrcntMin=0
,    @PrcntMax=0
,    @FundID=2
,    @Qty=0
,    @InclusiveTermID=0
,    @Coef=0
,    @Scale=0
,    @SteppedCalc=0
           

IF @RetVal!=0
BEGIN
    SELECT @pRetMessage = 
           'Ошибка добавления ставки по договору (проценты по ссуде)'
           PRINT @pRetMessage
    
    GOTO ERROR
END



EXEC @RetVal=ConsInterestValue_Update
     @PercentType=211 -- комиссия 1
,    @Prcnt=0
,    @ParentID=0
,    @OnDate=@DateFrom
,    @PrcntMin=0
,    @PrcntMax=0
,    @FundID=2
,    @Qty=0
,    @InclusiveTermID=2010000000075
,    @Coef=0
,    @Scale=0
,    @SteppedCalc=0

IF @RetVal!=0
BEGIN
    SELECT @pRetMessage = 'Ошибка добавления ставки по договору (комиссия 1)'
           PRINT @pRetMessage
    
    GOTO ERROR
END



EXEC @RetVal=ConsInterestValue_Update
     @PercentType=212 -- комиссия 2
,    @Prcnt=0
,    @ParentID=0
,    @OnDate=@DateFrom
,    @PrcntMin=0
,    @PrcntMax=0
,    @FundID=2
,    @Qty=0
,    @InclusiveTermID=0
,    @Coef=0
,    @Scale=0
,    @SteppedCalc=0

IF @RetVal!=0
BEGIN
    SELECT @pRetMessage = 'Ошибка добавления ставки по договору (комиссия 2)'
           PRINT @pRetMessage
    
    GOTO ERROR
END


EXEC @RetVal=ConsInterestValue_Update
     @PercentType=214 -- комиссия 4
,    @Prcnt=0
,    @ParentID=0
,    @OnDate=@DateFrom
,    @PrcntMin=0
,    @PrcntMax=0
,    @FundID=2
,    @Qty=0
,    @InclusiveTermID=2010000000076
,    @Coef=0
,    @Scale=0
,    @SteppedCalc=0

IF @RetVal!=0
BEGIN
    SELECT @pRetMessage = 'Ошибка добавления ставки по договору (комиссия 4)'
           PRINT @pRetMessage
    
    GOTO ERROR
END


EXEC @RetVal=ConsInterestValue_Update
     @PercentType=215
,    @Prcnt=0
,    @ParentID=0
,    @OnDate=@DateFrom
,    @PrcntMin=0
,    @PrcntMax=0
,    @FundID=2
,    @Qty=0
,    @InclusiveTermID=2010000000080
,    @Coef=0
,    @Scale=0
,    @SteppedCalc=0

IF @RetVal!=0
BEGIN
    SELECT @pRetMessage = 'Ошибка добавления ставки по договору (комиссия 5)'
           PRINT @pRetMessage
    
    GOTO ERROR
END


EXEC @RetVal=ConsInterestValue_Update
     @PercentType=216 -- Штрафы ОД
,    @Prcnt=@pFineRateLoan
,    @ParentID=0
,    @OnDate=@DateFrom
,    @PrcntMin=0
,    @PrcntMax=0
,    @FundID=2
,    @Qty=0
,    @InclusiveTermID=0
,    @Coef=0
,    @Scale=0
,    @SteppedCalc=0

IF @RetVal!=0
BEGIN
    SELECT @pRetMessage = 
           'Ошибка добавления ставки по договору (Штрафы по ссуде)'
           PRINT @pRetMessage
    
    GOTO ERROR
END

EXEC @RetVal=ConsInterestValue_Update
     @PercentType=217
,    @Prcnt=@pFineRatePrc -- Штрафы проценты
,    @ParentID=0
,    @OnDate=@DateFrom
,    @PrcntMin=0
,    @PrcntMax=0
,    @FundID=2
,    @Qty=0
,    @InclusiveTermID=0
,    @Coef=0
,    @Scale=0
,    @SteppedCalc=0

IF @RetVal!=0
BEGIN
    SELECT @pRetMessage = 
           'Ошибка добавления ставки по договору (Штрафы по процентам)'
           PRINT @pRetMessage
    
    GOTO ERROR
END


SELECT * FROM pConsInterestValue WHERE SPID = @@SPID

/*
EXEC @RetVal=ConsInterestValue_Update
     @PercentType=218 -- Штрафы Ком
,    @Prcnt=73
,    @ParentID=0
,    @OnDate=@DateFrom
,    @PrcntMin=0
,    @PrcntMax=0
,    @FundID=2
,    @Qty=0
,    @InclusiveTermID=0
,    @Coef=0
,    @Scale=0
,    @SteppedCalc=0

IF @RetVal!=0
BEGIN
    SELECT @pRetMessage = 
           'Ошибка добавления ставки по договору (Штрафы по комиссии)'
           PRINT @pRetMessage
    
    GOTO ERROR
END
*/

-- создание ГПП

DECLARE @InstrumentID            DSIDENTIFIER
,       @Date                    DsDateTime
,       @AmountProlongation      DSMONEY
,       @CreditDateFrom          DSDateTime
,       @UserAnnual              DSMONEY
,       @MortMode                INT
,       @CreditAction            INT
,       @MainAction              INT
,       @PercentAction           INT
,       @PercentAddAction        INT
,       @Comission1Action        INT
,       @Comission2Action        INT
,       @Comission3Action        INT
,       @Comission4Action        INT
,       @Comission5Action        INT
,       @ComissionEqulize        DSIDENTIFIER
,       @QtyAllComission         DSMONEY
,       @TypeAllComission        DSIDENTIFIER
,       @PrcAllComission         DSFLOAT
,       @Flag                    DSINT_KEY
,       @FlagCalc                DSINT_KEY
,       @PaymentAmountRound      DSSMALLINT
,       @PaymentDate             DSOPERDAY
,       @GracePaymentAmount      DSFLOAT
,       @GracePaymentDate        DSOPERDAY
,       @BalloonAmount           DSMONEY
,       @CreditLineID            DSIDENTIFIER
,       @AmountAdd               DSMONEY
,       @DateCalc                DSSMALLINT
,       @GraceDebtsPayAlg        DSTINYINT
,       @GracePrcPayAlg          DSTINYINT
,       @GracePrcDateEnd         DSOPERDAY
,       @GracePrcDateStart       DSOPERDAY
,       @RestrCommission         DSMONEY
,       @RestrCommissionDate     DSOPERDAY

SELECT @ContractID = 0
,      @InstrumentID            = @pInstrumentID
,      @BankProductID           = @BankProductID
,      @MortMode                = 1
,      @CreditAction            = 1
,      @MainAction              = 2
,      @PercentAction           = 4
,      @PercentAddAction        = 12
,      @Comission1Action        = 8
,      @Comission2Action        = 0
,      @Comission3Action        = 0
,      @Comission4Action        = 21
,      @Comission5Action        = 0
,      @CreditDateFrom          = @DateFrom
,      @ComissionEqulize        = 0
,      @QtyAllComission         = $0.0000
,      @TypeAllComission        = 0
,      @PrcAllComission         = 0
,      @Flag                    = 128
,      @UserAnnual              = @pAnnQty
,      @FundID                  = 2
,      @PaymentAmountRound      = 0
,      @PaymentDate             = @PayDay
,      @AmountProlongation      = NULL
,      @GracePaymentAmount      = $0.0000
,      @GracePaymentDate        = '19000101'
,      @BalloonAmount           = @Baloon
,      @FlagCalc                = 0
,      @CreditLineID            = 0
,      @AmountAdd               = 0
,      @DateCalc                = 1
,      @GraceDebtsPayAlg        = 0
,      @GracePrcPayAlg          = 0
,      @GracePrcDateEnd         = '19000101'
,      @GracePrcDateStart       = '19000101'
,      @RestrCommission         = $0.0000
,      @RestrCommissionDate     = '19000101'
,      @Date                    = @DateFrom

SELECT @DateFrom, @BankProductID, @pAnnQty, @PayDay, @Baloon

EXEC @RetVal=PaySchedule_Create
     @ContractID=@ContractID
,    @InstrumentID=@InstrumentID
,    @BankProductID=@BankProductID
,    @Amount=@Amount
,    @Date=@Date
,    @MortMode=@MortMode
,    @Flag=@Flag
,    @DateFrom=@DateFrom
,    @DateTo=@DateTo
,    @UserAnnual=@UserAnnual OUTPUT
,    @FundID=@FundID
,    @CreditAction=@CreditAction
,    @MainAction=@MainAction
,    @PercentAction=@PercentAction
,    @PercentAddAction=@PercentAddAction
,    @Comission1Action=@Comission1Action
,    @Comission2Action=@Comission2Action
,    @Comission3Action=@Comission3Action
,    @Comission4Action=@Comission4Action
,    @Comission5Action=@Comission5Action
,    @CreditDateFrom=@CreditDateFrom
,    @QtyAllComission=@QtyAllComission
,    @ComissionEqulize=@ComissionEqulize
,    @TypeAllComission=@TypeAllComission
,    @PrcAllComission=@PrcAllComission
,    @PaymentAmountRound=@PaymentAmountRound
,    @PaymentDate=@PaymentDate
,    @AmountProlongation=@AmountProlongation
,    @GracePaymentAmount=@GracePaymentAmount
,    @GracePaymentDate=@GracePaymentDate
,    @BranchID=@BranchID
,    @BalloonAmount=@BalloonAmount OUTPUT
,    @FlagCalc=@FlagCalc
,    @CreditLineID=@CreditLineID
,    @AmountAdd=@AmountAdd
,    @DateCalc=@DateCalc
,    @GraceDebtsPayAlg=@GraceDebtsPayAlg
,    @GracePrcPayAlg=@GracePrcPayAlg
,    @GracePrcDateEnd=@GracePrcDateEnd
,    @GracePrcDateStart=@GracePrcDateStart
,    @RestrCommission=@RestrCommission
,    @RestrCommissionDate=@RestrCommissionDate


IF @RetVal!=0
BEGIN
    SELECT @pRetMessage = 'Ошибка создания графика платежей'
           PRINT @pRetMessage
		  PRINT @RetVal
    GOTO ERROR
END


-- проверка ГПП

DECLARE @QtyIssue       FLOAT
,       @QtyRedempt     FLOAT

SELECT @ContractID = 0
,      @DateFrom = @DateFrom

SELECT @DateFrom = ISNULL(@DateFrom , '19000101')

EXEC @RetVal=PaySchedule_CheckSum
     @ContractID=@ContractID
,    @DateFrom=@DateFrom
,    @QtyIssue=@QtyIssue OUTPUT
,    @QtyRedempt=@QtyRedempt OUTPUT

IF @RetVal!=0
   OR @QtyIssue!=@QtyRedempt
BEGIN
    SELECT @pRetMessage = 'Ошибка проверки графика платежей'
           PRINT @pRetMessage
    
    GOTO ERROR
END


-- создание договора (заявки)

DECLARE @BranchExtID     DSIDENTIFIER
,       @IsBranchExt     TINYINT

SELECT @ID = 0
,      @RetVal          = 0
,      @BranchExtID     = 0

SELECT @IsBranchExt = CASE 
                           WHEN InstType=1 THEN 0 -- банк
                           WHEN InstType=3 THEN 1 -- отделение
                           ELSE 2 -- что-то другое
                      END
FROM   tInstitution WITH (NOLOCK INDEX=XPKtInstitution)
WHERE  InstitutionID = @BranchID
         

IF @IsBranchExt=1 -- отделение
BEGIN
    SELECT @BranchExtID = @BranchID
    SELECT @BranchID = ParentID
    FROM   tInstitution WITH (NOLOCK INDEX=XPKtInstitution)
    WHERE  InstitutionID = @BranchExtID
END

EXEC @RetVal=ContractCredit_Insert
     @ContractID=@ID OUT
,    @BranchID=@BranchID
,    @BranchExtID=@BranchExtID
,    @InstitutionID=@ClientID
,    @Number=@pCreditNumber
,    @InstrumentID=@pInstrumentID
,    @CreditDateFrom=@DateFrom
,    @CreditDateTo=@DateTo
,    @CreditPeriod=@Term
,    @Amount=@Amount
,    @FundID=2
,    @ContractGroupID=@ContractGroupID --2010000000471 --TODO
,    @Flag=0
,    @Comment=''
,    @DateOfSignDeal=@DateFrom
,    @Mortgage=1
,    @TenderDate='19000101'
,    @QualityProvisionKind=0
,    @DateFrom=@DateFrom
,    @PaymentAmount=@UserAnnual
,    @MaxTermContinuous=0
,    @MaxTerm=0
,    @CreditConditionID=0
,    @MoratoriumPeriod=0
,    @MoratoriumKind=0
,    @MinRepayAmount=$0.0000
,    @FlagCrd=12416
,    @CommentCrd=''
,    @ResourceID=0
,    @MainContractID=0
,    @AmountAdd=$0.0000
,    @LimitType=0
,    @BankProductID=@BankProductID
,    @OpenAccounts=1
,    @ComissionEqulize=0
,    @QtyAllComission=$0.0000
,    @TypeAllComission=0
,    @PrcAllComission=0
,    @IsActive=2 --IS_ACTIVE
,    @PaymentAmountRound=0
,    @PaymentDate=@PayDay
,    @GracePeriodTerm=0
,    @GracePaymentAmount=0
,    @GracePeriodType=0
,    @GracePaymentDate='19000101'
,    @ContractInstrumentID=@pInstrumentID
,    @SchemeRepaymentID=0
--,    @WorkCardID=0
,    @BalloonAmount=$0.0000
,    @PaymentPeriodType=0
,    @PaymentPeriodTerm=0
,    @StatementDate='19000101'
,    @RepaymentAlg=0
,    @CourseType=0
,    @FundsSource=0
,    @LoanUpInstID=0
,    @RiskID=0
,    @FlagCrd2=0
,    @ExtraContractNumber=''
                 
SELECT @pContractID = @ID                 

IF @RetVal!=0
   OR @pContractID=0
BEGIN
	SELECT @pContractID = 0
    SELECT @pRetMessage = 'Ошибка создания заявки (договора):'+MESSAGE
    FROM   tReturnCode trc(NOLOCK)
    WHERE  trc.RetCode = @RetVal
           PRINT @pRetMessage
    
    GOTO ERROR
END

SELECT @pRetMessage = 'Договор успешно создан'


-- создание счетов
DECLARE @Today SMALLDATETIME

SELECT @Today = CONVERT(SMALLDATETIME, CONVERT(VARCHAR(10), GETDATE(), 112))
 

DECLARE @LoanAccID NUMERIC(15, 0)
DECLARE @PrcAccID NUMERIC(15, 0)

DECLARE @LoanAccNumber VARCHAR(35)
DECLARE @PrcAccNumber VARCHAR(35)

-- внутрен


EXEC @Retval = ContractCredit_OpenResource 
	@ResourceID = @ID OUT,
	@ContractID = @pContractID, 
	@DateLink = @DateFrom,
	@TypeAccLinkID = 2010000003621,
	@Date = @DateFrom

-- расчетный
EXEC @Retval = ContractCredit_OpenResource 
	@ResourceID = @ID OUT,
	@ContractID = @pContractID, 
	@DateLink = @DateFrom,
	@TypeAccLinkID = 2010000003740,
	@Date = @pOperdate

-- 2010000004081	1	2010000001762	Стоимость приобретенных прав требования (47801[2])
EXEC @Retval = ContractCredit_OpenResource 
	@ResourceID = @ID OUT,
	@ContractID = @pContractID, 
	@DateLink = @DateFrom,
	@TypeAccLinkID = 2010000004081,
	@Date = @pOperdate

--2010000004082	1	2010000001762	Погашение приобретенных прав требования (61212)	
EXEC @Retval = ContractCredit_OpenResource 
	@ResourceID = @ID OUT,
	@ContractID = @pContractID, 
	@DateLink = @DateFrom,
	@TypeAccLinkID = 2010000004082,
	@Date = @pOperdate
	
--2010000004085	1	2010000001762	Выкупленный срочный основной долг по закладной	
EXEC @Retval = ContractCredit_OpenResource 
	@ResourceID = @ID OUT,
	@ContractID = @pContractID, 
	@DateLink = @DateFrom,
	@TypeAccLinkID = 2010000004085,
	@Date = @pOperdate

SELECT @LoanAccID = @ID	
	
--2010000004086	1	2010000001762	Выкупленные срочные проценты по закладной	
EXEC @Retval = ContractCredit_OpenResource 
	@ResourceID = @ID OUT,
	@ContractID = @pContractID, 
	@DateLink = @DateFrom,
	@TypeAccLinkID = 2010000004086,
	@Date = @pOperdate		

SELECT @PrcAccID = @ID


SELECT @LoanAccNumber = Brief FROM tResource WITH (NOLOCK) WHERE ResourceID = @LoanAccID
SELECT @PrcAccNumber  = Brief FROM tResource WITH (NOLOCK) WHERE ResourceID = @PrcAccID

SELECT @LoanAccID, @LoanAccNumber, @PrcAccID, @PrcAccNumber

DECLARE @CommentOD VARCHAR(210)
SET @CommentOD = 'Выкуп основного долга по кредиту ' + @pCreditNumber  --+ ' ' + @ClientName

DECLARE @CommentPrc VARCHAR(210)
SET @CommentPrc = 'Выкуп процентов по кредиту ' + @pCreditNumber  --+ ' ' + @ClientName

DECLARE @RetMsg VARCHAR(250)

-- делаем документы

DECLARE @Num VARCHAR(20)

SELECT @Num = RIGHT(RTRIM(LTRIM(@LoanAccNumber)), 3)
 EXEC VKAB_1CInsertCashDoc5 @FO = 1303, @DocStatus = 1
 , @Batch = 'Кр3_Оп1', 
 @DebAcc = @LoanAccNumber, 
 @CreAcc = '99999810200000000000', 
 @VidOper = 9, @DocNum = @Num, @DocSum = @pAmount, @OperDate = @pOperdate, @Sum1 = @pAmount,
 @NaznText=@CommentOD , @DealTransactID = @ID OUT, @RetMsg = @RetMsg OUT
 
 
 IF @pAmountPrc > 0
 BEGIN

 SELECT @Num = RIGHT(RTRIM(LTRIM(@PrcAccNumber)), 3)
 EXEC VKAB_1CInsertCashDoc5 @FO = 1303, @DocStatus = 1
 , @Batch = 'Кр3_Оп1', 
 @DebAcc = @PrcAccNumber, 
 @CreAcc = '99999810200000000000', 
 @VidOper = 9, @DocNum = @Num, @DocSum = @pAmountPrc, @OperDate = @pOperdate, @Sum1 = @pAmountPrc,
 @NaznText=@CommentPrc , @DealTransactID = @ID OUT, @RetMsg = @RetMsg OUT

END
/*
2010000004081	1	2010000001762	Стоимость приобретенных прав требования
2010000004082	1	2010000001762	Погашение приобретенных прав требования
2010000004083	1	2010000001762	Выкупленные пени на просроченные проценты по закладной
2010000004084	1	2010000001762	Выкупленные пени на просроченный основной долг по закладной
2010000004085	1	2010000001762	Выкупленный срочный основной долг по закладной
2010000004086	1	2010000001762	Выкупленные срочные проценты по закладной
2010000004087	1	2010000001762	Выкупленный просроченный основной долг по закладной
2010000004088	1	2010000001762	Выкупленные просроченные проценты по закладной
2010000004089	1	2010000001762	Выкупленные проценты на просроченный основной долг
2010000004090	1	2010000001762	Выкупленная комиссия 1
*/

   
/*   
SELECT @pContractID



DECLARE @RuleID NUMERIC(15, 0)
DECLARE @AccId NUMERIC(15, 0)

SELECT @AccId = al.ResourceID FROM 
tLoanAccountLink al WITH(NOLOCK) 
INNER JOIN tTypeAccLink tal  WITH (NOLOCK) ON al.RuleID = tal.TypeAccLinkID
WHERE tal.Brief = 'ССУДНЫЙ' AND al.DealID = @DealID


 
SELECT @RuleID= TypeAccLinkID FROM tTypeAccLink  WITH (NOLOCK) WHERE brief = 'КуплКрТреб' AND BranchID = 0 AND ObjectID=@pInstrumentID  

exec @RetVal= ConsAccountLink_Insert
  @ConsAccountLinkID   = @ID out,
  @ContractID          = @pContractID,
  @RuleID              = @RuleID,
  @AccountID           = @AccID,
  @OnDate              = @pDateFrom,
  @DateLast            = '19000101'

/*SELECT @AccId = al.ResourceID FROM 
tLoanAccountLink al WITH(NOLOCK) 
INNER JOIN tTypeAccLink tal  WITH (NOLOCK) ON al.RuleID = tal.TypeAccLinkID
WHERE tal.Brief = 'Ц_47801_ПРЦ' AND al.DealID = @DealID
 
SELECT @RuleID= TypeAccLinkID FROM tTypeAccLink  WITH (NOLOCK) WHERE brief = 'КуплПрцСрЗ' AND BranchID = 0 AND ObjectID=@pInstrumentID  

exec @RetVal= ConsAccountLink_Insert
  @ConsAccountLinkID   = @ID out,
  @ContractID          = @pContractID,
  @RuleID              = @RuleID,
  @AccountID           = @AccID,
  @OnDate              = @pDateFrom,
  @DateLast            = '19000101'

*/

SELECT @AccId = al.ResourceID FROM 
tLoanAccountLink al WITH(NOLOCK) 
INNER JOIN tTypeAccLink tal  WITH (NOLOCK) ON al.RuleID = tal.TypeAccLinkID
WHERE tal.Brief = 'Ц_61212_ОД' AND al.DealID = @DealID

 
SELECT @RuleID= TypeAccLinkID FROM tTypeAccLink  WITH (NOLOCK) WHERE brief = 'ГашКуплТрб' AND BranchID = 0 AND ObjectID=@pInstrumentID  

exec @RetVal= ConsAccountLink_Insert
  @ConsAccountLinkID   = @ID out,
  @ContractID          = @pContractID,
  @RuleID              = @RuleID,
  @AccountID           = @AccID,
  @OnDate              = @pDateFrom,
  @DateLast            = '19000101'


SELECT @AccId = al.ResourceID FROM 
tLoanAccountLink al WITH(NOLOCK) 
INNER JOIN tTypeAccLink tal  WITH (NOLOCK) ON al.RuleID = tal.TypeAccLinkID
WHERE tal.Brief = 'РЕЗЕРВЫ' AND al.DealID = @DealID

 
SELECT @RuleID= TypeAccLinkID FROM tTypeAccLink  WITH (NOLOCK) WHERE brief = 'РЕЗЕРВЫ' AND BranchID = 2000 AND ObjectID=@pInstrumentID  

exec @RetVal= ConsAccountLink_Insert
  @ConsAccountLinkID   = @ID out,
  @ContractID          = @pContractID,
  @RuleID              = @RuleID,
  @AccountID           = @AccID,
  @OnDate              = @pDateFrom,
  @DateLast            = '19000101'



SELECT @AccId = al.ResourceID FROM 
tLoanAccountLink al WITH(NOLOCK) 
INNER JOIN tTypeAccLink tal  WITH (NOLOCK) ON al.RuleID = tal.TypeAccLinkID
WHERE tal.Brief = 'Ц_91418_ОД' AND al.DealID = @DealID

 
SELECT @RuleID= TypeAccLinkID FROM tTypeAccLink  WITH (NOLOCK) WHERE brief = 'КуплСрСсЗд' AND BranchID = 0 AND ObjectID=@pInstrumentID  

exec @RetVal= ConsAccountLink_Insert
  @ConsAccountLinkID   = @ID out,
  @ContractID          = @pContractID,
  @RuleID              = @RuleID,
  @AccountID           = @AccID,
  @OnDate              = @pDateFrom,
  @DateLast            = '19000101'


SELECT @AccId = al.ResourceID FROM 
tLoanAccountLink al WITH(NOLOCK) 
INNER JOIN tTypeAccLink tal  WITH (NOLOCK) ON al.RuleID = tal.TypeAccLinkID
WHERE tal.Brief = 'Ц_91418_ПРЦ' AND al.DealID = @DealID

 
SELECT @RuleID= TypeAccLinkID FROM tTypeAccLink  WITH (NOLOCK) WHERE brief = 'КуплСрПрц' AND BranchID = 0 AND ObjectID=@pInstrumentID  

exec @RetVal= ConsAccountLink_Insert
  @ConsAccountLinkID   = @ID out,
  @ContractID          = @pContractID,
  @RuleID              = @RuleID,
  @AccountID           = @AccID,
  @OnDate              = @pDateFrom,
  @DateLast            = '19000101'

SELECT @AccId = al.ResourceID FROM 
tLoanAccountLink al WITH(NOLOCK) 
INNER JOIN tTypeAccLink tal  WITH (NOLOCK) ON al.RuleID = tal.TypeAccLinkID
WHERE tal.Brief = 'РАСЧЕТЫ' AND al.DealID = @DealID

 
SELECT @RuleID= 2010000000762  -- расчеты резид го

exec @RetVal= ConsAccountLink_Insert
  @ConsAccountLinkID   = @ID out,
  @ContractID          = @pContractID,
  @RuleID              = @RuleID,
  @AccountID           = @AccID,
  @OnDate              = @pDateFrom,
  @DateLast            = '19000101'  

*/
   
ERROR:




-- очистка и выход

DELETE pWarrantyContent
FROM   pWarrantyContent WITH (INDEX=XPKpWarrantyContent)
WHERE  SPID = @@spid

DELETE pAimContent
FROM   pAimContent WITH (INDEX=XAK0pAimContent)
WHERE  SPID = @@spid

DELETE pSignature
FROM   pSignature WITH (INDEX=XPKpSignature)
WHERE  SPID = @@spid

DELETE pUserCtrRelation
FROM   pUserCtrRelation WITH (INDEX=XPKpUserCtrRelation)
WHERE  SPID = @@spid

DELETE pPaySchedule
FROM   pPaySchedule WITH (INDEX=XIE1pPaySchedule)
WHERE  SPID = @@spid

DELETE pPayScheduleExt
FROM   pPayScheduleExt WITH (INDEX=XIE1pPayScheduleExt)
WHERE  SPID = @@spid

DELETE pConsInterestValue
FROM   pConsInterestValue WITH (INDEX=XIE1pConsInterestValue)
WHERE  SPID = @@spid

DELETE pODTree
FROM   pODTree WITH (INDEX=XIE0pODTree)
WHERE  SPID = @@spid

DELETE pODTreePointer
FROM   pODTreePointer WITH (INDEX=XIE0pODTreePointer)
WHERE  SPID = @@spid

DELETE pODPointer
FROM   pODPointer WITH (INDEX=XIE0pODPointer)
WHERE  SPID = @@spid

DELETE pODPointVal
FROM   pODPointVal WITH (INDEX=XIE0pODPointVal)
WHERE  SPID = @@spid

DELETE pBankProductObjRelation
FROM   pBankProductObjRelation WITH (INDEX=XIE0pBankProductObjRelation)
WHERE  SPID = @@spid

DELETE pErrorLine
FROM   pErrorLine WITH (INDEX=XIE0pErrorLine)
WHERE  SPID = @@spid

DELETE pConsParamValue
FROM   pConsParamValue WITH (INDEX=XPKpConsParamValue)
WHERE  SPID = @@spid

DELETE pActionPeriod
FROM   pActionPeriod WITH (INDEX=XPKpActionPeriod)
WHERE  SPID = @@spid

DELETE pPayInstruct
FROM   pPayInstruct WITH (INDEX=XAK0pPayInstructID)
WHERE  SPID = @@spid

DELETE pTranchesToLong
FROM   pTranchesToLong WITH (NOLOCK INDEX=XPKpTranchesToLong)
WHERE  SPID = @@SPID

DELETE pConsRestructing
FROM   pConsRestructing WITH (NOLOCK INDEX=XPKpConsRestructing)
WHERE  SPID = @@spid

DELETE pCtrCtrRelation
FROM   pCtrCtrRelation WITH (NOLOCK INDEX=XIE1pCtrCtrRelation)
WHERE  SPID = @@spid

DELETE pConsGraceContent
FROM   pConsGraceContent WITH (NOLOCK INDEX=XPKpConsGraceContent)
WHERE  SPID = @@spid

DELETE pUserCtrRelationAttr
FROM   pUserCtrRelationAttr WITH (ROWLOCK INDEX=XPKpUserCtrRelationAttr)
WHERE  SPID = @@spid

DELETE pUserCtrRelationAttr2
FROM   pUserCtrRelationAttr2 WITH (ROWLOCK INDEX=XPKpUserCtrRelationAttr2)
WHERE  SPID = @@spid
 

RETURN @RetVal
 
GO
 

GRANT EXEC ON [VKAB_CreateRefinContract] TO public

