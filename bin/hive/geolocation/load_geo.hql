-- Load the Geo Database
-- sudo su - hdfs
-- cd /home/dsmith/data/hcd123/geolocation
-- ls
-- hdfs dfs -ls /data
-- hdfs dfs -mkdir -p /data/geolocation
-- hdfs dfs -put *csv /data/geolocation
-- hdfs dfs -chown -R hive /data/geolocation
-- hdfs dfs -ls /data/geolocation

USE geo;

LOAD DATA INPATH '/data/geolocation/geolocation.csv' OVERWRITE INTO TABLE geolocation_stage;

LOAD DATA INPATH '/data/geolocation/trucks.csv' OVERWRITE INTO TABLE trucks_stage;

SELECT * FROM geolocation_stage LIMIT 10;

SELECT * FROM trucks_stage LIMIT 10;

-- Use AMBARI File View to list /data/geolocation and /warehouse/tablespace/managed
