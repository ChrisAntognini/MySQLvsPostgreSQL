--
-- This script demonstrates the utilization of SELECT statement modifiers
--

-- setup

warnings

DROP TABLE t1;
DROP TABLE t2;
DROP TABLE t3;
DROP TABLE t4;
DROP TABLE t5;

CREATE TABLE t1 AS SELECT * FROM large WHERE u <= 10;
CREATE TABLE t2 AS SELECT * FROM large WHERE u <= 100;
CREATE TABLE t3 AS SELECT * FROM large WHERE u <= 1000;
CREATE TABLE t4 AS SELECT * FROM large WHERE u <= 10000;
CREATE TABLE t5 AS SELECT * FROM large WHERE u <= 100000;

CREATE INDEX i1_u ON t1 (u);
CREATE INDEX i2_u ON t2 (u);
CREATE INDEX i2_nu ON t2 (nu);
CREATE INDEX i3_nu ON t3 (nu);
CREATE INDEX i3_n ON t3 (n);
CREATE INDEX i4_n ON t4 (n);
CREATE INDEX i4_nn ON t4 (nn);
CREATE INDEX i5_nn ON t5 (nn);

ANALYZE TABLE t1;
ANALYZE TABLE t2;
ANALYZE TABLE t3;
ANALYZE TABLE t4;
ANALYZE TABLE t5;

-- STRAIGHT_JOIN

EXPLAIN 
SELECT count(*)
FROM t1, t4, t2, t5, t3
WHERE t1.u = t2.u
AND t2.nu = t3.nu
AND t3.n = t4.n
AND t4.nn = t5.nn;

EXPLAIN 
SELECT STRAIGHT_JOIN count(*)
FROM t1, t4, t2, t5, t3
WHERE t1.u = t2.u
AND t2.nu = t3.nu
AND t3.n = t4.n
AND t4.nn = t5.nn;

EXPLAIN
SELECT count(*)
FROM t5 JOIN t4 ON t5.nn = t4.nn
        JOIN t3 ON t4.n = t3.n
        JOIN t2 ON t3.nu = t2.nu
        JOIN t1 ON t2.u = t1.u;

EXPLAIN
SELECT count(*)
FROM t5 STRAIGHT_JOIN t4 ON t5.nn = t4.nn
        JOIN t3 ON t4.n = t3.n
        JOIN t2 ON t3.nu = t2.nu
        JOIN t1 ON t2.u = t1.u;

EXPLAIN
SELECT count(*)
FROM t5 JOIN t4 ON t5.nn = t4.nn
        STRAIGHT_JOIN t3 ON t4.n = t3.n
        JOIN t2 ON t3.nu = t2.nu
        JOIN t1 ON t2.u = t1.u;

EXPLAIN
SELECT count(*)
FROM t5 JOIN t4 ON t5.nn = t4.nn
        JOIN t3 ON t4.n = t3.n
        STRAIGHT_JOIN t2 ON t3.nu = t2.nu
        JOIN t1 ON t2.u = t1.u;

EXPLAIN
SELECT count(*)
FROM t5 JOIN t4 ON t5.nn = t4.nn
        JOIN t3 ON t4.n = t3.n
        JOIN t2 ON t3.nu = t2.nu
        STRAIGHT_JOIN t1 ON t2.u = t1.u;

-- SQL_BIG_RESULT / SQL_SMALL_RESULT

EXPLAIN
SELECT DISTINCT u, nu
FROM t5;

EXPLAIN
SELECT DISTINCT SQL_SMALL_RESULT u, nu
FROM t5;

EXPLAIN
SELECT DISTINCT SQL_BIG_RESULT u, nu
FROM t5;

EXPLAIN
SELECT u, nu, count(*)
FROM t5
GROUP BY u, nu;

EXPLAIN
SELECT SQL_SMALL_RESULT u, nu, count(*)
FROM t5
GROUP BY u, nu;

EXPLAIN
SELECT SQL_BIG_RESULT u, nu, count(*)
FROM t5
GROUP BY u, nu;

-- SQL_BUFFER_RESULT

EXPLAIN
SELECT * 
FROM t1;

EXPLAIN
SELECT SQL_BUFFER_RESULT * 
FROM t1;

-- cleanup

DROP TABLE t1;
DROP TABLE t2;
DROP TABLE t3;
DROP TABLE t4;
DROP TABLE t5;
