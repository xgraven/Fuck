--Form class: TAttributeData Query name: QrInsertAttrValue
--Base: testdb
declare @InterfaceType DSTINYINT
       ,@InstrumentID  DSIDENTIFIER
       ,@ObjectID      DSIDENTIFIER
       ,@AttributeID   DSIDENTIFIER
       ,@OnDate        smalldatetime
       ,@PKey          DSIDENTIFIER
       ,@Value         DSCOMMENT

select @InterfaceType = isnull(0 /* :InterfaceType */, 0)
      ,@InstrumentID  = isnull(2010000000630 /* :InstrumentID */, 0.0)
      ,@ObjectID      = isnull(0 /* :ObjectID */, 0.0)
      ,@AttributeID   = isnull(2010000000301 /* :AttributeID */, 0.0)
      ,@OnDate        = isnull('19000101', '19000101')
      ,@PKey          = isnull(0 /* :PKey */, 0.0)
      ,@Value         = isnull('NOMDVIG' /* :Value */, '')
      

select @InterfaceType = isnull(0 /* :InterfaceType */, 0)
      ,@InstrumentID  = isnull(2010000000630 /* :InstrumentID */, 0.0)
      ,@ObjectID      = isnull(0 /* :ObjectID */, 0.0)
      ,@AttributeID   = isnull(2010000000316 /* :AttributeID */, 0.0)
      ,@OnDate        = isnull('19000101', '19000101')
      ,@PKey          = isnull(0 /* :PKey */, 0.0)
      ,@Value         = isnull('GOSNOM' /* :Value */, '')
      
select @InterfaceType = isnull(0 /* :InterfaceType */, 0)
      ,@InstrumentID  = isnull(2010000000630 /* :InstrumentID */, 0.0)
      ,@ObjectID      = isnull(0 /* :ObjectID */, 0.0)
      ,@AttributeID   = isnull(2010000000317 /* :AttributeID */, 0.0)
      ,@OnDate        = isnull('19000101', '19000101')
      ,@PKey          = isnull(0 /* :PKey */, 0.0)
      ,@Value         = isnull('116' /* :Value */, '')

select @InterfaceType = isnull(0 /* :InterfaceType */, 0)
      ,@InstrumentID  = isnull(2010000000630 /* :InstrumentID */, 0.0)
      ,@ObjectID      = isnull(0 /* :ObjectID */, 0.0)
      ,@AttributeID   = isnull(2010000000302 /* :AttributeID */, 0.0)
      ,@OnDate        = isnull('19000101', '19000101')
      ,@PKey          = isnull(0 /* :PKey */, 0.0)
      ,@Value         = isnull('NOMKUZ' /* :Value */, '')      
      

CREATE PROC VKAB_AddWarrDealAttrP (
)
AS

GO

GRANT 

if exists (select 1
             from pEntAttrValue WITH (NOLOCK index=XAK0pEntAttrValue)
            where SPID          = @@spid
              and InterfaceType = @InterfaceType
              and ObjectID      = @ObjectID
              and InstrumentID  = @InstrumentID
              and AttributeID   = @AttributeID
              and OnDate        = @OnDate
          )
begin
  update pEntAttrValue
     set PKey  = @PKey
        ,Value = @Value
    from pEntAttrValue  WITH (rowlock, updlock INDEX=XAK0pEntAttrValue)
   where SPID          = @@spid
     and InterfaceType = @InterfaceType
     and ObjectID      = @ObjectID
     and InstrumentID  = @InstrumentID
     and AttributeID   = @AttributeID
     and OnDate        = @OnDate
end
else
begin
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
end
