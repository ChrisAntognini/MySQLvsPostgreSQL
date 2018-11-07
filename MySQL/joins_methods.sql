--
-- This script is used to generate an execution plan for each available join method.
--

DROP TABLE IF EXISTS t1;
DROP TABLE IF EXISTS t2;

CREATE TABLE t1 (id INTEGER PRIMARY KEY, n INTEGER, p VARCHAR(128));
INSERT INTO t1 SELECT u, u, p FROM small;
COMMIT;
ANALYZE TABLE t1;

CREATE TABLE t2 (id INTEGER PRIMARY KEY, n INTEGER, p VARCHAR(128));
INSERT INTO t2 SELECT u, u, p FROM large;
COMMIT;
ANALYZE TABLE t2;

-- nested loops join (inner loop of type eq_ref)

EXPLAIN
SELECT count(*)
FROM t1, t2
WHERE t1.id = t2.id;

SELECT count(*)
FROM t1, t2
WHERE t1.id = t2.id;

-- block nested loops join (inner loop of type ALL --> JOIN_ORDER hint neded to force the plan)

EXPLAIN
SELECT /*+ join_order(t1, t2) */ count(*)
FROM t1, t2
WHERE t1.id = t2.n;

SELECT /*+ join_order(t1, t2) */ count(*)
FROM t1, t2
WHERE t1.id = t2.n;

-- nested loops join (inner loop of type ALL --> JOIN_ORDER/NO_BNL hints needed to force this plan)

EXPLAIN
SELECT /*+ join_order(t1, t2) no_bnl(t2) */ count(*)
FROM t1, t2
WHERE t1.id = t2.n;

SELECT /*+ join_order(t1, t2) no_bnl(t2) */ count(*)
FROM t1, t2
WHERE t1.id = t2.n;

-- cleanup

DROP TABLE t1;
DROP TABLE t2;
