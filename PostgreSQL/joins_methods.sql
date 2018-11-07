--
-- This script is used to generate an execution plan for each available join method.
--

-- setup

DROP TABLE IF EXISTS a;
DROP TABLE IF EXISTS b;
DROP TABLE IF EXISTS c;
DROP TABLE IF EXISTS d;

CREATE TABLE a AS SELECT u AS a, u AS b, u AS c, u AS d FROM large WHERE u <= 10000;
CREATE TABLE b AS SELECT u AS a, u AS b, u AS c, u AS d FROM large WHERE u <= 1000;
CREATE TABLE c AS SELECT u AS a, u AS b, u AS c, u AS d FROM large WHERE u <= 100;
CREATE TABLE d AS SELECT u AS a, u AS b, u AS c, u AS d FROM large WHERE u <= 10;

ANALYZE a;
ANALYZE b;
ANALYZE c;
ANALYZE d;

-- hash join

set enable_hashjoin to true;
set enable_mergejoin to false;
set enable_nestloop to false;

EXPLAIN SELECT * FROM a JOIN b ON a.b = b.b JOIN c ON b.c = c.c JOIN d ON c.d = d.d;

-- merge join

set enable_hashjoin to false;
set enable_mergejoin to true;
set enable_nestloop to false;

EXPLAIN SELECT * FROM a JOIN b ON a.b = b.b JOIN c ON b.c = c.c JOIN d ON c.d = d.d;

-- nested loop join

set enable_hashjoin to false;
set enable_mergejoin to false;
set enable_nestloop to true;

EXPLAIN SELECT * FROM a JOIN b ON a.b = b.b JOIN c ON b.c = c.c JOIN d ON c.d = d.d;

-- cleanup

set enable_hashjoin to default;
set enable_mergejoin to default;
set enable_nestloop to default;

DROP TABLE a;
DROP TABLE b;
DROP TABLE c;
DROP TABLE d;
