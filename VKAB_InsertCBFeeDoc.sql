USE [workdb]
GO
/****** Object:  StoredProcedure [dbo].[VKAB_InsertCBFeeDoc]    Script Date: 04/16/2015 17:20:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[VKAB_InsertCBFeeDoc](
                                          @PayType INT -- 1 КБ / 2 ИБ / 3 - SMS / 4 - Ведение счета / 5 - мобклиент / 6- выписка онлайн / 7 - призраки
                                         ,@InstrumentID NUMERIC(15 ,0)
                                         ,@VO INT -- вид операции
                                         ,@NumDoc VARCHAR(3)
                                         ,@OperDate SMALLDATETIME
                                         ,@ResourceDebBrief VARCHAR(35)
                                         ,@Qty MONEY
                                         ,@Comment VARCHAR(210)
                                         ,@PayCnt INT
                                      )

AS


DECLARE @ResourceDebID     DSIDENTIFIER
       ,@ResourceCreID     DSIDENTIFIER
       ,@ResourceCreBrief  VARCHAR(20)
       ,@ErrMsg            VARCHAR(160)
       ,@RetVal            INT
       ,@ID                DSIDENTIFIER
       ,@BatchID           DSIDENTIFIER
       ,@BatchName         VARCHAR(20)
       ,@DocMode           TINYINT
       ,@CurUserInst       DSIDENTIFIER
       ,@DealTransactID    DSIDENTIFIER
       ,@Status            INT
       ,@Flags             VARCHAR(25)

SELECT @Status = 1
      ,@Flags = '    1'
      ,@DocMode = 1


    -- пачку и счет по кредиту определяем в зависимости от отделения к которому принадлежит пользователь ---------------

/*SELECT @CurUserInst = institutionID
FROM   tUser(NOLOCK INDEX = XAK0tUser)
WHERE  brief = CONVERT(CHAR(30) ,SUSER_SNAME())
*/

SELECT @CurUserInst = SubDivisionID
FROM   tResource r  WITH (NOLOCK)
WHERE  brief = @ResourceDebBrief
       AND BalanceID = 2140
       AND DateEnd = '19000101'


SELECT @BatchName = '1'
	
	-- Отделение проклассифицировано рубрикой классификатора, название рубрики - пачка, примечание - счет
SELECT @BatchName = oc.Brief
      ,@ResourceCreBrief = oc.Comment
FROM   tObjClsRelation ocr(NOLOCK INDEX = XIE1tObjClsRelation)
       INNER JOIN tObjClassifier oc(NOLOCK INDEX = XPKtDepClassifier)
            ON  ocr.ObjClassifierID = oc.ObjClassifierID
       INNER JOIN tObjClassifier ocp(NOLOCK INDEX = XPKtDepClassifier)
            ON  oc.ParentID = ocp.ObjClassifierID
WHERE  1 = 1
       AND ocr.ObjectID = @CurUserInst
       AND ocr.ObjType = 1
       AND ocp.Brief = CASE 
                            WHEN @PayType = 1 THEN 'ПлатаКБ'
                            ELSE 'ПлатаИБ'
                       END
    
DECLARE @IncomeAccMask VARCHAR(20)
    
    
    -- определение счета доходов за СМС
IF @PayType = 3
    SELECT @ResourceCreBrief = r.Brief
    FROM   tResource r(NOLOCK)
           INNER JOIN tInstitution i WITH (NOLOCK INDEX = XPKtInstitution)
                ON  r.InstitutionID = i.InstitutionID
    WHERE  r.Brief LIKE '70601810_____1620341'
           AND r.SubDivisionID = @CurUserInst
           AND r.BalanceID <> 10
           AND r.DateEnd = '19000101'
		
    -- определение счета доходов за Ведение счета
IF @PayType = 4
    SELECT @ResourceCreBrief = r.Brief
    FROM   tResource r(NOLOCK)
           INNER JOIN tInstitution i WITH (NOLOCK INDEX = XPKtInstitution)
                ON  r.InstitutionID = i.InstitutionID
    WHERE  r.Brief LIKE '70601810_____1210101'
           AND r.SubDivisionID = @CurUserInst
           AND r.BalanceID <> 10
           AND r.DateEnd = '19000101'		
    	

    -- определение счета доходов за Мобильный клиент
IF @PayType = 5
    SELECT @ResourceCreBrief = r.Brief
    FROM   tResource r(NOLOCK)
           INNER JOIN tInstitution i WITH (NOLOCK INDEX = XPKtInstitution)
                ON  r.InstitutionID = i.InstitutionID
    WHERE  r.Brief LIKE '70601810_____12102__'
           AND r.Name LIKE '%мобиль%'
           AND r.SubDivisionID = @CurUserInst
           AND r.BalanceID <> 10
           AND r.DateEnd = '19000101'	

-- выписка онлайн           
IF @PayType = 6
    SELECT @ResourceCreBrief = r.Brief
    FROM   tResource r(NOLOCK)
           INNER JOIN tInstitution i WITH (NOLOCK INDEX = XPKtInstitution)
                ON  r.InstitutionID = i.InstitutionID
    WHERE  r.Brief LIKE '70601810_____1210271'
           AND r.SubDivisionID = @CurUserInst
           AND r.BalanceID <> 10
           AND r.DateEnd = '19000101'           
           
-- неработающие счета           
IF @PayType = 7
    SELECT @ResourceCreBrief = r.Brief
    FROM   tResource r(NOLOCK)
           INNER JOIN tInstitution i WITH (NOLOCK INDEX = XPKtInstitution)
                ON  r.InstitutionID = i.InstitutionID
    WHERE  r.Brief LIKE '70601810_____1210101'
           AND r.SubDivisionID = @CurUserInst
           AND r.BalanceID <> 10
           AND r.DateEnd = '19000101' 
           
-- РКО          
IF @PayType = 8
    SELECT @ResourceCreBrief = r.Brief
    FROM   tResource r(NOLOCK)
           INNER JOIN tInstitution i WITH (NOLOCK INDEX = XPKtInstitution)
                ON  r.InstitutionID = i.InstitutionID
    WHERE  r.Brief LIKE '70601810_____1210209'
           AND r.SubDivisionID = @CurUserInst
           AND r.BalanceID <> 10
           AND r.DateEnd = '19000101'            
    	
    

SELECT @BatchID = PropertyUsrID
FROM   tPropertyUsr(NOLOCK)
WHERE  PropertyType = 6
       AND Brief = @BatchName



SELECT @NumDoc = CONVERT(VARCHAR(6) ,@PayType * 111) 


    -- ищем счет и реквизиты плательщика -------------------------------------------------------------------------------

DECLARE @SubDivisionID NUMERIC(15 ,0)
DECLARE @UserMainID NUMERIC(15 ,0)
DECLARE @AccProfileID NUMERIC(15 ,0)
DECLARE @InstOwnerID NUMERIC(15 ,0)
DECLARE @INN VARCHAR(12)
DECLARE @KPP VARCHAR(12)
DECLARE @Acc DSACC_SWIFT
       ,@PAcc CHAR(40)

DECLARE @OwnerName VARCHAR(160)
DECLARE @CreName VARCHAR(160)

SELECT @ResourceDebID = ResourceID
      ,@SubDivisionID = SubdivisionID
      ,@UserMainID = UserMainID
      ,@AccProfileID = AccProfileID
      ,@InstOwnerID = InstOwnerID
FROM   tResource(NOLOCK)
WHERE  Brief = @ResourceDebBrief
       AND BalanceID = 2140
       AND DateEnd = '19000101'

SELECT @OwnerName = CASE 
                         WHEN i.PropDealPart = 0 THEN i.Name + ' ' + i.Name1 +
                              ' ' + i.Name2
                         ELSE i.Name
                    END
FROM   tInstitution i(NOLOCK)
WHERE  InstitutionID = @InstOwnerID

SELECT @INN = INN
FROM   tInstitution(NOLOCK)
WHERE  InstitutionID = @InstOwnerID

SELECT @KPP = Reuters
FROM   tReuters(NOLOCK)
WHERE  InstitutionID = @InstOwnerID
       AND TradingSysID = 2
       AND IsDefault = 1

SELECT @RetVal = 0

IF ISNULL(@ResourceDebID ,0) = 0
BEGIN
    SELECT @ErrMsg = ' Не найден счет по дебету!'
    SELECT @RetVal = 27587
    GOTO _ERROR
END

    -- ищем доходный счет ------------------------------------------------------------------------------------
SELECT @ResourceCreID = ResourceID
FROM   tResource(NOLOCK)
WHERE  Brief = @ResourceCreBrief
       AND BalanceID = 2140

    

IF ISNULL(@ResourceCreID ,0) = 0
BEGIN
    SELECT @ErrMsg = ' Не найден счет по кредиту!'
    SELECT @RetVal = 27588
    GOTO _ERROR
END
    
DECLARE @BankID NUMERIC(15 ,0)
SELECT @BankID = InstitutionID
FROM   tResource r(NOLOCK)
WHERE  r.ResourceID = @ResourceDebID
    
SELECT @CreName = NAME
FROM   tInstitution(NOLOCK)
WHERE  InstitutionID = @BankID


    -- ищем счета картотеки и требований ---------------------------------------------------------------------

DECLARE @CouponID NUMERIC(15 ,0)  -- счет К2
DECLARE @CouponID1 NUMERIC(15 ,0)  -- счет К1

DECLARE @DebtAcc NUMERIC(15 ,0)   -- счет 47423
DECLARE @DebtAccBrief VARCHAR(35) -- счет 47423

DECLARE @DebtAccName VARCHAR(160)




SELECT @CouponID = a.ResourceID
FROM   tAccSystemDoc a WITH (NOLOCK)
       INNER JOIN tResource r WITH (NOLOCK)
            ON  a.ResourceID = r.ResourceID
WHERE  r.DateEnd = '19000101'
       AND a.AccType = 1
       AND (a.AccDeb LIKE @ResourceDebBrief + '\%')

SELECT @CouponID1 = a.ResourceID
FROM   tAccSystemDoc a WITH (NOLOCK)
       INNER JOIN tResource r WITH (NOLOCK)
            ON  a.ResourceID = r.ResourceID
WHERE  r.DateEnd = '19000101'
       AND a.AccType = 2
       AND (a.AccDeb LIKE @ResourceDebBrief + '\%')       



SELECT @DebtAcc = a.ResourceID
      ,@DebtAccBrief = r.Brief
FROM   tAccSystemDoc a WITH (NOLOCK)
       INNER JOIN tResource r WITH (NOLOCK)
            ON  a.ResourceID = r.ResourceID
WHERE  r.DateEnd = '19000101'
       AND a.AccType = 22
       AND (
               a.AccDeb LIKE @ResourceDebBrief + '\%'
               OR a.ClientDeb = @InstOwnerID
           )




    -- расчет остатка на расчетном счете ----------------------------------------------------------------------
DECLARE @RestBs MONEY

DELETE pResource
WHERE  spid = @@spid

DELETE pResList
WHERE  spid = @@spid

INSERT pResource
  (
    spid
   ,ResourceID
  )
SELECT @@spid
      ,@ResourceDebID

IF ISNULL(@CouponID, 0) != 0      
INSERT pResource
  (
    spid
   ,ResourceID
  )
SELECT @@spid
      ,@CouponID

IF ISNULL(@CouponID1, 0) != 0      
INSERT pResource
  (
    spid
   ,ResourceID
  )
SELECT @@spid
      ,@CouponID1

EXEC AccList_Rest @Date = @OperDate
    ,@Confirmed = 0

SELECT @RestBs = ABS(RestBs)
FROM   pResList(NOLOCK INDEX = XPKpResList)
WHERE  spid = @@spid
       AND ResourceID = @ResourceDebID

-- проверим наличие картотеки       
DECLARE @CouponRest MONEY
       
SELECT @CouponRest = ABS(RestBs)
FROM   pResList(NOLOCK INDEX = XPKpResList)
WHERE  spid = @@spid
       AND ResourceID = @CouponID
       
SELECT @CouponRest = abs(ISNULL(@CouponRest, 0))

IF (@CouponRest > 0) AND @PayType IN (1, 2, 3,  5, 6)  --, 4
	BEGIN 
		SELECT @Qty = 0
		SELECT @RetVal = 27880   -- не достаточно средств
		GOTO _ERROR
    END       
    
SELECT @CouponRest = ABS(RestBs)
FROM   pResList(NOLOCK INDEX = XPKpResList)
WHERE  spid = @@spid
       AND ResourceID = @CouponID1
       
SELECT @CouponRest = abs(ISNULL(@CouponRest, 0))

IF (@CouponRest > 0) AND @PayType IN (1, 2, 3,  5, 6)  --, 4
	BEGIN 
		SELECT @Qty = 0
		SELECT @RetVal = 27880   -- не достаточно средств
		GOTO _ERROR
    END         

    --SELECT @ResourceDebID, @restBs, @ResourceCreID, @CouponID, @DebtAcc, @SubDivisionID, @UserMainID, @AccProfileID, @OwnerName

SELECT @DebtAccName = 'Требования по РКО ' + @OwnerName
DECLARE @VerIFyNeed INT


    

DECLARE @ArrestSum MONEY 

SELECT @ArrestSum = SUM(ArrestSum)
FROM   tResArrest ta(NOLOCK)
WHERE  ta.ResourceID = @ResourceDebID
       AND ta.DateEnd = '19000101'

SELECT @ArrestSum = ISNULL(@ArrestSum ,0)
	
	-- для  КБ и ИБ списываем в пределах остатка, если не было движения
	
/*IF (@Qty > (@RestBs - @ArrestSum))
   AND @PayType IN (1 ,2) AND @PayCnt = 0
    SELECT @Qty = @RestBs - @ArrestSum*/
	
	-- для КБ и ИБ ничего не делаем если нет денег (с 1.05.2012)

	IF (@Qty > (@RestBs - @ArrestSum)) AND @PayType IN (1, 2, 3,  5, 6, 4)
	BEGIN 
		SELECT @Qty = 0
		SELECT @RetVal = 23151   -- не достаточно средств
		GOTO _ERROR
    END	
	 
 
IF EXISTS (
           SELECT 1
           FROM   tResArrest (NOLOCK)
           WHERE  DateEnd = '19000101'
                  AND FullArrest = 1
                  AND ResourceID = @ResourceDebID
) AND @PayType IN (1, 2, 3, 5, 6, 4)
BEGIN
	SELECT @RetVal = 25440	
	GOTO _ERROR	
END 
	 
	 
-- денег хватает и нет полного ареста  - списываем с расчетного в доходы
IF @restBs >= (@Qty + @ArrestSum)
   AND NOT EXISTS (
           SELECT 1
           FROM   tResArrest (NOLOCK)
           WHERE  DateEnd = '19000101'
                  AND FullArrest = 1
                  AND ResourceID = @ResourceDebID
       ) 
BEGIN
    EXEC @RetVal = TDocumentPlat_F_Insert
         @DealTransactID = @DealTransactID OUT -- 1 --
        ,@InstrumentID = @InstrumentID -- фин. операция
        ,@DocNumber = @NumDoc --номер документа
        ,@BatchID = @BatchID -- DSIDENTIFIER  = NULL,     -- пачка
        ,@OpCode = 17 --DSIDENTIFIER  = NULL,     -- вид операции
        ,@Date = @OperDate -- smalldatetime = NULL,     -- дата
        ,@Confirmed = 1 --tinyint       = NULL,     -- статус документа
        ,@Qty = @Qty --money         = NULL,     -- сумма	-- плательщик
        ,@BankIn = @BankID --DSIDENTIFIER  = NULL,     -- банк
        ,@AccInID = @ResourceDebID --DSIDENTIFIER  = NULL,     -- счет клиента (передаем для корректности ФСМ)
        ,@AccIn = @ResourceDebBrief --varchar(25)   = NULL,     -- счет клиента
        ,@KppIn = @KPP --varchar(9)    = NULL,     -- КПП клиента
        ,@InnIn = @INN --varchar(15)   = NULL,     -- ИНН клиента
        ,@NameIn = @OwnerName --varchar(255)  = NULL,     -- наименование клиента	-- получатель
        ,@BankOut = @BankID --DSIDENTIFIER  = NULL,     -- банк
        ,@AccOutID = @ResourceCreID --DSIDENTIFIER  = NULL,      -- счет клиента (передаем для корректности ФСМ)
        ,@AccOut = @ResourceCreBrief --varchar(25)   = NULL,     -- счет клиента
        ,@KppOut = '165801001' --varchar(9)    = NULL,     -- КПП клиента
        ,@InnOut = '1653016689' --varchar(15)   = NULL,     -- ИНН клиента
        ,@NameOut = @CreName -- varchar(255)  = NULL,     -- наименование клиента	--
        ,@DocDate = @OperDate -- smalldatetime = NULL,     -- дата документа
        ,@TermDate = @OperDate -- smalldatetime = NULL,     -- срок	--@ProcType              = @ProcType, -- DSIDENTIFIER  = NULL,     -- вид обработки
        ,@Priority = 5 --DSIDENTIFIER  = NULL,     -- очередность
        ,@PaymentType = 2010000000311 -- DSIDENTIFIER  = NULL,     -- вид платежа
        ,@Comment = @Comment --DSCOMMENT     = NULL,     -- назначение платежа
        ,@ResDebID = @ResourceDebID --  DSIDENTIFIER  = NULL,     -- счет по дебету
        ,@ResCreID = @ResourceCreID --  DSIDENTIFIER  = NULL,     -- счет по кредиту
        ,@CommingDate = @OperDate --varchar(255)  = NULL,     -- датв поступления в банк платежа
        ,@SaveClient = 0 -- int = NULL 1 сохранить инф о клиенте получателе
    
    IF @RetVal = 22422
       OR @RetVal = 23153
        GOTO _ERROR
END
ELSE
    -- нет денег, ставим на картотеку, если это живой клиент (есть платежи)
IF @PayCnt > 0
BEGIN
    IF ISNULL(@CouponID ,0) = 0
    BEGIN
        SELECT @Status = 101
        SELECT @Flags = ''
    END
    
    -- проверим наличие 47423
    
    BEGIN TRAN
    
    IF ISNULL(@DebtAcc ,0) = 0 -- нет счета надо открыть
    BEGIN
        EXEC @RetVal = CreateAccountNumber
             @Account = @Acc OUT
            ,@ParentMask = @Pacc OUT
            ,@ParentID = 2112
            ,@ResType = 1
            ,@FundID = 2
            ,@CharType = 1
            ,@PropType = 0
            ,@InstitutionID = @SubDivisionID --  отделение
            ,@InstOwnerID = @BankID --клиент
            ,@JustEvalKey = 3
            ,@ID = 0
            ,@DealID = 0
            ,@BranchID = @BankID -- филиал
        
        IF @RetVal <> 0
        BEGIN
            ROLLBACK TRAN
            GOTO _ERROR
        END
        
        EXEC @RetVal = AccRcv_Insert
             @ResourceID = @DebtAcc OUT
            ,@InstitutionID = @BankID
            ,@FundID = 2
            ,@SecurityID = 0
            ,@AccRcv = @Acc
            ,@Name = @DebtAccName
            ,@CharType = 1
            ,@DefaultAcc = 0
            ,@PropType = 0
            ,@Note = ''
            ,@Note1 = ''
            ,@BeneficID = 0
            ,@ResourceCorID = 0
            ,@AccRcvCor = ''
            ,@NameCor = ''
            ,@ResourceID2 = 0
            ,@DepID1 = 2010000104308
            ,@DepID2 = 0
            ,@ObjectID = 0
            ,@RestrictType = 0
            ,@DateStart = @OperDate
            ,@DateEnd = '19000101'
            ,@ResourceType = 1
            ,@ParentID = 2112
            ,@SecIssueID = 0
            ,@ParentMask = ''
            ,@RevalType = 0
            ,@Mask = '|Э{Ф{СчетВКАБ}}'
            ,@MainAcc = 0
            ,@RES_Identity = 0
            ,@RestCheck = $0.0000
            ,@InstOwnerID = @InstOwnerID
            ,@InstRelTypeID = 0
            ,@AccLinkedID = NULL
            ,@LevelID = NULL
            ,@UserMainID = @UserMainID
            ,@AccAnlID = 0
            ,@IsSubconto = 0
            ,@ClientInstructID = 0
            ,@BankContractNum = ''
            ,@BankContractDate = '19000101'
            ,@DateNotIFyGNI = @OperDate
            ,@DateNotIFyPF = @OperDate
            ,@DateNotIFyFOMS = @OperDate
            ,@IsRestCheck = 0
            ,@SubDivisionID = @SubDivisionID
            ,@OwnerControl = 501
            ,@InternalAccount = 0
            ,@VerIFyNeed = @VerIFyNeed OUTPUT
            ,@AlterName = ''
            ,@ClientCloseInstructID = 0
            ,@CommissionAccount = 0
            ,@CopyCls = 0
            ,@ForcedAllowances = 0
            ,@OpenInstResource = 0
        
        IF @RetVal <> 0
        BEGIN
            ROLLBACK TRAN
            GOTO _ERROR
        END
        
        -- добавим в ССС
        DECLARE @AccSystemID DSIDENTIFIER
        EXEC @RetVal = AccSystem_Insert
             @AccSystemID = @AccSystemID OUTPUT
            ,@ResourceID = @DebtAcc
            ,@AccType = 22
            ,@Comment = @DebtAccName
            ,@Brief = @Acc
            ,@BranchID = @BankID
        
        -- добавим связь с расчетным
        
        DECLARE @AccSystemDocID DSIDENTIFIER
        
        EXEC @RetVal = AccSystemDoc_Insert
             @AccSystemDocID = @AccSystemDocID OUTPUT
            ,@SELECTionRuleID = 0
            ,@AccSystemID = @AccSystemID
            ,@Brief = ''
            ,@Name = @ResourceDebBrief
            ,@SubDivDeb = 0
            ,@AccDeb = '_____810____________'	--@ResourceDebBrief,
            ,@SubDivCre = 0
            ,@AccCre = '____________________\%'
            ,@BicIn = '_________\%'
            ,@AccIn = '____________________\%'
            ,@BicOut = '_________\%'
            ,@AccOut = '____________________\%'
            ,@ExclRes = 0
            ,@Flag = '                         '
            ,@InstrumentID = 0
            ,@BranchID = @BankID
            ,@DocTypeID = 0
            ,@Coupon = '____________________\%'
            ,@ProcType = 0
            ,@PaymentType = 0
            ,@PayUnique = 0
            ,@ClientDeb = @InstOwnerID
            ,@ClientCre = 0
            ,@Time1 = 0
            ,@Time2 = 0
            ,@Qty1 = $0.0000
            ,@BatchIDSearch = 0
            ,@ExclBatchIDSearch = 0
            ,@Qty2 = $0.0000
            ,@OpCodeSearch = 0
            ,@ExclOpCodeSearch = 0
            ,@ExclProcTypeSearch = 0
            ,@PrioritySearch = 0
            ,@ExclPrioritySearch = 0
            ,@ExclPaymentTypeSearch = 0
            ,@Weight = 0
            ,@DayMonthPlat = '____'
            ,@UserResMainDebID = 0
            ,@UserResMainCreID = 0
            ,@DebClientResident = 0
            ,@CreClientResident = 0
            ,@ParentConfirmed = 0
            ,@NumberExt = '_________________________'
            ,@UserID = 0
            ,@ExclAccDeb = 0
            ,@ExclAccCre = 0
            ,@ExclAccIn = 0
            ,@ExclAccOut = 0
            ,@ExclConfirmed = 0
            ,@CurrTranCode = '_____'
            ,@PS = '________/____/____/_/_'
        
        
        IF @RetVal <> 0
        BEGIN
            ROLLBACK TRAN
            GOTO _ERROR
        END
    END -- открытие счета
    
    -- документ Дт 47423 Кт 70601
    EXEC @RetVal = TDocumentPlat_F_Insert
         @DealTransactID = @DealTransactID OUT	-- 1 --
        ,@InstrumentID = 1558	-- фин. операция
        ,@DocNumber = @NumDoc	--номер документа
        ,@BatchID = @BatchID	-- DSIDENTIFIER  = NULL,     -- пачка
        ,@OpCode = 9	--DSIDENTIFIER  = NULL,     -- вид операции
        ,@Date = @OperDate	-- smalldatetime = NULL,     -- дата
        ,@Confirmed = 1	--tinyint       = NULL,     -- статус документа
        ,@Qty = @Qty	--money         = NULL,     -- сумма
        ,-- плательщик
         @BankIn = @BankID	--DSIDENTIFIER  = NULL,     -- банк
        ,@AccInID = @DebtAcc	--DSIDENTIFIER  = NULL,     -- счет клиента (передаем для корректности ФСМ)
        ,@AccIn = @DebtAccBrief	--varchar(25)   = NULL,     -- счет клиента
        ,@KppIn = @KPP	--varchar(9)    = NULL,     -- КПП клиента
        ,@InnIn = @INN	--varchar(15)   = NULL,     -- ИНН клиента
        ,@NameIn = @OwnerName	--varchar(255)  = NULL,     -- наименование клиента
        ,-- получатель
         @BankOut = @BankID	--DSIDENTIFIER  = NULL,     -- банк
        ,@AccOutID = @ResourceCreID	--DSIDENTIFIER  = NULL,      -- счет клиента (передаем для корректности ФСМ)
        ,@AccOut = @ResourceCreBrief	--varchar(25)   = NULL,     -- счет клиента
        ,@KppOut = '165801001'	--varchar(9)    = NULL,     -- КПП клиента
        ,@InnOut = '1653016689'	--varchar(15)   = NULL,     -- ИНН клиента
        ,@NameOut = @CreName	-- varchar(255)  = NULL,     -- наименование клиента
        ,--
         @DocDate = @OperDate	-- smalldatetime = NULL,     -- дата документа
        ,@TermDate = @OperDate	-- smalldatetime = NULL,     -- срок
        ,--@ProcType              = @ProcType, -- DSIDENTIFIER  = NULL,     -- вид обработки
         @Priority = 5	--DSIDENTIFIER  = NULL,     -- очередность
        ,@PaymentType = 2010000000311	-- DSIDENTIFIER  = NULL,     -- вид платежа
        ,@Comment = @Comment	--DSCOMMENT     = NULL,     -- назначение платежа
        ,@ResDebID = @DebtAcc	--  DSIDENTIFIER  = NULL,     -- счет по дебету
        ,@ResCreID = @ResourceCreID	--  DSIDENTIFIER  = NULL,     -- счет по кредиту
        ,@CommingDate = @OperDate	--varchar(255)  = NULL,     -- датв поступления в банк платежа
        ,@SaveClient = 0 -- int = NULL 1 сохранить инф о клиенте получателе
    
    IF @RetVal <> 0
    BEGIN
        ROLLBACK TRAN
        GOTO _ERROR
    END
    
    -- документ Дт 40702 Кт 47423 На картотеку
    EXEC @RetVal = TDocumentPlat_F_Insert
         @DealTransactID = @DealTransactID OUT	-- 1 --
        ,@InstrumentID = @InstrumentID	-- фин. операция
        ,@DocNumber = @NumDoc	--номер документа
        ,@BatchID = @BatchID	-- DSIDENTIFIER  = NULL,     -- пачка
        ,@OpCode = 17	--DSIDENTIFIER  = NULL,     -- вид операции
        ,@Date = @OperDate	-- smalldatetime = NULL,     -- дата
        ,@Confirmed = @Status	--tinyint       = NULL,     -- статус документа
        ,@Qty = @Qty	--money         = NULL,     -- сумма
        ,-- плательщик
         @BankIn = @BankID	--DSIDENTIFIER  = NULL,     -- банк
        ,@AccInID = @ResourceDebID	--DSIDENTIFIER  = NULL,     -- счет клиента (передаем для корректности ФСМ)
        ,@AccIn = @ResourceDebBrief	--varchar(25)   = NULL,     -- счет клиента
        ,@KppIn = @KPP	--varchar(9)    = NULL,     -- КПП клиента
        ,@InnIn = @INN	--varchar(15)   = NULL,     -- ИНН клиента
        ,@NameIn = @OwnerName	--varchar(255)  = NULL,     -- наименование клиента
        ,-- получатель
         @BankOut = @BankID	--DSIDENTIFIER  = NULL,     -- банк
        ,@AccOutID = @DebtAcc	--DSIDENTIFIER  = NULL,      -- счет клиента (передаем для корректности ФСМ)
        ,@AccOut = @DebtAccBrief	--varchar(25)   = NULL,     -- счет клиента
        ,@KppOut = @KPP	--varchar(9)    = NULL,     -- КПП клиента
        ,@InnOut = @INN	--varchar(15)   = NULL,     -- ИНН клиента
        ,@NameOut = @OwnerName	-- varchar(255)  = NULL,     -- наименование клиента
        ,--
         @DocDate = @OperDate	-- smalldatetime = NULL,     -- дата документа
        ,@TermDate = @OperDate	-- smalldatetime = NULL,     -- срок
        ,--@ProcType              = @ProcType, -- DSIDENTIFIER  = NULL,     -- вид обработки
         @Priority = 5	--DSIDENTIFIER  = NULL,     -- очередность
        ,@PaymentType = 2010000000311	-- DSIDENTIFIER  = NULL,     -- вид платежа
        ,@Comment = @Comment	--DSCOMMENT     = NULL,     -- назначение платежа
        ,@ResDebID = @ResourceDebID	--  DSIDENTIFIER  = NULL,     -- счет по дебету
        ,@ResCreID = @DebtAcc	--  DSIDENTIFIER  = NULL,     -- счет по кредиту
        ,@Flag = @Flags	--char(25)      = NULL,     -- флаги
        ,@ResKartID = @CouponID	--DSIDENTIFIER  = NULL,     -- счет картотеки
        ,@CommingDate = @OperDate	--varchar(255)  = NULL,     -- датв поступления в банк платежа
        ,@SaveClient = 0 -- int = NULL 1 сохранить инф о клиенте получателе
    
    
    IF @RetVal <> 0
    BEGIN
        ROLLBACK TRAN
        GOTO _ERROR
    END
    
    COMMIT TRAN
    
    
    SELECT @Qty = 0
END

    RETURN 0

_ERROR:
    RETURN @RetVal
