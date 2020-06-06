-- Exploring unknown data with Pig 
--
-- These commands are meant to be run in Ambari Pig View
-- But they can be run from the pig grunt shell
--
-- Configurations to be check to enable Tez in Ambari
-- 1. Ambari > Hive configs >
-- tez.lib.uris = /hdp/apps/${hdp.version}/tez/tez.tar.gz
-- 2. webhcat-site.xml
-- templeton.libjars=/usr/hdp/${hdp.version}/zookeeper/zookeeper.jar,/usr/hdp/${hdp.version}/hive/lib/hive-common.jar/,/etc/tez/conf/tez-site.xml
-- 3. Set AM Ram to 4 GB
-- yarn.scheduler.capacity.maximum-am-resource-percent=0.8
--
-- The "--" are equal to "#" in pig

A = LOAD '/user/centos/whitehouse/' USING TextLoader();
B = GROUP A ALL;
DESCRIBE B;

-- Count records
A_count = FOREACH B GENERATE 'rowcount', COUNT(A);
DUMP A_count;

-- View records
C = LIMIT A 10;
DUMP C;

-- Explore columns of value
visits = LOAD '/user/centos/whitehouse/' USING PigStorage(',');

-- Use array values for column search
firstten = FOREACH visits GENERATE $0..$9;
firstten_limit = LIMIT firstten 50;
DUMP firstten_limit;

-- Use array values for column search
lastfields = FOREACH visits GENERATE $19..$25;
lastfields_limit = LIMIT lastfields 500;
DUMP lastfields_limit;

-- Use Filter and Regular Expression
potus = FILTER visits BY $19 MATCHES 'POTUS';
potus_limit = LIMIT potus 500;
DUMP potus_limit;

-- Filter and group to count
potus = FILTER visits BY $19 MATCHES 'POTUS';
potus_group = GROUP potus ALL;
potus_count = FOREACH potus_group GENERATE COUNT(potus);
DUMP potus_count;

-- Preprocess raw data into valued data set 
potus = FILTER visits BY $19 MATCHES 'POTUS';
potus_details = FOREACH potus GENERATE
(chararray) $0 AS lname:chararray,
(chararray) $1 AS fname:chararray,
(chararray) $6 AS arrival_time:chararray,
(chararray) $19 AS visitee:chararray;
-- Order data
potus_details_ordered = ORDER potus_details BY lname ASC;
-- Load data into storage
STORE potus_details_ordered INTO 'potus' USING PigStorage(',');

-- Validate in hdfs, pig, or Ambari File View
-- hdfs dfs -ls potus
-- hdfs dfs -cat potus/part-r-00000
