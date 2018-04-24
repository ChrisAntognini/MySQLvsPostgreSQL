--
-- This script is used to check whether bushy plans are evaluated or not.
--

-- setup

DROP TABLE s1;
DROP TABLE l1;
DROP TABLE s2;
DROP TABLE l2;

CREATE TABLE s1 AS SELECT u AS s, p FROM small;
CREATE TABLE l1 AS SELECT u AS s, mod(u,10) AS l, p FROM large;
CREATE TABLE s2 AS SELECT u AS s, p FROM small;
CREATE TABLE l2 AS SELECT u AS s, mod(u,10) AS l, p FROM large;

ANALYZE TABLE s1;
ANALYZE TABLE l1;
ANALYZE TABLE s2;
ANALYZE TABLE l2;

-- bushy plan not used

EXPLAIN
SELECT *
FROM s1, l1, s2, l2
WHERE s1.s = l1.s AND s2.s = l2.s AND l1.l = l2.l;

SELECT *
FROM s1, l1, s2, l2
WHERE s1.s = l1.s AND s2.s = l2.s AND l1.l = l2.l;

-- force bushy plan

EXPLAIN
SELECT /*+ no_merge(a) no_merge(b) */ * 
FROM (SELECT s1.s, l1.l
      FROM s1, l1
      WHERE s1.s = l1.s) a,
     (SELECT s2.s, l2.l
      FROM s2, l2
      WHERE s2.s = l2.s) b
WHERE a.l = b.l;

SELECT /*+ no_merge(a) no_merge(b) */ * 
FROM (SELECT s1.s, l1.l
      FROM s1, l1
      WHERE s1.s = l1.s) a,
     (SELECT s2.s, l2.l
      FROM s2, l2
      WHERE s2.s = l2.s) b
WHERE a.l = b.l;

-- cleanup

DROP TABLE s1;
DROP TABLE l1;
DROP TABLE s2;
DROP TABLE l2;
