drop table states;

create external table states(abb string, full_name string)
row format delimited
fields terminated by '\t'
location '/states';
