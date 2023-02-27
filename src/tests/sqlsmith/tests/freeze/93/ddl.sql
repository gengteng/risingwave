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
CREATE MATERIALIZED VIEW m0 AS SELECT ((coalesce(NULL, NULL, NULL, NULL, NULL, (SMALLINT '8'), NULL, NULL, NULL, NULL)) # (hop_0.id + (BIGINT '-9223372036854775808'))) AS col_0 FROM hop(person, person.date_time, INTERVAL '3600', INTERVAL '36000') AS hop_0 GROUP BY hop_0.id, hop_0.credit_card;
CREATE MATERIALIZED VIEW m2 AS SELECT t_0.l_receiptdate AS col_0 FROM lineitem AS t_0 WHERE false GROUP BY t_0.l_shipinstruct, t_0.l_receiptdate, t_0.l_returnflag, t_0.l_shipmode, t_0.l_linenumber, t_0.l_comment, t_0.l_tax, t_0.l_shipdate HAVING true;
CREATE MATERIALIZED VIEW m3 AS SELECT t_0.c3 AS col_0 FROM alltypes1 AS t_0 LEFT JOIN partsupp AS t_1 ON t_0.c3 = t_1.ps_availqty AND (t_1.ps_suppkey <= (REAL '698')) GROUP BY t_0.c3;
CREATE MATERIALIZED VIEW m4 AS WITH with_0 AS (SELECT ((SMALLINT '12047') * (((SMALLINT '161') * t_1.c_custkey) & t_1.c_custkey)) AS col_0, string_agg('KHQRcHKtMU', t_1.c_comment) AS col_1, (OVERLAY((concat((TRIM(t_1.c_name)))) PLACING 'S1ybmZwCSD' FROM t_1.c_custkey FOR t_1.c_custkey)) AS col_2 FROM customer AS t_1 GROUP BY t_1.c_mktsegment, t_1.c_address, t_1.c_name, t_1.c_custkey HAVING true) SELECT (REAL '568') AS col_0, (INT '732') AS col_1, DATE '2021-12-31' AS col_2, max((INT '964')) FILTER(WHERE ((BIGINT '397') IS NOT NULL)) AS col_3 FROM with_0;
CREATE MATERIALIZED VIEW m5 AS WITH with_0 AS (SELECT TIMESTAMP '2021-12-31 03:56:07' AS col_0 FROM nation AS t_1 LEFT JOIN customer AS t_2 ON t_1.n_name = t_2.c_address GROUP BY t_2.c_comment, t_1.n_comment, t_1.n_name) SELECT (INTERVAL '86400') AS col_0, (INT '2147483647') AS col_1, TIME '03:56:07' AS col_2, DATE '2022-01-07' AS col_3 FROM with_0 WHERE (TIME '03:56:06' IS NOT NULL);
CREATE MATERIALIZED VIEW m6 AS SELECT t_1.c9 AS col_0, (t_1.c7 / (char_length((TRIM(BOTH t_1.c9 FROM (TRIM(LEADING 'V5zgMzZQPr' FROM (split_part((substr('PmZUrnaNz8', (INT '899'))), t_1.c9, (SMALLINT '-32768')))))))))) AS col_1, 'UjyN9s5NV8' AS col_2, t_1.c7 AS col_3 FROM auction AS t_0 LEFT JOIN alltypes1 AS t_1 ON t_0.initial_bid = t_1.c4 GROUP BY t_1.c9, t_1.c7 HAVING false;
CREATE MATERIALIZED VIEW m7 AS SELECT hop_0.id AS col_0, hop_0.id AS col_1, (SMALLINT '466') AS col_2, ((BIGINT '0') * ((INT '425') * ((SMALLINT '289') # (SMALLINT '451')))) AS col_3 FROM hop(person, person.date_time, INTERVAL '579018', INTERVAL '8685270') AS hop_0 GROUP BY hop_0.id, hop_0.date_time, hop_0.city;
CREATE MATERIALIZED VIEW m9 AS SELECT TIME '03:56:08' AS col_0, ARRAY[(454), (351906899), (428)] AS col_1 FROM hop(alltypes1, alltypes1.c11, INTERVAL '4889', INTERVAL '39112') AS hop_0 WHERE CAST((INT '0') AS BOOLEAN) GROUP BY hop_0.c8, hop_0.c10, hop_0.c16, hop_0.c7;
