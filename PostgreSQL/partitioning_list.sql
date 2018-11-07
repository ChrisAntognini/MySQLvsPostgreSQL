--
-- This script is used to test the list partitioning capabilities
--

--
-- setup
--

DROP TABLE IF EXISTS t;
DROP TABLE IF EXISTS fk;

-- single-column partitioning

CREATE TABLE t (id INTEGER, i INTEGER) PARTITION BY LIST (i);

CREATE TABLE t_n PARTITION OF t FOR VALUES IN (NULL);
CREATE TABLE t_1 PARTITION OF t FOR VALUES IN (1);
CREATE TABLE t_2 PARTITION OF t FOR VALUES IN (2);
CREATE TABLE t_3 PARTITION OF t FOR VALUES IN (3);
CREATE TABLE t_4 PARTITION OF t FOR VALUES IN (4);
CREATE TABLE t_x PARTITION OF t FOR VALUES IN (5,6,7,8,9,10);

INSERT INTO t SELECT u, mod(u,10)+1 FROM large WHERE u <= 10000;

COMMIT;

ANALYZE t;

-- PK/UK support (since the index is local, the partition key must be included)

ALTER TABLE t ADD CONSTRAINT t_pk PRIMARY KEY (id);
ALTER TABLE t ADD CONSTRAINT t_pk PRIMARY KEY (id, i);
ALTER TABLE t DROP CONSTRAINT t_pk;

ALTER TABLE t ADD CONSTRAINT t_uk UNIQUE (id);
ALTER TABLE t ADD CONSTRAINT t_uk UNIQUE (id, i);
ALTER TABLE t DROP CONSTRAINT t_uk;

-- FK cannot reference partitioned table

CREATE TABLE fk AS SELECT * FROM t;
ALTER TABLE t ADD CONSTRAINT t_pk PRIMARY KEY (id, i);
ALTER TABLE fk ADD CONSTRAINT fk_t_fk FOREIGN KEY (id,i) REFERENCES t (id,i);
ALTER TABLE t DROP CONSTRAINT t_pk;

-- FK on partitioned table supported

ALTER TABLE t ADD CONSTRAINT t_large_fk FOREIGN KEY (id) REFERENCES large (u);

--
-- partition exclusion (pruning)
--

-- parse-time pruning based on equalities, ranges, IN conditions

EXPLAIN SELECT * FROM t;
EXPLAIN SELECT * FROM t WHERE i = 4;
EXPLAIN SELECT * FROM t WHERE i < 4;
EXPLAIN SELECT * FROM t WHERE i BETWEEN 4 AND 14;
EXPLAIN SELECT * FROM t WHERE i IN (4, 6);
EXPLAIN SELECT * FROM t WHERE i IN (4, 24);
EXPLAIN SELECT * FROM t WHERE i = 42;

-- parse-time pruning with NOT equalities, ranges, IN conditions

EXPLAIN SELECT * FROM t WHERE i != 4;
EXPLAIN SELECT * FROM t WHERE NOT i < 4;
EXPLAIN SELECT * FROM t WHERE i NOT BETWEEN 4 AND 14;
EXPLAIN SELECT * FROM t WHERE i NOT IN (4, 6);
EXPLAIN SELECT * FROM t WHERE i NOT IN (4, 24);

-- no execution-time pruning for joins

EXPLAIN SELECT * FROM t JOIN small ON t.i = small.nu WHERE small.u = 4;
EXPLAIN SELECT * FROM t JOIN small ON t.i = small.u WHERE small.nu = 4;

--
-- local indexes as well as pruning on them are supported
--

CREATE INDEX i1 ON t (id);

EXPLAIN SELECT * FROM t WHERE id = 4;
EXPLAIN SELECT * FROM t WHERE id = 4 AND i = 5;

--
-- cleanup
--

DROP TABLE t;
DROP TABLE fk;
