
--SELECT * FROM tInstitution WHERE ParentID = 2000

DECLARE @Today              SMALLDATETIME
       ,@ThisMonthBegin     SMALLDATETIME
       ,@ThisMonthEnd       SMALLDATETIME
       ,@PrevMonthBegin     SMALLDATETIME
       ,@PrevMonthEnd       SMALLDATETIME

SET @Today = CONVERT(SMALLDATETIME ,CONVERT(VARCHAR(10) ,GETDATE() ,112))

set @Today = '20150331'

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
from tInstitution i with (nolock) where InstitutionID = 2000

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



/*SELECT r.ResourceID
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
      , 0*/
SELECT COUNT(DISTINCT r.InstOwnerID)      
FROM
       tResource r(NOLOCK)
       inner JOIN tDealTransact dt WITH (NOLOCK INDEX = XIE9tDealTransact)
            ON  dt.ResourceID = r.ResourceID
            AND dt.Date BETWEEN '20150301' AND @Day24
            AND dt.Confirmed = 1
            AND dt.TransactType = 5
       inner JOIN tOperpart o WITH (NOLOCK INDEX=XIE4tOperPart)
            on o.DealTransactID = dt.DealTransactID
       LEFT OUTER JOIN tRKODealRelation dr  WITH (NOLOCK) ON dr.ParentID = dt.DealTransactID AND dr.RelType = 6
       inner join tResource r2 with (nolock) on r2.ResourceID = dt.ResourcePsvID

WHERE  1 = 1
       AND r.PropType = 51
       AND r.FundID = 2
       AND r.ResourceType = 1
       AND r.BalanceID = 2140
       --AND r.InstitutionID = @BranchID
       AND r.DateEnd = '19000101'
       and r.DateStart <= @Day24
       AND EXISTS (
               SELECT 1
               FROM   tObjClsRelation ocr(NOLOCK INDEX = XIE1tObjClsRelation)
                      INNER JOIN tObjClassifier oc(NOLOCK INDEX = XAK0tObjClassifier)
                           ON  ocr.ObjClassifierID = oc.ObjClassifierID
               WHERE  ocr.ObjType = 3
                      AND ocr.ObjectID = r.ResourceID
                      AND oc.ParentID = 2010000937818
                      AND oc.Brief IN ('ИК_Аб' ,'ИК_Аб2')
           )

       AND dt.UserID = 2010000011549
       /*and left(r2.Brief, 3) NOT IN ('420', '421', '422', '706')
       and left(r2.Brief, 5) NOT IN ('47422', '47423', '47427', '60322')
       AND not LEFT(r2.Brief, 3) BETWEEN '442' AND '473'
       AND dr.ChildID IS NULL
       AND substring(dt.NumberExt, 9, 1) != '1'*/
       and o.CharType = 1 and o.ResourceID = dt.ResourceID
            and o.Confirmed = 1
--GROUP BY
  --     r.ResourceID, r.Brief
       
SELECT * FROM tUser WHERE Brief = 'bss'       