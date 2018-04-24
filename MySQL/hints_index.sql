--
-- This script demonstrates the utilization of index hints
--

warnings

-- show default plans

EXPLAIN SELECT * FROM large WHERE nu < 9999999;

EXPLAIN SELECT * FROM large WHERE u < 42 AND nu < 42;

-- USE INDEX

EXPLAIN SELECT * FROM large USE INDEX (large_nu) WHERE nu < 9999999;

EXPLAIN SELECT * FROM large USE INDEX () WHERE nu < 9999999;
EXPLAIN SELECT * FROM large USE INDEX FOR JOIN () WHERE nu < 9999999;
EXPLAIN SELECT * FROM large USE INDEX FOR ORDER BY () WHERE nu < 9999999;
EXPLAIN SELECT * FROM large USE INDEX FOR GROUP BY () WHERE nu < 9999999;

-- FORCE INDEX

EXPLAIN SELECT * FROM large FORCE INDEX (large_nu) WHERE nu < 9999999;

-- IGNORE INDEX

EXPLAIN SELECT * FROM large IGNORE INDEX (large_u) WHERE u < 42 AND nu < 42;
EXPLAIN SELECT * FROM large IGNORE INDEX FOR JOIN (large_u) WHERE u < 42 AND nu < 42;
EXPLAIN SELECT * FROM large IGNORE INDEX FOR ORDER BY (large_u) WHERE u < 42 AND nu < 42;
EXPLAIN SELECT * FROM large IGNORE INDEX FOR GROUP BY (large_u) WHERE u < 42 AND nu < 42;

EXPLAIN SELECT * FROM large IGNORE INDEX (large_u, large_nu) WHERE u < 42 AND nu < 42;
EXPLAIN SELECT * FROM large IGNORE INDEX FOR JOIN (large_u, large_nu) WHERE u < 42 AND nu < 42;
EXPLAIN SELECT * FROM large IGNORE INDEX FOR ORDER BY (large_u, large_nu) WHERE u < 42 AND nu < 42;
EXPLAIN SELECT * FROM large IGNORE INDEX FOR GROUP BY (large_u, large_nu) WHERE u < 42 AND nu < 42;

-- an error is raised when the index is missing

EXPLAIN SELECT * FROM large USE INDEX (large_dummy) WHERE nu < 9999999;
EXPLAIN SELECT * FROM large FORCE INDEX (large_dummy) WHERE nu < 9999999;
EXPLAIN SELECT * FROM large IGNORE INDEX (large_dummy) WHERE u < 42 AND nu < 42;
