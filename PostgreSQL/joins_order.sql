--
-- This script is used to test whether the query optimizer chooses sensible join orders and to show
-- how it is possible to force a specific join order.
--

--
-- Choice of join order
--

EXPLAIN ANALYZE SELECT * FROM small JOIN large ON small.u = large.u;
EXPLAIN ANALYZE SELECT * FROM large JOIN small ON small.u = large.u;
EXPLAIN ANALYZE SELECT * FROM small JOIN large ON large.u = small.u;
EXPLAIN ANALYZE SELECT * FROM large JOIN small ON large.u = small.u;

SELECT * FROM small JOIN large ON small.u = large.u;
SELECT * FROM large JOIN small ON small.u = large.u;
SELECT * FROM small JOIN large ON large.u = small.u;
SELECT * FROM large JOIN small ON large.u = small.u;

EXPLAIN ANALYZE SELECT * FROM small, large WHERE small.u = large.u;
EXPLAIN ANALYZE SELECT * FROM large, small WHERE small.u = large.u;
EXPLAIN ANALYZE SELECT * FROM small, large WHERE large.u = small.u;
EXPLAIN ANALYZE SELECT * FROM large, small WHERE large.u = small.u;

SELECT * FROM small, large WHERE small.u = large.u;
SELECT * FROM large, small WHERE small.u = large.u;
SELECT * FROM small, large WHERE large.u = small.u;
SELECT * FROM large, small WHERE large.u = small.u;

--
-- Influence join order
--

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

EXPLAIN SELECT * FROM a JOIN b ON a.b = b.b JOIN c ON b.c = c.c JOIN d ON c.d = d.d;

set join_collapse_limit TO 1;
EXPLAIN SELECT * FROM a JOIN b ON a.b = b.b JOIN c ON b.c = c.c JOIN d ON c.d = d.d;
EXPLAIN SELECT * FROM b JOIN c ON b.c = c.c JOIN d ON c.d = d.d JOIN a ON a.b = b.b;
set join_collapse_limit TO default;

DROP TABLE a;
DROP TABLE b;
DROP TABLE c;
DROP TABLE d;
