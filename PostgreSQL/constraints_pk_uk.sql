--
-- This script is used to test whether the query optimizer gives precedence to the indexes associated 
-- to primary and unique key constraints.

-- correlation of PK better than UK -> PK used

DROP TABLE t;

CREATE TABLE t (
  i1 INTEGER PRIMARY KEY,
  i2 INTEGER UNIQUE
);

INSERT INTO t SELECT row_number() OVER (), u FROM large;

COMMIT;

ANALYZE t;

SELECT attname, null_frac, avg_width, n_distinct, correlation FROM pg_stats WHERE tablename = 't' ORDER BY attname;

EXPLAIN SELECT * FROM t WHERE i1 BETWEEN 6 AND 19;
EXPLAIN SELECT * FROM t WHERE i2 BETWEEN 6 AND 19;
EXPLAIN SELECT * FROM t WHERE i1 BETWEEN 6 AND 19 AND i2 BETWEEN 6 AND 19;

-- correlation of PK worse than UK -> UK used

DROP TABLE t;

CREATE TABLE t (
  i1 INTEGER PRIMARY KEY,
  i2 INTEGER UNIQUE
);

INSERT INTO t SELECT u, row_number() OVER () FROM large;

COMMIT;

ANALYZE t;

SELECT attname, null_frac, avg_width, n_distinct, correlation FROM pg_stats WHERE tablename = 't' ORDER BY attname;

EXPLAIN SELECT * FROM t WHERE i1 BETWEEN 6 AND 19;
EXPLAIN SELECT * FROM t WHERE i2 BETWEEN 6 AND 19;
EXPLAIN SELECT * FROM t WHERE i1 BETWEEN 6 AND 19 AND i2 BETWEEN 6 AND 19;

-- correlation of PK worse than non-UK -> non-UK used

DROP TABLE t;

CREATE TABLE t (
  i1 INTEGER PRIMARY KEY,
  i2 INTEGER
);

CREATE INDEX t_i2 ON t (i2);

INSERT INTO t SELECT u, row_number() OVER () FROM large;

COMMIT;

ANALYZE t;

SELECT attname, null_frac, avg_width, n_distinct, correlation FROM pg_stats WHERE tablename = 't' ORDER BY attname;

EXPLAIN SELECT * FROM t WHERE i1 BETWEEN 6 AND 19;
EXPLAIN SELECT * FROM t WHERE i2 BETWEEN 6 AND 19;
EXPLAIN SELECT * FROM t WHERE i1 BETWEEN 6 AND 19 AND i2 BETWEEN 6 AND 19;

-- correlation of UK worse than non-UK -> non-UK used

DROP TABLE t;

CREATE TABLE t (
  i1 INTEGER UNIQUE,
  i2 INTEGER
);

CREATE INDEX t_i2 ON t (i2);

INSERT INTO t SELECT u, row_number() OVER () FROM large;

COMMIT;

ANALYZE t;

SELECT attname, null_frac, avg_width, n_distinct, correlation FROM pg_stats WHERE tablename = 't' ORDER BY attname;

EXPLAIN SELECT * FROM t WHERE i1 BETWEEN 6 AND 19;
EXPLAIN SELECT * FROM t WHERE i2 BETWEEN 6 AND 19;
EXPLAIN SELECT * FROM t WHERE i1 BETWEEN 6 AND 19 AND i2 BETWEEN 6 AND 19;

DROP TABLE t;
