SELECT case when i.PropdealPart = 1 then i.Name else i.Name + ' ' +  i.Name1+ ' ' + i.Name2 END AS ClientName
, tcsd.DebtAmount 
FROM tConsSaleDetail tcsd WITH(NOLOCK)
INNER JOIN tCOntract c  WITH (NOLOCK) ON c.ContractID = tcsd.ContractID
INNER JOIN tInstitution  i  WITH (NOLOCK) ON i.InstitutionID = c.InstitutionID 
WHERE tcsd.ConsSalePortfolioID = 2010008988574
AND tcsd.DebtType = 4
AND i.Name = 'Äלטענטוגא'
ORDER BY 1

/*
UPDATE tcsd SET DebtAmount = 1561.89
FROM tConsSaleDetail tcsd WITH(NOLOCK)
INNER JOIN tCOntract c  WITH (NOLOCK) ON c.ContractID = tcsd.ContractID
INNER JOIN tInstitution  i  WITH (NOLOCK) ON i.InstitutionID = c.InstitutionID 
WHERE tcsd.ConsSalePortfolioID = 2010008988574
AND tcsd.DebtType = 4
AND i.Name = 'Äלטענטוגא'
*/


SELECT * FROM pObjectQtyPrepared WHERE ObjectID = 2010008988547

SELECT (443559.64+194.43) * 0.0254601751879
-11017.4

SELECT * FROM TConsSaleDetail WHERE ContractID = 2010008988536


SELECT SUM(debtAmount) FROM tConsSaleDetail tcsd WITH(NOLOCK) WHERE tcsd.ConsSalePortfolioID = 2010008988574

SELECT SUM(debtAmount) FROM tConsSaleDetail tcsd WITH(NOLOCK) WHERE tcsd.ConsSalePortfolioID = 2010008988574 AND tcsd.DebtType = 2
SELECT SUM(debtAmount) FROM tConsSaleDetail tcsd WITH(NOLOCK) WHERE tcsd.ConsSalePortfolioID = 2010008988574 AND tcsd.DebtType = 4

SELECT (17349129.47 + 120154.36) / 17035555.60


select 433728.23 * (661295.72+4891.78) / (17349129.47 + 120154.36)

SELECT * FROM tConsSaleDetail tcsd WITH(NOLOCK) WHERE tcsd.ContractID = 2010008988535

SELECT (661295.72+4891.78) -16540.14

