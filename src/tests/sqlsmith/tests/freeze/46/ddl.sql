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
CREATE MATERIALIZED VIEW m0 AS SELECT (FLOAT '561') AS col_0 FROM supplier AS t_0 LEFT JOIN alltypes1 AS t_1 ON t_0.s_nationkey = t_1.c3 AND t_1.c1 WHERE ((t_1.c8 <= t_1.c11) IS NOT TRUE) GROUP BY t_1.c13, t_1.c7, t_0.s_address, t_0.s_comment, t_1.c9, t_1.c1, t_1.c2;
CREATE MATERIALIZED VIEW m1 AS SELECT t_0.n_name AS col_0 FROM nation AS t_0 RIGHT JOIN region AS t_1 ON t_0.n_comment = t_1.r_name GROUP BY t_0.n_comment, t_0.n_name HAVING true;
CREATE MATERIALIZED VIEW m2 AS SELECT sq_1.col_0 AS col_0, sq_1.col_0 AS col_1, sq_1.col_0 AS col_2, (~ (SMALLINT '1')) AS col_3 FROM (SELECT t_0.s_acctbal AS col_0 FROM supplier AS t_0 GROUP BY t_0.s_acctbal HAVING false) AS sq_1 WHERE false GROUP BY sq_1.col_0;
CREATE MATERIALIZED VIEW m3 AS WITH with_0 AS (WITH with_1 AS (WITH with_2 AS (SELECT CAST(NULL AS STRUCT<a INT>) AS col_0, CAST(NULL AS STRUCT<a INT>) AS col_1, DATE '2022-01-31' AS col_2 FROM (SELECT false AS col_0, CAST(NULL AS STRUCT<a INT>) AS col_1 FROM alltypes2 AS t_3 RIGHT JOIN part AS t_4 ON t_3.c9 = t_4.p_name WHERE (t_3.c10 <> (coalesce(NULL, NULL, NULL, NULL, TIME '11:41:58', NULL, NULL, NULL, NULL, NULL))) GROUP BY t_3.c14, t_4.p_name, t_4.p_mfgr, t_3.c1) AS sq_5 WHERE (false) GROUP BY sq_5.col_1) SELECT TIMESTAMP '2022-01-30 12:41:58' AS col_0, (2147483647) AS col_1, (BIGINT '932') AS col_2, ARRAY[(FLOAT '925'), (FLOAT '699'), (FLOAT '337')] AS col_3 FROM with_2) SELECT (REAL '605') AS col_0, ((-2147483648)) AS col_1 FROM with_1 WHERE true) SELECT (BIGINT '530') AS col_0 FROM with_0 WHERE (false);
CREATE MATERIALIZED VIEW m5 AS SELECT hop_0.extra AS col_0, (hop_0.id & (((INT '1')) % (CASE WHEN true THEN (SMALLINT '20') WHEN false THEN ((SMALLINT '220') - (SMALLINT '431')) WHEN true THEN (SMALLINT '327') ELSE (SMALLINT '964') END))) AS col_1 FROM hop(person, person.date_time, INTERVAL '3600', INTERVAL '237600') AS hop_0 WHERE false GROUP BY hop_0.id, hop_0.date_time, hop_0.email_address, hop_0.extra;
CREATE MATERIALIZED VIEW m6 AS WITH with_0 AS (SELECT sq_3.col_1 AS col_0 FROM (SELECT (REAL '545') AS col_0, (((SMALLINT '1') & (SMALLINT '84')) * t_2.col_1) AS col_1 FROM m5 AS t_1 RIGHT JOIN m5 AS t_2 ON t_1.col_0 = t_2.col_0 GROUP BY t_2.col_1, t_1.col_0) AS sq_3 GROUP BY sq_3.col_1) SELECT TIME '03:42:23' AS col_0 FROM with_0 WHERE true;
CREATE MATERIALIZED VIEW m7 AS SELECT tumble_0.channel AS col_0, tumble_0.bidder AS col_1 FROM tumble(bid, bid.date_time, INTERVAL '22') AS tumble_0 GROUP BY tumble_0.channel, tumble_0.bidder HAVING true;
CREATE MATERIALIZED VIEW m8 AS SELECT t_0.c_nationkey AS col_0 FROM customer AS t_0 FULL JOIN bid AS t_1 ON t_0.c_address = t_1.channel AND ((((REAL '-659968212') * (coalesce(NULL, (REAL '602'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))) / (REAL '-2147483648')) <> ((INT '855'))) WHERE ((FLOAT '2147483647') < (((((SMALLINT '32767') >> t_0.c_custkey) + t_0.c_custkey) | (BIGINT '-9223372036854775808')) / (SMALLINT '823'))) GROUP BY t_1.url, t_0.c_acctbal, t_1.auction, t_0.c_comment, t_1.date_time, t_1.extra, t_1.channel, t_0.c_nationkey;
CREATE MATERIALIZED VIEW m9 AS SELECT (INT '38') AS col_0, t_1.o_orderstatus AS col_1 FROM m2 AS t_0 LEFT JOIN orders AS t_1 ON t_0.col_1 = t_1.o_totalprice WHERE true GROUP BY t_1.o_orderstatus;
