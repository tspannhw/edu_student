-- Split data in pig

-- Validate visits.txt in whitehouse with hdfs or Ambari File View
-- hdfs dfs -ls whitehouse

-- Extract data
visits = LOAD '/user/centos/whitehouse/visits.txt' USING PigStorage(',');

-- Filter data
not_null_25 = FILTER visits BY ($25 IS NOT NULL);
comments = FOREACH not_null_25 GENERATE $25 AS comment;
describe comments;
comments_sample = SAMPLE comments 0.001;
DUMP comments_sample;

-- Group data
--comments_all = GROUP comments ALL;
--comments_count = FOREACH comments_all GENERATE
--COUNT(comments);
--DUMP comments_count;

-- Split data
--SPLIT visits INTO congress IF($25 MATCHES
--'.* CONGRESS .*'), not_congress IF (NOT($25 MATCHES
--'.* CONGRESS .*'));
--STORE congress INTO 'congress';
--STORE not_congress INTO 'not_congress';

--Validate with hdfs or Ambari File View
--hdfs -ls congress
--hdfs -cat congress/part-m-00000

-- Group and count data
--congress_grp = GROUP congress ALL;
--congress_count = FOREACH congress_grp GENERATE
--COUNT(congress);
--DUMP congress_count;
