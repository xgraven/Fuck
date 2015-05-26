
CREATE PROC VKAB_RefinCreateWDealCar (
	
 @ContractID NUMERIC(15, 0),
        
 @CarMark VARCHAR(50),
 @CarModel VARCHAR(50),
 @CarYear VARCHAR(50),
 @CarState VARCHAR(10),
 @CarWeight VARCHAR(10),
 @CarColor VARCHAR(50),

 @VIN   VARCHAR(50),
 @EngineNum VARCHAR(50),
 @ChassisNum VARCHAR(50),  
 
 @CarNumber VARCHAR(10),
 @CarRegion VARCHAR(5),

 @MarketQty MONEY,  -- рыночная
 @WarrQty MONEY,    -- залоговая
 @FairQty MONEY     -- справедлива  	
)

AS

SET NOCOUNT ON 

DELETE FROM pEntAttrValue WHERE SPID = @@spid  

-- номер двигателя      
EXEC VKAB_AddWarrDealAttrP @InstrumentID =  2010000000630, @AttributeID = 2010000000301, @PKey = 0, @Value =  @EngineNum --'NOMDVIG'
-- госномер
EXEC VKAB_AddWarrDealAttrP @InstrumentID =  2010000000630, @AttributeID = 2010000000316, @PKey = 0, @Value =  @CarNumber -- 'Х950ХВ'
-- регион
EXEC VKAB_AddWarrDealAttrP @InstrumentID =  2010000000630, @AttributeID = 2010000000317, @PKey = 0, @Value =  @CarRegion --'116'
-- номер кузова
EXEC VKAB_AddWarrDealAttrP @InstrumentID =  2010000000630, @AttributeID = 2010000000302, @PKey = 0, @Value =  @ChassisNum --'NOMKUZ'
-- марка
EXEC VKAB_AddWarrDealAttrP @InstrumentID =  2010000000630, @AttributeID = 2010000000299, @PKey = 0, @Value =  @CarMark --'MARKA'
-- модель
EXEC VKAB_AddWarrDealAttrP @InstrumentID =  2010000000630, @AttributeID = 2010000000300, @PKey = 0, @Value =  @CarModel --'МОДЕЛЬ'
-- состояние
IF @CarState = 'Новый'
EXEC VKAB_AddWarrDealAttrP @InstrumentID =  2010000000630, @AttributeID = 2010000000378, @PKey = 0, @Value =  'Новый'
ELSE
EXEC VKAB_AddWarrDealAttrP @InstrumentID =  2010000000630, @AttributeID = 2010000000378, @PKey = 1, @Value =  'Подержаный'	
-- VIN
EXEC VKAB_AddWarrDealAttrP @InstrumentID =  2010000000630, @AttributeID = 2010000000303, @PKey = 0, @Value =  @VIN --'VIN1234'
-- масса
EXEC VKAB_AddWarrDealAttrP @InstrumentID =  2010000000630, @AttributeID = 2010000001004, @PKey = 0, @Value =  @CarWeight
-- год
EXEC VKAB_AddWarrDealAttrP @InstrumentID =  2010000000630, @AttributeID = 2010000000318, @PKey = 0, @Value =  @CarYear
-- цвет
EXEC VKAB_AddWarrDealAttrP @InstrumentID =  2010000000630, @AttributeID = 2010000001150, @PKey = 0, @Value =  @CarColor       


DECLARE @CtrNum VARCHAR(50)
DECLARE @ClientID NUMERIC(15, 0)
DECLARE @InstrumentID NUMERIC(15, 0)
DECLARE @DateFrom SMALLDATETIME
DECLARE @DateTo SMALLDATETIME


SELECT @CtrNum = 'ДО ' + RTRIM(LTRIM(c.Number))
, @ClientID = c.InstitutionID
, @InstrumentID = c.InstrumentID
, @DateFrom = c.DateFrom
, @DateTo = cc.CreditDateTo 
FROM tCOntract c  WITH (NOLOCK)
INNER JOIN tContractCredit cc  WITH (NOLOCK) ON cc.ContractCreditID = c.ContractID 
WHERE c.ContractID = @ContractID

declare @ID        DSIDENTIFIER,
        @DealID    DSIDENTIFIER,
        @RetVal    int,
        @Flag      DSTINYINT

select @DealID    = 0,

       @Flag      = 0
       
       


/*
SET @CarMark = 'VAZ'
SET @CarModel = 'LADA'
SET @CarYear = '2012'

SET @VIN = 'VIN12345'
SET @EngineNum = 'DVIG1234567'
SET @ChassisNum = 'KUZOV123'*/


DECLARE @ObjName VARCHAR(250)

SELECT @ObjName = @CarMark + ' ' + @CarModel   

DECLARE @discount FLOAT

SELECT @discount = @MarketQty / @WarrQty                     


exec @RetVal = WCnt_DealInsert
                 @WarrantyCntID       = @ID output,
                 @DealID              = @DealID,
                 @InstrumentID        = 2010000000636,
                 @Brief               = '',
                 @Name                = @ObjName,
                 @InstitutionID       = 0,
                 @Num                 = 1,
                 @Price               = @MarketQty,
                 @Qty                 = @MarketQty,
                 @FundID              = 2,
                 @QtyApplied          = @WarrQty,
                 @Comment             = '',
                 @DepositPrice        = @WarrQty,
                 @MarginCallType      = 0,
                 @MarginCallValue     = 0,
                 @Discount            = @discount,
                 @Liquid              = 0,
                 @CorrectQty          = @FairQty,
                 @QualityFactor       = 0.0,
                 @Flag                = @Flag,
                 @UsePTable           = 1,
                 @InsurerID           = 0,
                 @InsuranceType       = 0,
                 @InsuranceNumber     = '',
                 @InsuranceDate       = '19000101',
                 @InsuranceDateLast   = '19000101',
                 @InsuranceQty        = $0.0000,
                 @InsuranceFundID     = 0,
                 @Location            = '',
                 @ManagerType         = 0,
                 @ManagerID           = 2010000591321, --- TO DO
                 @Usage               = 0,
                 @UsageCondition      = '',
                 @Alienation          = 0,
                 @AlienationCondition = '',
                 @Sale                = 0,
                 @SaleCondition       = '',
                 @NumberLC            = '',
                 @DateLC              = '19000101',
                 @InsurancePremium    = $0.0000,
                 @DateCollection      = '19000101',
                 @Comment1            = '',
                 @InsuranceDateFirst  = '19000101',
                 @SecurityType        = 0,
                 @InsCalcPremium      = 0









         
DECLARE @Days INT
SELECT @Days = DATEDIFF(dd, @DateFrom, @DateTo)         

exec @RetVal = WDeal_Insert
                 @DealID = @DealID output,
                 @DealType          = 0,
                 @InstitutionID     = @ClientID,
                 @InstrumentID      = 2010000000630,
                 @Number            = @CtrNum,
                 @Date              = @DateFrom,
                 @ValueDate         = @DateFrom,
                 @DateLast          = @DateTo,
                 @Days              = @Days,
                 @Qty               = @MarketQty,
                 @FundID            = 2,
                 @QtyApplied        = @WarrQty,
                 @SignCompID        = 0,
                 @SignCompBKID      = 0,
                 @SignContrID       = 0,
                 @SignContrBKID     = 0,
                 @InsurerID         = 0,
                 @InsuranceQty      = $0.0000,
                 @InsuranceNumber   = '',
                 @InsuranceDate     = '19000101',
                 @InsuranceDateLast = '19000101',
                 @Trader            = 2010000000869 -- UserID,
                 @Comment           = '',
                 @BranchID          = 2000,
                 @ExecWCnt_Link     = 1, -- переливаем из pWarrantyContent
                 @ParentDealID      = 0,
                 @WarrantyPresent   = 1,
                 @DateSignature     = '19000101',
                 @Responce          = 0,
                 @Insurance         = 0,
                 @BankProductID     = 2010000000004,
                 @ParentID          = @ContractID, -- ИД кредитного договора
                 @ParentInstrumentID = @InstrumentID, -- ИД ФО кредитного договора
                 @CorrectQty        = @FairQty,
                 @QualityFactor     = 0,
                 @NotaryID          = 0,
                 @NotaryDate        = '19000101',
                 @ContractNum       = '',
                 @BrokerID          = 0,
                 @BrocerDate        = '19000101',
                 @BrokerNumber      = '',
                 @Usage             = 0,
                 @UsageCondition    = '',
                 @Alienation        = 0,
                 @AlienationCondition = '',
                 @Sale              = 0,
                 @SaleCondition     = '',
                 @InsuranceFundID   = 0,
                 @Unfixed           = 0,
                 @NumberLC          = '',
                 @DateLC            = '19000101',
                 @AgreementID       = 0,
                 @AlgorythmID       = 39,
                 @InsurancePremium  = $0.0000,
                 @DateCollection    = '19000101',
                 @SecurityID        = 0,
                 @SecurityName      = '',
                 @InsuranceDateFirst= '19000101',
                 @SecurityType      = 0,
                 @ContractorID      = 0,
                 @InterfaceInput    = 1,
                 @InsCalcPremium    = 0



SELECT * FROM tUser WHERE UserID = 2010000000869        