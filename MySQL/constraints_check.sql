--
-- This script is used to test whether the query optimizer uses check constraints to verify the
-- validity of predicates.
--

-- setup

DROP TABLE t;

CREATE TABLE t (
  i1 INTEGER,
  i2 INTEGER CHECK (i2 IN (1,2,3,4,5)),
  i3 INTEGER CHECK (i3 > 0)
);

INSERT INTO t SELECT u, u, u FROM large WHERE u <= 5;
INSERT INTO t SELECT * FROM t;
INSERT INTO t SELECT * FROM t;
INSERT INTO t SELECT * FROM t;

COMMIT;

ANALYZE TABLE t;

-- how many rows return the test queries?

SELECT count(*) FROM t WHERE i1 = 1;
SELECT count(*) FROM t WHERE i1 = 0;
SELECT count(*) FROM t WHERE i2 = 1;
SELECT count(*) FROM t WHERE i2 = 0;
SELECT count(*) FROM t WHERE i3 = 1;
SELECT count(*) FROM t WHERE i3 = 0;

-- without indexes (i.e. no statistics on columns), the query optimizer has no clue about the correct cardinality

EXPLAIN SELECT * FROM t WHERE i1 = 1;
EXPLAIN SELECT * FROM t WHERE i1 = 0;
EXPLAIN SELECT * FROM t WHERE i2 = 1;
EXPLAIN SELECT * FROM t WHERE i2 = 0;
EXPLAIN SELECT * FROM t WHERE i3 = 1;
EXPLAIN SELECT * FROM t WHERE i3 = 0;

-- with indexes (i.e. with statistics on columns), the query optimizer computes a correct cardinality

CREATE INDEX i1 ON t (i1);
CREATE INDEX i2 ON t (i2);
CREATE INDEX i3 ON t (i3);

EXPLAIN SELECT * FROM t WHERE i1 = 1;
EXPLAIN SELECT * FROM t WHERE i1 = 0;
EXPLAIN SELECT * FROM t WHERE i2 = 1;
EXPLAIN SELECT * FROM t WHERE i2 = 0;
EXPLAIN SELECT * FROM t WHERE i3 = 1;
EXPLAIN SELECT * FROM t WHERE i3 = 0;

-- cleanup

DROP TABLE t;
