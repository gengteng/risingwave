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
CREATE MATERIALIZED VIEW m0 AS SELECT hop_0.id AS col_0, hop_0.initial_bid AS col_1, (534) AS col_2, (BIGINT '9223372036854775807') AS col_3 FROM hop(auction, auction.date_time, INTERVAL '86400', INTERVAL '8380800') AS hop_0 WHERE false GROUP BY hop_0.initial_bid, hop_0.id, hop_0.date_time HAVING ((916) <> (REAL '358'));
CREATE MATERIALIZED VIEW m1 AS SELECT sq_3.col_0 AS col_0, 'URLM1KMzj8' AS col_1, (101) AS col_2 FROM (WITH with_0 AS (SELECT t_2.c16 AS col_0, t_2.c13 AS col_1 FROM region AS t_1 LEFT JOIN alltypes1 AS t_2 ON t_1.r_name = t_2.c9 GROUP BY t_2.c10, t_2.c14, t_2.c13, t_1.r_name, t_2.c16, t_2.c3) SELECT (243) AS col_0 FROM with_0 WHERE false) AS sq_3 GROUP BY sq_3.col_0;
CREATE MATERIALIZED VIEW m2 AS SELECT tumble_0.date_time AS col_0, TIMESTAMP '2022-09-30 18:49:12' AS col_1, ((INTERVAL '0') + DATE '2022-09-30') AS col_2 FROM tumble(person, person.date_time, INTERVAL '58') AS tumble_0 WHERE true GROUP BY tumble_0.date_time HAVING false;
CREATE MATERIALIZED VIEW m3 AS SELECT t_0.l_discount AS col_0, (DATE '2022-09-30' + (INT '96')) AS col_1 FROM lineitem AS t_0 JOIN nation AS t_1 ON t_0.l_shipmode = t_1.n_comment AND ((SMALLINT '-12288') >= (t_0.l_orderkey & (BIGINT '607'))) GROUP BY t_0.l_linestatus, t_0.l_shipdate, t_0.l_quantity, t_0.l_discount;
CREATE MATERIALIZED VIEW m4 AS SELECT t_0.s_acctbal AS col_0, 'VGVsvjyKQ8' AS col_1, t_1.id AS col_2 FROM supplier AS t_0 LEFT JOIN auction AS t_1 ON t_0.s_comment = t_1.extra WHERE true GROUP BY t_1.id, t_1.extra, t_0.s_acctbal, t_1.date_time, t_1.description HAVING true;
CREATE MATERIALIZED VIEW m5 AS SELECT hop_0.date_time AS col_0, TIME '18:48:14' AS col_1, hop_0.price AS col_2, (coalesce(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, hop_0.date_time)) AS col_3 FROM hop(bid, bid.date_time, INTERVAL '604800', INTERVAL '19353600') AS hop_0 GROUP BY hop_0.url, hop_0.price, hop_0.channel, hop_0.date_time HAVING true;
CREATE MATERIALIZED VIEW m6 AS SELECT (((INTERVAL '86400') / (INT '989')) + DATE '2022-09-30') AS col_0 FROM hop(m2, m2.col_1, INTERVAL '1', INTERVAL '85') AS hop_0 GROUP BY hop_0.col_2;
CREATE MATERIALIZED VIEW m7 AS SELECT t_1.auction AS col_0, ((SMALLINT '771') & (INT '-462470405')) AS col_1 FROM m1 AS t_0 FULL JOIN bid AS t_1 ON t_0.col_1 = t_1.extra GROUP BY t_1.auction, t_1.bidder;
CREATE MATERIALIZED VIEW m8 AS WITH with_0 AS (WITH with_1 AS (SELECT t_4.p_retailprice AS col_0 FROM part AS t_4 GROUP BY t_4.p_container, t_4.p_mfgr, t_4.p_name, t_4.p_retailprice, t_4.p_brand HAVING CAST((INT '807') AS BOOLEAN)) SELECT CAST((INT '695') AS BOOLEAN) AS col_0 FROM with_1) SELECT true AS col_0, (BIGINT '-7909276190606120581') AS col_1 FROM with_0;
CREATE MATERIALIZED VIEW m9 AS SELECT (concat(string_agg(t_0.name, (CASE WHEN false THEN ('n4K4zpionh') ELSE t_0.email_address END)) FILTER(WHERE CAST((INT '-2147483648') AS BOOLEAN)))) AS col_0, (coalesce(NULL, NULL, NULL, NULL, NULL, NULL, NULL, (BIGINT '6913562594829313443'), NULL, NULL)) AS col_1 FROM person AS t_0 FULL JOIN auction AS t_1 ON t_0.state = t_1.extra AND true GROUP BY t_0.id, t_1.initial_bid, t_0.credit_card, t_0.email_address, t_0.extra, t_1.date_time;
