
/****** Object:  StoredProcedure [dbo].[ConsPortfolio_CalcNominal]    Script Date: 04/23/2015 19:25:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER procedure [dbo].[ConsPortfolio_CalcNominal]
                 @ConsSalePortfolioID     DSIDENTIFIER,
                 @CurrentDate             DSOPERDAY   ,
                 @ActionID                DSIDENTIFIER = null,
                 @Cnt                     DSINT_KEY   output
as

  set rowcount 0                            
declare @RetVal int, @trancount int    
select @RetVal = 0, @trancount = @@trancount 


  declare @DateReduction     DSOPERDAY,
          @Msg               DSVARFULLNAME,
          @MarginProfit      DSFLOAT,
          @InstrumentID      DSIDENTIFIER,
          @NodeID            DSIDENTIFIER,
          @DealProtocolID    DSIDENTIFIER,
          @OperSetID         DSIDENTIFIER,
          @TrueChildID       DSIDENTIFIER,
          @CurrProtocolID    DSIDENTIFIER,
          @BranchID          DSIDENTIFIER,
          @InterfaceObjectID DSIDENTIFIER,
          @MinID             DSIDENTIFIER,
          @MaxID             DSIDENTIFIER,
          @Offset            DSIDENTIFIER,
          @Delta             DSINT_KEY,
          @ConsSaleDetailID  DSIDENTIFIER,
          @ProtocolNumber    DSIDENTIFIER,
          @ActionType        DSINT_KEY   ,
          @ContractID        DSIDENTIFIER,
          @ObjectTypeID      DSIDENTIFIER,
          @RowCount          DSINT_KEY   ,
          @TypeFinResultID   DSINT_KEY,
          @CurrencyID        DSIDENTIFIER,
          @Portf_payinst_alg DSIDENTIFIER,
          @InstructID        DSIDENTIFIER,
          @RelationID        DSIDENTIFIER,
          @SubPortfolioID    DSIDENTIFIER,
          @BIC               DSBIC,
          @CorAccount        DSACC_SWIFT,
          @Account           DSACC_SWIFT, 
          @AccountID         DSIDENTIFIER,
          @INN               DSBIC,
          @PayeeName         DSCOMMENT,
          @Brief             DSBRIEFNAME,
          @Name              DSVARFULLNAME,          
          @InstitutionID     DSIDENTIFIER,
          @TotalAmount       DSMONEY

  select @DateReduction     = c.DateReduction,
         @MarginProfit      = c.MarginProfit,
         @InstrumentID      = c.InstrumentID,
         @InterfaceObjectID = i.InterfaceObjectID,
         @BranchID          = c.BranchID,
         @TypeFinResultID   = c.TypeFinResultID,
         @ObjectTypeID      = case i.InterfaceObjectID
                                when 417         then 191
                                when 442    then 206
                              end,
         @CurrencyID        = CurrencyID                              
    from tConsSalePortfolio       c WITH (NOLOCK INDEX=XPKtConsSalePortfolio)
   inner join tConsInstrumentSync i WITH (NOLOCK INDEX=XPKtConsInstrumentSync)
           on i.InstrumentID = c.InstrumentID
   where c.ConsSalePortfolioID = @ConsSalePortfolioID
  
  option (FORCE ORDER, LOOP JOIN, KEEPFIXED PLAN)

  if IsNull(@DateReduction,'19000101') = '19000101'
  begin
    select @RetVal = 31721
    GoTo RET_VAL
  end

  if @DateReduction < @CurrentDate
  begin
    select @RetVal = 31722
    GoTo RET_VAL
  end

  if isNull(@ActionID, 0) = 0
    exec @RetVal = FCD_Cons_GetNodeIDByAttr
                     @NodeID       = @ActionID output,
                     @InstrumentID = @InstrumentID,
                     @ActionType   = 111

  exec FCD_CON_FindLstAction
               @ContractID    = @ConsSalePortfolioID,
               @OnDate        = @CurrentDate        ,
               @FinOperID     = @InstrumentID       ,
               @ObjectTypeID  = @ObjectTypeID

  select @TrueChildID = StateID
    from pAPI_SM_ActionState WITH (NOLOCK INDEX=XPKpAPI_SM_ActionState)
   where SPID     = @@SPID
     and ActionID = @ActionID
  

  exec @RetVal = FCD_Cons_DealProtocol_Add2
                   @DealProtocolID   = @DealProtocolID output,
                   @DealID           = @ConsSalePortfolioID,
                   @Number           = @ObjectTypeID,
                   @InstrumentID     = @InstrumentID,
                   @OperSetID        = @ActionID,
                   @DateSet          = @CurrentDate,
                   @ObjectID         = @ActionID,
                   @TrueChildID      = @TrueChildID,
                   @Comment          = ''

  if @RetVal != 0
    GoTo RET_VAL


      begin
 set rowcount 5000 
 declare @_TryDel_Var271909 DSSPID 
 while 1 = 1 
 begin 
   delete pConsPrePay 
     from pConsPrePay p WITH (ROWLOCK INDEX=XIE1pConsPrePay READPAST) 
    where p.SPID = @@spid 
   option (KEEPFIXED PLAN) 
   if @@rowcount < 5000 
   begin 
     select @_TryDel_Var271909 = min(p.SPID) 
       from pConsPrePay p WITH (NOLOCK INDEX=XIE1pConsPrePay) 
      where p.SPID = @@spid 
     option (KEEPFIXED PLAN) 
      
     if @_TryDel_Var271909 is not null begin 
       set rowcount 0         
       delete pConsPrePay 
         from pConsPrePay p WITH (ROWLOCK INDEX=XIE1pConsPrePay) 
        where p.SPID = @@spid 
       option (KEEPFIXED PLAN) 
     end 
     break 
   end 
 end 
 set rowcount 0 
end
    begin
 set rowcount 5000 
 declare @_TryDel_Var281910 DSSPID 
 while 1 = 1 
 begin 
   delete pConsPrePay 
     from pConsPrePay p WITH (ROWLOCK INDEX=XIE1pConsPrePay READPAST) 
    where p.SPID = -@@spid 
   option (KEEPFIXED PLAN) 
   if @@rowcount < 5000 
   begin 
     select @_TryDel_Var281910 = min(p.SPID) 
       from pConsPrePay p WITH (NOLOCK INDEX=XIE1pConsPrePay) 
      where p.SPID = -@@spid 
     option (KEEPFIXED PLAN) 
      
     if @_TryDel_Var281910 is not null begin 
       set rowcount 0         
       delete pConsPrePay 
         from pConsPrePay p WITH (ROWLOCK INDEX=XIE1pConsPrePay) 
        where p.SPID = -@@spid 
       option (KEEPFIXED PLAN) 
     end 
     break 
   end 
 end 
 set rowcount 0 
end
        begin
 set rowcount 5000 
 declare @_TryDel_Var291911 DSSPID 
 while 1 = 1 
 begin 
   delete pConsAccrual_SumInterval 
     from pConsAccrual_SumInterval p WITH (ROWLOCK INDEX=XPKpConsAccrual_SumInterval READPAST) 
    where p.SPID = @@spid 
   option (KEEPFIXED PLAN) 
   if @@rowcount < 5000 
   begin 
     select @_TryDel_Var291911 = min(p.SPID) 
       from pConsAccrual_SumInterval p WITH (NOLOCK INDEX=XPKpConsAccrual_SumInterval) 
      where p.SPID = @@spid 
     option (KEEPFIXED PLAN) 
      
     if @_TryDel_Var291911 is not null begin 
       set rowcount 0         
       delete pConsAccrual_SumInterval 
         from pConsAccrual_SumInterval p WITH (ROWLOCK INDEX=XPKpConsAccrual_SumInterval) 
        where p.SPID = @@spid 
       option (KEEPFIXED PLAN) 
     end 
     break 
   end 
 end 
 set rowcount 0 
end
  declare InstrumentCursorPre insensitive cursor for
  select c.InstrumentID
    from tCtrCtrRelation r WITH (NOLOCK INDEX=XE1tCtrCtrRelation)
   inner join tContract c WITH (NOLOCK INDEX=XPKtContract)
           on c.ContractID = r.ContractID
   where r.ParentContractID = @ConsSalePortfolioID
     and r.TypeLink         = 24
   group by c.InstrumentID
   

  open InstrumentCursorPre

  fetch InstrumentCursorPre into @InstrumentID

  while (@@FETCH_STATUS = 0)
  begin

    select @ContractID = 1
    while isNull(@ContractID, 0) > 0
    begin 
          begin
 set rowcount 5000 
 declare @_TryDel_Var301932 DSSPID 
 while 1 = 1 
 begin 
   delete pContractPaySchedule 
     from pContractPaySchedule p WITH (ROWLOCK INDEX=XIE0pContractPaySchedule READPAST) 
    where p.SPID = @@spid 
   option (KEEPFIXED PLAN) 
   if @@rowcount < 5000 
   begin 
     select @_TryDel_Var301932 = min(p.SPID) 
       from pContractPaySchedule p WITH (NOLOCK INDEX=XIE0pContractPaySchedule) 
      where p.SPID = @@spid 
     option (KEEPFIXED PLAN) 
      
     if @_TryDel_Var301932 is not null begin 
       set rowcount 0         
       delete pContractPaySchedule 
         from pContractPaySchedule p WITH (ROWLOCK INDEX=XIE0pContractPaySchedule) 
        where p.SPID = @@spid 
       option (KEEPFIXED PLAN) 
     end 
     break 
   end 
 end 
 set rowcount 0 
end

      set rowcount 100
      insert pContractPaySchedule
             (SPID,
              ContractID)
      select @@spid,
             r.ContractID
        from tCtrCtrRelation r WITH (NOLOCK INDEX=XE1tCtrCtrRelation)
       inner join tContract c WITH (NOLOCK INDEX=XPKtContract)
               on c.ContractID = r.ContractID
       where r.ParentContractID = @ConsSalePortfolioID
         and r.TypeLink         = 24
         and c.InstrumentID     = @InstrumentID
         and r.ContractID       > @ContractID
       order by r.ContractID
      option (FORCE ORDER, LOOP JOIN, KEEPFIXED PLAN)
      select @RowCount = @@rowcount

      set rowcount 0

      

    

      if @RowCount > 0
      begin
        exec @RetVal = Cons_Mass_PrePayment
                         @DateCtr = @CurrentDate

        select @ContractID = 0

        select @ContractID = max(ContractID)
          from pContractPaySchedule WITH (NOLOCK INDEX=XIE0pContractPaySchedule)
         where SPID = @@spid
    

        insert pConsPrePay WITH (rowlock)
               (
               SPID,
               ContractID,
               ActionType,
               DepartmentID,
               NodeID,
               QtyTotal,
               QtyPlan,
               QtyPre,
               QtyBefore,
               Prt,
               Flag
               )
        select -@@Spid,
               ContractID,
               ActionType,
               DepartmentID,
               NodeID,
               QtyTotal,
               QtyPlan,
               QtyPre,
               QtyBefore,
               Prt,
               Flag
          from pConsPrePay  WITH (NOLOCK INDEX=XIE1pConsPrePay)
         where Spid = @@Spid 

-----------------------!!!!!!!!!!!!!!!!!!!!!!! Алякин А

update pConsPrePay
   set QtyPlan = QtyPlan + (select QtyPlan from pConsPrePay p
                                          where p.SPID       = @@spid
                                            and p.ActionType = 6
                                            and p.ContractID = @ContractID)
  from pConsPrePay p
 where p.SPID       = -@@spid
   and p.ActionType = 4

update pConsPrePay
   set QtyPlan = QtyPlan + (select QtyPlan from pConsPrePay p
                                          where p.SPID       = @@spid
                                            and p.ActionType = 3
                                            and p.ContractID = @ContractID)
  from pConsPrePay p
 where p.SPID       = -@@spid
   and p.ActionType = 2

-----------------------!!!!!!!!!!!!!!!!!!!!!!!

           begin
 set rowcount 5000 
 declare @_TryDel_Var311997 DSSPID 
 while 1 = 1 
 begin 
   delete pConsPrePay 
     from pConsPrePay p WITH (ROWLOCK INDEX=XIE1pConsPrePay READPAST) 
    where p.SPID = @@spid 
   option (KEEPFIXED PLAN) 
   if @@rowcount < 5000 
   begin 
     select @_TryDel_Var311997 = min(p.SPID) 
       from pConsPrePay p WITH (NOLOCK INDEX=XIE1pConsPrePay) 
      where p.SPID = @@spid 
     option (KEEPFIXED PLAN) 
      
     if @_TryDel_Var311997 is not null begin 
       set rowcount 0         
       delete pConsPrePay 
         from pConsPrePay p WITH (ROWLOCK INDEX=XIE1pConsPrePay) 
        where p.SPID = @@spid 
       option (KEEPFIXED PLAN) 
     end 
     break 
   end 
 end 
 set rowcount 0 
end
      end
      else
        select @ContractID = 0
    end
    

  fetch InstrumentCursorPre into @InstrumentID
  end


  close InstrumentCursorPre
  deallocate InstrumentCursorPre

      begin
 set rowcount 5000 
 declare @_TryDel_Var322011 DSSPID 
 while 1 = 1 
 begin 
   delete pConsPrePay 
     from pConsPrePay p WITH (ROWLOCK INDEX=XIE1pConsPrePay READPAST) 
    where p.SPID = @@spid 
   option (KEEPFIXED PLAN) 
   if @@rowcount < 5000 
   begin 
     select @_TryDel_Var322011 = min(p.SPID) 
       from pConsPrePay p WITH (NOLOCK INDEX=XIE1pConsPrePay) 
      where p.SPID = @@spid 
     option (KEEPFIXED PLAN) 
      
     if @_TryDel_Var322011 is not null begin 
       set rowcount 0         
       delete pConsPrePay 
         from pConsPrePay p WITH (ROWLOCK INDEX=XIE1pConsPrePay) 
        where p.SPID = @@spid 
       option (KEEPFIXED PLAN) 
     end 
     break 
   end 
 end 
 set rowcount 0 
end
  insert pConsPrePay WITH (rowlock)
         (
         SPID,
         ContractID,
         ActionType,
         DepartmentID,
         NodeID,
         QtyTotal,
         QtyPlan,
         QtyPre,
         QtyBefore,
         Prt,
         Flag
         )
  select @@Spid,
         ContractID,
         ActionType,
         DepartmentID,
         NodeID,
         QtyTotal,
         QtyPlan,
         QtyPre,
         QtyBefore,
         Prt,
         Flag
    from pConsPrePay  WITH (NOLOCK INDEX=XIE1pConsPrePay)
   where SPID = -@@Spid

    begin
 set rowcount 5000 
 declare @_TryDel_Var332040 DSSPID 
 while 1 = 1 
 begin 
   delete pConsPrePay 
     from pConsPrePay p WITH (ROWLOCK INDEX=XIE1pConsPrePay READPAST) 
    where p.SPID = -@@spid 
   option (KEEPFIXED PLAN) 
   if @@rowcount < 5000 
   begin 
     select @_TryDel_Var332040 = min(p.SPID) 
       from pConsPrePay p WITH (NOLOCK INDEX=XIE1pConsPrePay) 
      where p.SPID = -@@spid 
     option (KEEPFIXED PLAN) 
      
     if @_TryDel_Var332040 is not null begin 
       set rowcount 0         
       delete pConsPrePay 
         from pConsPrePay p WITH (ROWLOCK INDEX=XIE1pConsPrePay) 
        where p.SPID = -@@spid 
       option (KEEPFIXED PLAN) 
     end 
     break 
   end 
 end 
 set rowcount 0 
end 

  
  select @TotalAmount = sum(QtyPlan)
    from pConsPrePay    p WITH (NOLOCK INDEX=XIE1pConsPrePay)
   where p.SPID = @@Spid
     and p.QtyPlan <> 0
     and p.ActionType in (  2, 3, 4, 6,              
  5, 8, 19, 20,       
  21, 22, 7, 40,    
  41, 42, 43, 9,
  10, 11)
  

  insert pConsPrePay
         (SPID,
          ContractID,
          ActionType,
          QtyPlan,
          QtyPre ,
          QtyTotal,
          QtyBefore,
          Prt)
  select @@spid,
         p.ContractID          ,
         100,
         case 
           when @TypeFinResultID = 0 
             then Round(sum(p.QtyPlan) * ( (@MarginProfit / 100) - 1), 2)
           when @TypeFinResultID = 1
             then Round((@MarginProfit - @TotalAmount) * sum(p.QtyPlan)/@TotalAmount, 2)
         end,
         0,
         0,
         0,
         0
    from pConsPrePay    p WITH (NOLOCK INDEX=XIE1pConsPrePay)
   inner join tContract c WITH (NOLOCK INDEX=XPKtContract)
           on c.ContractID = p.ContractID
   where p.Spid = @@Spid
     and p.QtyPlan <> 0
     and p.ActionType in (  2, 3, 4, 6,              
  5, 8, 19, 20,       
  21, 22, 7, 40,    
  41, 42, 43, 9,
  10, 11)
   group by p.ContractID

  

  delete tConsSaleDetail
    from tConsSaleDetail WITH (ROWLOCK INDEX=XPKtConsSaleDetail)
   where ConsSalePortfolioID  = @ConsSalePortfolioID

  select @MinID = min(p.ID)
    from pConsPrePay p WITH (NOLOCK INDEX=XIE1pConsPrePay)
   where p.SPID = @@Spid
  

  select @MaxID = max(p.ID)
    from pConsPrePay p WITH (NOLOCK INDEX=XIE1pConsPrePay)
   where p.SPID = @@Spid
  

  select @Delta = @MaxID - @MinID + 1

  

  if isNull(@Delta, 0) <> 0
  begin
    begin                              
  declare @_Offs34    DSIDENTIFIER,  
          @_Delay35   varchar(20),   
          @_TranVar36 int,           
          @_TryNum37  int            
  
begin                                                  
select @_TranVar36 = @@trancount                      
exec FCD_39_GetNextNumberByBrief @Range = @Delta, @Brief = 'ConsSaleDetail', @Number = @ConsSaleDetailID out
  if (@@error <> 0) or (isnull(@ConsSaleDetailID, 0)=0) 
  begin                                              
    if @_TranVar36 = 0 and @@trancount > 0            
      rollback tran                                  
    raiserror ("Невозможно получить идентификатор для вставки записи !", 16, 1)  
  end                                                
  else                                               
  if @_TranVar36 = 0 and @@trancount > 0              
    rollback tran                                    
end                                                  

end

    insert tConsSaleDetail WITH (rowlock)
           (
           ConsSaleDetailID    ,
           ConsSalePortfolioID ,
           ContractID          ,
           DebtType            ,
           DebtAmount          ,
           FundID              ,
           OperDate            ,
           BranchID            ,
           BranchExtID         
           )
    select @ConsSaleDetailID + p.ID - @MinID,
           @ConsSalePortfolioID  ,
           p.ContractID          ,
           100,
           p.QtyPlan             ,
           c.FundID              ,
           @CurrentDate          ,
           c.BranchID            ,
           c.BranchExtID
      from pConsPrePay    p WITH (NOLOCK INDEX=XIE1pConsPrePay)
     inner join tContract c WITH (NOLOCK INDEX=XPKtContract)
             on c.ContractID = p.ContractID
     where p.Spid = @@Spid
       and p.QtyPlan <> 0
       and p.ActionType = 100
    option (FORCE ORDER, LOOP JOIN, KEEPFIXED PLAN)

    delete pConsPrePay
      from pConsPrePay    p WITH (ROWLOCK INDEX=XIE1pConsPrePay)
     where p.Spid = @@Spid
       and p.ActionType = 100
    option (FORCE ORDER, LOOP JOIN, KEEPFIXED PLAN)


    if @CurrencyID = 0
    begin
          begin
 set rowcount 5000 
 declare @_TryDel_Var382142 DSSPID 
 while 1 = 1 
 begin 
   delete pAccrObject 
     from pAccrObject p WITH (ROWLOCK INDEX=XIE0pAccrObject READPAST) 
    where p.SPID = @@spid 
   option (KEEPFIXED PLAN) 
   if @@rowcount < 5000 
   begin 
     select @_TryDel_Var382142 = min(p.SPID) 
       from pAccrObject p WITH (NOLOCK INDEX=XIE0pAccrObject) 
      where p.SPID = @@spid 
     option (KEEPFIXED PLAN) 
      
     if @_TryDel_Var382142 is not null begin 
       set rowcount 0         
       delete pAccrObject 
         from pAccrObject p WITH (ROWLOCK INDEX=XIE0pAccrObject) 
        where p.SPID = @@spid 
       option (KEEPFIXED PLAN) 
     end 
     break 
   end 
 end 
 set rowcount 0 
end

      insert pAccrObject
             (
             spid,
             RevalPosition,
             ID
             )              
      select @@spid,
             case 
                when @TypeFinResultID = 0 
              then Round(sum(p.QtyPlan) * ( (csm.Amount / 100) - 1), 2)
                when @TypeFinResultID = 1
              then Round(sum(p.QtyPlan) - csm.Amount, 2)
             end,                     
             csd.ConsSaleDetailID  
        from tConsSaleDetail    csd WITH (NOLOCK INDEX=XIE1tConsSaleDetail)
       inner join pConsPrePay    p   WITH (NOLOCK INDEX=XIE1pConsPrePay)
               on p.SPID = @@spid
              and p.QtyPlan <> 0
              and p.ActionType in (  2, 3, 4, 6,              
  5, 8, 19, 20,       
  21, 22, 7, 40,    
  41, 42, 43, 9,
  10, 11)
              and p.ContractID = csd.ContractID
       inner join tConsSaleMultiCurrency csm WITH (NOLOCK INDEX=XIE0tConsSaleMulticurrency)
               on csm.ConsSalePortfolioID = @ConsSalePortfolioID
              and csm.CurrencyID          =  csd.FundID 
       inner join tContract c WITH (NOLOCK INDEX=XPKtContract)
               on c.ContractID = csd.ContractID
       where csd.ConsSalePortfolioID = @ConsSalePortfolioID 
         and csd.DebtType            = 100
       group by p.ContractID, c.FundID, c.BranchID, c.BranchExtID, csm.Amount, csd.ConsSaleDetailID 
      option (FORCE ORDER, LOOP JOIN, KEEPFIXED PLAN)

      update tConsSaleDetail
         set DebtAmount = p.RevalPosition
        from pAccrObject p WITH (NOLOCK INDEX=XIE0pAccrObject)
       inner join tConsSaleDetail t  WITH (rowlock, updlock INDEX=XPKtConsSaleDetail)
          on t.ConsSaleDetailID = p.ID
       where p.SPID = @@spid    
      option (FORCE ORDER, LOOP JOIN, KEEPFIXED PLAN)
    end

    

    insert tConsSaleDetail WITH (rowlock)
           (
           ConsSaleDetailID    ,
           ConsSalePortfolioID ,
           ContractID          ,
           DebtType            ,
           DebtAmount          ,
           FundID              ,
           OperDate            ,
           BranchID            ,
           BranchExtID         
           )
    select @ConsSaleDetailID + p.ID - @MinID,
           @ConsSalePortfolioID,
           p.ContractID        ,
           p.ActionType        ,
           p.QtyPlan           ,
           c.FundID            ,
           @CurrentDate        ,
           c.BranchID          ,
           c.BranchExtID
      from pConsPrePay    p WITH (NOLOCK INDEX=XIE1pConsPrePay)
     inner join tContract c WITH (NOLOCK INDEX=XPKtContract)
             on c.ContractID = p.ContractID
     where p.Spid = @@Spid
       and p.ActionType in (  2, 3, 4, 6,              
  5, 8, 19, 20,       
  21, 22, 7, 40,    
  41, 42, 43, 9,
  10, 11)
       and p.QtyPlan <> 0
    option (FORCE ORDER, LOOP JOIN, KEEPFIXED PLAN)

    
  end
        begin
 set rowcount 5000 
 declare @_TryDel_Var392216 DSSPID 
 while 1 = 1 
 begin 
   delete pConsRelationPortfolio 
     from pConsRelationPortfolio p WITH (ROWLOCK INDEX=XPKpConsRelationPortfolio READPAST) 
    where p.SPID = @@spid 
   option (KEEPFIXED PLAN) 
   if @@rowcount < 5000 
   begin 
     select @_TryDel_Var392216 = min(p.SPID) 
       from pConsRelationPortfolio p WITH (NOLOCK INDEX=XPKpConsRelationPortfolio) 
      where p.SPID = @@spid 
     option (KEEPFIXED PLAN) 
      
     if @_TryDel_Var392216 is not null begin 
       set rowcount 0         
       delete pConsRelationPortfolio 
         from pConsRelationPortfolio p WITH (ROWLOCK INDEX=XPKpConsRelationPortfolio) 
        where p.SPID = @@spid 
       option (KEEPFIXED PLAN) 
     end 
     break 
   end 
 end 
 set rowcount 0 
end

  insert pConsRelationPortfolio WITH (rowlock)
         (
         SPID,
         RelType,
         BranchID
         )
  select @@Spid,
         26,
         c.BranchID
    from tConsSalePortfolio  sp WITH (NOLOCK INDEX=XPKtConsSalePortfolio)
   inner join tCtrCtrRelation r WITH (NOLOCK INDEX=XE1tCtrCtrRelation)
           on r.ParentContractID = sp.ConsSalePortfolioID
          and r.TypeLink         = 24
   inner join tContract       c WITH (NOLOCK INDEX=XPKtContract)
           on c.ContractID      = r.ContractID
          and c.BranchID       != @BranchID
   where sp.ConsSalePortfolioID = @ConsSalePortfolioID
  group by c.BranchID
  option (FORCE ORDER, LOOP JOIN, KEEPFIXED PLAN)

  select @RowCount = @@RowCount
  
  if @RowCount != 0
  begin   
    exec ContractSubPortfolio_Insert
           @SalePortfolioID = @ConsSalePortfolioID,
           @OnDate          = @CurrentDate
               
    exec FCD_Cons_tConfigParam
            @SysName = 'PORTFOLIO_PAYINSTR_ALG',
            @ID      = @Portf_payinst_alg output

    if @Portf_payinst_alg = 0 
    begin
      select @AccountID =  cal.ResourceID                  
        from tConsAccountLink   cal  WITH (NOLOCK INDEX=XIE1tConsAccountLink),
             tConsRuleAccSync   cras WITH (NOLOCK INDEX=XPKtConsRuleAccSync)
       where cal.ContractID = @ConsSalePortfolioID
         and cras.RuleID    = cal.RuleID
         and cras.PropVal   = 288
      option (FORCE ORDER, LOOP JOIN, KEEPFIXED PLAN)
           
      if isnull(@AccountId, 0) = 0
      begin
        insert pErrorLine WITH (rowlock)
               (
               SPID,
               Tag,
               Number,
               TextLine
               )
        select @@spid,
               '0',
               @ConsSalePortfolioID,
               'Создание платежной инструкции не возможно, отсутствует счет получателя на портфеле'       
        Goto RET_VAL
      end
           
            begin
 set rowcount 5000 
 declare @_TryDel_Var402276 DSSPID 
 while 1 = 1 
 begin 
   delete pAPI_Acc_ListID 
     from pAPI_Acc_ListID p WITH (ROWLOCK INDEX=XPKpAPI_Acc_ListID READPAST) 
    where p.SPID = @@spid 
   option (KEEPFIXED PLAN) 
   if @@rowcount < 5000 
   begin 
     select @_TryDel_Var402276 = min(p.SPID) 
       from pAPI_Acc_ListID p WITH (NOLOCK INDEX=XPKpAPI_Acc_ListID) 
      where p.SPID = @@spid 
     option (KEEPFIXED PLAN) 
      
     if @_TryDel_Var402276 is not null begin 
       set rowcount 0         
       delete pAPI_Acc_ListID 
         from pAPI_Acc_ListID p WITH (ROWLOCK INDEX=XPKpAPI_Acc_ListID) 
        where p.SPID = @@spid 
       option (KEEPFIXED PLAN) 
     end 
     break 
   end 
 end 
 set rowcount 0 
end
      insert pAPI_Acc_ListID WITH (rowlock)
             (
             spid,
             AccountID
             )
      select @@spid,
             @AccountId
                  
      exec  FCD_CCred_Acc_FindListByID                  
           
      select @Account = AccNumber       
        from pAPI_Acc_FindList    WITH (NOLOCK INDEX=XPKpAPI_Acc_FindList)
       where SPID = @@spid
      

      exec FCD_Cons_tConfigParam
             @SysName = 'INSTITUTIONID',
             @ID      = @InstitutionID output

      select @InstitutionID = isnull(@InstitutionID, 0)
          
      exec FCD_Consumer_gl_InstSel
             @InstitutionID = @InstitutionID,
             @BIC           = @BIC    output,
             @AccountCB     = @CorAccount output,
             @Name          = @Name   output,
             @INN           = @INN    output
                        
                        
      declare SubPortfolio_cursor insensitive cursor for
      select ContractID
        from pCtrCtrRelation WITH (NOLOCK INDEX=XIE1pCtrCtrRelation)
       where SPID             = @@spid
         and ParentContractID = @ConsSalePortfolioID
         and TypeLink         = 26
      

       open SubPortfolio_cursor
       fetch SubPortfolio_cursor into @SubPortfolioID

       while ( @@FETCH_STATUS = 0 )
       begin
         exec @RetVal = ConsPayInstruct_SingleInsert
                          @InstructID        = @InstructID        output,
                          @RelationID        = @RelationID        output,
                          @ContractID        = @SubPortfolioID          ,              
                          @Type              = 0                        ,
                          @Kind              = 0                        ,
                          @Priority          = 1                        ,
                          @Brief             = '1'                      ,
                          @Name              = @Name                    ,
                          @CurrencyID        = 2                        ,
                          @BIC               = @BIC                     ,                           
                          @CorAccount        = @CorAccount              ,                
                          @Account           = @Account                 ,
                          @AccountID         = @AccountID               ,
                          @INN               = @INN                     ,
                          @Flag              = 1                                     
                                       
              
         fetch SubPortfolio_cursor into @SubPortfolioID
       end
             
       if @RetVal = 0 
         exec @RetVal = ConsPayInstruct_Save
       
       deallocate SubPortfolio_cursor   
    end

  end 
  select @Cnt = 0

        begin
 set rowcount 5000 
 declare @_TryDel_Var412349 DSSPID 
 while 1 = 1 
 begin 
   delete pTmpID0 
     from pTmpID0 p WITH (ROWLOCK INDEX=XPKpTmpID0 READPAST) 
    where p.SPID = @@spid 
   option (KEEPFIXED PLAN) 
   if @@rowcount < 5000 
   begin 
     select @_TryDel_Var412349 = min(p.SPID) 
       from pTmpID0 p WITH (NOLOCK INDEX=XPKpTmpID0) 
      where p.SPID = @@spid 
     option (KEEPFIXED PLAN) 
      
     if @_TryDel_Var412349 is not null begin 
       set rowcount 0         
       delete pTmpID0 
         from pTmpID0 p WITH (ROWLOCK INDEX=XPKpTmpID0) 
        where p.SPID = @@spid 
       option (KEEPFIXED PLAN) 
     end 
     break 
   end 
 end 
 set rowcount 0 
end

  insert pTmpID0 WITH (rowlock)
         (
         spid,
         id
         )
  select @@spid,
         sd.ContractID   
    from tConsSaleDetail sd WITH (NOLOCK INDEX=XPKtConsSaleDetail)
   where sd.ConsSalePortfolioID = @ConsSalePortfolioID
   group by sd.ContractID
  having sum(abs(sd.DebtAmount)) = 0
  option (KEEPFIXED PLAN)

  select @Cnt = count(1)
    from pTmpID0 WITH (NOLOCK INDEX=XPKpTmpID0)
   where spid = @@spid
  option (FORCE ORDER, LOOP JOIN, KEEPFIXED PLAN)

RET_VAL:
      
return @RetVal
