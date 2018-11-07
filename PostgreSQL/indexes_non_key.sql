--
-- This script is used to check whether NULL values are indexed or not.
-- If they are indexed, the query optimizer is able to apply a predicate "IS NULL" through the index.
--

-- setup

DROP TABLE IF EXISTS t;

CREATE TABLE t (
  n1 INTEGER,
  n2 INTEGER,
  n3 INTEGER
);

INSERT INTO t SELECT u, u, u FROM large WHERE u <= 10000;

COMMIT;

CREATE UNIQUE INDEX i ON t (n1) INCLUDE (n2);

ANALYZE t;

-- test behavior

EXPLAIN SELECT n1, n2 FROM t WHERE n1 = 42;
EXPLAIN SELECT n1, n2, n3 FROM t WHERE n1 = 42;

-- cleanup

DROP TABLE t;
