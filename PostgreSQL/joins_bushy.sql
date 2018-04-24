--
-- This script is used to check whether bushy plans are evaluated or not.
--

-- setup

set max_parallel_workers_per_gather to 0;

DROP TABLE s1;
DROP TABLE l1;
DROP TABLE s2;
DROP TABLE l2;

CREATE TABLE s1 AS SELECT u AS s, p FROM small;
CREATE TABLE l1 AS SELECT u AS s, mod(u,10) AS l, p FROM large;
CREATE TABLE s2 AS SELECT u AS s, p FROM small;
CREATE TABLE l2 AS SELECT u AS s, mod(u,10) AS l, p FROM large;

ANALYZE s1;
ANALYZE l1;
ANALYZE s2;
ANALYZE l2;

-- bushy plan used

EXPLAIN ANALYZE
SELECT *
FROM s1, l1, s2, l2
WHERE s1.s = l1.s AND s2.s = l2.s AND l1.l = l2.l;

-- cleanup

DROP TABLE s1;
DROP TABLE l1;
DROP TABLE s2;
DROP TABLE l2;
