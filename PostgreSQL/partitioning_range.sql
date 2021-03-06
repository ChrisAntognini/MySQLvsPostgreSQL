--
-- This script is used to test the range partitioning capabilities
--

--
-- setup
--

DROP TABLE IF EXISTS t1;
DROP TABLE IF EXISTS t2;
DROP TABLE IF EXISTS t3;
DROP TABLE IF EXISTS t4;
DROP TABLE IF EXISTS t5;
DROP TABLE IF EXISTS fk;

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

INSERT INTO t1 SELECT u, mod(u,40), u, u, u FROM large WHERE u <= 10000;

COMMIT;

ANALYZE t1;

-- PK/UK support (since the index is local, the partition key must be included)

ALTER TABLE t1 ADD CONSTRAINT t1_pk PRIMARY KEY (id);
ALTER TABLE t1 ADD CONSTRAINT t1_pk PRIMARY KEY (id, i1);
ALTER TABLE t1 DROP CONSTRAINT t1_pk;

ALTER TABLE t1 ADD CONSTRAINT t1_uk UNIQUE (id);
ALTER TABLE t1 ADD CONSTRAINT t1_uk UNIQUE (id, i1);
ALTER TABLE t1 DROP CONSTRAINT t1_uk;

-- FK cannot reference partitioned table

CREATE TABLE fk AS SELECT * FROM t1;
ALTER TABLE t1 ADD CONSTRAINT t1_pk PRIMARY KEY (id, i1);
ALTER TABLE fk ADD CONSTRAINT fk_t1_fk FOREIGN KEY (id,i1) REFERENCES t1 (id,i1);
ALTER TABLE t1 DROP CONSTRAINT t1_pk;

-- FK on partitioned table supported

ALTER TABLE t1 ADD CONSTRAINT t1_large_fk FOREIGN KEY (id) REFERENCES large (u);

--
-- partition exclusion (pruning)
--

-- parse-time pruning based on equalities, ranges, IN conditions

EXPLAIN SELECT * FROM t1;
EXPLAIN SELECT * FROM t1 WHERE i1 = 4;
EXPLAIN SELECT * FROM t1 WHERE i1 < 4;
EXPLAIN SELECT * FROM t1 WHERE i1 BETWEEN 4 AND 14;
EXPLAIN SELECT * FROM t1 WHERE i1 IN (4, 24);
EXPLAIN SELECT * FROM t1 WHERE i1 = 42;

-- parse-time pruning with NOT ranges

EXPLAIN SELECT * FROM t1 WHERE NOT i1 < 4;
EXPLAIN SELECT * FROM t1 WHERE i1 NOT BETWEEN 4 AND 24;

-- no pruning with inequalities and NOT IN

EXPLAIN SELECT * FROM t1 WHERE i1 != 0;
EXPLAIN SELECT * FROM t1 WHERE i1 NOT IN (0);

-- no execution-time pruning for joins

EXPLAIN SELECT * FROM t1 JOIN small ON t1.i1 = small.nu WHERE small.u = 42;
EXPLAIN SELECT * FROM t1 JOIN small ON t1.i1 = small.u WHERE small.nu = 42;

--
-- local indexes as well as pruning on them are supported
--

CREATE INDEX i1 ON t1 (id);

EXPLAIN SELECT * FROM t1 WHERE id = 4;
EXPLAIN SELECT * FROM t1 WHERE id = 4 AND i1 = 5;

--
-- cleanup
--

DROP TABLE t1;
DROP TABLE t2;
DROP TABLE t3;
DROP TABLE t4;
DROP TABLE t5;
DROP TABLE fk;
