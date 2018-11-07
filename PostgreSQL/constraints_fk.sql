--
-- This script is used to test whether the query optimizer uses foreign key constraints to eliminate
-- unnecessary loss-less joins.
--

-- setup

DROP TABLE IF EXISTS t2;
DROP TABLE IF EXISTS t1;

CREATE TABLE t1 (
  id INTEGER PRIMARY KEY,
  pad CHAR(10)
);

INSERT INTO t1 SELECT u, 'ABCDEFGHIJ' FROM large WHERE u <= 1000;
COMMIT;

CREATE TABLE t2 (
  id INTEGER PRIMARY KEY,
  t1_id INTEGER NOT NULL,
  pad CHAR(10)
);

ALTER TABLE t2 ADD CONSTRAINT t2_t1_fk FOREIGN KEY (t1_id) REFERENCES t1 (id);

INSERT INTO t2 SELECT t1.id*10+small.u, t1.id, 'ABCDEFGHIJ' FROM small, t1;
COMMIT;

ANALYZE t1;
ANALYZE t2;

-- join elimination does not take place

EXPLAIN SELECT t2.* FROM t1 JOIN t2 ON t1.id = t2.t1_id;
EXPLAIN SELECT t2.* FROM t1, t2 WHERE t1.id = t2.t1_id;

-- cleanup

DROP TABLE t2;
DROP TABLE t1;
