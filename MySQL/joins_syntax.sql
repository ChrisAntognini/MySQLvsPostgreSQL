--
-- This script is used to test which joins methods are supported.
--

-- setup

DROP TABLE t1;
DROP TABLE t2;

CREATE TABLE t1 AS SELECT u FROM small WHERE u BETWEEN 4 AND 8;
CREATE TABLE t2 AS SELECT u FROM small WHERE u <= 5;

ANALYZE TABLE t1;
ANALYZE TABLE t2;

SELECT * FROM t1;
SELECT * FROM t2;

-- available join methods

SELECT * FROM t1 CROSS JOIN t2;

SELECT * FROM t1 NATURAL JOIN t2;
SELECT * FROM t1 JOIN t2 USING (u);
SELECT * FROM t1 INNER JOIN t2 USING (u);
SELECT * FROM t1 JOIN t2 ON t1.u = t2.u;
SELECT * FROM t1 INNER JOIN t2 ON t1.u = t2.u;

SELECT * FROM t1 LEFT JOIN t2 USING (u);
SELECT * FROM t1 LEFT OUTER JOIN t2 USING (u);
SELECT * FROM t1 LEFT JOIN t2 ON t1.u = t2.u;
SELECT * FROM t1 LEFT OUTER JOIN t2 ON t1.u = t2.u;

SELECT * FROM t1 RIGHT JOIN t2 USING (u);
SELECT * FROM t1 RIGHT OUTER JOIN t2 USING (u);
SELECT * FROM t1 RIGHT JOIN t2 ON t1.u = t2.u;
SELECT * FROM t1 RIGHT OUTER JOIN t2 ON t1.u = t2.u;

-- the following are not supported

SELECT * FROM t1 FULL JOIN t2 USING (u);
SELECT * FROM t1 FULL OUTER JOIN t2 USING (u);
SELECT * FROM t1 FULL JOIN t2 ON t1.u = t2.u;
SELECT * FROM t1 FULL OUTER JOIN t2 ON t1.u = t2.u;

-- cleanup

DROP TABLE t1;
DROP TABLE t2;
