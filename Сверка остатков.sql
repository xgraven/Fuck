declare @FO numeric(15,0)
select @FO = 2010000000825

declare @StartDate smalldatetime
declare @FinalDate smalldatetime



declare @ReportDate smalldatetime
select @ReportDate = '20150514'

-- список договоров
declare @tContract table
(
    ContractID numeric(15,0)
,   ClientID   numeric(15,0)
,   StartDate      smalldatetime -- дата выдачи    
,   LastPayDate    smalldatetime -- дата последней уплаты факта
,   MinPlanDate    smalldatetime -- первый непогашенный план    
)

-- план погашения
declare @tPlan table
(
    ContractID numeric (15,0)
,   PlanType tinyint -- тип данных (1-проценты начисление, 2- % погашение )
,   PlanSum  money
)

-- добавляем договора
insert @tContract
select c.ContractID, c.InstitutionID, cc.CreditDateFrom, cc.CreditDateFrom, cc.CreditDateFrom
from tContract c with (nolock), tContractCredit cc with (nolock)
where c.ContractID = cc.ContractCreditID and c.InstrumentID IN (2010000000825, 2010000000750, 2010000000836, 2010000001762, 2010000001763)
--and c.ContractID = 2010001151316
and c.BranchID in (2000,2010000418172,2010000385084)--2000-- 2010000418172
and c.DateTo = '19000101'

--SELECT * FROM tInstitution WHERE ParentID =2000

-- счета договора
declare @tAcc table
(
 ContractID numeric(15,0)   -- ID договора
,Type varchar(50)           -- тип счета
,ResourceID numeric(15,0)   -- ID счета
,ResBrief varchar(35)       -- Номер счета
,DateStart smalldatetime    -- Дата окрытия счета
,DateClose smalldatetime    -- Дата закрытия счета
,RestBS money               -- Остаток на счете
,Rest   money
)


--diasoft 7.2
INSERT @tAcc
SELECT c.ContractID, tal.Brief, r.ResourceID, r.Brief, r.DateStart, r.DateEnd, 0, 0
FROM @tContract c
        INNER JOIN tConsAccountLink al WITH (NOLOCK index=XIE1tConsAccountLink) ON al.ContractID = c.ContractID
        INNER JOIN tTypeAccLink  tal WITH (NOLOCK) ON tal.TypeAccLinkID = al.RuleID
        INNER JOIN tResource r (NOLOCK INDEX=XPKtResource) ON r.ResourceID=al.ResourceID




-- расчет остатков по счетам

DELETE pResource FROM pResource WITH (ROWLOCK INDEX=XPKpResource) WHERE spid = @@SPID
delete pResList where  spid = @@spid
insert pResource(spid, ResourceID, num) select distinct @@spid, ResourceID, 1 from @tAcc


exec AccList_Rest @Date = @ReportDate
update @tAcc set RestBs = p.RestBs from pResList p with (nolock), @tAcc a where p.spid = @@spid and a.ResourceID = p.ResourceID 

DELETE pResource FROM pResource WITH (ROWLOCK INDEX=XPKpResource) WHERE spid = @@SPID
delete pResList where  spid = @@spid

-- расчет остатков по субконто -----------------------------------------------------------------------------

declare @tAccInner table
(
  ContractID numeric(15,0)
, ResourceID numeric(15,0)

)


declare @DepParentID     DSIDENTIFIER,  -- Субконто КатегорияСредств
        @DepRepaymentID  DSIDENTIFIER,  -- Субконто ТипОперВУ - Упл/Погаш
        @DepAccrualID    DSIDENTIFIER   -- Субконто ТипОперВУ - Выд/Нач

select @DepParentID = d.DepartmentID from tDepartment d  (NOLOCK INDEX=XAK3tDepartment)
where d.Brief = 'КатСрдств'

select @DepRepaymentID = ID from tConfigParam (NOLOCK INDEX=XAK0tConfigParam)
where SysName = 'REPAYMENT_DEPARTMENT_ID'

select @DepAccrualID = ID from tConfigParam (NOLOCK INDEX=XAK0tConfigParam)
where SysName = 'ACCRUAL_DEPARTMENT_ID'

-- очистка врем таблиц перед ресчетом
delete pResource   where SPID = @@spid
delete pDepResList where SPID = @@spid


-- заполнение таблицы счетов внутреннего учета
insert @tAccInner
select d.ContractID, da.ResourceID
from 
    tLinkedAccType     lt  (NOLOCK INDEX=XPKtLinkedAccType),
    @tContract             d,  
    tContract           c  with (NOLOCK),
    tTypeAccLink       ta  (NOLOCK INDEX=XIE3tTypeAccLink),
    tConsAccountLink       da  (NOLOCK INDEX=XIE1tConsAccountLink)
where lt.PropVal        = 112
    and ta.RelType        = 1
    and ta.LinkType       = 0
    and ta.ObjectID       = c.InstrumentID
    and ta.AccType        = lt.LinkedAccTypeID
    and da.ContractID       = d.ContractID
    and d.ContractID      = c.ContractID
    and da.RuleID  = ta.TypeAccLinkID
/*    and da.OnDate        <= @StartDate
    and (da.DateLast = '19000101' or da.DateLast > @ReportDate)
    and (da.Flags % 10)   = 2*/

-- расчет остатков по субконто внутр счетов
insert pResource (SPID, ResourceID, Num, DepID1, DepID2)
-- Срочная Ссудная Задолженность - Выдано/Начислено
select @@spid, ResourceID, 2, d.DepartmentID, @DepAccrualID     
from tDepartment d  (NOLOCK INDEX=XAK2tDepartment), @tAccInner
where d.ParentID = @DepParentID                     
and d.Brief    = 'СрочСсудЗд'       
    union all 
-- Срочная Ссудная Задолженность - Уплачено/Погашено                      
select @@spid, ResourceID, 255-2, d.DepartmentID, @DepRepaymentID     
from tDepartment d  (NOLOCK INDEX=XAK2tDepartment), @tAccInner
where d.ParentID = @DepParentID                     
and d.Brief    = 'СрочСсудЗд'  
    union all
-- Просроч Ссудная Задолженность - Выдано/Начислено
select @@spid, ResourceID, 3, d.DepartmentID, @DepAccrualID     
from tDepartment d  (NOLOCK INDEX=XAK2tDepartment), @tAccInner
where d.ParentID = @DepParentID                     
and d.Brief    = 'ПрсрСсудЗд'       
    union all 
-- Просроч Ссудная Задолженность - Уплачено/Погашено                      
select @@spid, ResourceID, 255-3, d.DepartmentID, @DepRepaymentID     
from tDepartment d  (NOLOCK INDEX=XAK2tDepartment), @tAccInner
where d.ParentID = @DepParentID                     
and d.Brief    = 'ПрсрСсудЗд'
    /*union all
-- Сроч Проценты на Сроч Ссуд Задолженность - Выдано/Начислено
select @@spid, ResourceID, 4, d.DepartmentID, @DepAccrualID     
from tDepartment d  (NOLOCK INDEX=XAK2tDepartment), @tAccInner
where d.ParentID = @DepParentID                     
and d.Brief    = 'СрПрСрСсЗд'       
    union all 
-- Сроч Проценты на Сроч Ссуд - Уплачено/Погашено                      
select @@spid, ResourceID, 255-4, d.DepartmentID, @DepRepaymentID     
from tDepartment d  (NOLOCK INDEX=XAK2tDepartment), @tAccInner
where d.ParentID = @DepParentID                     
and d.Brief    = 'СрПрСрСсЗд'
    union all
-- Просроч Проценты - Выдано/Начислено
select @@spid, ResourceID, 5, d.DepartmentID, @DepAccrualID     
from tDepartment d  (NOLOCK INDEX=XAK2tDepartment), @tAccInner
where d.ParentID = @DepParentID                     
and d.Brief    = 'ПрсрПроц'       
    union all 
-- Просроч Проценты - Уплачено/Погашено                      
select @@spid, ResourceID, 255-5, d.DepartmentID, @DepRepaymentID     
from tDepartment d  (NOLOCK INDEX=XAK2tDepartment), @tAccInner
where d.ParentID = @DepParentID                     
and d.Brief    = 'ПрсрПроц'
    union all
-- Штрафы на просроч комиссии - Выдано/Начислено
select @@spid, ResourceID, 6, d.DepartmentID, @DepAccrualID     
from tDepartment d  (NOLOCK INDEX=XAK2tDepartment), @tAccInner
where d.ParentID = @DepParentID                     
and d.Brief    = 'ШтПрсрКом'       
    union all 
-- Штрафы на просроч комиссии - Уплачено/Погашено                      
select @@spid, ResourceID, 255-6, d.DepartmentID, @DepRepaymentID     
from tDepartment d  (NOLOCK INDEX=XAK2tDepartment), @tAccInner
where d.ParentID = @DepParentID                     
and d.Brief    = 'ШтПрсрКом'
    union all
-- Штрафы на просроч проценты - Выдано/Начислено
select @@spid, ResourceID, 7, d.DepartmentID, @DepAccrualID     
from tDepartment d  (NOLOCK INDEX=XAK2tDepartment), @tAccInner
where d.ParentID = @DepParentID                     
and d.Brief    = 'ШтПрсрПр'       
    union all 
-- Штрафы на просроч проценты - Уплачено/Погашено                      
select @@spid, ResourceID, 255-7, d.DepartmentID, @DepRepaymentID     
from tDepartment d  (NOLOCK INDEX=XAK2tDepartment), @tAccInner
where d.ParentID = @DepParentID                     
and d.Brief    = 'ШтПрсрПр'
    union all
-- Штрафы на просроч ОД - Выдано/Начислено
select @@spid, ResourceID, 8, d.DepartmentID, @DepAccrualID     
from tDepartment d  (NOLOCK INDEX=XAK2tDepartment), @tAccInner
where d.ParentID = @DepParentID                     
and d.Brief    = 'ШтПрсрСсЗд'       
    union all 
-- Штрафы на просроч ОД - Уплачено/Погашено                      
select @@spid, ResourceID, 255-8, d.DepartmentID, @DepRepaymentID     
from tDepartment d  (NOLOCK INDEX=XAK2tDepartment), @tAccInner
where d.ParentID = @DepParentID                     
and d.Brief    = 'ШтПрсрСсЗд'
    union all
-- Комиссия 1 - Выдано/Начислено
select @@spid, ResourceID, 11, d.DepartmentID, @DepAccrualID     
from tDepartment d  (NOLOCK INDEX=XAK2tDepartment), @tAccInner
where d.ParentID = @DepParentID                     
and d.Brief    = 'Комиссии'       
    union all 
-- Комиссия 1 - Уплачено/Погашено                      
select @@spid, ResourceID, 255-11, d.DepartmentID, @DepRepaymentID     
from tDepartment d  (NOLOCK INDEX=XAK2tDepartment), @tAccInner
where d.ParentID = @DepParentID                     
and d.Brief    = 'Комиссии'
*/

exec DepList_Rest @Date = @ReportDate

declare @tSub table
(
    ContractID numeric(15, 0)
,   SubType tinyint  -- тип субконто
,   RestBs  money
)

insert @tSub
select ai.ContractID, p.Num, p.RestBs
from @tAccInner ai, pDepResList p with (nolock) 
where ai.ResourceID = p.ResourceID
and p.spid = @@spid

delete pResource   where SPID = @@spid
delete pDepResList where SPID = @@spid




select 
  ltrim(rtrim(c.Number))          as CredNum

-- субконты 

, s2.RestBs  as LoanAccr   -- ОД
, s_2.RestBs as LoanPaid
, s3.RestBs  as OLoanAccr  -- просроч ОД
, s_3.RestBs as OLoanPaid
, a1.RestBS AS BalRest
, s2.RestBs+s_2.RestBs AS InnerRest 
, r.Brief
, r.Name
, a1.RestBS - (s2.RestBs+s_2.RestBs) AS DIFF

, a2.RestBS AS PrBalRest



from @tContract tc inner join tContract c with (nolock) on tc.ContractID = c.ContractID
inner join tContractCredit cc with (nolock) on tc.ContractID = cc.ContractCreditID

INNER JOIN @tAccInner ai ON ai.ContractID = tc.ContractID
INNER JOIN tResource r  WITH (NOLOCK) ON r.ResourceID = ai.ResourceID

inner join @tSub s2 on tc.ContractID = s2.ContractID and s2.SubType = 2
inner join @tSub s_2 on tc.ContractID = s_2.ContractID and s_2.SubType = 255-2

inner join @tSub s3 on tc.ContractID = s3.ContractID and s3.SubType = 3
inner join @tSub s_3 on tc.ContractID = s_3.ContractID and s_3.SubType = 255-3


left outer join @tAcc a1 on tc.ContractID = a1.ContractID and a1.Type = 'ССУДНЫЙ'
left outer join @tAcc a2 on tc.ContractID = a2.ContractID and a2.Type = 'ПР_ССУДНЫЙ'                             

WHERE 1=1
AND a1.restBs <> s2.RestBs + s_2.RestBs
--AND a2.restBs <> s3.RestBs + s_3.RestBs

