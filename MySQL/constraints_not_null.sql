--
-- This script is used to test whether the query optimizer uses not null constraints to verify the
-- validity of predicates.
--

-- setup

DROP TABLE t;

CREATE TABLE t (
  i1 INTEGER NULL,
  i2 INTEGER NOT NULL
);

INSERT INTO t SELECT CASE WHEN u <= 100 THEN NULL ELSE u END, u FROM large WHERE u <= 1000;

COMMIT;

ANALYZE TABLE t;

-- nullable column

EXPLAIN SELECT * FROM t WHERE i1 IS NULL;
EXPLAIN SELECT * FROM t WHERE i1 IS NOT NULL;

-- not nullable column

EXPLAIN SELECT * FROM t WHERE i2 IS NULL;
EXPLAIN SELECT * FROM t WHERE i2 IS NOT NULL;

-- cleanup

DROP TABLE t;
