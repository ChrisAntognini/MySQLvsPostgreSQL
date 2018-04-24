--
-- This script is used to create two tables, small and large, which are used to generate test data 
-- by the other scripts.
--

CREATE EXTENSION pgcrypto;

DROP TABLE small;

CREATE TABLE small (u INTEGER NOT NULL, nu INTEGER NOT NULL, n INTEGER NULL, nn INTEGER NOT NULL, p VARCHAR(128) NULL);

INSERT INTO small VALUES (2, 2, 2, 2, substring(cast(gen_random_bytes(64) as text) from 3));
INSERT INTO small VALUES (6, 6, 6, 6, substring(cast(gen_random_bytes(64) as text) from 3));
INSERT INTO small VALUES (1, 1, 1, 1, substring(cast(gen_random_bytes(64) as text) from 3));
INSERT INTO small VALUES (3, 3, 3, 3, substring(cast(gen_random_bytes(64) as text) from 3));
INSERT INTO small VALUES (10, 10, 10, 10, substring(cast(gen_random_bytes(64) as text) from 3));
INSERT INTO small VALUES (5, 5, 5, 5, substring(cast(gen_random_bytes(64) as text) from 3));
INSERT INTO small VALUES (7, 7, NULL, 7, substring(cast(gen_random_bytes(64) as text) from 3));
INSERT INTO small VALUES (4, 4, 4, 4, substring(cast(gen_random_bytes(64) as text) from 3));
INSERT INTO small VALUES (9, 9, 9, 9, substring(cast(gen_random_bytes(64) as text) from 3));
INSERT INTO small VALUES (8, 8, 8, 8, substring(cast(gen_random_bytes(64) as text) from 3));

CREATE UNIQUE INDEX small_u ON small (u);
CREATE INDEX small_nu ON small (nu);
CREATE INDEX small_n ON small (n);
CREATE INDEX small_nn ON small (nn);

ANALYZE small;

DROP TABLE large;

CREATE TABLE large (u INTEGER NOT NULL, nu INTEGER NOT NULL, n INTEGER NULL, nn INTEGER NOT NULL, p VARCHAR(128) NULL);

INSERT INTO large
SELECT u, u, u, u, substring(cast(gen_random_bytes(64) as text) from 3)
FROM (SELECT (s1.u-1)*100000 + (s2.u-1)*10000 + (s3.u-1)*1000 + (s4.u-1)*100 + (s5.u-1)*10 + s6.u u
      FROM (SELECT u FROM small ORDER BY random()) s1,
           (SELECT u FROM small ORDER BY random()) s2,
           (SELECT u FROM small ORDER BY random()) s3,
           (SELECT u FROM small ORDER BY random()) s4,
           (SELECT u FROM small ORDER BY random()) s5,
           (SELECT u FROM small ORDER BY random()) s6) t;

UPDATE large set n = NULL WHERE n = 7;

CREATE UNIQUE INDEX large_u ON large (u);
CREATE INDEX large_nu ON large (nu);
CREATE INDEX large_n ON large (n);
CREATE INDEX large_nn ON large (nn);

ANALYZE large;
