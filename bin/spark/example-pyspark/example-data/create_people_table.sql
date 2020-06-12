/* impala-shell -f ...this-file */

DROP TABLE IF EXISTS people;
CREATE TABLE people (pcode STRING, first_name STRING, last_name STRING, age INT) STORED AS PARQUET;
INSERT INTO  people VALUES ('02134','Hopper','Grace',52);
INSERT INTO  people VALUES ('94020','Turing','Alan',32);
INSERT INTO  people VALUES ('94020','Lovelace','Ada',28);
INSERT INTO  people VALUES ('87501','Babbage','Charles',49);
INSERT INTO  people VALUES ('02134','Wirth','Niklaus',48);