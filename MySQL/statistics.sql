--
-- This script is used to show the available object statistics and, at the same time, to check how 
-- they are used from the query optimizer.
--

-- setup

DROP TABLE t;

CREATE TABLE t (
  id INTEGER NOT NULL PRIMARY KEY, 
  scattered1 INTEGER, scattered2 INTEGER, scattered3 INTEGER, 
  clustered1 INTEGER, clustered2 INTEGER, clustered3 INTEGER, 
  normal1 INTEGER, normal2 INTEGER, normal3 INTEGER, 
  status1 BOOLEAN, status2 BOOLEAN, status3 BOOLEAN, 
  pad CHAR(50)
);

INSERT INTO t
SELECT u AS id,
       mod(u,5)+1 AS scattered1,
       mod(u,500)+1 AS scattered2,
       mod(u,50000)+1 AS scattered3,
       ceiling(u/20000) AS clustered1,
       ceiling(u/200) AS clustered2,
       ceiling(u/2) AS clustered3,
       ceiling(rand(0)*5) AS normal1,
       ceiling(rand(0)*500) AS normal2,
       ceiling(rand(0)*50000) AS normal3,
       CASE WHEN u<=99995 THEN true ELSE false END AS status1,
       CASE WHEN u<=99500 THEN true ELSE false END AS status2,
       CASE WHEN u<=50000 THEN true ELSE false END AS status3,
       '12345678901234567890123456789012345678901234567890' AS pad
FROM large
WHERE u <= 100000;

UPDATE t 
SET scattered1 = NULL, scattered2 = NULL, scattered3 = NULL, 
    clustered1 = NULL, clustered2 = NULL, clustered3 = NULL, 
    normal1 = NULL, normal2 = NULL, normal3 = NULL,
    status1 = NULL, status2 = NULL, status3 = NULL 
WHERE mod(id,100) = 0;

COMMIT;

CREATE INDEX t_scattered_i ON t(scattered1,scattered2,scattered3);
CREATE INDEX t_scattered1_i ON t(scattered1);
CREATE INDEX t_scattered2_i ON t(scattered2);
CREATE INDEX t_scattered3_i ON t(scattered3);
CREATE INDEX t_clustered_i ON t(clustered1,clustered2,clustered3);
CREATE INDEX t_clustered1_i ON t(clustered1);
CREATE INDEX t_clustered2_i ON t(clustered2);
CREATE INDEX t_clustered3_i ON t(clustered3);
CREATE INDEX t_normal_i ON t(normal1,normal2,normal3);
CREATE INDEX t_normal1_i ON t(normal1);
CREATE INDEX t_normal2_i ON t(normal2);
CREATE INDEX t_normal3_i ON t(normal3);
CREATE INDEX t_status_i ON t(status1,status2,status3);
CREATE INDEX t_status1_i ON t(status1);
CREATE INDEX t_status2_i ON t(status2);
CREATE INDEX t_status3_i ON t(status3);

ANALYZE TABLE t UPDATE HISTOGRAM ON id, scattered1, scattered2, scattered3, normal1, normal2, normal3, status1, status2, status3 WITH 10 BUCKETS;

-- table statistics

SELECT n_rows, clustered_index_size, sum_of_other_index_sizes FROM mysql.innodb_table_stats WHERE database_name = 'chris' AND table_name = 't';

-- column statistics

SELECT column_name, histogram->>'$."histogram-type"' AS histogram_type, json_length(histogram, '$.buckets') AS buckets, histogram->>'$."null-values"' AS null_values FROM information_schema.column_statistics WHERE schema_name = 'chris' AND table_name = 't';
SELECT column_name, histogram FROM information_schema.column_statistics WHERE schema_name = 'chris' AND table_name = 't' AND column_name LIKE 'normal%';
SELECT column_name, histogram FROM information_schema.column_statistics WHERE schema_name = 'chris' AND table_name = 't' AND column_name LIKE 'scattered%';
SELECT column_name, histogram FROM information_schema.column_statistics WHERE schema_name = 'chris' AND table_name = 't' AND column_name LIKE 'status%';

-- index statistics

SELECT index_name, stat_name, stat_value, sample_size, stat_description FROM mysql.innodb_index_stats WHERE database_name = 'chris' AND table_name = 't';

-- queries to compare reality with statistics

SELECT min(id), max(id), avg(id), count(distinct id), count(id), count(*) FROM t;
SELECT min(scattered1), max(scattered1), avg(scattered1), count(distinct scattered1), count(scattered1), count(*) FROM t;
SELECT min(scattered2), max(scattered2), avg(scattered2), count(distinct scattered2), count(scattered2), count(*) FROM t;
SELECT min(scattered3), max(scattered3), avg(scattered3), count(distinct scattered3), count(scattered3), count(*) FROM t;
SELECT min(clustered1), max(clustered1), avg(clustered1), count(distinct clustered1), count(clustered1), count(*) FROM t;
SELECT min(clustered2), max(clustered2), avg(clustered2), count(distinct clustered2), count(clustered2), count(*) FROM t;
SELECT min(clustered3), max(clustered3), avg(clustered3), count(distinct clustered3), count(clustered3), count(*) FROM t;
SELECT min(normal1), max(normal1), avg(normal1), count(distinct normal1), count(normal1), count(*) FROM t;
SELECT min(normal2), max(normal2), avg(normal2), count(distinct normal2), count(normal2), count(*) FROM t;
SELECT min(normal3), max(normal3), avg(normal3), count(distinct normal3), count(normal3), count(*) FROM t;
SELECT status1, count(*) FROM t GROUP BY status1;
SELECT status2, count(*) FROM t GROUP BY status2;
SELECT status3, count(*) FROM t GROUP BY status3;
SELECT status1, status2,          count(*) FROM t GROUP BY status1, status2;
SELECT status1,          status3, count(*) FROM t GROUP BY status1,          status3;
SELECT          status2, status3, count(*) FROM t GROUP BY          status2, status3;
SELECT status1, status2, status3, count(*) FROM t GROUP BY status1, status2, status3;

SELECT cnt, count(*)
FROM (
  SELECT clustered2, count(*) AS cnt
  FROM t 
  GROUP BY clustered2
) AS t
GROUP BY cnt
ORDER BY cnt;

SELECT cnt, count(*)
FROM (
  SELECT scattered2, count(*) AS cnt
  FROM t 
  GROUP BY scattered2 
) AS t
GROUP BY cnt
ORDER BY cnt;

SELECT cnt, count(*)
FROM (
  SELECT normal2, count(*) AS cnt
  FROM t 
  GROUP BY normal2 
  ORDER BY normal2
) AS t
GROUP BY cnt
ORDER BY cnt;

-- queries to check the utilization of statistics

EXPLAIN SELECT * FROM t WHERE id = 10;
EXPLAIN SELECT * FROM t WHERE id IS NULL;
EXPLAIN SELECT * FROM t WHERE id IS NOT NULL;

EXPLAIN SELECT * FROM t WHERE status1 IS NULL;
EXPLAIN SELECT * FROM t WHERE status1 IS NOT NULL;
EXPLAIN SELECT * FROM t WHERE status1 = 0;
EXPLAIN SELECT * FROM t WHERE status1 = 1;
EXPLAIN SELECT * FROM t WHERE status2 IS NULL;
EXPLAIN SELECT * FROM t WHERE status2 IS NOT NULL;
EXPLAIN SELECT * FROM t WHERE status2 = 0;
EXPLAIN SELECT * FROM t WHERE status2 = 1;
EXPLAIN SELECT * FROM t WHERE status3 IS NULL;
EXPLAIN SELECT * FROM t WHERE status3 IS NOT NULL;
EXPLAIN SELECT * FROM t WHERE status3 = 0;
EXPLAIN SELECT * FROM t WHERE status3 = 1;
EXPLAIN SELECT * FROM t WHERE status1 IS NULL OR status1 IS NOT NULL;
EXPLAIN SELECT * FROM t WHERE status1 IS NULL AND status1 IS NOT NULL;
EXPLAIN SELECT * FROM t WHERE status2 IS NULL OR status2 IS NOT NULL;
EXPLAIN SELECT * FROM t WHERE status2 IS NULL AND status2 IS NOT NULL;
EXPLAIN SELECT * FROM t WHERE status3 IS NULL OR status3 IS NOT NULL;
EXPLAIN SELECT * FROM t WHERE status3 IS NULL AND status3 IS NOT NULL;

EXPLAIN SELECT * FROM t WHERE normal2 = 0;
EXPLAIN SELECT * FROM t WHERE normal2 = 1;
EXPLAIN SELECT * FROM t WHERE normal2 = 343;
EXPLAIN SELECT * FROM t WHERE normal2 = 500;
EXPLAIN SELECT * FROM t WHERE normal2 = 501;

EXPLAIN SELECT * FROM t WHERE clustered2 IS NULL;
EXPLAIN SELECT * FROM t WHERE clustered2 IS NOT NULL;
EXPLAIN SELECT * FROM t WHERE clustered2 BETWEEN 10 AND 20;
EXPLAIN SELECT * FROM t WHERE scattered2 BETWEEN 10 AND 20;
EXPLAIN SELECT * FROM t WHERE normal2 BETWEEN 10 AND 20;
EXPLAIN SELECT * FROM t WHERE clustered1 BETWEEN 10 AND 10010;
EXPLAIN SELECT * FROM t WHERE scattered2 BETWEEN 10 AND 10010;
EXPLAIN SELECT * FROM t WHERE scattered3 BETWEEN 10 AND 10010;
EXPLAIN SELECT * FROM t WHERE normal1 BETWEEN 10 AND 10010;
EXPLAIN SELECT * FROM t WHERE normal2 BETWEEN 10 AND 10010;
EXPLAIN SELECT * FROM t WHERE normal3 BETWEEN 10 AND 10010;

EXPLAIN SELECT * FROM t WHERE clustered2 = 0;
EXPLAIN SELECT * FROM t WHERE scattered2 = 0;
EXPLAIN SELECT * FROM t WHERE normal2 = 0;
EXPLAIN SELECT * FROM t WHERE clustered3 = 50000;
EXPLAIN SELECT * FROM t WHERE clustered3 = 50001;
EXPLAIN SELECT * FROM t WHERE normal3 = 50000;
EXPLAIN SELECT * FROM t WHERE normal3 = 50001;
EXPLAIN SELECT * FROM t WHERE scattered3 = 50000;
EXPLAIN SELECT * FROM t WHERE scattered3 = 50001;

EXPLAIN SELECT * FROM t, small WHERE t.id = small.u;
EXPLAIN SELECT * FROM t, small WHERE t.clustered1 = small.u;
EXPLAIN SELECT * FROM t, small WHERE t.scattered1 = small.u;
EXPLAIN SELECT * FROM t, small WHERE t.normal1 = small.u;

-- cleanup

DROP TABLE t;
