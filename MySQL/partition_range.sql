--
-- This script is used to test the range partitioning capabilities
--

--
-- setup
--

DROP TABLE fk;
DROP TABLE t1;
DROP TABLE t2;
DROP TABLE t3;
DROP TABLE t4;
DROP TABLE t5;

-- single and multi-column partitioning

CREATE TABLE t1 (id INTEGER, i1 INTEGER, i2 INTEGER, i3 INTEGER, i4 INTEGER, i5 INTEGER)
PARTITION BY RANGE (i1) (
    PARTITION p00 VALUES LESS THAN (1),
    PARTITION p10 VALUES LESS THAN (11),
    PARTITION p20 VALUES LESS THAN (21),
    PARTITION p30 VALUES LESS THAN (31),
    PARTITION p40 VALUES LESS THAN (41)
);

CREATE TABLE t2 (id INTEGER, i1 INTEGER, i2 INTEGER, i3 INTEGER, i4 INTEGER, i5 INTEGER)
PARTITION BY RANGE COLUMNS (i1, i2) (
    PARTITION p00 VALUES LESS THAN (1, 1),
    PARTITION p10 VALUES LESS THAN (11, 11),
    PARTITION p20 VALUES LESS THAN (21, 21),
    PARTITION p30 VALUES LESS THAN (31, 31),
    PARTITION p40 VALUES LESS THAN (41, 41)
);

CREATE TABLE t3 (id INTEGER, i1 INTEGER, i2 INTEGER, i3 INTEGER, i4 INTEGER, i5 INTEGER)
PARTITION BY RANGE COLUMNS (i1, i2, i3) (
    PARTITION p00 VALUES LESS THAN (1, 1, 1),
    PARTITION p10 VALUES LESS THAN (11, 11, 11),
    PARTITION p20 VALUES LESS THAN (21, 21, 21),
    PARTITION p30 VALUES LESS THAN (31, 31, 31),
    PARTITION p40 VALUES LESS THAN (41, 41, 41)
);

CREATE TABLE t4 (id INTEGER, i1 INTEGER, i2 INTEGER, i3 INTEGER, i4 INTEGER, i5 INTEGER)
PARTITION BY RANGE COLUMNS (i1, i2, i3, i4) (
    PARTITION p00 VALUES LESS THAN (1, 1, 1, 1),
    PARTITION p10 VALUES LESS THAN (11, 11, 11, 11),
    PARTITION p20 VALUES LESS THAN (21, 21, 21, 21),
    PARTITION p30 VALUES LESS THAN (31, 31, 31, 31),
    PARTITION p40 VALUES LESS THAN (41, 41, 41, 41)
);

CREATE TABLE t5 (id INTEGER, i1 INTEGER, i2 INTEGER, i3 INTEGER, i4 INTEGER, i5 INTEGER)
PARTITION BY RANGE COLUMNS (i1, i2, i3, i4, i5) (
    PARTITION p00 VALUES LESS THAN (1, 1, 1, 1, 1),
    PARTITION p10 VALUES LESS THAN (11, 11, 11, 11, 11),
    PARTITION p20 VALUES LESS THAN (21, 21, 21, 21, 21),
    PARTITION p30 VALUES LESS THAN (31, 31, 31, 31, 31),
    PARTITION p40 VALUES LESS THAN (41, 41, 41, 41, 41)
);

-- PK/UK support

ALTER TABLE t1 ADD CONSTRAINT t1_pk PRIMARY KEY (id);
ALTER TABLE t1 ADD CONSTRAINT t1_pk PRIMARY KEY (id, i1);
ALTER TABLE t1 DROP PRIMARY KEY;

ALTER TABLE t1 ADD CONSTRAINT t1_uk UNIQUE (id);
ALTER TABLE t1 ADD CONSTRAINT t1_uk UNIQUE (id, i1);
ALTER TABLE t1 DROP INDEX t1_uk;

-- no FK support

CREATE TABLE fk AS SELECT * FROM t1;
ALTER TABLE t1 ADD CONSTRAINT t1_pk PRIMARY KEY (id, i1);
ALTER TABLE fk ADD CONSTRAINT fk_t1_fk FOREIGN KEY (id,i1) REFERENCES t1 (id,i1);
ALTER TABLE t1 DROP PRIMARY KEY;

ALTER TABLE t1 ADD CONSTRAINT t1_large_fk FOREIGN KEY (id) REFERENCES large (u);

--
-- partition exclusion (pruning)
--

-- pruning based on equalities, ranges, IN conditions

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
-- local indexes are supported
--

CREATE INDEX i1 ON t1 (id);

EXPLAIN SELECT * FROM t1 WHERE id = 4;
EXPLAIN SELECT * FROM t1 WHERE id = 4 AND i1 = 5;

--
-- cleanup
--

DROP TABLE fk;
DROP TABLE t1;
DROP TABLE t2;
DROP TABLE t3;
DROP TABLE t4;
DROP TABLE t5;