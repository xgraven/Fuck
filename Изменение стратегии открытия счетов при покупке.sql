SELECT * FROM tInstrument WHERE InstrumentID = 2010000001762

--UPDATE tInstrument SET AutoComment = 'Consumer\Autocred2Cess.smf' WHERE InstrumentID = 2010000001762


--AutoOpen
/*
* 0-вручную
* 1-при создании
*/
SELECT tal.TypeAccLinkID, tal.Brief, tal.Name, tal.AutoOpen 
FROM tTypeAccLink tal  WITH (NOLOCK) 
WHERE 
tal.ObjectID = 2010000001762
--and tal.Brief IN  (' упл р“реб', ' уплЎтѕр',' уплЎтќƒ',' упл—р—с«д',' упл—рѕрц',' уплѕр—с«д',' уплѕрѕрц', '√аш упл“рб')
and tal.Brief IN  (' упл р“реб', ' упл—р—с«д',' упл—рѕрц','√аш упл“рб')

SELECT cras.RuleID, cras.Brief, cras.Name, cras.Strategy
  FROM tConsRuleAccSync cras WITH(NOLOCK)
WHERE cras.ObjectID = 2010000001762
AND cras.Brief IN  (' упл р“реб', ' упл—р—с«д',' упл—рѕрц','√аш упл“рб')

UPDATE tal SET autoopen = 1
FROM tTypeAccLink tal  WITH (NOLOCK) 
WHERE 
tal.ObjectID = 2010000001762
--and tal.Brief IN  (' упл р“реб', ' уплЎтѕр',' уплЎтќƒ',' упл—р—с«д',' упл—рѕрц',' уплѕр—с«д',' уплѕрѕрц', '√аш упл“рб')
and tal.Brief IN  (' упл р“реб', ' упл—р—с«д',' упл—рѕрц','√аш упл“рб')

UPDATE cras SET strategy = 1
  FROM tConsRuleAccSync cras WITH(NOLOCK)
WHERE cras.ObjectID = 2010000001762
AND cras.Brief IN  (' упл р“реб', ' упл—р—с«д',' упл—рѕрц','√аш упл“рб')

