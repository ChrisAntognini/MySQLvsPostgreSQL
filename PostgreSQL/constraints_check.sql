--
-- This script is used to test whether the query optimizer uses check constraints to verify the
-- validity of predicates.
--

-- setup

DROP TABLE IF EXISTS t1;

CREATE TABLE t1 (
  i1 INTEGER,
  i2 INTEGER CHECK (i2 IN (1,2,3,4,5)),
  i3 INTEGER CHECK (i3 > 0)
);

INSERT INTO t1 SELECT u, u, u FROM large WHERE u <= 5;
INSERT INTO t1 SELECT * FROM t1;
INSERT INTO t1 SELECT * FROM t1;
INSERT INTO t1 SELECT * FROM t1;

COMMIT;

ANALYZE t1;

DROP TABLE IF EXISTS t2;

CREATE TABLE t2 (
  partkey INTEGER NOT NULL,
  i1 INTEGER,
  i2 INTEGER CHECK (i2 IN (1,2,3,4,5)),
  i3 INTEGER CHECK (i3 > 0)
)
PARTITION BY RANGE (partkey);

CREATE TABLE t2_p1 PARTITION OF t2 FOR VALUES FROM (1) TO (10000);

INSERT INTO t2 SELECT i2, i1, i2, i3 FROM t1;

COMMIT;

ANALYZE t2;

-- how many rows return the test queries?

SELECT count(*) FROM t1 WHERE i1 = 1;
SELECT count(*) FROM t1 WHERE i1 = 0;
SELECT count(*) FROM t1 WHERE i2 = 1;
SELECT count(*) FROM t1 WHERE i2 = 0;
SELECT count(*) FROM t1 WHERE i3 = 1;
SELECT count(*) FROM t1 WHERE i3 = 0;

SELECT count(*) FROM t2 WHERE i1 = 1;
SELECT count(*) FROM t2 WHERE i1 = 0;
SELECT count(*) FROM t2 WHERE i2 = 1;
SELECT count(*) FROM t2 WHERE i2 = 0;
SELECT count(*) FROM t2 WHERE i3 = 1;
SELECT count(*) FROM t2 WHERE i3 = 0;

-- per default the not null constraint is only used for partitioned tables

SET constraint_exclusion = default;

EXPLAIN SELECT * FROM t1 WHERE i1 = 1;
EXPLAIN SELECT * FROM t2 WHERE i1 = 1;
EXPLAIN SELECT * FROM t1 WHERE i1 = 0;
EXPLAIN SELECT * FROM t2 WHERE i1 = 0;
EXPLAIN SELECT * FROM t1 WHERE i2 = 1;
EXPLAIN SELECT * FROM t2 WHERE i2 = 1;
EXPLAIN SELECT * FROM t1 WHERE i2 = 0;
EXPLAIN SELECT * FROM t2 WHERE i2 = 0;
EXPLAIN SELECT * FROM t1 WHERE i3 = 1;
EXPLAIN SELECT * FROM t2 WHERE i3 = 1;
EXPLAIN SELECT * FROM t1 WHERE i3 = 0;
EXPLAIN SELECT * FROM t2 WHERE i3 = 0;

SET constraint_exclusion = on;

EXPLAIN SELECT * FROM t1 WHERE i2 = 0;
EXPLAIN SELECT * FROM t2 WHERE i2 = 0;
EXPLAIN SELECT * FROM t1 WHERE i3 = 0;
EXPLAIN SELECT * FROM t2 WHERE i3 = 0;

SET constraint_exclusion = partition;

EXPLAIN SELECT * FROM t1 WHERE i2 = 0;
EXPLAIN SELECT * FROM t2 WHERE i2 = 0;
EXPLAIN SELECT * FROM t1 WHERE i3 = 0;
EXPLAIN SELECT * FROM t2 WHERE i3 = 0;

SET constraint_exclusion = off;

EXPLAIN SELECT * FROM t1 WHERE i2 = 0;
EXPLAIN SELECT * FROM t2 WHERE i2 = 0;
EXPLAIN SELECT * FROM t1 WHERE i3 = 0;
EXPLAIN SELECT * FROM t2 WHERE i3 = 0;

SET constraint_exclusion = default;

-- cleanup

DROP TABLE t1;
DROP TABLE t2;
