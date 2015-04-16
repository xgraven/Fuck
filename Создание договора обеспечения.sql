declare @ID        DSIDENTIFIER,
        @DealID    DSIDENTIFIER,
        @RetVal    int,
        @UsePTable DSTINYINT,
        @Flag      DSTINYINT

select @DealID    = 0,
       @UsePTable = 1,
       @Flag      = 0
       
       
DECLARE @Marka VARCHAR(50)
DECLARE @Model VARCHAR(50)
DECLARE @VIN   VARCHAR(50)
DECLARE @   VARCHAR(50)

SET @Marka = 'VAZ'
SET @Model = 'LADA'





       

exec @RetVal = WCnt_DealInsert
                 @WarrantyCntID       = @ID output,
                 @DealID              = @DealID,
                 @InstrumentID        = 2010000000636,
                 @Brief               = '',
                 @Name                = 'MAZDA',
                 @InstitutionID       = 0,
                 @Num                 = 1,
                 @Price               = 77000,
                 @Qty                 = 77000,
                 @FundID              = 2,
                 @QtyApplied          = 66000.01,
                 @Comment             = '',
                 @DepositPrice        = 66000.01,
                 @MarginCallType      = 0,
                 @MarginCallValue     = 0,
                 @Discount            = 0.857143,
                 @Liquid              = 0,
                 @CorrectQty          = 77000,
                 @QualityFactor       = 0.55,
                 @Flag                = @Flag,
                 @UsePTable           = @UsePTable,
                 @InsurerID           = 0,
                 @InsuranceType       = 0,
                 @InsuranceNumber     = '',
                 @InsuranceDate       = '19000101',
                 @InsuranceDateLast   = '19000101',
                 @InsuranceQty        = $0.0000,
                 @InsuranceFundID     = 0,
                 @Location            = '',
                 @ManagerType         = 0,
                 @ManagerID           = 2010000011038,
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

select @RetVal,
       @ID

/*
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
        ,@InterfaceType
        ,@InstrumentID
        ,@ObjectID
        ,@AttributeID
        ,@OnDate
        ,@PKey
        ,@Value
        
*/


declare @RetVal     int,
        @DealID     DSIDENTIFIER,
        @el         smallint,
        @Unfixed    int,
        @Qty        DSMONEY,
        @QtyApplied DSMONEY,
        @CorrectQty DSMONEY

select @Unfixed = 0

if @Unfixed = 0
  select @Qty        = $77000.0000 ,
         @QtyApplied = $66000.0100,
         @CorrectQty = $77000.0000
else
  select @Qty        = 0,
         @QtyApplied = 0,
         @CorrectQty = 0

exec @RetVal = WDeal_Insert
                 @DealID = @DealID output,
                 @DealType          = 0,
                 @InstitutionID     = 2010000011038,
                 @InstrumentID      = 2010000000630,
                 @Number            = 'ДОГ_ОБЕСП1',
                 @Date              = '20150409',
                 @ValueDate         = '20150409',
                 @DateLast          = '20160430',
                 @Days              = 387,
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
                 @ParentID          = 2010008986062, -- ИД кредитного договора
                 @ParentInstrumentID = 2010000001762, -- ИД ФО кредитного договора
                 @CorrectQty        = @CorrectQty,
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
if exists(select Number
            from pWErrorLine WITH (NOLOCK index=XIE0pWErrorLine)
           where SPID = @@spid)
  select @el = 1
else
  select @el = 0

select @RetVal, @el, @DealID
        