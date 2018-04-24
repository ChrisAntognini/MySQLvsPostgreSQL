--
-- This script is used to check whether searches for min and max values are evaluated through indexes.
--

EXPLAIN ANALYZE SELECT min(u) FROM large;
EXPLAIN ANALYZE SELECT max(u) FROM large;
EXPLAIN ANALYZE SELECT min(u), max(u) FROM large;
