--
-- This script is used to test whether the query optimizer gives precedence to the indexes associated 
-- to primary and unique key constraints.
--

-- during the generation of an execution plan equalities on PK/UK are probed for matching row

DROP TABLE IF EXISTS t;

CREATE TABLE t (
  i1 INTEGER PRIMARY KEY,
  i2 INTEGER NOT NULL,
  i3 INTEGER NULL,
  i4 INTEGER NULL
);

INSERT INTO t SELECT u, u, u, u FROM large;

CREATE UNIQUE INDEX i2 ON t (i2);
CREATE UNIQUE INDEX i3 ON t (i3);
CREATE INDEX i4 ON t (i4);

ANALYZE TABLE t;

EXPLAIN SELECT * FROM t WHERE i1 = 0;
EXPLAIN SELECT * FROM t WHERE i2 = 0;
EXPLAIN SELECT * FROM t WHERE i3 = 0;
EXPLAIN SELECT * FROM t WHERE i4 = 0;

-- physical order matches PK/UK, i.e PK/UK better than non-PK/UK -> PK/UK used

DROP TABLE t;

CREATE TABLE t (
  i1 INTEGER PRIMARY KEY,
  i2 INTEGER UNIQUE,
  i3 INTEGER
);

CREATE INDEX i3 ON  t (i3);

SET @row_number = 0;

INSERT INTO t SELECT l.u, l.u, (@row_number:=@row_number+1) FROM (SELECT * FROM large ORDER BY rand()) l;

COMMIT;

ANALYZE TABLE t;

SELECT * FROM t LIMIT 10;

EXPLAIN SELECT * FROM t WHERE i1 BETWEEN 6 AND 19;
EXPLAIN SELECT * FROM t WHERE i2 BETWEEN 6 AND 19;
EXPLAIN SELECT * FROM t WHERE i3 BETWEEN 6 AND 19;
EXPLAIN SELECT * FROM t WHERE i1 BETWEEN 6 AND 19 AND i2 BETWEEN 6 AND 19;
EXPLAIN SELECT * FROM t WHERE i1 BETWEEN 6 AND 19 AND i2 BETWEEN 6 AND 10;
EXPLAIN SELECT * FROM t WHERE i1 BETWEEN 6 AND 19 AND i2 BETWEEN 6 AND 9;
EXPLAIN SELECT * FROM t WHERE i1 BETWEEN 6 AND 19 AND i3 BETWEEN 6 AND 19;
EXPLAIN SELECT * FROM t WHERE i1 BETWEEN 6 AND 19 AND i3 BETWEEN 6 AND 11;
EXPLAIN SELECT * FROM t WHERE i1 BETWEEN 6 AND 19 AND i3 BETWEEN 6 AND 10;
EXPLAIN SELECT * FROM t WHERE i2 BETWEEN 6 AND 19 AND i3 BETWEEN 6 AND 19;
EXPLAIN SELECT * FROM t WHERE i2 BETWEEN 6 AND 19 AND i3 BETWEEN 6 AND 18;

-- physical order matches non-UK, i.e non-UK is better than UK -> UK used !!!

DROP TABLE t;

CREATE TABLE t (
  i1 INTEGER PRIMARY KEY,
  i2 INTEGER UNIQUE,
  i3 INTEGER
);

CREATE INDEX i3 ON  t (i3);

SET @row_number = 0;

INSERT INTO t SELECT l.u, (@row_number:=@row_number+1), l.u FROM (SELECT * FROM large ORDER BY rand()) l;

COMMIT;

ANALYZE TABLE t;

SELECT * FROM t LIMIT 10;

EXPLAIN SELECT * FROM t WHERE i2 BETWEEN 6 AND 19;
EXPLAIN SELECT * FROM t WHERE i3 BETWEEN 6 AND 19;
EXPLAIN SELECT * FROM t WHERE i2 BETWEEN 6 AND 19 AND i3 BETWEEN 6 AND 19;
EXPLAIN SELECT * FROM t WHERE i2 BETWEEN 6 AND 19 AND i3 BETWEEN 6 AND 18;

DROP TABLE t;
