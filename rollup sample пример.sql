CREATE TABLE fact 
(
	a INT,
	b INT,
	c money
)

INSERT INTO fact
(
	a,
	b,
	c
)
VALUES 
 (1,1,10),
 (1,2,11),
 (1,3,22),
 (1,4,33),
 (1,5,44),
 (1,6,15),
 (1,7,18)
 
 
 INSERT INTO fact
(
	a,
	b,
	c
)
VALUES 
 (2,1,50),
 (2,2,35),
 (2,3,89),
 (2,4,67),
 (2,5,32),
 (2,6,15),
 (2,7,10)
 
 
  INSERT INTO fact
(
	a,
	b,
	c
)
VALUES 
 (3,1,76),
-- (2,2,35),
 (3,3,11)

SELECT a, b, sum(c), grouping_id(a, b)
FROM fact f WITH(NOLOCK)	
GROUP BY ROLLUP(a, b)

SELECT a, [1], [2], [3], ISNULL([1], 0) + ISNULL([2], 0) + ISNULL([3], 0)  AS tot
FROM (SELECT a, b, c FROM fact) q
PIVOT (SUM(c) FOR b IN ( [1], [2], [3])) p
