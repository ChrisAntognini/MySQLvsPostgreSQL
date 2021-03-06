--
-- This script is used to test whether ORDER BY clauses are evaluated through indexes. 
-- In addition the possibility to create a DESC index is tested.
--

-- setup

DROP TABLE IF EXISTS t;

CREATE TABLE t (
  i1 INTEGER, 
  i2 INTEGER,
  i3 INTEGER,
  dummy INTEGER
);

INSERT INTO t 
SELECT u, u, u, NULL 
FROM large
WHERE u <= 10000;

COMMIT;

ANALYZE TABLE t;

-- index without ASC/DESC

CREATE INDEX i ON t (i1, i2, i3);

EXPLAIN SELECT * FROM t WHERE i1 = 1 ORDER BY i2 ASC;
EXPLAIN SELECT * FROM t WHERE i1 = 1 ORDER BY i2 DESC;
EXPLAIN SELECT * FROM t WHERE i1 = 1 ORDER BY i2 ASC, i3 ASC;
EXPLAIN SELECT * FROM t WHERE i1 = 1 ORDER BY i2 DESC, i3 DESC;
EXPLAIN SELECT * FROM t WHERE i1 = 1 ORDER BY i2 ASC, i3 DESC;
EXPLAIN SELECT * FROM t WHERE i1 = 1 ORDER BY i2 DESC, i3 ASC;

-- index with ASC/DESC

DROP INDEX i ON t;
CREATE INDEX i ON t (i1 ASC, i2 DESC, i3 ASC);

EXPLAIN SELECT * FROM t WHERE i1 = 1 ORDER BY i2 ASC, i3 DESC;
EXPLAIN SELECT * FROM t WHERE i1 = 1 ORDER BY i2 DESC, i3 ASC;

-- index with NULLS FIRST/LAST not supported

DROP INDEX i;
CREATE INDEX i ON t (i1 ASC, i2 DESC NULLS LAST, i3 ASC NULLS FIRST);

-- cleanup

DROP TABLE t;
