--
-- This script is used to verify whether the query optimizer is able to merge multiple indexes
-- to access a single table.
--

-- setup

DROP TABLE t;

CREATE TABLE t (
  i1 INTEGER, 
  i2 INTEGER,
  i3 INTEGER,
  i4 INTEGER, 
  i5 INTEGER,
  dummy INTEGER
);

INSERT INTO t 
SELECT 1, mod(u,2), mod(u,5), mod(u,25), mod(u,125), NULL 
FROM large
WHERE u <= 10000;

COMMIT;

CREATE INDEX i1 ON t (i1);
CREATE INDEX i2 ON t (i2);
CREATE INDEX i3 ON t (i3);
CREATE INDEX i4 ON t (i4);
CREATE INDEX i5 ON t (i5);

ANALYZE TABLE t;

-- test behavior with different combinations, notice that every column has it's own selectivity

EXPLAIN SELECT * FROM t WHERE i1 = 1;
EXPLAIN SELECT * FROM t WHERE i2 = 1;
EXPLAIN SELECT * FROM t WHERE i3 = 1;
EXPLAIN SELECT * FROM t WHERE i4 = 1;
EXPLAIN SELECT * FROM t WHERE i5 = 1;

EXPLAIN SELECT * FROM t WHERE i1 = 1 AND i2 = 1;
EXPLAIN SELECT * FROM t WHERE i1 = 1 AND i2 = 1 AND i3 = 1;
EXPLAIN SELECT * FROM t WHERE i1 = 1 AND i2 = 1 AND i3 = 1 AND i4 = 1;
EXPLAIN SELECT * FROM t WHERE i1 = 1 AND i2 = 1 AND i3 = 1 AND i4 = 1 AND i5 = 1;
EXPLAIN SELECT * FROM t WHERE            i2 = 1 AND i3 = 1 AND i4 = 1 AND i5 = 1;
EXPLAIN SELECT * FROM t WHERE                       i3 = 1 AND i4 = 1 AND i5 = 1;
EXPLAIN SELECT * FROM t WHERE                                  i4 = 1 AND i5 = 1;
EXPLAIN SELECT * FROM t WHERE                                             i5 = 1;

EXPLAIN SELECT * FROM t WHERE i2 = 1 OR i3 = 1;
EXPLAIN SELECT * FROM t WHERE i2 = 1 OR i3 = 1 OR i4 = 1;
EXPLAIN SELECT * FROM t WHERE i2 = 1 OR i3 = 1 OR i4 = 1 OR i5 = 1;
EXPLAIN SELECT * FROM t WHERE           i3 = 1 OR i4 = 1 OR i5 = 1;
EXPLAIN SELECT * FROM t WHERE                     i4 = 1 OR i5 = 1;

EXPLAIN SELECT * FROM t WHERE i2 < 1 OR i3 < 1;
EXPLAIN SELECT * FROM t WHERE i2 < 1 OR i3 < 1 OR i4 < 1;
EXPLAIN SELECT * FROM t WHERE i2 < 1 OR i3 < 1 OR i4 < 1 OR i5 < 1;
EXPLAIN SELECT * FROM t WHERE           i3 < 1 OR i4 < 1 OR i5 < 1;
EXPLAIN SELECT * FROM t WHERE                     i4 < 1 OR i5 < 1;

EXPLAIN SELECT * FROM t WHERE i2 BETWEEN 1 AND 2 OR i3 BETWEEN 1 AND 2;
EXPLAIN SELECT * FROM t WHERE i2 BETWEEN 1 AND 2 OR i3 BETWEEN 1 AND 2 OR i4 BETWEEN 1 AND 2;
EXPLAIN SELECT * FROM t WHERE i2 BETWEEN 1 AND 2 OR i3 BETWEEN 1 AND 2 OR i4 BETWEEN 1 AND 2 OR i5 BETWEEN 1 AND 2;
EXPLAIN SELECT * FROM t WHERE                       i3 BETWEEN 1 AND 2 OR i4 BETWEEN 1 AND 2 OR i5 BETWEEN 1 AND 2;
EXPLAIN SELECT * FROM t WHERE                                             i4 BETWEEN 1 AND 2 OR i5 BETWEEN 1 AND 2;

-- cleanup

DROP TABLE t;
