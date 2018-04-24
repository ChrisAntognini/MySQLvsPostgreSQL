--
-- This script shows an example of partial index.
--

-- setup

DROP TABLE t;

CREATE TABLE t (
  i1 INTEGER,
  i2 INTEGER
);

INSERT INTO t SELECT CASE WHEN u<=9500 THEN 1 ELSE 2 END, CASE WHEN u<=9500 THEN 1 ELSE 2 END FROM large WHERE u <= 10000;

COMMIT;

CREATE INDEX i1 ON t (i1);
CREATE INDEX i2 ON t (i2) WHERE i2 <> 1;

ANALYZE t;

SELECT i1, i2, count(*) FROM t GROUP BY i1, i2;

-- "regular" index

EXPLAIN SELECT * FROM t WHERE i1 = 0;
EXPLAIN SELECT * FROM t WHERE i1 = 1;
EXPLAIN SELECT * FROM t WHERE i1 = 2;
EXPLAIN SELECT * FROM t WHERE i1 = 3;

-- partial index

EXPLAIN SELECT * FROM t WHERE i2 = 0;
EXPLAIN SELECT * FROM t WHERE i2 = 1;
EXPLAIN SELECT * FROM t WHERE i2 = 2;
EXPLAIN SELECT * FROM t WHERE i2 = 3;

-- cleanup

DROP TABLE t;
