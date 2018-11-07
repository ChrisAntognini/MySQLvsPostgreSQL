--
-- This script is used to check whether NULL values are indexed or not.
-- If they are indexed, the query optimizer is able to apply a predicate "IS NULL" through the index.
--

-- setup

DROP TABLE IF EXISTS t;

CREATE TABLE t (
  i1 INTEGER,
  i2 INTEGER
);

INSERT INTO t SELECT CASE WHEN u<=9999 THEN u ELSE NULL END, u FROM large WHERE u <= 10000;

COMMIT;

CREATE INDEX i1 ON t (i1);

ANALYZE TABLE t;

-- test behavior

EXPLAIN SELECT * FROM t WHERE i1 = 42;
EXPLAIN SELECT * FROM t WHERE i1 IS NULL;

-- cleanup

DROP TABLE t;
