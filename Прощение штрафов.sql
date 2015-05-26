/************************************************************
 * Code formatted by SoftTree SQL Assistant � v6.2.107
 * Time: 16.04.2015 19:31:18
 ************************************************************/

DECLARE @ReportDate SMALLDATETIME
SET @ReportDate = '20150401'

DECLARE @Number VARCHAR(30)
SET @Number = '���/489/09-07/01'

DECLARE @ContractID NUMERIC(15, 0)
DECLARE @InstrumentID NUMERIC(15, 0)
DECLARE @BankProductID NUMERIC(15, 0)

SELECT 
	@ContractID = ContractID,
	@InstrumentID = InstrumentID, 
	@BankProductID = BankProductID
FROM
	tContract WITH (NOLOCK)
WHERE
	number LIKE CHAR(37) + @Number + CHAR(37)
	AND InstrumentID IN (2010000000750,
	                     2010000000825,
	                     2010000000836,
	                     2010000001762,
	                     2010000001763)

SELECT @ContractID, @InstrumentID, @BankProductID

DECLARE @Rate FLOAT
DECLARE @NewRate FLOAT

SET @NewRate = 12.00

SELECT @Rate = ci.Interest FROM tConsInterest  ci  WITH (NOLOCK) 
WHERE ci.ObjectID = @ContractID
AND ci.InterestType = 216 
AND ci.Interest > 0

SELECT @Rate 

IF OBJECT_ID('tempdb..#contract') IS NOT NULL DROP TABLE #contract	
CREATE TABLE #contract
(
	ContractID numeric(15, 0)
)
INSERT #contract SELECT @ContractID

-- ������ �������� �� �������� -----------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#AccInner') IS NOT NULL
    DROP TABLE #AccInner

CREATE TABLE #AccInner
(
        ContractID     NUMERIC(15, 0),
        ResourceID     NUMERIC(15, 0)
)

CREATE UNIQUE INDEX x1 ON #AccInner(ContractID)


DECLARE @DepParentID        DSIDENTIFIER,        -- �������� ����������������
        @DepRepaymentID     DSIDENTIFIER,        -- �������� ��������� - ���/�����
        @DepAccrualID       DSIDENTIFIER   -- �������� ��������� - ���/���

SELECT @DepParentID = d.DepartmentID
FROM   tDepartment d(NOLOCK INDEX = XAK3tDepartment)
WHERE  d.Brief = '���������'

SELECT @DepRepaymentID = ID
FROM   tConfigParam(NOLOCK INDEX = XAK0tConfigParam)
WHERE  SYSNAME = 'REPAYMENT_DEPARTMENT_ID'

SELECT @DepAccrualID = ID
FROM   tConfigParam(NOLOCK INDEX = XAK0tConfigParam)
WHERE  SYSNAME = 'ACCRUAL_DEPARTMENT_ID'

-- ������� ���� ������ ����� ��������
DELETE pResource
FROM   pResource WITH (ROWLOCK INDEX = XPKpResource)
WHERE  spid = @@spid

DELETE pResList
FROM   pResList WITH (ROWLOCK INDEX = XPKpResList)
WHERE  spid = @@spid

DELETE pDepResList
FROM   pDepResList WITH (ROWLOCK INDEX = XPKpDepResList)
WHERE  spid = @@spid


-- ���������� ������� ������ ����������� �����
INSERT #AccInner
SELECT 
	d.ContractID,
	al.ResourceID
FROM
	#contract d
	INNER JOIN tContract c WITH (NOLOCK) ON  d.ContractID = c.ContractID
	INNER JOIN tConsAccountLink al with (NOLOCK INDEX = XIE1tConsAccountLink) ON  al.ContractID = d.ContractID
	INNER JOIN tTypeAccLink ta WITH (NOLOCK INDEX = XIE3tTypeAccLink) ON  ta.TypeAccLinkID = al.RuleID AND ta.ObjectID = c.InstrumentID
	INNER JOIN tLinkedAccType lt WITH (NOLOCK INDEX = XPKtLinkedAccType) ON  ta.AccType = lt.LinkedAccTypeID AND lt.PropVal = 112
WHERE
	ta.RelType = 1
	AND ta.LinkType = 0


    
-- ������ �������� �� �������� ����� ������
INSERT pResource
  (
    SPID,
    ResourceID,
    Num,
    DepID1,
    DepID2
  )
---- ������� ������� ������������� - ������/���������
--select @@spid, ResourceID, 2, d.DepartmentID, @DepAccrualID     
--from tDepartment d  (NOLOCK INDEX=XAK2tDepartment), #AccInner
--where d.ParentID = @DepParentID                     
--and d.Brief    = '����������'       
--    union all 
-- ������� ������� ������������� - ��������/��������                      
--select @@spid, ResourceID, 255-2, d.DepartmentID, @DepRepaymentID     
--from tDepartment d  (NOLOCK INDEX=XAK2tDepartment), #AccInner
--where d.ParentID = @DepParentID                     
--and d.Brief    = '����������'  
--    union all
-- ������� ������� ������������� - ������/���������
/*SELECT @@spid,
       ResourceID,
       3,
       d.DepartmentID,
       @DepAccrualID
FROM   tDepartment d(NOLOCK INDEX = XAK2tDepartment),
       #AccInner
WHERE  d.ParentID = @DepParentID
       AND d.Brief = '����������' 
UNION ALL
-- ������� ������� ������������� - ��������/��������                      
SELECT @@spid,
       ResourceID,
       255 -3,
       d.DepartmentID,
       @DepRepaymentID
FROM   tDepartment d(NOLOCK INDEX = XAK2tDepartment),
       #AccInner
WHERE  d.ParentID = @DepParentID
       AND d.Brief = '����������'
UNION ALL*/
---- ���� �������� �� ���� ���� ������������� - ������/���������
--select @@spid, ResourceID, 4, d.DepartmentID, @DepAccrualID     
--from tDepartment d  (NOLOCK INDEX=XAK2tDepartment), #AccInner
--where d.ParentID = @DepParentID                     
--and d.Brief    = '����������'       
--    union all 
---- ���� �������� �� ���� ���� - ��������/��������                      
--select @@spid, ResourceID, 255-4, d.DepartmentID, @DepRepaymentID     
--from tDepartment d  (NOLOCK INDEX=XAK2tDepartment), #AccInner
--where d.ParentID = @DepParentID                     
--and d.Brief    = '����������'
--    union all
-- ������� �������� - ������/���������
/*SELECT @@spid,
       ResourceID,
       5,
       d.DepartmentID,
       @DepAccrualID
FROM   tDepartment d(NOLOCK INDEX = XAK2tDepartment),
       #AccInner
WHERE  d.ParentID = @DepParentID
       AND d.Brief = '��������' 
UNION ALL
-- ������� �������� - ��������/��������                      
SELECT @@spid,
       ResourceID,
       255 -5,
       d.DepartmentID,
       @DepRepaymentID
FROM   tDepartment d(NOLOCK INDEX = XAK2tDepartment),
       #AccInner
WHERE  d.ParentID = @DepParentID
       AND d.Brief = '��������'
UNION ALL*/
-- ������ �� ������� �������� - ������/���������
SELECT @@spid,
       ResourceID,
       6,
       d.DepartmentID,
       @DepAccrualID
FROM   tDepartment d(NOLOCK INDEX = XAK2tDepartment),
       #AccInner
WHERE  d.ParentID = @DepParentID
       AND d.Brief = '���������' 
UNION ALL
-- ������ �� ������� �������� - ��������/��������                      
SELECT @@spid,
       ResourceID,
       255 -6,
       d.DepartmentID,
       @DepRepaymentID
FROM   tDepartment d(NOLOCK INDEX = XAK2tDepartment),
       #AccInner
WHERE  d.ParentID = @DepParentID
       AND d.Brief = '���������'
UNION ALL
-- ������ �� ������� �������� - ������/���������
SELECT @@spid,
       ResourceID,
       7,
       d.DepartmentID,
       @DepAccrualID
FROM   tDepartment d(NOLOCK INDEX = XAK2tDepartment),
       #AccInner
WHERE  d.ParentID = @DepParentID
       AND d.Brief = '��������' 
UNION ALL
-- ������ �� ������� �������� - ��������/��������                      
SELECT @@spid,
       ResourceID,
       255 -7,
       d.DepartmentID,
       @DepRepaymentID
FROM   tDepartment d(NOLOCK INDEX = XAK2tDepartment),
       #AccInner
WHERE  d.ParentID = @DepParentID
       AND d.Brief = '��������'
UNION ALL
-- ������ �� ������� �� - ������/���������
SELECT @@spid,
       ResourceID,
       8,
       d.DepartmentID,
       @DepAccrualID
FROM   tDepartment d(NOLOCK INDEX = XAK2tDepartment),
       #AccInner
WHERE  d.ParentID = @DepParentID
       AND d.Brief = '����������' 
UNION ALL
-- ������ �� ������� �� - ��������/��������                      
SELECT @@spid,
       ResourceID,
       255 -8,
       d.DepartmentID,
       @DepRepaymentID
FROM   tDepartment d(NOLOCK INDEX = XAK2tDepartment),
       #AccInner
WHERE  d.ParentID = @DepParentID
       AND d.Brief = '����������'
--UNION ALL
/*
-- �������� 1 - ������/���������
SELECT @@spid,
       ResourceID,
       11,
       d.DepartmentID,
       @DepAccrualID
FROM   tDepartment d(NOLOCK INDEX = XAK2tDepartment),
       #AccInner
WHERE  d.ParentID = @DepParentID
       AND d.Brief = '��������' 
UNION ALL
-- �������� 1 - ��������/��������                      
SELECT @@spid,
       ResourceID,
       255 -11,
       d.DepartmentID,
       @DepRepaymentID
FROM   tDepartment d(NOLOCK INDEX = XAK2tDepartment),
       #AccInner
WHERE  d.ParentID = @DepParentID
       AND d.Brief = '��������'
*/


EXEC DepList_Rest @Date = @ReportDate



IF OBJECT_ID('tempdb..#sub') IS NOT NULL
    DROP TABLE #sub

CREATE TABLE #Sub
(
        ContractID     NUMERIC(15, 0),
        SubType        TINYINT -- ��� ��������
        ,
        RestBs         MONEY
)

INSERT #Sub
SELECT ai.ContractID,
       p.Num,
       p.RestBs
FROM   #AccInner ai,
       pDepResList p WITH (NOLOCK)
WHERE  ai.ResourceID = p.ResourceID
       AND p.spid = @@spid

CREATE INDEX x1 ON #sub(ContractID)



-- ������� ���� ������ ����� ��������
DELETE pResource
FROM   pResource WITH (ROWLOCK INDEX = XPKpResource)
WHERE  spid = @@spid

DELETE pResList
FROM   pResList WITH (ROWLOCK INDEX = XPKpResList)
WHERE  spid = @@spid

DELETE pDepResList
FROM   pDepResList WITH (ROWLOCK INDEX = XPKpDepResList)
WHERE  spid = @@spid


DECLARE @FineSum MONEY
DECLARE @SumToPay MONEY
DECLARE @Part FLOAT
DECLARE @NewFine MONEY
DECLARE @ForgiveSum MONEY
DECLARE @RestFine MONEY


SELECT @FineSum = SUM(RestBs) FROM #Sub
IF @FineSum = 0 RETURN
SELECT @NewFine = @FineSum * @NewRate / @Rate

SET @SumToPay = 1000
SET @SumToPay = isnull(NULLIF(@SumToPay, 0), @NewFine)
SET @Part = @SumToPay / @NewFine



SELECT @ForgiveSum = @FineSum * @Part - @SumToPay
SELECT @RestFine = @FineSum - @ForgiveSum - @SumToPay

SELECT @FineSum AS FineSum
, @Rate AS Rate
, @NewFine AS NewFine
, @NewRate AS NewRate
, @SumToPay AS SumToPay
, @Part AS Part
, @ForgiveSum AS ForgiveSum
, @RestFine AS RestFine
, it.Brief AS FinOper
, case when i.PropdealPart = 1 then i.Name else i.Name + ' ' +  i.Name1+ ' ' + i.Name2 END AS ClientName
, @Number AS Number
FROM tCOntract c  WITH (NOLOCK)
INNER JOIN tInstrument it  WITH (NOLOCK) ON it.InstrumentID = c.InstrumentID
INNER JOIN tInstitution i  WITH (NOLOCK) ON i.InstitutionID = c.InstitutionID
WHERE c.ContractID = @ContractID
 
 