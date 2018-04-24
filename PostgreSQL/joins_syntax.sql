--
-- This script is used to test which joins methods are supported and, for outer joins, how the
-- query optimizer process them.
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

SELECT * FROM t1 FULL JOIN t2 USING (u);
SELECT * FROM t1 FULL OUTER JOIN t2 USING (u);
SELECT * FROM t1 FULL JOIN t2 ON t1.u = t2.u;
SELECT * FROM t1 FULL OUTER JOIN t2 ON t1.u = t2.u;

-- show how outer joins are processed

set enable_hashjoin to true;
set enable_mergejoin to false;
set enable_nestloop to false;

EXPLAIN SELECT * FROM t1 LEFT OUTER JOIN t2 ON t1.u = t2.u;
EXPLAIN SELECT * FROM t1 RIGHT OUTER JOIN t2 ON t1.u = t2.u;
EXPLAIN SELECT * FROM t1 FULL OUTER JOIN t2 ON t1.u = t2.u;

set enable_hashjoin to false;
set enable_mergejoin to true;
set enable_nestloop to false;

EXPLAIN SELECT * FROM t1 LEFT OUTER JOIN t2 ON t1.u = t2.u;
EXPLAIN SELECT * FROM t1 RIGHT OUTER JOIN t2 ON t1.u = t2.u;
EXPLAIN SELECT * FROM t1 FULL OUTER JOIN t2 ON t1.u = t2.u;

set enable_hashjoin to false;
set enable_mergejoin to false;
set enable_nestloop to true;

EXPLAIN SELECT * FROM t1 LEFT OUTER JOIN t2 ON t1.u = t2.u;
EXPLAIN SELECT * FROM t1 RIGHT OUTER JOIN t2 ON t1.u = t2.u;
EXPLAIN SELECT * FROM t1 FULL OUTER JOIN t2 ON t1.u = t2.u;

-- cleanup

set enable_hashjoin to default;
set enable_mergejoin to default;
set enable_nestloop to default;

DROP TABLE t1;
DROP TABLE t2;
