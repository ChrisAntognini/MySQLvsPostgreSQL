--
-- This script is used to test whether the query optimizer uses not null constraints to verify the
-- validity of predicates.
--

-- setup

DROP TABLE t1;

CREATE TABLE t1 (
  i1 INTEGER NULL,
  i2 INTEGER NOT NULL
);

INSERT INTO t1 SELECT CASE WHEN u <= 100 THEN NULL ELSE u END, u FROM large WHERE u <= 1000;

COMMIT;

ANALYZE t1;

DROP TABLE t2;

CREATE TABLE t2 (
  partkey INTEGER NOT NULL,
  i1 INTEGER NULL,
  i2 INTEGER NOT NULL
)
PARTITION BY RANGE (partkey);

CREATE TABLE t2_p1 PARTITION OF t2 FOR VALUES FROM (1) TO (10000);

INSERT INTO t2 SELECT i2, i1, i2 FROM t1;

COMMIT;

ANALYZE t2;

-- per default the not null constraint is only used for partitioned tables

SET constraint_exclusion = default;

EXPLAIN SELECT * FROM t1 WHERE i1 IS NULL;
EXPLAIN SELECT * FROM t2 WHERE i1 IS NULL;
EXPLAIN SELECT * FROM t1 WHERE i1 IS NOT NULL;
EXPLAIN SELECT * FROM t2 WHERE i1 IS NOT NULL;
EXPLAIN SELECT * FROM t1 WHERE i2 IS NULL;
EXPLAIN SELECT * FROM t2 WHERE i2 IS NULL;
EXPLAIN SELECT * FROM t1 WHERE i2 IS NOT NULL;
EXPLAIN SELECT * FROM t2 WHERE i2 IS NOT NULL;

SET constraint_exclusion = on;

EXPLAIN SELECT * FROM t1 WHERE i2 IS NULL;
EXPLAIN SELECT * FROM t2 WHERE i2 IS NULL;

SET constraint_exclusion = partition;

EXPLAIN SELECT * FROM t1 WHERE i2 IS NULL;
EXPLAIN SELECT * FROM t2 WHERE i2 IS NULL;

SET constraint_exclusion = off;

EXPLAIN SELECT * FROM t1 WHERE i2 IS NULL;
EXPLAIN SELECT * FROM t2 WHERE i2 IS NULL;

-- cleanup

DROP TABLE t1;
DROP TABLE t2;
