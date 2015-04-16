/************************************************************
 * Code formatted by SoftTree SQL Assistant © v6.2.107
 * Time: 26.03.2015 14:14:18
 ************************************************************/

DECLARE @ReportDate SMALLDATETIME

SET @ReportDate = '20150331' 

IF OBJECT_ID('tempdb..#contract') IS NOT NULL
    DROP TABLE #contract
	
CREATE TABLE #contract
(
	ContractID        NUMERIC(15, 0),
	CtrNumber         VARCHAR(50),
	ClientID          NUMERIC(15, 0),
	ClientName        VARCHAR(400),
	BankProductID     NUMERIC(15, 0),
	BankProduct       VARCHAR(250),
	SubdivisionID     NUMERIC(15, 0),
	CtrState          VARCHAR(50),
	InterestRate      FLOAT NULL,
)

INSERT #contract
SELECT 
	c.ContractID,
	LTRIM(RTRIM(c.Number))  AS CtrNumber,
	i.InstitutionID,
	CASE 
	     WHEN i.PropdealPart = 1 THEN i.Name
	     ELSE i.Name + ' ' + i.Name1 + ' ' + i.Name2
	END                     AS ClientName,
	bp.BankProductID,
	bp.Name,
	ISNULL(NULLIF(c.BranchExtID, 0), c.BranchID) AS SubDivisionID,
	n.Brief                 AS CtrState,
	NULL                    AS InterestRate
FROM
	tContract c WITH (NOLOCK)
	INNER JOIN tInstitution i WITH (NOLOCK INDEX = XPKtInstitution) ON  i.InstitutionID = c.InstitutionID
	INNER JOIN tBankProduct bp WITH (NOLOCK) ON  bp.BankProductID = c.BankProductID
	INNER JOIN tObject o WITH (NOLOCK INDEX = XAK1tObject) ON  o.id = c.ContractID AND o.ObjectTypeID = 105
	INNER JOIN tProtocol p WITH (NOLOCK INDEX = XPKtProtocol) ON  p.ProtocolID = o.CurrProtocolID
	INNER JOIN tTransition t WITH (NOLOCK INDEX = XPKtTransition) ON  t.TransitionID = p.TransitionID
	INNER JOIN tNode n WITH (NOLOCK INDEX = XPKtNode) ON  n.NodeID = t.TargetStateID
WHERE
	c.InstrumentID IN (2010000000750,
	                   2010000000825,
	                   2010000000836,
	                   2010000001762,
	                   2010000001763)
	AND c.DateTo = '19000101'
	AND n.Brief IN ('Предоставл', 'КуплПред', 'НеоплВовр', 'КуплНеопл')
ORDER BY
       c.DateFrom DESC

-- типы ставок
IF OBJECT_ID('tempdb..#tPrcType') IS NOT NULL
        DROP TABLE #tPrcType
CREATE TABLE #tPrcType(PrcType INT)

INSERT #tPrcType
SELECT 211       

-- ставки на продукте
IF OBJECT_ID('tempdb..#tProductPrc') IS NOT NULL
        DROP TABLE #tProductPrc
        
CREATE TABLE #tProductPrc
        (
            BankProductID NUMERIC(15 , 0)
        ,   PrcType INT
        ,   PrcVal FLOAT NULL
        ,   PrcBaseID NUMERIC(15 , 0)
        )

    
  INSERT #tProductPrc
    SELECT bp.BankProductID -- Продукт
    ,      ci.InterestType -- Тип проц ставки
    ,      ci.Interest -- Величина проц ставки
    ,      ci.ParentID -- Базовая проц ставка
    FROM   tBankProduct bp WITH(NOLOCK)-- Банковский продукт
    INNER JOIN tBPConsCondPartner bpp WITH(NOLOCK) ON AND bpp.BankProductID = bp.BankProductID -- Соглашение с контрагентами в условиях банковского продукта
    INNER JOIN tProperty p WITH(NOLOCK) ON  AND bpp.SubjectID = p.PropVal AND p.PropType = 151 -- Тип контрагента (заемщик в данном случае) 151
    INNER JOIN tCtrCtrRelation ccr WITH(NOLOCK) ON ccr.ParentContractID = bpp.BPConsCondPartnerID -- Связь договоров (для связи соглашения с КА с договором обслуживания)
    INNER JOIN tConsInstRelation cir WITH(NOLOCK) ON  ccr.ContractID = cir.ConsInstRelationID AND ccr.TypeLink = 4 -- Договор Обслуживания    
    INNER JOIN tConsInterest ci WITH(NOLOCK) -- Ставка на дату
    ,      #tPrcType pt
    WHERE  1 = 1

           AND ci.ObjectID = cir.ConsInstRelationID -- сами ставки вешаются на договор обслуживания
           AND ci.InterestType = ltp.PropVal -- тип истории ставки совпадает с типом проц ставки на договоре
           AND ci.InterestType = pt.PrcType
           AND ci.Date = (
                   SELECT MAX(ci2.Date)
                   FROM   tConsInterest ci2 WITH (NOLOCK)
                   WHERE  ci2.InterestType = ci.InterestType
                          AND ci2.ObjectID = ci.ObjectID
                          AND ci2.Date <= @ReportDate
               )

-- ставка по договору на дату отчета	
UPDATE c
SET    InterestRate = ci.Interest
FROM   #contract c
       INNER JOIN tConsInterest ci WITH (NOLOCK)
            ON  c.ContractID = ci.ObjectID
                AND ci.ObjType = 119
                AND ci.InterestType = 201
                AND ci.Date = (
                        SELECT 
                        	MAX(Date)
                        FROM
                        	tConsInterest ci2 WITH (NOLOCK)
                        WHERE
                        	ci2.ObjectID = c.ContractID
                        	AND ci2.ObjType = 119
                        	AND ci2.InterestType = 201
                        	AND ci2.Date <= @ReportDate
                    )

UPDATE c
SET    InterestRate = ci.Interest
FROM   #contract c
       INNER JOIN tConsInterest ci WITH (NOLOCK)
            ON  c.BankProductID = ci.ObjectID
                AND ci.ObjType = 2
                AND ci.InterestType = 201
                AND ci.Date = (
                        SELECT 
                        	MAX(Date)
                        FROM
                        	tConsInterest ci2 WITH (NOLOCK)
                        WHERE
                        	ci2.ObjectID = c.BankProductID
                        	AND ci2.ObjType = 2
                        	AND ci2.InterestType = 201
                        	AND ci2.Date <= @ReportDate
                    )
WHERE  c.InterestRate IS NULL

SELECT 
	*
FROM
	#contract
	