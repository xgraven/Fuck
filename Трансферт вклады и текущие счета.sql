SELECT distinct kodbap, Acc2
  FROM tAccount WHERE KodBap IN (21300 , 21400, 21600) ORDER BY KodBap
  
SELECT a.kodbap, a.AccNum, a.AccName, r.RestBs 
  FROM tAccount a  WITH (NOLOCK)
  INNER JOIN tRest r  WITH (NOLOCK) ON r.ResourceID = a.ResourceID AND r.RYear = 2015 AND r.Rmon = 2 
  WHERE 
  KodBap = 21300 AND Acc2 = '42309'
  COMPUTE SUM(r.RestBs)
  
  
SELECT a.kodbap, a.Acc2, abs(SUM(r.RestBs))
  FROM tAccount a  WITH (NOLOCK)
  INNER JOIN tRest r  WITH (NOLOCK) ON r.ResourceID = a.ResourceID AND r.RYear = 2015 AND r.Rmon = 2 
  WHERE 
  KodBap IN (21300 , 21400, 21600)
  GROUP BY a.kodbap, a.Acc2