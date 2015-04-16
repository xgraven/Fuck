SELECT tsa.ResourceID, r.Brief, r.Name, r.DateStart,  d.Brief, d.name 
  FROM tResource r WITH (NOLOCK INDEX=XAK1tResource)
INNER JOIN tSubcontoAccount tsa WITH(NOLOCK) ON tsa.ParentID = r.ResourceID 
INNER JOIN tSubcontoSetDetail ssd WITH(NOLOCK) ON ssd.SubcontoSetID = tsa.SubcontoSetID
INNER JOIN tDepartment d  WITH (NOLOCK) ON d.DepartmentID = ssd.DepartmentID 
WHERE 
r.Brief LIKE '4%'
OPTION(FORCE ORDER, LOOP JOIN)

	exec SubcontoAccount_Delete @ResourceID = 2010015578143


SELECT r.Brief, r.resourceid, o.resourceid,  o.OperationID, o.DealTransactID, o.qty, o.CharType, o.OperDate, o.Comment, d.Name
--begin tran 
--DELETE o
  FROM tResource r WITH (NOLOCK INDEX=XAK1tResource)
INNER JOIN tSubcontoAccount tsa WITH(NOLOCK) ON tsa.ParentID = r.ResourceID 

INNER JOIN tOperpart o  WITH (NOLOCK INDEX=XAK1tOperpart) ON o.ResourceID = tsa.ResourceID
INNER JOIN tSubcontoSetDetail ssd WITH(NOLOCK) ON ssd.SubcontoSetID = tsa.SubcontoSetID
INNER JOIN tDepartment d  WITH (NOLOCK) ON d.DepartmentID = ssd.DepartmentID 
WHERE 
o.OperDate = '20150409'
and r.Brief LIKE '458%'
order BY r.ResourceID
OPTION(FORCE ORDER, LOOP JOIN)

DECLARE @SubContoAccountID DSIDENTIFIER
DECLARE @OperationID DSIDENTIFIER
DECLARE @r INT

DECLARE curs CURSOR FOR
SELECT tsa.resourceid, o.OperationID
  FROM tResource r WITH (NOLOCK INDEX=XAK1tResource)
INNER JOIN tSubcontoAccount tsa WITH(NOLOCK) ON tsa.ParentID = r.ResourceID 

INNER JOIN tOperpart o  WITH (NOLOCK INDEX=XAK1tOperpart) ON o.ResourceID = tsa.ResourceID
INNER JOIN tSubcontoSetDetail ssd WITH(NOLOCK) ON ssd.SubcontoSetID = tsa.SubcontoSetID
INNER JOIN tDepartment d  WITH (NOLOCK) ON d.DepartmentID = ssd.DepartmentID 
WHERE 
o.OperDate = '20150409'
and r.Brief LIKE '91604%'
order BY r.ResourceID
OPTION(FORCE ORDER, LOOP JOIN)
OPEN curs
FETCH NEXT FROM curs INTO @SubContoAccountID, @OperationID
WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT '---------------------------------'
	PRINT @SubContoAccountID
	PRINT @OperationID
	DELETE FROM tOperPart WHERE ResourceID = @SubContoAccountID AND OperationID = @OperationID
	exec @r = SubcontoAccount_Delete @ResourceID = @SubContoAccountID
	PRINT @r
	FETCH NEXT FROM curs INTO @SubContoAccountID, @OperationID
END

CLOSE curs
DEALLOCATE curs

/*
ROLLBACK TRAN

2010015575907	2010179747082
2010015575941	2010179751390
2010015575939	2010179751357



SELECT * FROM tOperpart WITH (NOLOCK) WHERE operationid = 2010179955878



COMMIT tran

 
2010015575926	2010179750131
2010015575908	2010179747095
2010015575942	2010179751399
2010015575942	2010179751406
2010015575940	2010179751371
2010015575940	2010179751364

SELECT * FROM tResource WHERE ResourceID = 2010015575926


--Погашение срочной ссудной задолженности по договору  NКПФ/116/03-13/03 от 22/03/2013

DECLARE @r INT

exec @r = SubcontoAccount_Delete @ResourceID = 2010015575907
SELECT @r
exec @r = SubcontoAccount_Delete @ResourceID = 2010015575941
SELECT @r
exec @r = SubcontoAccount_Delete @ResourceID = 2010015575939
SELECT @r


exec @r = SubcontoAccount_Delete @ResourceID = 2010015575926
SELECT @r

exec @r = SubcontoAccount_Delete @ResourceID = 2010015575908
SELECT @r

exec @r = SubcontoAccount_Delete @ResourceID = 2010015575942
SELECT @r



exec @r = SubcontoAccount_Delete @ResourceID = 2010015575940
SELECT @r
*/