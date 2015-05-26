

-- номер двигателя      
EXEC VKAB_AddWarrDealAttrP @InstrumentID =  2010000000630, @AttributeID = 2010000000301, @PKey = 0, @Value =  'NOMDVIG'
-- госномер
EXEC VKAB_AddWarrDealAttrP @InstrumentID =  2010000000630, @AttributeID = 2010000000316, @PKey = 0, @Value =  'Х950ХВ'
-- регион
EXEC VKAB_AddWarrDealAttrP @InstrumentID =  2010000000630, @AttributeID = 2010000000317, @PKey = 0, @Value =  '116'
-- номер кузова
EXEC VKAB_AddWarrDealAttrP @InstrumentID =  2010000000630, @AttributeID = 2010000000302, @PKey = 0, @Value =  'NOMKUZ'
-- марка
EXEC VKAB_AddWarrDealAttrP @InstrumentID =  2010000000630, @AttributeID = 2010000000299, @PKey = 0, @Value =  'MARKA'
-- модель
EXEC VKAB_AddWarrDealAttrP @InstrumentID =  2010000000630, @AttributeID = 2010000000300, @PKey = 0, @Value =  'МОДЕЛЬ'
-- состояние
EXEC VKAB_AddWarrDealAttrP @InstrumentID =  2010000000630, @AttributeID = 2010000000378, @PKey = 1, @Value =  'Подержаный'
-- VIN
EXEC VKAB_AddWarrDealAttrP @InstrumentID =  2010000000630, @AttributeID = 2010000000303, @PKey = 0, @Value =  'VIN1234'
-- масса
EXEC VKAB_AddWarrDealAttrP @InstrumentID =  2010000000630, @AttributeID = 2010000001004, @PKey = 0, @Value =  '1530'
-- год
EXEC VKAB_AddWarrDealAttrP @InstrumentID =  2010000000630, @AttributeID = 2010000000318, @PKey = 0, @Value =  '2014'
-- цвет
EXEC VKAB_AddWarrDealAttrP @InstrumentID =  2010000000630, @AttributeID = 2010000001150, @PKey = 0, @Value =  'черный'       


SELECT * FROM pEntAttrValue WHERE SPID = @@spid      

ALTER PROC VKAB_AddWarrDealAttrP ( 
@InstrumentID DSIDENTIFIER, 
@AttributeID DSIDENTIFIER, 
@OnDate SMALLDATETIME = '19000101', 
@PKey DSIDENTIFIER = 0, 
@Value DSCOMMENT)

AS

    insert pEntAttrValue WITH (rowlock) 
         (
         SPID
        ,InterfaceType
        ,InstrumentID
        ,ObjectID
        ,AttributeID
        ,OnDate
        ,PKey
        ,Value
         )
  select @@spid
        ,0
        ,@InstrumentID
        ,0
        ,@AttributeID
        ,@OnDate
        ,@PKey
        ,@Value    


GO

GRANT EXEC ON VKAB_AddWarrDealAttrP TO public

declare @RetVal     int,
        @DealID     DSIDENTIFIER,
        @el         smallint,
        @Unfixed    int,
        @Qty        DSMONEY,
        @QtyApplied DSMONEY,
        @CorrectQty DSMONEY

select @Unfixed = 0

if @Unfixed = 0
  select @Qty        = $333333.0000 ,
         @QtyApplied = $222222.0000,
         @CorrectQty = $111111.0000
else
  select @Qty        = 0,
         @QtyApplied = 0,
         @CorrectQty = 0

exec @RetVal = WDeal_Insert
                 @DealID = @DealID output,
                 @DealType          = 0,
                 @InstitutionID     = 2010000591321,
                 @InstrumentID      = 2010000000630,
                 @Number            = 'NOMDOGOBESP',
                 @Date              = '20150410',
                 @ValueDate         = '20150410',
                 @DateLast          = '20160430',
                 @Days              = 386,
                 @Qty               = @Qty,
                 @FundID            = 2,
                 @QtyApplied        = @QtyApplied,
                 @SignCompID        = 0,
                 @SignCompBKID      = 0,
                 @SignContrID       = 0,
                 @SignContrBKID     = 0,
                 @InsurerID         = 0,
                 @InsuranceQty      = $0.0000,
                 @InsuranceNumber   = '',
                 @InsuranceDate     = '19000101',
                 @InsuranceDateLast = '19000101',
                 @Trader            = 2010000000869,
                 @Comment           = '',
                 @BranchID          = 2000,
                 @ExecWCnt_Link     = 1, -- переливаем из pWarrantyContent
                 @ParentDealID      = 0,
                 @WarrantyPresent   = 1,
                 @DateSignature     = '19000101',
                 @Responce          = 0,
                 @Insurance         = 0,
                 @BankProductID     = 2010000000004,
                 @ParentID          = 2010008986070, -- ИД кредитного договора
                 @ParentInstrumentID = 2010000001762, -- ИД ФО кредитного договора
                 @CorrectQty        = @CorrectQty,
                 @QualityFactor     = 0.7,
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
if exists(select Number
            from pWErrorLine WITH (NOLOCK index=XIE0pWErrorLine)
           where SPID = @@spid)
  select @el = 1
else
  select @el = 0

select @RetVal, @el, @DealID
