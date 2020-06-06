
### create database
### use database
use movies; 

## Drop table movie_crew_info
drop table IF EXISTS movie_crew_info;
### Contains the information for names
CREATE EXTERNAL TABLE movie_crew_info( 
                        nconst string,
                        primaryName string,
                        birthYear string,
                        deathYear string,
                        primaryProfession ARRAY<STRING>,
                        knownForTitles ARRAY<STRING>
                        ) ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t' LOCATION '/user/zeppelin/movie_crew_info/';

## Load data movie_crew_info
LOAD DATA  INPATH '/labs/data/name.basics.tsv' OVERWRITE INTO TABLE movie_crew_info;

## Remove header for movie_crew_info
ALTER TABLE movie_crew_info SET TBLPROPERTIES ("skip.header.line.count"="1");



