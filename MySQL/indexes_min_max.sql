--
-- This script is used to check whether searches for min and max values are evaluated through indexes.
--

SELECT min(u) FROM large;
SELECT max(u) FROM large;
SELECT min(u), max(u) FROM large;

EXPLAIN SELECT min(u) FROM large;
EXPLAIN SELECT max(u) FROM large;
EXPLAIN SELECT min(u), max(u) FROM large;
