--
-- This script is used to test invisible indexes.
--

-- setup

DROP TABLE IF EXISTS t;

CREATE TABLE t (
  i INTEGER,
  padding VARCHAR(10)
);

INSERT INTO t SELECT u, 'blablabla' FROM large WHERE u <= 10000;

COMMIT;

CREATE INDEX i ON t (i) INVISIBLE;

ANALYZE TABLE t;

-- default settings

set optimizer_switch=default;

EXPLAIN SELECT * FROM t WHERE i = 42;

-- use of invisible indexes activated

set optimizer_switch='use_invisible_indexes=on';

EXPLAIN SELECT * FROM t WHERE i = 42;

-- use of invisible indexes deactivated

set optimizer_switch='use_invisible_indexes=off';

EXPLAIN SELECT * FROM t WHERE i = 42;
ALTER TABLE t ALTER INDEX i VISIBLE;
EXPLAIN SELECT * FROM t WHERE i = 42;

-- cleanup

DROP TABLE t;
