--
-- This script is used to test how the query optimizer handles sub-queries.
--

warnings

--
-- scalar with equality
--

-- A1

SELECT 'A1' AS "CASE";

EXPLAIN SELECT * FROM small WHERE u  = (SELECT nu FROM large WHERE u = 6);
EXPLAIN SELECT * FROM small WHERE n  = (SELECT n  FROM large WHERE u = 6);
EXPLAIN SELECT * FROM small WHERE n  = (SELECT nn FROM large WHERE u = 6);
EXPLAIN SELECT * FROM small WHERE nn = (SELECT n  FROM large WHERE u = 6);
EXPLAIN SELECT * FROM small WHERE nn = (SELECT nn FROM large WHERE u = 6);

pager > /dev/null
SELECT * FROM small WHERE u  = (SELECT nu FROM large WHERE u = 6);
SELECT * FROM small WHERE n  = (SELECT n  FROM large WHERE u = 6);
SELECT * FROM small WHERE n  = (SELECT nn FROM large WHERE u = 6);
SELECT * FROM small WHERE nn = (SELECT n  FROM large WHERE u = 6);
SELECT * FROM small WHERE nn = (SELECT nn FROM large WHERE u = 6);
nopager

-- A2

SELECT 'A2 ' AS "CASE";

EXPLAIN SELECT * FROM large WHERE u  = (SELECT nu FROM small WHERE u = 6);
EXPLAIN SELECT * FROM large WHERE n  = (SELECT n  FROM small WHERE u = 6);
EXPLAIN SELECT * FROM large WHERE n  = (SELECT nn FROM small WHERE u = 6);
EXPLAIN SELECT * FROM large WHERE nn = (SELECT n  FROM small WHERE u = 6);
EXPLAIN SELECT * FROM large WHERE nn = (SELECT nn FROM small WHERE u = 6);

pager > /dev/null
SELECT * FROM large WHERE u  = (SELECT nu FROM small WHERE u = 6);
SELECT * FROM large WHERE n  = (SELECT n  FROM small WHERE u = 6);
SELECT * FROM large WHERE n  = (SELECT nn FROM small WHERE u = 6);
SELECT * FROM large WHERE nn = (SELECT n  FROM small WHERE u = 6);
SELECT * FROM large WHERE nn = (SELECT nn FROM small WHERE u = 6);
nopager

--
-- scalar with inequality
--

-- B1

SELECT 'B1' AS "CASE";

EXPLAIN SELECT * FROM small WHERE u  != (SELECT nu FROM large WHERE u = 6);
EXPLAIN SELECT * FROM small WHERE n  != (SELECT n  FROM large WHERE u = 6);
EXPLAIN SELECT * FROM small WHERE n  != (SELECT nn FROM large WHERE u = 6);
EXPLAIN SELECT * FROM small WHERE nn != (SELECT n  FROM large WHERE u = 6);
EXPLAIN SELECT * FROM small WHERE nn != (SELECT nn FROM large WHERE u = 6);

pager > /dev/null
SELECT * FROM small WHERE u  != (SELECT nu FROM large WHERE u = 6);
SELECT * FROM small WHERE n  != (SELECT n  FROM large WHERE u = 6);
SELECT * FROM small WHERE n  != (SELECT nn FROM large WHERE u = 6);
SELECT * FROM small WHERE nn != (SELECT n  FROM large WHERE u = 6);
SELECT * FROM small WHERE nn != (SELECT nn FROM large WHERE u = 6);
nopager

-- B2

SELECT ' B2' AS "CASE";

EXPLAIN SELECT * FROM large WHERE u  != (SELECT nu FROM small WHERE u = 6);
EXPLAIN SELECT * FROM large WHERE n  != (SELECT n  FROM small WHERE u = 6);
EXPLAIN SELECT * FROM large WHERE n  != (SELECT nn FROM small WHERE u = 6);
EXPLAIN SELECT * FROM large WHERE nn != (SELECT n  FROM small WHERE u = 6);
EXPLAIN SELECT * FROM large WHERE nn != (SELECT nn FROM small WHERE u = 6);

pager > /dev/null
SELECT * FROM large WHERE u  != (SELECT nu FROM small WHERE u = 6);
SELECT * FROM large WHERE n  != (SELECT n  FROM small WHERE u = 6);
SELECT * FROM large WHERE n  != (SELECT nn FROM small WHERE u = 6);
SELECT * FROM large WHERE nn != (SELECT n  FROM small WHERE u = 6);
SELECT * FROM large WHERE nn != (SELECT nn FROM small WHERE u = 6);
nopager

--
-- uncorrelated with IN or EXISTS
--

-- C1

SELECT 'C1' AS "CASE";

EXPLAIN SELECT * FROM small WHERE n  IN     (SELECT n  FROM large);
EXPLAIN SELECT * FROM small WHERE n  IN     (SELECT nn FROM large);
EXPLAIN SELECT * FROM small WHERE nn IN     (SELECT n  FROM large);
EXPLAIN SELECT * FROM small WHERE nn IN     (SELECT nn FROM large);
EXPLAIN SELECT * FROM small WHERE    EXISTS (SELECT *  FROM large);

pager > /dev/null
SELECT * FROM small WHERE n  IN     (SELECT n  FROM large);
SELECT * FROM small WHERE n  IN     (SELECT nn FROM large);
SELECT * FROM small WHERE nn IN     (SELECT n  FROM large);
SELECT * FROM small WHERE nn IN     (SELECT nn FROM large);
SELECT * FROM small WHERE    EXISTS (SELECT *  FROM large);
nopager

-- C2

SELECT 'C2' AS "CASE";

EXPLAIN SELECT * FROM large WHERE n  IN     (SELECT n  FROM small);
EXPLAIN SELECT * FROM large WHERE n  IN     (SELECT nn FROM small);
EXPLAIN SELECT * FROM large WHERE nn IN     (SELECT n  FROM small);
EXPLAIN SELECT * FROM large WHERE nn IN     (SELECT nn FROM small);
EXPLAIN SELECT * FROM large WHERE    EXISTS (SELECT *  FROM small);

pager > /dev/null
SELECT * FROM large WHERE n  IN     (SELECT n  FROM small);
SELECT * FROM large WHERE n  IN     (SELECT nn FROM small);
SELECT * FROM large WHERE nn IN     (SELECT n  FROM small);
SELECT * FROM large WHERE nn IN     (SELECT nn FROM small);
SELECT * FROM large WHERE    EXISTS (SELECT *  FROM small);
nopager

--
-- uncorrelated with NOT IN or NOT EXISTS
--

-- D1

SELECT 'D1' AS "CASE";

EXPLAIN SELECT * FROM small WHERE n  NOT IN     (SELECT n  FROM large);
EXPLAIN SELECT * FROM small WHERE n  NOT IN     (SELECT nn FROM large);
EXPLAIN SELECT * FROM small WHERE nn NOT IN     (SELECT n  FROM large);
EXPLAIN SELECT * FROM small WHERE nn NOT IN     (SELECT nn FROM large);
EXPLAIN SELECT * FROM small WHERE    NOT EXISTS (SELECT *  FROM large);

pager > /dev/null
SELECT * FROM small WHERE n  NOT IN     (SELECT n  FROM large);
SELECT * FROM small WHERE n  NOT IN     (SELECT nn FROM large);
SELECT * FROM small WHERE nn NOT IN     (SELECT n  FROM large);
SELECT * FROM small WHERE nn NOT IN     (SELECT nn FROM large);
SELECT * FROM small WHERE    NOT EXISTS (SELECT *  FROM large);
nopager

-- D2

SELECT 'D2' AS "CASE";

EXPLAIN SELECT * FROM large WHERE n  NOT IN     (SELECT n  FROM small);
EXPLAIN SELECT * FROM large WHERE n  NOT IN     (SELECT nn FROM small);
EXPLAIN SELECT * FROM large WHERE nn NOT IN     (SELECT n  FROM small);
EXPLAIN SELECT * FROM large WHERE nn NOT IN     (SELECT nn FROM small);
EXPLAIN SELECT * FROM large WHERE    NOT EXISTS (SELECT *  FROM small);

pager > /dev/null
SELECT * FROM large WHERE n  NOT IN     (SELECT n  FROM small);
SELECT * FROM large WHERE n  NOT IN     (SELECT nn FROM small);
SELECT * FROM large WHERE nn NOT IN     (SELECT n  FROM small);
SELECT * FROM large WHERE nn NOT IN     (SELECT nn FROM small);
SELECT * FROM large WHERE    NOT EXISTS (SELECT *  FROM small);
nopager

--
-- correlated with IN or EXISTS
--

-- E1

SELECT 'E1' AS "CASE";

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

pager > /dev/null
SELECT * FROM small WHERE n  IN     (SELECT n  FROM large WHERE large.u  = small.u);
SELECT * FROM small WHERE n  IN     (SELECT nn FROM large WHERE large.u  = small.u);
SELECT * FROM small WHERE nn IN     (SELECT n  FROM large WHERE large.u  = small.u);
SELECT * FROM small WHERE nn IN     (SELECT nn FROM large WHERE large.u  = small.u);
SELECT * FROM small WHERE n  IN     (SELECT n  FROM large WHERE large.nu = small.u);
SELECT * FROM small WHERE n  IN     (SELECT nn FROM large WHERE large.nu = small.u);
SELECT * FROM small WHERE nn IN     (SELECT n  FROM large WHERE large.nu = small.u);
SELECT * FROM small WHERE nn IN     (SELECT nn FROM large WHERE large.nu = small.u);
SELECT * FROM small WHERE    EXISTS (SELECT *  FROM large WHERE large.u  = small.u);
SELECT * FROM small WHERE    EXISTS (SELECT *  FROM large WHERE large.nu = small.u);
nopager

-- E2

SELECT 'E2' AS "CASE";

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

pager > /dev/null
SELECT * FROM large WHERE n  IN     (SELECT n  FROM small WHERE small.u  = large.u);
SELECT * FROM large WHERE n  IN     (SELECT nn FROM small WHERE small.u  = large.u);
SELECT * FROM large WHERE nn IN     (SELECT n  FROM small WHERE small.u  = large.u);
SELECT * FROM large WHERE nn IN     (SELECT nn FROM small WHERE small.u  = large.u);
SELECT * FROM large WHERE n  IN     (SELECT n  FROM small WHERE small.nu = large.u);
SELECT * FROM large WHERE n  IN     (SELECT nn FROM small WHERE small.nu = large.u);
SELECT * FROM large WHERE nn IN     (SELECT n  FROM small WHERE small.nu = large.u);
SELECT * FROM large WHERE nn IN     (SELECT nn FROM small WHERE small.nu = large.u);
SELECT * FROM large WHERE    EXISTS (SELECT *  FROM small WHERE small.u  = large.u);
SELECT * FROM large WHERE    EXISTS (SELECT *  FROM small WHERE small.nu = large.u);
nopager

--
-- correlated with NOT IN or NOT EXISTS
--

-- F1

SELECT 'F1' AS "CASE";

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

pager > /dev/null
SELECT * FROM small WHERE n  NOT IN     (SELECT n  FROM large WHERE large.u  = small.u);
SELECT * FROM small WHERE n  NOT IN     (SELECT nn FROM large WHERE large.u  = small.u);
SELECT * FROM small WHERE nn NOT IN     (SELECT n  FROM large WHERE large.u  = small.u);
SELECT * FROM small WHERE nn NOT IN     (SELECT nn FROM large WHERE large.u  = small.u);
SELECT * FROM small WHERE n  NOT IN     (SELECT n  FROM large WHERE large.nu = small.u);
SELECT * FROM small WHERE n  NOT IN     (SELECT nn FROM large WHERE large.nu = small.u);
SELECT * FROM small WHERE nn NOT IN     (SELECT n  FROM large WHERE large.nu = small.u);
SELECT * FROM small WHERE nn NOT IN     (SELECT nn FROM large WHERE large.nu = small.u);
SELECT * FROM small WHERE    NOT EXISTS (SELECT *  FROM large WHERE large.u  = small.u);
SELECT * FROM small WHERE    NOT EXISTS (SELECT *  FROM large WHERE large.nu = small.u);
nopager

-- F2

SELECT 'F2' AS "CASE";

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

pager > /dev/null
SELECT * FROM large WHERE n  NOT IN     (SELECT n  FROM small WHERE small.u  = large.u);
SELECT * FROM large WHERE n  NOT IN     (SELECT nn FROM small WHERE small.u  = large.u);
SELECT * FROM large WHERE nn NOT IN     (SELECT n  FROM small WHERE small.u  = large.u);
SELECT * FROM large WHERE nn NOT IN     (SELECT nn FROM small WHERE small.u  = large.u);
SELECT * FROM large WHERE n  NOT IN     (SELECT n  FROM small WHERE small.nu = large.u);
SELECT * FROM large WHERE n  NOT IN     (SELECT nn FROM small WHERE small.nu = large.u);
SELECT * FROM large WHERE nn NOT IN     (SELECT n  FROM small WHERE small.nu = large.u);
SELECT * FROM large WHERE nn NOT IN     (SELECT nn FROM small WHERE small.nu = large.u);
SELECT * FROM large WHERE    NOT EXISTS (SELECT *  FROM small WHERE small.u  = large.u);
SELECT * FROM large WHERE    NOT EXISTS (SELECT *  FROM small WHERE small.nu = large.u);
nopager
