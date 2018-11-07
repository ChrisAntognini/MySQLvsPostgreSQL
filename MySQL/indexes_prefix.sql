--
-- This script is used to check the utilization of an index for which a prefix length is specified.
--

-- setup

DROP TABLE IF EXISTS t;

CREATE TABLE t (
  i1 VARCHAR(30),
  i2 VARCHAR(30)
);

INSERT INTO t SELECT concat(u,'verydullsuffix'), concat(u,'verydullsuffix') FROM large WHERE u BETWEEN 10000 AND 19999;

COMMIT;

CREATE INDEX i1 ON t (i1);
CREATE INDEX i2 ON t (i2(5));

ANALYZE TABLE t;

-- check that the size of the indexes

SELECT index_name, stat_value
FROM mysql.innodb_index_stats 
WHERE database_name = 'chris' 
AND table_name = 't'
AND index_name IN ('i1','i2')
AND stat_name = 'size';

-- check that both indexes can be used

EXPLAIN SELECT * FROM t WHERE i1 LIKE '10042%';
EXPLAIN SELECT * FROM t WHERE i2 LIKE '10042%';

-- cleanup

DROP TABLE t;
