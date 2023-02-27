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
CREATE MATERIALIZED VIEW m0 AS SELECT (TIMESTAMP '2022-02-09 05:36:50') AS col_0 FROM hop(bid, bid.date_time, INTERVAL '66181', INTERVAL '4169403') AS hop_0 GROUP BY hop_0.channel, hop_0.auction, hop_0.date_time HAVING false;
CREATE MATERIALIZED VIEW m1 AS SELECT (INTERVAL '-1') AS col_0, CAST(NULL AS STRUCT<a INT>) AS col_1, t_0.c5 AS col_2 FROM alltypes1 AS t_0 GROUP BY t_0.c14, t_0.c5;
CREATE MATERIALIZED VIEW m2 AS SELECT ('QQJmNYQNay') AS col_0 FROM nation AS t_0 WHERE ((DATE '2022-02-09' - (INT '188')) = DATE '2022-02-09') GROUP BY t_0.n_name;
CREATE MATERIALIZED VIEW m3 AS SELECT t_0.c3 AS col_0 FROM alltypes2 AS t_0 WHERE true GROUP BY t_0.c8, t_0.c6, t_0.c16, t_0.c3 HAVING CAST((INT '-2147483648') AS BOOLEAN);
CREATE MATERIALIZED VIEW m4 AS SELECT TIME '05:36:50' AS col_0, (ARRAY[TIMESTAMP '2022-02-09 05:36:51']) AS col_1 FROM m0 AS t_2 GROUP BY t_2.col_0 HAVING ((BIGINT '518') = (INT '958'));
CREATE MATERIALIZED VIEW m5 AS SELECT t_2.c_address AS col_0, (INT '459') AS col_1, t_2.c_address AS col_2 FROM customer AS t_2 GROUP BY t_2.c_custkey, t_2.c_acctbal, t_2.c_address;
CREATE MATERIALIZED VIEW m6 AS SELECT false AS col_0, max((t_0.col_0 % ((INT '-970451184')))) AS col_1, (INT '821') AS col_2, t_0.col_0 AS col_3 FROM m3 AS t_0 WHERE (TIME '05:36:51' > (INTERVAL '0')) GROUP BY t_0.col_0;
CREATE MATERIALIZED VIEW m7 AS SELECT ((REAL '0')) AS col_0, 'E3jqvJs8Y2' AS col_1, t_0.o_orderstatus AS col_2, t_0.o_orderkey AS col_3 FROM orders AS t_0 GROUP BY t_0.o_comment, t_0.o_orderpriority, t_0.o_custkey, t_0.o_orderstatus, t_0.o_orderkey HAVING ((REAL '659') > t_0.o_orderkey);
CREATE MATERIALIZED VIEW m8 AS SELECT (replace(t_0.name, t_0.name, 'Y4Uu6nPG3b')) AS col_0, t_0.credit_card AS col_1 FROM person AS t_0 GROUP BY t_0.credit_card, t_0.name, t_0.state, t_0.email_address;
CREATE MATERIALIZED VIEW m9 AS SELECT hop_0.c6 AS col_0, (((FLOAT '723')) - hop_0.c5) AS col_1, hop_0.c11 AS col_2 FROM hop(alltypes1, alltypes1.c11, INTERVAL '86400', INTERVAL '4060800') AS hop_0 WHERE (hop_0.c7 = hop_0.c4) GROUP BY hop_0.c1, hop_0.c5, hop_0.c9, hop_0.c7, hop_0.c11, hop_0.c3, hop_0.c10, hop_0.c6 HAVING ((SMALLINT '386') >= (hop_0.c3 - min((SMALLINT '412')) FILTER(WHERE ((SMALLINT '1') IS NULL))));
