declare @BranchID numeric(15, 0)
select @BranchID = 2000 --2010000385084

--SELECT * FROM tInstitution WHERE ParentID = 2000

DECLARE @Today              SMALLDATETIME
       ,@ThisMonthBegin     SMALLDATETIME
       ,@ThisMonthEnd       SMALLDATETIME
       ,@PrevMonthBegin     SMALLDATETIME
       ,@PrevMonthEnd       SMALLDATETIME

SET @Today = CONVERT(SMALLDATETIME ,CONVERT(VARCHAR(10) ,GETDATE() ,112))


SET @ThisMonthBegin = DATEADD(dd ,1 -DAY(@Today) ,@Today)
SET @ThisMonthEnd = DATEADD(dd ,-1 ,DATEADD(m ,1 ,@ThisMonthBegin))
SET @PrevMonthBegin = DATEADD(m ,-1 ,@ThisMonthBegin)
SET @PrevMonthEnd = DATEADD(dd ,-1 ,DATEADD(m ,1 ,@PrevMonthBegin))

DECLARE @Day24 SMALLDATETIME

SET @Day24 = DATEADD(dd, 23, @ThisMonthBegin)


   
declare @Comment4 varchar(210)
declare @MonthName varchar (50)
select @MonthName = case month(@ThisMonthBegin)
when 1 then 'январь'
when 2 then 'февраль'                          
when 3 then 'март'                          
when 4 then 'апрель'                          
when 5 then 'май'                          
when 6 then 'июнь'                          
when 7 then 'июль'                          
when 8 then 'август'                          
when 9 then 'сентябрь'                          
when 10 then 'октябрь'                          
when 11 then 'ноябрь'                          
when 12 then 'декабрь'                          
else 'Жулдыбрь'
end + ' ' + convert (varchar(4), YEAR (@ThisMonthBegin))

select @Comment4 = 'За ведение рублевого счета за (месяц) ' +
@MonthName + ' года согласно тарифам Банка.'    

DECLARE @File VARCHAR(50)
SELECT
        @File = ISNULL(@File ,'Нач_') + rtrim(ltrim(convert(varchar(13), BranchNumber)))+'_Ведение.txt'
from tInstitution i with (nolock) where InstitutionID = @BranchID

IF OBJECT_ID('tempdb..#PayCount') IS NOT NULL DROP TABLE #PayCount	
  
-- количество проведенных платежей и отправленных смс
CREATE TABLE #PayCount
(
    ResourceID NUMERIC(15 ,0)
   ,Accnum VARCHAR(35)
   ,PayType VARCHAR(25)
   ,PayCnt INT
   ,PayAccID NUMERIC(15 ,0)
   ,PayAccnum VARCHAR(35)   
   ,PayCode INT
   ,PaySum MONEY
   ,PayComment VARCHAR(255)
   ,FactQty MONEY
)

-- количество платежей по ВСЕМ счетам клиента (по дебету) 
-- В качестве дебетовых оборотов по расчетному счету не рассматриваются: 
-- операции по перечислению в счет погашения обязательств перед Банком, 
-- в том числе оплата комиссионного вознаграждения Банку 
-- (на балансовые счета Банка № 420 - 422, 442 - 473, 47422, 47423, 47427, 60322, , 706);     

       
INSERT #PayCount
SELECT r.ResourceID
      ,r.Brief
      ,'ВедСч'
      ,SUM(
           CASE 
                WHEN ISNULL(dt.DealTransactID ,0) = 0 THEN 0
                ELSE 1
           END
       )
      ,r.ResourceID
      ,r.Brief
      ,4
      ,150   --- ТАРИФ ТУТ!
      ,@Comment4
      , 0
FROM   
       tResource r(NOLOCK)
       inner JOIN tDealTransact dt WITH (NOLOCK INDEX = XIE9tDealTransact)
            ON  dt.ResourceID = r.ResourceID
            AND dt.Date BETWEEN @ThisMonthBegin AND @Today
            AND dt.Confirmed = 1
            AND dt.TransactType = 5
       LEFT OUTER JOIN tRKODealRelation dr  WITH (NOLOCK) ON dr.ParentID = dt.DealTransactID AND dr.RelType = 6     
       inner JOIN tOperpart o WITH (NOLOCK INDEX=XIE4tOperPart) 
            on o.DealTransactID = dt.DealTransactID 
             
       inner join tResource r2 with (nolock) on r2.ResourceID = dt.ResourcePsvID      
            
WHERE  1 = 1
       AND r.PropType = 51
       AND r.ResourceType = 1
       AND r.BalanceID = 2140
       AND r.InstitutionID = @BranchID
       AND r.DateEnd = '19000101'
       AND NOT EXISTS (
               SELECT 1
               FROM   tObjClsRelation ocr(NOLOCK INDEX = XIE1tObjClsRelation)
                      INNER JOIN tObjClassifier oc(NOLOCK INDEX = XAK0tObjClassifier)
                           ON  ocr.ObjClassifierID = oc.ObjClassifierID
               WHERE  ocr.ObjType = 3
                      AND ocr.ObjectID = r.ResourceID
                      AND oc.ParentID = 2010000937818
                      AND oc.Brief IN ('ИК_Аб' ,'ИК_Аб2') 
           )
      
       and left(r2.Brief, 3) NOT IN ('420', '421', '422', '706') 
       and left(r2.Brief, 5) NOT IN ('47422', '47423', '47427', '60322')
       AND not LEFT(r2.Brief, 3) BETWEEN '442' AND '473'
       AND dr.ChildID IS NULL 
       AND not substring(dt.NumberExt, 9, 1) = '1'
       and o.CharType = 1 and o.ResourceID = dt.ResourceID     
            and o.Confirmed = 1 
GROUP BY
       r.ResourceID, r.Brief
       
       
delete #PayCount where PayCnt = 0 and PayType = 'ВедСч'       
       
SELECT Accnum, r.Name, i.Name, u.FIOBrief, u.Brief FROM 
#PayCount p 
INNER JOIN tResource r  WITH (NOLOCK) ON r.ResourceID = p.ResourceID
INNER JOIN tInstitution i  WITH (NOLOCK) ON i.InstitutionID = r.SubDivisionID
INNER JOIN tUser u  WITH (NOLOCK) ON u.UserID = r.UserMainID




-- ищем факт оплаты в этом месяце
UPDATE pc
SET    pc.FactQty = o1.Qty
FROM   #PayCount pc
       INNER JOIN tOperpart o1 WITH (NOLOCK INDEX = XAK1tOperpart)
            ON  o1.ResourceID = pc.PayAccID
                AND o1.OperDate BETWEEN @ThisMonthBegin AND @ThisMonthEnd
                AND o1.Confirmed = 1
                AND o1.CharType = 1
       INNER JOIN tOperpart o2 WITH (NOLOCK INDEX = XPKtOperpart)
            ON  o2.OperationID = o1.OperationID
                AND o2.CharType = -1
       INNER JOIN tResource r2 WITH (NOLOCK INDEX = XPKtResource)
            ON  r2.ResourceID = o2.ResourceID
WHERE  r2.Brief LIKE '70601810_____1210101'
       AND o1.Qty = pc.PaySum
       AND pc.PayCode IN (1 ,2)


DELETE #PayCount WHERE  PaySum <= FactQty


SELECT
        CONVERT(VARCHAR(8) ,@Today ,112)  AS OperDate
,        @File AS                            FileN
,        LEFT(c.PayAccNum ,20)            AS PayAccNum
,        r.Name                           AS ClientName
,        c.PayCnt                         AS PayCnt
,        c.PaySum                         AS PayQty
,        c.PayCode                        AS PayCode
,        c.PayComment                     AS Comment
,        r.Brief                          AS AccountNumber
,        c.PayAccID
,        c.FactQty
FROM   #PayCount c
       INNER JOIN tResource r(NOLOCK INDEX = XPKtResource) ON  c.ResourceID = r.ResourceID
WHERE  1 = 1
ORDER BY
       c.PayType
      ,c.PayAccNum     
 