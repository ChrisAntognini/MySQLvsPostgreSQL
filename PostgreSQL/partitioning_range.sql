--
-- This script is used to test the range partitioning capabilities
--

--
-- setup
--

DROP TABLE t1;
DROP TABLE t2;
DROP TABLE t3;
DROP TABLE t4;
DROP TABLE t5;

-- no PK/UK support

CREATE TABLE t1 (id INTEGER PRIMARY KEY, i1 INTEGER, i2 INTEGER, i3 INTEGER, i4 INTEGER, i5 INTEGER) PARTITION BY RANGE (i1);
CREATE TABLE t1 (id INTEGER UNIQUE, i1 INTEGER, i2 INTEGER, i3 INTEGER, i4 INTEGER, i5 INTEGER) PARTITION BY RANGE (i1);

-- single and multi-column partitioning

CREATE TABLE t1 (id INTEGER, i1 INTEGER, i2 INTEGER, i3 INTEGER, i4 INTEGER, i5 INTEGER) PARTITION BY RANGE (i1);
CREATE TABLE t2 (id INTEGER, i1 INTEGER, i2 INTEGER, i3 INTEGER, i4 INTEGER, i5 INTEGER) PARTITION BY RANGE (i1, i2);
CREATE TABLE t3 (id INTEGER, i1 INTEGER, i2 INTEGER, i3 INTEGER, i4 INTEGER, i5 INTEGER) PARTITION BY RANGE (i1, i2, i3);
CREATE TABLE t4 (id INTEGER, i1 INTEGER, i2 INTEGER, i3 INTEGER, i4 INTEGER, i5 INTEGER) PARTITION BY RANGE (i1, i2, i3, i4);
CREATE TABLE t5 (id INTEGER, i1 INTEGER, i2 INTEGER, i3 INTEGER, i4 INTEGER, i5 INTEGER) PARTITION BY RANGE (i1, i2, i3, i4, i5);

CREATE TABLE t1_00 PARTITION OF t1 FOR VALUES FROM (0) TO (1);
CREATE TABLE t1_10 PARTITION OF t1 FOR VALUES FROM (1) TO (11);
CREATE TABLE t1_20 PARTITION OF t1 FOR VALUES FROM (11) TO (21);
CREATE TABLE t1_30 PARTITION OF t1 FOR VALUES FROM (21) TO (31);
CREATE TABLE t1_40 PARTITION OF t1 FOR VALUES FROM (31) TO (41);

-- no FK to another table

ALTER TABLE t1 ADD CONSTRAINT t1_large_fk FOREIGN KEY (id) REFERENCES large (u);

--
-- partition exclusion (pruning)
--

-- if constraint_exclusion != off (default), pruning based on equalities, ranges, IN conditions

-- SET constraint_exclusion = on;
-- SET constraint_exclusion = partition;
-- SET constraint_exclusion = off;

EXPLAIN SELECT * FROM t1;
EXPLAIN SELECT * FROM t1 WHERE i1 = 4;
EXPLAIN SELECT * FROM t1 WHERE i1 < 4;
EXPLAIN SELECT * FROM t1 WHERE i1 BETWEEN 4 AND 14;
EXPLAIN SELECT * FROM t1 WHERE i1 IN (4, 24);
EXPLAIN SELECT * FROM t1 WHERE i1 = 42;

-- pruning with NOT ranges

EXPLAIN SELECT * FROM t1 WHERE NOT i1 < 4;
EXPLAIN SELECT * FROM t1 WHERE i1 NOT BETWEEN 4 AND 24;

-- no pruning with inequalities and NOT IN

EXPLAIN SELECT * FROM t1 WHERE i1 != 0;
EXPLAIN SELECT * FROM t1 WHERE i1 NOT IN (0);

--
-- indexes
--

-- can't create index at the table level

CREATE INDEX i1 ON t1 (id);
CREATE UNIQUE INDEX i1 ON t1 (id);

-- index to be created at the partition level

CREATE UNIQUE INDEX i1_00 ON t1_00 (id);
CREATE UNIQUE INDEX i1_10 ON t1_10 (id);
CREATE UNIQUE INDEX i1_20 ON t1_20 (id);
CREATE UNIQUE INDEX i1_30 ON t1_30 (id);
CREATE UNIQUE INDEX i1_40 ON t1_40 (id);

-- uniqueness checked only at the partition level

INSERT INTO t1 VALUES (1, 1, 1, 1, 1, 1);
INSERT INTO t1 VALUES (1, 2, 2, 2, 2, 2);
INSERT INTO t1 VALUES (1, 10, 10, 10, 10, 10);

--
-- cleanup
--

DROP TABLE t1;
DROP TABLE t2;
DROP TABLE t3;
DROP TABLE t4;
DROP TABLE t5;
