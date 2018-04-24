--
-- This script shows examples of indexes based on expressions.
--

-- setup

DROP TABLE t;

CREATE TABLE t (
  i1 INTEGER,
  i2 INTEGER,
  i3 INTEGER
);

INSERT INTO t SELECT u, u, u FROM large WHERE u <= 10000;

COMMIT;

-- test behavior with three different expressions

CREATE INDEX i1 ON t ((i1+1));
CREATE INDEX i2 ON t (mod(i2,10));
CREATE INDEX i3 ON t ((CASE WHEN i3>1 THEN TRUE ELSE FALSE END));

ANALYZE t;

EXPLAIN SELECT * FROM t WHERE i1+1 = 42;
EXPLAIN SELECT * FROM t WHERE i1+2 = 42;

EXPLAIN SELECT * FROM t WHERE mod(i2,10) = 2;
EXPLAIN SELECT * FROM t WHERE mod(i2,11) = 2;

EXPLAIN SELECT * FROM t WHERE CASE WHEN i3>1 THEN TRUE ELSE FALSE END = FALSE;
EXPLAIN SELECT * FROM t WHERE CASE WHEN i3>2 THEN TRUE ELSE FALSE END = FALSE;

-- cleanup

DROP TABLE t;
