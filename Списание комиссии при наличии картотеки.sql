
       
       
SELECT r1.Brief, o1.Comment, r1.Name, asd.acctype, r3.Brief, asd.*
FROM tResource r2 WITH (NOLOCK)
INNER JOIN tOperpart o2  WITH (NOLOCK) ON o2.ResourceID = r2.ResourceID AND o2.OperDate = '20150505' AND o2.CharType = -1
INNER JOIN tOperpart o1  WITH (NOLOCK) ON o2.OperationID = o1.OperationID AND o1.CharType = 1
INNER JOIN tResource r1 WITH (NOLOCK INDEX = XPKtResource) ON  r1.ResourceID = o1.ResourceID
inner join tAccSystemDoc asd  WITH (NOLOCK) ON asd.AccDeb = r1.Brief
INNER JOIN tResource r3  WITH (NOLOCK) ON r3.ResourceID = asd.ResourceID 
INNER JOIN pVKABRests p  WITH (NOLOCK) ON p.ResourceID = r3.ResourceID AND p.RestBs <> 0 AND p.RestDate = '20150504'
WHERE r2.Brief LIKE '70601810_____1620341'    
AND r3.DateEnd = ''
ORDER BY r2.ResourceID   



select Brief, PropVal,
       Name,
       DsModuleID,
       InterfaceObjectID
  from tProperty WITH (NOLOCK)
 where PropType = 90