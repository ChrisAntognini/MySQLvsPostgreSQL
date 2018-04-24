--
-- This script is used to test the list partitioning capabilities
--

--
-- setup
--

DROP TABLE t;

-- no PK/UK support

CREATE TABLE t (id INTEGER PRIMARY KEY, i INTEGER) PARTITION BY LIST (i);
CREATE TABLE t (id INTEGER UNIQUE, i INTEGER) PARTITION BY LIST (i);

-- single-column partitioning

CREATE TABLE t (id INTEGER, i INTEGER) PARTITION BY LIST (i);

CREATE TABLE t_n PARTITION OF t FOR VALUES IN (NULL);
CREATE TABLE t_1 PARTITION OF t FOR VALUES IN (1);
CREATE TABLE t_2 PARTITION OF t FOR VALUES IN (2);
CREATE TABLE t_3 PARTITION OF t FOR VALUES IN (3);
CREATE TABLE t_4 PARTITION OF t FOR VALUES IN (4);
CREATE TABLE t_x PARTITION OF t FOR VALUES IN (5,6,7,8,9,10);

-- no FK to another table

ALTER TABLE t ADD CONSTRAINT t_large_fk FOREIGN KEY (id) REFERENCES large (u);

--
-- partition exclusion (pruning)
--

-- if constraint_exclusion != off (default), pruning based on equalities, ranges, IN conditions

-- SET constraint_exclusion = on;
-- SET constraint_exclusion = partition;
-- SET constraint_exclusion = off;

EXPLAIN SELECT * FROM t;
EXPLAIN SELECT * FROM t WHERE i = 4;
EXPLAIN SELECT * FROM t WHERE i < 4;
EXPLAIN SELECT * FROM t WHERE i BETWEEN 4 AND 14;
EXPLAIN SELECT * FROM t WHERE i IN (4, 6);
EXPLAIN SELECT * FROM t WHERE i IN (4, 24);
EXPLAIN SELECT * FROM t WHERE i = 42;

-- pruning with inequalities and NOT

EXPLAIN SELECT * FROM t WHERE i != 4;
EXPLAIN SELECT * FROM t WHERE NOT i < 4;
EXPLAIN SELECT * FROM t WHERE i NOT BETWEEN 4 AND 14;
EXPLAIN SELECT * FROM t WHERE i NOT IN (4, 6);
EXPLAIN SELECT * FROM t WHERE i NOT IN (4, 24);

--
-- indexes
--

-- can't create index at the table level

CREATE INDEX i ON t (id);
CREATE UNIQUE INDEX i ON t (id);

-- index to be created at the partition level

CREATE UNIQUE INDEX i_n ON t_n (id);
CREATE UNIQUE INDEX i_1 ON t_1 (id);
CREATE UNIQUE INDEX i_2 ON t_2 (id);
CREATE UNIQUE INDEX i_3 ON t_3 (id);
CREATE UNIQUE INDEX i_4 ON t_4 (id);
CREATE UNIQUE INDEX i_x ON t_x (id);

-- uniqueness checked only at the partition level

INSERT INTO t VALUES (1, 1);
INSERT INTO t VALUES (1, 1);
INSERT INTO t VALUES (1, 10);

--
-- cleanup
--

DROP TABLE t;
