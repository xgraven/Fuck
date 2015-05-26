SELECT * FROM tBankProduct WHERE brief = ' *НестанАК'

DECLARE @RetMessage VARCHAR(300)
DECLARE @ContractID NUMERIC(15 ,0)
 

EXEC [dbo].[VKAB_CreateRefinContract] 
       @pCreditNumber = 'TEST2ACC2' 
      ,@pInstrumentID  = 2010000001762-- 2010000001762 
      ,@pOperDate = '20150515'
      ,@pBranchID = 2010000382135
      ,@pClientID  = 2010000011038
      ,@pDateFrom = '20150416'
      ,@pDateTo = '20160416'
      ,@pPayDay = 16
      ,@pAmount = 100000
      ,@pAmountPrc = 500
      ,@pAnnQty = 9000
      ,@pPrcRate = 10.0
      ,@pFineRateLoan = 73.0
      ,@pFineRatePrc = 150.0

      ,@pRetMessage = @RetMessage OUTPUT
      ,@pContractID = @ContractID OUTPUT
                                                   
                                                   
SELECT @RetMessage, @ContractID


EXEC VKAB_GenRefinDocs @ContractID = 2010008986062, @LoanQty = 100000, @PrcQty = 500, @OperDate = '20150409', @Status = 1


SELECT * FROM tInstitution WHERE NAME LIKE '%уф%' AND ParentID = 2000