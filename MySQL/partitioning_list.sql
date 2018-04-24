--
-- This script is used to test the list partitioning capabilities
--

--
-- setup
--

DROP TABLE fk;
DROP TABLE t1;
DROP TABLE t2;

-- single-column partitioning

CREATE TABLE t1 (id INTEGER, i1 INTEGER, i2 INTEGER, i3 INTEGER, i4 INTEGER, i5 INTEGER)
PARTITION BY LIST (i1) (
    PARTITION p00 VALUES IN (NULL),
    PARTITION p10 VALUES IN (1),
    PARTITION p20 VALUES IN (2),
    PARTITION p30 VALUES IN (3),
    PARTITION p40 VALUES IN (4),
    PARTITION p50 VALUES IN (5,6,7,8,9,10)
);

CREATE TABLE t2 (id INTEGER, i1 INTEGER, i2 INTEGER, i3 INTEGER, i4 INTEGER, i5 INTEGER)
PARTITION BY LIST COLUMNS (i1, i2) (
    PARTITION p00 VALUES IN ((NULL,NULL)),
    PARTITION p10 VALUES IN ((1,1)),
    PARTITION p20 VALUES IN ((2,1), (2,2)),
    PARTITION p30 VALUES IN ((3,1), (3,2), (3,3)),
    PARTITION p40 VALUES IN ((4,1), (4,2), (4,3), (4,4)),
    PARTITION p50 VALUES IN ((5,1), (5,2), (5,3), (5,4), (5,5))
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
EXPLAIN SELECT * FROM t1 WHERE i1 IN (4, 6);
EXPLAIN SELECT * FROM t1 WHERE i1 IN (4, 24);
EXPLAIN SELECT * FROM t1 WHERE i1 = 42;

-- pruning with inequalities and NOT

EXPLAIN SELECT * FROM t1 WHERE i1 != 4;
EXPLAIN SELECT * FROM t1 WHERE NOT i1 < 4;
EXPLAIN SELECT * FROM t1 WHERE i1 NOT BETWEEN 4 AND 14;
EXPLAIN SELECT * FROM t1 WHERE i1 NOT IN (4, 6);
EXPLAIN SELECT * FROM t1 WHERE i1 NOT IN (4, 24);

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
