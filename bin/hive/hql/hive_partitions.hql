
### create database
create database movies;
### use database
use movies; 

## Drop table movei_tittle
drop table IF EXISTS movie_title;
### Contains the following information for titles
CREATE EXTERNAL TABLE movie_title ( 
                        tconst string,
                        titleType string,
                        primaryTitle string,
                        originalTitle string,
                        isAdult string,
                        startYear string,
                        endYear string,
                        runtimeMinutes string,
                        genres ARRAY<STRING>
                        ) ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t' LOCATION '/user/zeppelin/movie_title/';

## Load data
LOAD DATA  INPATH '/labs/data/title.basics.tsv' OVERWRITE INTO TABLE movie_title;

## Remove header for movie_title
ALTER TABLE movie_title SET TBLPROPERTIES ("skip.header.line.count"="1");


## Drop table movie_crew
drop table IF EXISTS movie_crew;
### Contains the information for directors and writers
CREATE EXTERNAL TABLE movie_crew( 
                        tconst string,
                        directors ARRAY<STRING>,
                        writers ARRAY<STRING>
                        ) ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t' LOCATION '/user/zeppelin/movie_crew/';

## Load data movie_crew
LOAD DATA  INPATH '/labs/data/title.crew.tsv' OVERWRITE INTO TABLE movie_crew;

## Remove header for movie_crew
ALTER TABLE movie_crew SET TBLPROPERTIES ("skip.header.line.count"="1");


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


## Drop table ratings
drop table IF EXISTS ratings;
### Ratings and vote information for titles
CREATE EXTERNAL TABLE ratings( 
                        tconst string,
                        averageRting double,
                        numVotes int
                        ) ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t' LOCATION '/user/zeppelin/ratings/';


## Load data ratings
LOAD DATA  INPATH '/labs/data/title.ratings.tsv' OVERWRITE INTO TABLE ratings;

## Remove header for ratings
ALTER TABLE ratings SET TBLPROPERTIES ("skip.header.line.count"="1");

