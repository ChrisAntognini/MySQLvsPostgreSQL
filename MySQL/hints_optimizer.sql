--
-- This script demonstrates the utilization of optimizer hints
--

-- setup

warnings

-- BKA, NO_BKA: affect batched key access join processing (Query block, table)

EXPLAIN
SELECT /*+ no_bka(s, l) */ *
FROM small s JOIN large l ON s.u = l.nu;

EXPLAIN
SELECT /*+ bka(s, l) */ *
FROM small s JOIN large l ON s.u = l.nu;

-- BNL, NO_BNL: affect block nested-loop join processing (Query block, table)

EXPLAIN
SELECT /*+ no_bnl(l) */ *
FROM small s, large l;

EXPLAIN
SELECT /*+ bnl(l) */ *
FROM small s, large l;

-- INDEX_MERGE, NO_INDEX_MERGE: Affect Index Merge optimization (Table, index)

EXPLAIN
SELECT /*+ no_index_merge(large) */ *
FROM large
WHERE nu = 42 AND n = 42 AND nn = 42;

EXPLAIN
SELECT /*+ index_merge(large) */ *
FROM large
WHERE nu = 42 AND n = 42 AND nn = 42;

EXPLAIN
SELECT /*+ index_merge(large large_nu,large_nn) */ *
FROM large
WHERE nu = 42 AND n = 42 AND nn = 42;

-- JOIN_FIXED_ORDER: use table order specified in FROM clause for join order (Query block)

EXPLAIN
SELECT *
FROM small s1, large l1, small s2, large l2
WHERE s1.u = l1.nu AND s1.n = s2.n AND s2.u = l2.nu;

EXPLAIN
SELECT /*+ join_fixed_order() */ *
FROM small s1, large l1, small s2, large l2
WHERE s1.u = l1.nu AND s1.n = s2.n AND s2.u = l2.nu;

-- JOIN_ORDER: use table order specified in hint for join order (Query block)

EXPLAIN
SELECT /*+ join_order(s1, l1, s2, l2) */ *
FROM small s1, large l1, small s2, large l2
WHERE s1.u = l1.nu AND s1.n = s2.n AND s2.u = l2.nu;

-- JOIN_PREFIX: use table order specified in hint for first tables of join order (Query block)

EXPLAIN
SELECT /*+ join_prefix(s1, l1) */ *
FROM small s1, large l1, small s2, large l2
WHERE s1.u = l1.nu AND s1.n = s2.n AND s2.u = l2.nu;

-- JOIN_SUFFIX: use table order specified in hint for last tables of join order (Query block)

EXPLAIN
SELECT /*+ join_suffix(s2, l2) */ *
FROM small s1, large l1, small s2, large l2
WHERE s1.u = l1.nu AND s1.n = s2.n AND s2.u = l2.nu;

-- MERGE, NO_MERGE: affect derived table/view merging into outer query block (Table)

EXPLAIN
SELECT /*+ merge(s) merge(l) */ *
FROM (SELECT * FROM small) s, (SELECT * FROM large) l
WHERE s.nu = l.nu;

EXPLAIN
SELECT /*+ no_merge(s) merge(l) */ *
FROM (SELECT * FROM small) s, (SELECT * FROM large) l
WHERE s.nu = l.nu;

EXPLAIN
SELECT /*+ merge(s) no_merge(l) */ *
FROM (SELECT * FROM small) s, (SELECT * FROM large) l
WHERE s.nu = l.nu;

EXPLAIN
SELECT /*+ no_merge(s) no_merge(l) */ *
FROM (SELECT * FROM small) s, (SELECT * FROM large) l
WHERE s.nu = l.nu;

-- MRR, NO_MRR: affect multi-range read optimization (Table, index)

EXPLAIN 
SELECT /*+ no_mrr(large) */ *
FROM large
WHERE nu BETWEEN 100 AND 1000;

EXPLAIN 
SELECT /*+ mrr(large) */ *
FROM large
WHERE nu BETWEEN 100 AND 1000;

-- NO_ICP: affect index condition pushdown optimization (Table, index)

EXPLAIN 
SELECT *
FROM large
WHERE nu BETWEEN 100 AND 1000;

EXPLAIN 
SELECT /*+ no_icp(large) */ *
FROM large
WHERE nu BETWEEN 100 AND 1000;

-- NO_RANGE_OPTIMIZATION: affect range optimization (Table, index)

EXPLAIN 
SELECT *
FROM large
WHERE nu BETWEEN 100 AND 1000;

EXPLAIN 
SELECT /*+ no_range_optimization(large) */ *
FROM large
WHERE nu BETWEEN 100 AND 1000;

-- QB_NAME: assign name to query block (Query block)

EXPLAIN
SELECT /*+ index_merge(large) */ *
FROM large
WHERE nu = 42 AND n = 42 AND nn = 42;

EXPLAIN
SELECT /*+ index_merge(@dummy large) */ *
FROM large
WHERE nu = 42 AND n = 42 AND nn = 42;

EXPLAIN
SELECT /*+ qb_name(dummy) index_merge(@dummy large) */ *
FROM large
WHERE nu = 42 AND n = 42 AND nn = 42;

-- SEMIJOIN, NO_SEMIJOIN: affect semi-join strategies (Query block)

EXPLAIN 
SELECT *
FROM large
WHERE nu IN (SELECT /*+ no_semijoin() */ nu FROM small s);

EXPLAIN 
SELECT *
FROM large
WHERE nu IN (SELECT /*+ semijoin(loosescan) */ nu FROM small s);

EXPLAIN 
SELECT *
FROM large
WHERE nu IN (SELECT /*+ semijoin(dupsweedout) */ nu FROM small s);

EXPLAIN 
SELECT *
FROM large
WHERE nu IN (SELECT /*+ semijoin(firstmatch) */ nu FROM small s);

EXPLAIN 
SELECT *
FROM large
WHERE nu IN (SELECT /*+ semijoin(materialization) */ nu FROM small s);

-- SUBQUERY: affect materialization, IN-to-EXISTS subquery stratgies (Query block)

EXPLAIN 
SELECT *
FROM small
WHERE nu IN (SELECT /*+ subquery(materialization) */ nu FROM large s);

EXPLAIN 
SELECT *
FROM small
WHERE nu IN (SELECT /*+ subquery(intoexists) */ nu FROM large s);
