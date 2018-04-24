--
-- This script is used to test how the query optimizer handles sub-queries.
--

set max_parallel_workers_per_gather to 0;

--
-- scalar with equality
--

-- A1

SELECT 'A1' AS CASE;

EXPLAIN SELECT * FROM small WHERE u  = (SELECT nu FROM large WHERE u = 6);
EXPLAIN SELECT * FROM small WHERE n  = (SELECT n  FROM large WHERE u = 6);
EXPLAIN SELECT * FROM small WHERE n  = (SELECT nn FROM large WHERE u = 6);
EXPLAIN SELECT * FROM small WHERE nn = (SELECT n  FROM large WHERE u = 6);
EXPLAIN SELECT * FROM small WHERE nn = (SELECT nn FROM large WHERE u = 6);

EXPLAIN ANALYZE SELECT * FROM small WHERE u  = (SELECT nu FROM large WHERE u = 6);
EXPLAIN ANALYZE SELECT * FROM small WHERE n  = (SELECT n  FROM large WHERE u = 6);
EXPLAIN ANALYZE SELECT * FROM small WHERE n  = (SELECT nn FROM large WHERE u = 6);
EXPLAIN ANALYZE SELECT * FROM small WHERE nn = (SELECT n  FROM large WHERE u = 6);
EXPLAIN ANALYZE SELECT * FROM small WHERE nn = (SELECT nn FROM large WHERE u = 6);

-- A2

SELECT 'A2' AS CASE;

EXPLAIN SELECT * FROM large WHERE u  = (SELECT nu FROM small WHERE u = 6);
EXPLAIN SELECT * FROM large WHERE n  = (SELECT n  FROM small WHERE u = 6);
EXPLAIN SELECT * FROM large WHERE n  = (SELECT nn FROM small WHERE u = 6);
EXPLAIN SELECT * FROM large WHERE nn = (SELECT n  FROM small WHERE u = 6);
EXPLAIN SELECT * FROM large WHERE nn = (SELECT nn FROM small WHERE u = 6);

EXPLAIN ANALYZE SELECT * FROM large WHERE u  = (SELECT nu FROM small WHERE u = 6);
EXPLAIN ANALYZE SELECT * FROM large WHERE n  = (SELECT n  FROM small WHERE u = 6);
EXPLAIN ANALYZE SELECT * FROM large WHERE n  = (SELECT nn FROM small WHERE u = 6);
EXPLAIN ANALYZE SELECT * FROM large WHERE nn = (SELECT n  FROM small WHERE u = 6);
EXPLAIN ANALYZE SELECT * FROM large WHERE nn = (SELECT nn FROM small WHERE u = 6);

--
-- scalar with inequality
--

-- B1

SELECT 'B1' AS CASE;

EXPLAIN SELECT * FROM small WHERE u  != (SELECT nu FROM large WHERE u = 6);
EXPLAIN SELECT * FROM small WHERE n  != (SELECT n  FROM large WHERE u = 6);
EXPLAIN SELECT * FROM small WHERE n  != (SELECT nn FROM large WHERE u = 6);
EXPLAIN SELECT * FROM small WHERE nn != (SELECT n  FROM large WHERE u = 6);
EXPLAIN SELECT * FROM small WHERE nn != (SELECT nn FROM large WHERE u = 6);

EXPLAIN ANALYZE SELECT * FROM small WHERE u  != (SELECT nu FROM large WHERE u = 6);
EXPLAIN ANALYZE SELECT * FROM small WHERE n  != (SELECT n  FROM large WHERE u = 6);
EXPLAIN ANALYZE SELECT * FROM small WHERE n  != (SELECT nn FROM large WHERE u = 6);
EXPLAIN ANALYZE SELECT * FROM small WHERE nn != (SELECT n  FROM large WHERE u = 6);
EXPLAIN ANALYZE SELECT * FROM small WHERE nn != (SELECT nn FROM large WHERE u = 6);

-- B2

SELECT 'B2' AS CASE;

EXPLAIN SELECT * FROM large WHERE u  != (SELECT nu FROM small WHERE u = 6);
EXPLAIN SELECT * FROM large WHERE n  != (SELECT n  FROM small WHERE u = 6);
EXPLAIN SELECT * FROM large WHERE n  != (SELECT nn FROM small WHERE u = 6);
EXPLAIN SELECT * FROM large WHERE nn != (SELECT n  FROM small WHERE u = 6);
EXPLAIN SELECT * FROM large WHERE nn != (SELECT nn FROM small WHERE u = 6);

EXPLAIN ANALYZE SELECT * FROM large WHERE u  != (SELECT nu FROM small WHERE u = 6);
EXPLAIN ANALYZE SELECT * FROM large WHERE n  != (SELECT n  FROM small WHERE u = 6);
EXPLAIN ANALYZE SELECT * FROM large WHERE n  != (SELECT nn FROM small WHERE u = 6);
EXPLAIN ANALYZE SELECT * FROM large WHERE nn != (SELECT n  FROM small WHERE u = 6);
EXPLAIN ANALYZE SELECT * FROM large WHERE nn != (SELECT nn FROM small WHERE u = 6);

--
-- uncorrelated with IN or EXISTS
--

-- C1

SELECT 'C1' AS CASE;

EXPLAIN SELECT * FROM small WHERE n  IN     (SELECT n  FROM large);
EXPLAIN SELECT * FROM small WHERE n  IN     (SELECT nn FROM large);
EXPLAIN SELECT * FROM small WHERE nn IN     (SELECT n  FROM large);
EXPLAIN SELECT * FROM small WHERE nn IN     (SELECT nn FROM large);
EXPLAIN SELECT * FROM small WHERE    EXISTS (SELECT *  FROM large);

EXPLAIN ANALYZE SELECT * FROM small WHERE n  IN     (SELECT n  FROM large);
EXPLAIN ANALYZE SELECT * FROM small WHERE n  IN     (SELECT nn FROM large);
EXPLAIN ANALYZE SELECT * FROM small WHERE nn IN     (SELECT n  FROM large);
EXPLAIN ANALYZE SELECT * FROM small WHERE nn IN     (SELECT nn FROM large);
EXPLAIN ANALYZE SELECT * FROM small WHERE    EXISTS (SELECT *  FROM large);

-- C2

SELECT 'C2' AS CASE;

EXPLAIN SELECT * FROM large WHERE n  IN     (SELECT n  FROM small);
EXPLAIN SELECT * FROM large WHERE n  IN     (SELECT nn FROM small);
EXPLAIN SELECT * FROM large WHERE nn IN     (SELECT n  FROM small);
EXPLAIN SELECT * FROM large WHERE nn IN     (SELECT nn FROM small);
EXPLAIN SELECT * FROM large WHERE    EXISTS (SELECT *  FROM small);

EXPLAIN ANALYZE SELECT * FROM large WHERE n  IN     (SELECT n  FROM small);
EXPLAIN ANALYZE SELECT * FROM large WHERE n  IN     (SELECT nn FROM small);
EXPLAIN ANALYZE SELECT * FROM large WHERE nn IN     (SELECT n  FROM small);
EXPLAIN ANALYZE SELECT * FROM large WHERE nn IN     (SELECT nn FROM small);
EXPLAIN ANALYZE SELECT * FROM large WHERE    EXISTS (SELECT *  FROM small);

--
-- uncorrelated with NOT IN or NOT EXISTS
--

-- D1

SELECT 'D1' AS CASE;

EXPLAIN SELECT * FROM small WHERE n  NOT IN     (SELECT n  FROM large);
EXPLAIN SELECT * FROM small WHERE n  NOT IN     (SELECT nn FROM large);
EXPLAIN SELECT * FROM small WHERE nn NOT IN     (SELECT n  FROM large);
EXPLAIN SELECT * FROM small WHERE nn NOT IN     (SELECT nn FROM large);
EXPLAIN SELECT * FROM small WHERE    NOT EXISTS (SELECT *  FROM large);

EXPLAIN ANALYZE SELECT * FROM small WHERE n  NOT IN     (SELECT n  FROM large);
EXPLAIN ANALYZE SELECT * FROM small WHERE n  NOT IN     (SELECT nn FROM large);
EXPLAIN ANALYZE SELECT * FROM small WHERE nn NOT IN     (SELECT n  FROM large);
EXPLAIN ANALYZE SELECT * FROM small WHERE nn NOT IN     (SELECT nn FROM large);
EXPLAIN ANALYZE SELECT * FROM small WHERE    NOT EXISTS (SELECT *  FROM large);

-- D2

SELECT 'D2' AS CASE;

EXPLAIN SELECT * FROM large WHERE n  NOT IN     (SELECT n  FROM small);
EXPLAIN SELECT * FROM large WHERE n  NOT IN     (SELECT nn FROM small);
EXPLAIN SELECT * FROM large WHERE nn NOT IN     (SELECT n  FROM small);
EXPLAIN SELECT * FROM large WHERE nn NOT IN     (SELECT nn FROM small);
EXPLAIN SELECT * FROM large WHERE    NOT EXISTS (SELECT *  FROM small);

EXPLAIN ANALYZE SELECT * FROM large WHERE n  NOT IN     (SELECT n  FROM small);
EXPLAIN ANALYZE SELECT * FROM large WHERE n  NOT IN     (SELECT nn FROM small);
EXPLAIN ANALYZE SELECT * FROM large WHERE nn NOT IN     (SELECT n  FROM small);
EXPLAIN ANALYZE SELECT * FROM large WHERE nn NOT IN     (SELECT nn FROM small);
EXPLAIN ANALYZE SELECT * FROM large WHERE    NOT EXISTS (SELECT *  FROM small);

--
-- correlated with IN or EXISTS
--

-- E1

SELECT 'E1' AS CASE;

EXPLAIN SELECT * FROM small WHERE n  IN     (SELECT n  FROM large WHERE large.u  = small.u);
EXPLAIN SELECT * FROM small WHERE n  IN     (SELECT nn FROM large WHERE large.u  = small.u);
EXPLAIN SELECT * FROM small WHERE nn IN     (SELECT n  FROM large WHERE large.u  = small.u);
EXPLAIN SELECT * FROM small WHERE nn IN     (SELECT nn FROM large WHERE large.u  = small.u);
EXPLAIN SELECT * FROM small WHERE n  IN     (SELECT n  FROM large WHERE large.nu = small.u);
EXPLAIN SELECT * FROM small WHERE n  IN     (SELECT nn FROM large WHERE large.nu = small.u);
EXPLAIN SELECT * FROM small WHERE nn IN     (SELECT n  FROM large WHERE large.nu = small.u);
EXPLAIN SELECT * FROM small WHERE nn IN     (SELECT nn FROM large WHERE large.nu = small.u);
EXPLAIN SELECT * FROM small WHERE    EXISTS (SELECT *  FROM large WHERE large.u  = small.u);
EXPLAIN SELECT * FROM small WHERE    EXISTS (SELECT *  FROM large WHERE large.nu = small.u);

EXPLAIN ANALYZE SELECT * FROM small WHERE n  IN     (SELECT n  FROM large WHERE large.u  = small.u);
EXPLAIN ANALYZE SELECT * FROM small WHERE n  IN     (SELECT nn FROM large WHERE large.u  = small.u);
EXPLAIN ANALYZE SELECT * FROM small WHERE nn IN     (SELECT n  FROM large WHERE large.u  = small.u);
EXPLAIN ANALYZE SELECT * FROM small WHERE nn IN     (SELECT nn FROM large WHERE large.u  = small.u);
EXPLAIN ANALYZE SELECT * FROM small WHERE n  IN     (SELECT n  FROM large WHERE large.nu = small.u);
EXPLAIN ANALYZE SELECT * FROM small WHERE n  IN     (SELECT nn FROM large WHERE large.nu = small.u);
EXPLAIN ANALYZE SELECT * FROM small WHERE nn IN     (SELECT n  FROM large WHERE large.nu = small.u);
EXPLAIN ANALYZE SELECT * FROM small WHERE nn IN     (SELECT nn FROM large WHERE large.nu = small.u);
EXPLAIN ANALYZE SELECT * FROM small WHERE    EXISTS (SELECT *  FROM large WHERE large.u  = small.u);
EXPLAIN ANALYZE SELECT * FROM small WHERE    EXISTS (SELECT *  FROM large WHERE large.nu = small.u);

-- E2

SELECT 'E2' AS CASE;

EXPLAIN SELECT * FROM large WHERE n  IN     (SELECT n  FROM small WHERE small.u  = large.u);
EXPLAIN SELECT * FROM large WHERE n  IN     (SELECT nn FROM small WHERE small.u  = large.u);
EXPLAIN SELECT * FROM large WHERE nn IN     (SELECT n  FROM small WHERE small.u  = large.u);
EXPLAIN SELECT * FROM large WHERE nn IN     (SELECT nn FROM small WHERE small.u  = large.u);
EXPLAIN SELECT * FROM large WHERE n  IN     (SELECT n  FROM small WHERE small.nu = large.u);
EXPLAIN SELECT * FROM large WHERE n  IN     (SELECT nn FROM small WHERE small.nu = large.u);
EXPLAIN SELECT * FROM large WHERE nn IN     (SELECT n  FROM small WHERE small.nu = large.u);
EXPLAIN SELECT * FROM large WHERE nn IN     (SELECT nn FROM small WHERE small.nu = large.u);
EXPLAIN SELECT * FROM large WHERE    EXISTS (SELECT *  FROM small WHERE small.u  = large.u);
EXPLAIN SELECT * FROM large WHERE    EXISTS (SELECT *  FROM small WHERE small.nu = large.u);

EXPLAIN ANALYZE SELECT * FROM large WHERE n  IN     (SELECT n  FROM small WHERE small.u  = large.u);
EXPLAIN ANALYZE SELECT * FROM large WHERE n  IN     (SELECT nn FROM small WHERE small.u  = large.u);
EXPLAIN ANALYZE SELECT * FROM large WHERE nn IN     (SELECT n  FROM small WHERE small.u  = large.u);
EXPLAIN ANALYZE SELECT * FROM large WHERE nn IN     (SELECT nn FROM small WHERE small.u  = large.u);
EXPLAIN ANALYZE SELECT * FROM large WHERE n  IN     (SELECT n  FROM small WHERE small.nu = large.u);
EXPLAIN ANALYZE SELECT * FROM large WHERE n  IN     (SELECT nn FROM small WHERE small.nu = large.u);
EXPLAIN ANALYZE SELECT * FROM large WHERE nn IN     (SELECT n  FROM small WHERE small.nu = large.u);
EXPLAIN ANALYZE SELECT * FROM large WHERE nn IN     (SELECT nn FROM small WHERE small.nu = large.u);
EXPLAIN ANALYZE SELECT * FROM large WHERE    EXISTS (SELECT *  FROM small WHERE small.u  = large.u);
EXPLAIN ANALYZE SELECT * FROM large WHERE    EXISTS (SELECT *  FROM small WHERE small.nu = large.u);

--
-- correlated with NOT IN or NOT EXISTS
--

-- F1

SELECT 'F1' AS CASE;

EXPLAIN SELECT * FROM small WHERE n  NOT IN     (SELECT n  FROM large WHERE large.u  = small.u);
EXPLAIN SELECT * FROM small WHERE n  NOT IN     (SELECT nn FROM large WHERE large.u  = small.u);
EXPLAIN SELECT * FROM small WHERE nn NOT IN     (SELECT n  FROM large WHERE large.u  = small.u);
EXPLAIN SELECT * FROM small WHERE nn NOT IN     (SELECT nn FROM large WHERE large.u  = small.u);
EXPLAIN SELECT * FROM small WHERE n  NOT IN     (SELECT n  FROM large WHERE large.nu = small.u);
EXPLAIN SELECT * FROM small WHERE n  NOT IN     (SELECT nn FROM large WHERE large.nu = small.u);
EXPLAIN SELECT * FROM small WHERE nn NOT IN     (SELECT n  FROM large WHERE large.nu = small.u);
EXPLAIN SELECT * FROM small WHERE nn NOT IN     (SELECT nn FROM large WHERE large.nu = small.u);
EXPLAIN SELECT * FROM small WHERE    NOT EXISTS (SELECT *  FROM large WHERE large.u  = small.u);
EXPLAIN SELECT * FROM small WHERE    NOT EXISTS (SELECT *  FROM large WHERE large.nu = small.u);

EXPLAIN ANALYZE SELECT * FROM small WHERE n  NOT IN     (SELECT n  FROM large WHERE large.u  = small.u);
EXPLAIN ANALYZE SELECT * FROM small WHERE n  NOT IN     (SELECT nn FROM large WHERE large.u  = small.u);
EXPLAIN ANALYZE SELECT * FROM small WHERE nn NOT IN     (SELECT n  FROM large WHERE large.u  = small.u);
EXPLAIN ANALYZE SELECT * FROM small WHERE nn NOT IN     (SELECT nn FROM large WHERE large.u  = small.u);
EXPLAIN ANALYZE SELECT * FROM small WHERE n  NOT IN     (SELECT n  FROM large WHERE large.nu = small.u);
EXPLAIN ANALYZE SELECT * FROM small WHERE n  NOT IN     (SELECT nn FROM large WHERE large.nu = small.u);
EXPLAIN ANALYZE SELECT * FROM small WHERE nn NOT IN     (SELECT n  FROM large WHERE large.nu = small.u);
EXPLAIN ANALYZE SELECT * FROM small WHERE nn NOT IN     (SELECT nn FROM large WHERE large.nu = small.u);
EXPLAIN ANALYZE SELECT * FROM small WHERE    NOT EXISTS (SELECT *  FROM large WHERE large.u  = small.u);
EXPLAIN ANALYZE SELECT * FROM small WHERE    NOT EXISTS (SELECT *  FROM large WHERE large.nu = small.u);

-- F2

SELECT 'F2' AS CASE;

EXPLAIN SELECT * FROM large WHERE n  NOT IN     (SELECT n  FROM small WHERE small.u  = large.u);
EXPLAIN SELECT * FROM large WHERE n  NOT IN     (SELECT nn FROM small WHERE small.u  = large.u);
EXPLAIN SELECT * FROM large WHERE nn NOT IN     (SELECT n  FROM small WHERE small.u  = large.u);
EXPLAIN SELECT * FROM large WHERE nn NOT IN     (SELECT nn FROM small WHERE small.u  = large.u);
EXPLAIN SELECT * FROM large WHERE n  NOT IN     (SELECT n  FROM small WHERE small.nu = large.u);
EXPLAIN SELECT * FROM large WHERE n  NOT IN     (SELECT nn FROM small WHERE small.nu = large.u);
EXPLAIN SELECT * FROM large WHERE nn NOT IN     (SELECT n  FROM small WHERE small.nu = large.u);
EXPLAIN SELECT * FROM large WHERE nn NOT IN     (SELECT nn FROM small WHERE small.nu = large.u);
EXPLAIN SELECT * FROM large WHERE    NOT EXISTS (SELECT *  FROM small WHERE small.u  = large.u);
EXPLAIN SELECT * FROM large WHERE    NOT EXISTS (SELECT *  FROM small WHERE small.nu = large.u);

EXPLAIN ANALYZE SELECT * FROM large WHERE n  NOT IN     (SELECT n  FROM small WHERE small.u  = large.u);
EXPLAIN ANALYZE SELECT * FROM large WHERE n  NOT IN     (SELECT nn FROM small WHERE small.u  = large.u);
EXPLAIN ANALYZE SELECT * FROM large WHERE nn NOT IN     (SELECT n  FROM small WHERE small.u  = large.u);
EXPLAIN ANALYZE SELECT * FROM large WHERE nn NOT IN     (SELECT nn FROM small WHERE small.u  = large.u);
EXPLAIN ANALYZE SELECT * FROM large WHERE n  NOT IN     (SELECT n  FROM small WHERE small.nu = large.u);
EXPLAIN ANALYZE SELECT * FROM large WHERE n  NOT IN     (SELECT nn FROM small WHERE small.nu = large.u);
EXPLAIN ANALYZE SELECT * FROM large WHERE nn NOT IN     (SELECT n  FROM small WHERE small.nu = large.u);
EXPLAIN ANALYZE SELECT * FROM large WHERE nn NOT IN     (SELECT nn FROM small WHERE small.nu = large.u);
EXPLAIN ANALYZE SELECT * FROM large WHERE    NOT EXISTS (SELECT *  FROM small WHERE small.u  = large.u);
EXPLAIN ANALYZE SELECT * FROM large WHERE    NOT EXISTS (SELECT *  FROM small WHERE small.nu = large.u);
