CREATE TABLE supplier (s_suppkey INT, s_name CHARACTER VARYING, s_address CHARACTER VARYING, s_nationkey INT, s_phone CHARACTER VARYING, s_acctbal NUMERIC, s_comment CHARACTER VARYING, PRIMARY KEY (s_suppkey));
CREATE TABLE part (p_partkey INT, p_name CHARACTER VARYING, p_mfgr CHARACTER VARYING, p_brand CHARACTER VARYING, p_type CHARACTER VARYING, p_size INT, p_container CHARACTER VARYING, p_retailprice NUMERIC, p_comment CHARACTER VARYING, PRIMARY KEY (p_partkey));
CREATE TABLE partsupp (ps_partkey INT, ps_suppkey INT, ps_availqty INT, ps_supplycost NUMERIC, ps_comment CHARACTER VARYING, PRIMARY KEY (ps_partkey, ps_suppkey));
CREATE TABLE customer (c_custkey INT, c_name CHARACTER VARYING, c_address CHARACTER VARYING, c_nationkey INT, c_phone CHARACTER VARYING, c_acctbal NUMERIC, c_mktsegment CHARACTER VARYING, c_comment CHARACTER VARYING, PRIMARY KEY (c_custkey));
CREATE TABLE orders (o_orderkey BIGINT, o_custkey INT, o_orderstatus CHARACTER VARYING, o_totalprice NUMERIC, o_orderdate DATE, o_orderpriority CHARACTER VARYING, o_clerk CHARACTER VARYING, o_shippriority INT, o_comment CHARACTER VARYING, PRIMARY KEY (o_orderkey));
CREATE TABLE lineitem (l_orderkey BIGINT, l_partkey INT, l_suppkey INT, l_linenumber INT, l_quantity NUMERIC, l_extendedprice NUMERIC, l_discount NUMERIC, l_tax NUMERIC, l_returnflag CHARACTER VARYING, l_linestatus CHARACTER VARYING, l_shipdate DATE, l_commitdate DATE, l_receiptdate DATE, l_shipinstruct CHARACTER VARYING, l_shipmode CHARACTER VARYING, l_comment CHARACTER VARYING, PRIMARY KEY (l_orderkey, l_linenumber));
CREATE TABLE nation (n_nationkey INT, n_name CHARACTER VARYING, n_regionkey INT, n_comment CHARACTER VARYING, PRIMARY KEY (n_nationkey));
CREATE TABLE region (r_regionkey INT, r_name CHARACTER VARYING, r_comment CHARACTER VARYING, PRIMARY KEY (r_regionkey));
CREATE TABLE person (id BIGINT, name CHARACTER VARYING, email_address CHARACTER VARYING, credit_card CHARACTER VARYING, city CHARACTER VARYING, state CHARACTER VARYING, date_time TIMESTAMP, extra CHARACTER VARYING, PRIMARY KEY (id));
CREATE TABLE auction (id BIGINT, item_name CHARACTER VARYING, description CHARACTER VARYING, initial_bid BIGINT, reserve BIGINT, date_time TIMESTAMP, expires TIMESTAMP, seller BIGINT, category BIGINT, extra CHARACTER VARYING, PRIMARY KEY (id));
CREATE TABLE bid (auction BIGINT, bidder BIGINT, price BIGINT, channel CHARACTER VARYING, url CHARACTER VARYING, date_time TIMESTAMP, extra CHARACTER VARYING);
CREATE TABLE alltypes1 (c1 BOOLEAN, c2 SMALLINT, c3 INT, c4 BIGINT, c5 REAL, c6 DOUBLE, c7 NUMERIC, c8 DATE, c9 CHARACTER VARYING, c10 TIME, c11 TIMESTAMP, c13 INTERVAL, c14 STRUCT<a INT>, c15 INT[], c16 CHARACTER VARYING[]);
CREATE TABLE alltypes2 (c1 BOOLEAN, c2 SMALLINT, c3 INT, c4 BIGINT, c5 REAL, c6 DOUBLE, c7 NUMERIC, c8 DATE, c9 CHARACTER VARYING, c10 TIME, c11 TIMESTAMP, c13 INTERVAL, c14 STRUCT<a INT>, c15 INT[], c16 CHARACTER VARYING[]);
CREATE MATERIALIZED VIEW m0 AS SELECT ((coalesce(NULL, NULL, NULL, NULL, NULL, (SMALLINT '8'), NULL, NULL, NULL, NULL)) & (hop_0.id + (INT '-2147483648'))) AS col_0 FROM hop(person, person.date_time, INTERVAL '3600', INTERVAL '36000') AS hop_0 GROUP BY hop_0.id, hop_0.credit_card;
CREATE MATERIALIZED VIEW m1 AS SELECT sq_2.col_0 AS col_0 FROM (SELECT t_1.s_comment AS col_0 FROM nation AS t_0 FULL JOIN supplier AS t_1 ON t_0.n_comment = t_1.s_phone AND (((((BIGINT '-6649787959257614867') + t_1.s_acctbal) % t_0.n_nationkey) + (SMALLINT '523')) <= (REAL '965808191')) WHERE true GROUP BY t_1.s_comment HAVING false) AS sq_2 WHERE true GROUP BY sq_2.col_0;
CREATE MATERIALIZED VIEW m2 AS SELECT tumble_0.name AS col_0 FROM tumble(person, person.date_time, INTERVAL '61') AS tumble_0 GROUP BY tumble_0.name, tumble_0.city HAVING false;
CREATE MATERIALIZED VIEW m3 AS SELECT (((REAL '13') / (REAL '746838385')) + (REAL '892')) AS col_0 FROM (WITH with_0 AS (SELECT hop_1.url AS col_0, hop_1.url AS col_1 FROM hop(bid, bid.date_time, INTERVAL '1', INTERVAL '80') AS hop_1 GROUP BY hop_1.url, hop_1.bidder, hop_1.extra) SELECT (REAL '461') AS col_0, (TRIM(TRAILING 'Tn2ZocraA3' FROM 'jdrmM6EePC')) AS col_1, DATE '2022-01-07' AS col_2 FROM with_0) AS sq_2 GROUP BY sq_2.col_2, sq_2.col_1 HAVING true;
CREATE MATERIALIZED VIEW m4 AS SELECT t_2.c5 AS col_0, ARRAY[(INTERVAL '0'), (INTERVAL '-86400'), (INTERVAL '-86400')] AS col_1, (t_2.c10 - (INTERVAL '-86400')) AS col_2 FROM alltypes2 AS t_2 GROUP BY t_2.c10, t_2.c14, t_2.c5 HAVING false;
CREATE MATERIALIZED VIEW m5 AS SELECT 'Tuuslwe6U2' AS col_0 FROM m2 AS t_2 GROUP BY t_2.col_0 HAVING (false IS NOT TRUE);
CREATE MATERIALIZED VIEW m6 AS SELECT t_2.c_phone AS col_0 FROM customer AS t_2 WHERE (TIME '03:55:08' = TIME '03:56:08') GROUP BY t_2.c_phone, t_2.c_custkey, t_2.c_comment HAVING true;
CREATE MATERIALIZED VIEW m7 AS SELECT (substr(t_0.description, (INT '921'))) AS col_0, t_0.description AS col_1, 'Pkf6qXI5rN' AS col_2 FROM auction AS t_0 WHERE false GROUP BY t_0.description, t_0.item_name HAVING true;
CREATE MATERIALIZED VIEW m8 AS SELECT 'eRnQPtQbZf' AS col_0, t_2.col_2 AS col_1, (463) AS col_2, (BIGINT '9223372036854775807') AS col_3 FROM m7 AS t_2 GROUP BY t_2.col_2 HAVING true;
CREATE MATERIALIZED VIEW m9 AS SELECT hop_0.url AS col_0, hop_0.extra AS col_1 FROM hop(bid, bid.date_time, INTERVAL '60', INTERVAL '5460') AS hop_0 WHERE ((- ((REAL '0') / ((REAL '942') + (REAL '899')))) < (FLOAT '725450848')) GROUP BY hop_0.channel, hop_0.extra, hop_0.url, hop_0.auction HAVING (true);
