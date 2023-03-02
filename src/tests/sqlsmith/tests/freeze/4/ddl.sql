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
CREATE MATERIALIZED VIEW m1 AS SELECT CAST(NULL AS STRUCT<a INT>) AS col_0, t_1.c14 AS col_1, (BIGINT '0') AS col_2, t_1.c2 AS col_3 FROM region AS t_0 FULL JOIN alltypes2 AS t_1 ON t_0.r_comment = t_1.c9 AND true WHERE t_1.c1 GROUP BY t_1.c9, t_1.c2, t_0.r_name, t_1.c14;
CREATE MATERIALIZED VIEW m2 AS SELECT t_0.l_orderkey AS col_0, 'Wn1Fgj6kXm' AS col_1, (1) AS col_2, (t_0.l_suppkey % t_1.l_partkey) AS col_3 FROM lineitem AS t_0 JOIN lineitem AS t_1 ON t_0.l_linestatus = t_1.l_shipmode GROUP BY t_0.l_discount, t_0.l_orderkey, t_0.l_linestatus, t_1.l_tax, t_0.l_comment, t_0.l_shipmode, t_1.l_shipinstruct, t_1.l_linestatus, t_1.l_discount, t_1.l_partkey, t_1.l_shipdate, t_0.l_shipinstruct, t_0.l_suppkey, t_1.l_receiptdate, t_0.l_shipdate HAVING true;
CREATE MATERIALIZED VIEW m4 AS WITH with_0 AS (SELECT tumble_1.extra AS col_0, tumble_1.extra AS col_1, tumble_1.extra AS col_2 FROM tumble(bid, bid.date_time, INTERVAL '81') AS tumble_1 GROUP BY tumble_1.extra) SELECT CAST(true AS INT) AS col_0 FROM with_0;
CREATE MATERIALIZED VIEW m6 AS SELECT t_1.c15 AS col_0, ((t_1.c5 - ((- (REAL '721')) * t_1.c5)) + t_1.c5) AS col_1 FROM part AS t_0 RIGHT JOIN alltypes1 AS t_1 ON t_0.p_type = t_1.c9 AND (t_1.c5 <> t_0.p_size) GROUP BY t_1.c15, t_1.c5 HAVING (CASE WHEN true THEN false WHEN (t_1.c15) IN (t_1.c15, t_1.c15, t_1.c15) THEN true WHEN false THEN true ELSE true END);
CREATE MATERIALIZED VIEW m8 AS SELECT ((FLOAT '1501015134')) AS col_0 FROM alltypes2 AS t_0 RIGHT JOIN bid AS t_1 ON t_0.c9 = t_1.url WHERE t_0.c1 GROUP BY t_0.c15, t_1.bidder, t_0.c3, t_0.c1;
CREATE MATERIALIZED VIEW m9 AS SELECT (CAST(NULL AS STRUCT<a NUMERIC, b NUMERIC, c NUMERIC>)) AS col_0, ((t_2.col_0 << (INT '81')) + ((SMALLINT '234') + (SMALLINT '110'))) AS col_1, (504) AS col_2, (SMALLINT '836') AS col_3 FROM m2 AS t_2 WHERE false GROUP BY t_2.col_0, t_2.col_2;
