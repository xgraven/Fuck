SELECT * FROM pObjectQtyPrepared WHERE ObjectID = 2010008983103



SELECT * FROM tContract where contractid = 2010008983103
SELECT * FROM tConsSaleDetail WHERE ContractID = 2010008983103

SELECT * FROM tConsSalePortfolio tcsp WITH(NOLOCK) WHERE tcsp.ConsSalePortfolioID =2010008983183


SELECT csp.Number, csp.MarginProfit, csp.CostReduct, csp.TypeFinResultID, csp.SellTypeID, csd.DebtType, csd.DebtAmount
FROM
tConsSalePortfolio csp  WITH (NOLOCK) 
INNER JOIN tCtrCtrRelation ccr  WITH (NOLOCK) ON ccr.ParentContractID = csp.ConsSalePortfolioID
INNER JOIN tConsSaleDetail csd  WITH (NOLOCK) ON ccr.ContractID = csd.ContractID
WHERE ccr.ParentContractID =  2010008987537 
AND ccr.TypeLink = 24

COMPUTE SUM(DebtAmount)



SELECT csd.DebtType, sum(csd.DebtAmount)
FROM
tConsSalePortfolio csp  WITH (NOLOCK) 
INNER JOIN tCtrCtrRelation ccr  WITH (NOLOCK) ON ccr.ParentContractID = csp.ConsSalePortfolioID
INNER JOIN tConsSaleDetail csd  WITH (NOLOCK) ON ccr.ContractID = csd.ContractID
WHERE ccr.ParentContractID =  2010008987537 
AND ccr.TypeLink = 24
GROUP BY csd.DebtType

DELETE tConsSaleDetail 
WHERE DebtType = 22 AND ConsSalePortfolioID = 2010008987537

UPDATE tConsSaleDetail 
SET DebtAmount = 13301.75
WHERE DebtType = 4 AND ConsSalePortfolioID = 2010008987537

UPDATE tConsSaleDetail 
SET DebtAmount = 1697600.7
WHERE DebtType = 2 AND ConsSalePortfolioID = 2010008987537

UPDATE tConsSaleDetail
SET
	debtamount = 0
WHERE ConsSalePortfolioID =2010008987537	 
AND DebtType = 100


update tConsSalePortfolio 
SET MarginProfit = 2022604.89, CostReduct = 0, TypeFinResultID = 1 
WHERE ConsSalePortfolioID =2010008987537

BEGIN TRAN  
--UPDATE tConsSaleDetail
SET
	debtamount = 0
WHERE ConsSalePortfolioID =2010008984913	 
AND DebtType = 100

COMMIT TRAN



	
	