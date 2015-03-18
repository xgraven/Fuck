SET DATEFORMAT YMD

DECLARE @DateFrom1 SMALLDATETIME
DECLARE @DateFrom2 SMALLDATETIME

SELECT @DateFrom1 = %DateFrom1!
SELECT @DateFrom2 = %DateFrom2!



DECLARE @DateTo1 SMALLDATETIME
DECLARE @DateTo2 SMALLDATETIME

SELECT @DateTo1 = %DateTo1!
SELECT @DateTo2 = %DateTo2! 


SELECT @DateFrom2 = ISNULL(NULLIF(@DateFrom2, '19000101'), '20201231')
SELECT @DateTo2   = ISNULL(NULLIF(@DateTo2,   '19000101'), '20201231') 
 
IF OBJECT_ID('tempdb..#client') IS NOT NULL DROP TABLE #client    


    
CREATE TABLE #client
(
         ClientID numeric(15, 0)
,    FIO VARCHAR(200)
,    BirthDate SMALLDATETIME        
,    PaspSeries VARCHAR(20)
,    PaspNumber VARCHAR(20)
,    PhoneMob VARCHAR(50)
,    PhoneHome VARCHAR(50)
,    PhoneWork VARCHAR(50)
,    EMail VARCHAR(50)
,    RegAddress VARCHAR(200)
,    FactAddress VARCHAR(200)
,    Reason VARCHAR(250)
,    JobPlace VARCHAR(250)
,    Salary VARCHAR(250)
,    LastCreditID NUMERIC(15, 0)
)


INSERT #client
SELECT i.InstitutionID, case when i.PropdealPart = 1 then i.Name else i.Name + ' ' +  i.Name1+ ' ' + i.Name2 END AS ClientName, 
ia.BirthDay,  
'', ''
,'','','', '' 
, '', ''
, '' AS Reason
, '', '' 
,0 AS LastCreditID
FROM tInstitution i WITH (NOLOCK)
INNER JOIN tInstAttr ia  WITH (NOLOCK) ON ia.InstitutionID = i.InstitutionID
WHERE EXISTS (SELECT 1 FROM tContract c WITH (NOLOCK) 
INNER JOIN tContractCredit cc  WITH (NOLOCK) ON cc.ContractCreditID = c.ContractID
WHERE c.InstitutionID = i.InstitutionID
AND c.DateTo != '19000101'
AND cc.CreditDateFrom BETWEEN @DateFrom1 AND @DateFrom2
AND c.DateTo BETWEEN @DateTo1 AND @DateTo2
AND DATEDIFF(mm, cc.CreditDateFrom, c.dateTo) >= 6 
AND c.InstrumentID IN (2010000000750, 2010000000825, 2010000000836, 2010000001762, 2010000001763));

/*
-- ищем последний погашенный кредит
WITH x AS (
        SELECT 
                cl.ClientID
                ,MAX(c.ContractID) AS MaxCreditID
        FROM
                #client cl
                INNER JOIN tContract c WITH (NOLOCK) ON  c.InstitutionID = cl.ClientID
                INNER JOIN tContractCredit cc  WITH (NOLOCK) ON  cc.ContractCreditID = c.ContractID
        WHERE
                c.DateTo != '19000101'
                AND DATEDIFF(mm ,cc.CreditDateFrom ,c.dateTo) >= 6
                AND c.InstrumentID IN (2010000000750
                                      ,2010000000825
                                      ,2010000000836
                                      ,2010000001762
                                      ,2010000001763)
        GROUP BY cl.ClientID
)
UPDATE c
SET    LastCreditID = x.MaxCreditID
FROM   #client c
       INNER JOIN x
            ON  c.ClientID = x.ClientID;
*/



--PRINT '-- удаляем с возрастом больше 59 лет и 5 месяцев'
--SELECT *
DELETE 
FROM #client 
WHERE DATEDIFF(mm, BirthDate, GETDATE()) > 59*12+5 ;



UPDATE c
SET PaspSeries = ltrim(rtrim(replace(il.DocSeries, ' ', ''))), PaspNumber = ltrim(rtrim(replace(il.NumDoc, ' ', '')))
FROM #client c
INNER JOIN tInstLicense il WITH(NOLOCK) ON il.InstitutionID = c.clientID
WHERE il.isDefault = 1 AND il.Failed = 0 AND il.DocTypeID = 20



UPDATE c
SET PhoneMob = ic.Brief
FROM #client c
INNER JOIN tInstContact ic WITH(NOLOCK) ON ic.InstitutionID = c.clientID AND ic.ContactTypeID = 4 AND ic.Flag = 0

UPDATE c
SET PhoneHome = ic.Brief
FROM #client c
INNER JOIN tInstContact ic WITH(NOLOCK) ON ic.InstitutionID = c.clientID AND ic.ContactTypeID = 2 AND ic.Flag = 0

UPDATE c
SET PhoneWork = ic.Brief
FROM #client c
INNER JOIN tInstContact ic WITH(NOLOCK) ON ic.InstitutionID = c.clientID AND ic.ContactTypeID = 3 AND ic.Flag = 0

UPDATE c
SET Email = ic.Brief
FROM #client c
INNER JOIN tInstContact ic WITH(NOLOCK) ON ic.InstitutionID = c.clientID AND ic.ContactTypeID = 7 AND ic.Flag = 0

UPDATE c
SET RegAddress = ia.Name
FROM #client c
INNER JOIN tInstAddress ia WITH(NOLOCK) ON ia.InstitutionID = c.clientID AND ia.AddressTypeID = 5 AND ia.sign & 2 = 0

UPDATE c
SET FactAddress = ia.Name
FROM #client c
INNER JOIN tInstAddress ia WITH(NOLOCK) ON ia.InstitutionID = c.clientID AND ia.AddressTypeID = 6 AND ia.sign & 2 = 0

UPDATE c
SET FactAddress = ia.Name
FROM #client c
INNER JOIN tInstAddress ia WITH(NOLOCK) ON ia.InstitutionID = c.clientID AND ia.AddressTypeID = 2 AND ia.sign & 2 = 0
WHERE c.FactAddress = ''

--SELECT * FROM tAddressType tct WITH(NOLOCK)




--PRINT '-- удаляем сотрудников Головы'
DELETE c
--SELECT c.*, i.Failed, i.Blocked  
FROM #client c 
INNER JOIN tInststaff i  WITH (NOLOCK) ON i.InstUserID = c.clientID
WHERE i.InstitutionID = 2000

--PRINT '-- и филиалов и отделений'
DELETE c
--SELECT c.*, i.Failed, i.Blocked  
FROM #client c 
INNER JOIN tInststaff i  WITH (NOLOCK) ON i.InstUserID = c.clientID
INNER JOIN tInstitution p  WITH (NOLOCK) ON p.InstitutionID = i.InstitutionID
WHERE p.ParentID = 2000


--PRINT '-- удаляем нежелательных по фио и дате рождения'

DELETE c
--SELECT distinct c.*, convert(nvarchar(20), c.BirthDate, 112), tbl.GR, CONVERT(DATETIME, tbl.GR) 
FROM #client c
INNER JOIN databus.dbo.tBlackListAll tbl WITH(NOLOCK) ON tbl.NAMEU = c.FIO AND CONVERT(DATETIME, isnull(tbl.GR, '19000101')) = CONVERT(DATETIME, c.BirthDate)


--PRINT '-- удаляем нежелательных по фио и паспорту'
DELETE c
--SELECT c.*, convert(nvarchar(20), c.BirthDate, 112), tbl.GR, CONVERT(SMALLDATETIME, tbl.GR) 
FROM #client c
INNER JOIN databus.dbo.tBlackListAll tbl WITH(NOLOCK) ON tbl.NAMEU = c.FIO AND c.PaspNumber = tbl.RG

 


-- считаем просрочку по завершенным кредитам


IF OBJECT_ID('tempdb..#badLoanAcc') IS NOT NULL
    DROP TABLE #badLoanAcc

CREATE TABLE #badLoanAcc
(
        ContractID     DSIDENTIFIER,
        BadCount       INT NULL,
        BadMax         INT NULL,
        BadCurrent     INT NULL,
        BadTotal       INT NULL,
        BadLast        INT NULL,
        CountLess30    INT NULL,
        PrevBadDate    SMALLDATETIME NULL
);

IF OBJECT_ID('tempdb..#badLoanOper') IS NOT NULL DROP TABLE #badLoanOper
CREATE TABLE #badLoanOper
(
        ContractID DSIDENTIFIER
,    OperDate   SMALLDATETIME
,        OperQty           DSMONEY
,        RestBs     DSMONEY
,    IsNew      INT
);

IF OBJECT_ID('tempdb..#badLoanTerms') IS NOT NULL DROP TABLE #badLoanTerms
CREATE TABLE #badLoanTerms
(
        ContractID DSIDENTIFIER
,    FromDate   SMALLDATETIME
,    RepayDate  SMALLDATETIME
,        Term                INT
);

IF OBJECT_ID('tempdb..#badLoanTerms2') IS NOT NULL DROP TABLE #badLoanTerms2
CREATE TABLE #badLoanTerms2
(
        ContractID DSIDENTIFIER
,    FromDate   SMALLDATETIME
,    RepayDate  SMALLDATETIME
,        Term                INT
);

IF OBJECT_ID('tempdb..#badLoanTerms21') IS NOT NULL DROP TABLE #badLoanTerms21
CREATE TABLE #badLoanTerms21
(
        ContractID DSIDENTIFIER
,    RepayDate  SMALLDATETIME
,        Term                INT
);


insert #BadLoanAcc (c.ContractID) select ContractID
FROM
#client cl
INNER JOIN tContract c  WITH (NOLOCK) ON cl.ClientID = c.institutionID
WHERE c.InstrumentID IN (2010000000750, 2010000000825, 2010000000836, 2010000001762, 2010000001763)

exec VKAB_Report_BadLoanCalc5 @StartDate = '20150301', @ReportDate = '20150316', @TermCalcType = 2;

--PRINT '-- удаляем у кого есть текущая просрочка'
DELETE cl
--SELECT cl.*, bla.BadCurrent
FROM #client cl
INNER JOIN tContract c  WITH (NOLOCK) ON cl.ClientID = c.institutionID
INNER JOIN #badLoanAcc bla ON bla.ContractID = c.ContractID
WHERE bla.BadCurrent > 0

--PRINT '-- удаляем у кого есть просрочка общей длительностью больше 30 дней'
DELETE cl
--SELECT cl.*, bla.BadCurrent
FROM #client cl
INNER JOIN tContract c  WITH (NOLOCK) ON cl.ClientID = c.institutionID
INNER JOIN #badLoanAcc bla ON bla.ContractID = c.ContractID
WHERE bla.BadTotal > 30

--PRINT '-- удаляем у кого есть больше трех просрочек'
DELETE cl
--SELECT cl.*, bla.BadCurrent
FROM #client cl
INNER JOIN tContract c  WITH (NOLOCK) ON cl.ClientID = c.institutionID
INNER JOIN #badLoanAcc bla ON bla.ContractID = c.ContractID
WHERE bla.BadCount > 3




SELECT 
        cl.*
        , it.Brief as FinOper
        , c.Amount
        , isnull(bla.BadCount, 0) AS BadCount
        , isnull(bla.BadTotal, 0) AS BadTotal
        , cc.CreditDateFrom
        , c.DateTo
        , sd.Name as SDName
        , ltrim(rtrim(c.Number)) as Number
        , '@' as FormatText
FROM
        #client cl
        INNER JOIN tContract c WITH (NOLOCK) ON  c.InstitutionID = cl.ClientID
        INNER JOIN tInstrument it  WITH (NOLOCK) ON it.InstrumentID = c.InstrumentID
        INNER JOIN tInstitution sd  WITH (NOLOCK) ON sd.InstitutionID = isnull(NULLIF(c.BranchExtID, 0), c.BranchID)
        INNER JOIN tContractCredit cc  WITH (NOLOCK) ON  cc.ContractCreditID = c.ContractID
        LEFT OUTER JOIN #badLoanAcc bla ON bla.ContractID = c.ContractID
WHERE
        c.DateTo != '19000101'
        AND cc.CreditDateFrom BETWEEN @DateFrom1 AND @DateFrom2
     AND c.DateTo BETWEEN @DateTo1 AND @DateTo2
        AND DATEDIFF(mm ,cc.CreditDateFrom ,c.dateTo) >= 6
        AND c.InstrumentID IN (2010000000750
                              ,2010000000825
                              ,2010000000836
                              ,2010000001762
                              ,2010000001763)
     and not exists (select 1 
     from tObjClsRelation ocr WITH (NOLOCK)
          INNER JOIN tObjClassifier oc  WITH (NOLOCK) ON ocr.ObjClassifierID = oc.ObjClassifierID 
          WHERE oc.ParentID = 2010000928659
          AND oc.ObjType = 30 and ocr.ObjectID = c.ContractID)   
                                     
ORDER BY cl.FIO, c.ContractID  