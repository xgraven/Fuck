SELECT * FROM tInstrument WHERE InstrumentID = 2010000001762

--UPDATE tInstrument SET AutoComment = 'Consumer\Autocred2Cess.smf' WHERE InstrumentID = 2010000001762


--AutoOpen
/*
* 0-�������
* 1-��� ��������
*/
SELECT tal.TypeAccLinkID, tal.Brief, tal.Name, tal.AutoOpen 
FROM tTypeAccLink tal  WITH (NOLOCK) 
WHERE 
tal.ObjectID = 2010000001762
--and tal.Brief IN  ('����������', '��������','��������','����������','���������','����������','���������', '����������')
and tal.Brief IN  ('����������', '����������','���������','����������')

SELECT cras.RuleID, cras.Brief, cras.Name, cras.Strategy
  FROM tConsRuleAccSync cras WITH(NOLOCK)
WHERE cras.ObjectID = 2010000001762
AND cras.Brief IN  ('����������', '����������','���������','����������')

UPDATE tal SET autoopen = 1
FROM tTypeAccLink tal  WITH (NOLOCK) 
WHERE 
tal.ObjectID = 2010000001762
--and tal.Brief IN  ('����������', '��������','��������','����������','���������','����������','���������', '����������')
and tal.Brief IN  ('����������', '����������','���������','����������')

UPDATE cras SET strategy = 1
  FROM tConsRuleAccSync cras WITH(NOLOCK)
WHERE cras.ObjectID = 2010000001762
AND cras.Brief IN  ('����������', '����������','���������','����������')

