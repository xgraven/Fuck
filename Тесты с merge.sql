DROP TABLE foo;

CREATE TABLE foo
(
	a INT,
	n VARCHAR(10)
)

INSERT INTO foo 
VALUES (1, 'John')

INSERT INTO foo 
VALUES (2, 'Mary')


INSERT INTO foo 
VALUES (3, 'Lola')


INSERT INTO foo 
VALUES (4, 'Shon')



DROP TABLE doo;
CREATE TABLE doo
(
	a INT,
	n VARCHAR(10)
)

INSERT INTO doo 
VALUES (1, 'Johnny')


INSERT INTO doo 
VALUES (2, 'Mary23')



INSERT INTO doo 
VALUES (5, 'James')

MERGE doo AS d 
USING foo f WITH(NOLOCK) ON f.a = d.a
WHEN matched THEN UPDATE SET d.n = f.n
WHEN NOT matched by target THEN
	INSERT (a, n) VALUES (f.a, f.n) 
WHEN NOT matched by source THEN
	INSERT (a, n) VALUES (d.a, d.n);   
	
SELECT * FROM doo	