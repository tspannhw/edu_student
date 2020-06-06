--join.pig: joins Congress.txt and visits.txt

visitors = LOAD '/user/centos/whitehouse/visits.txt' USING PigStorage(',') AS 
(lname:chararray,
fname:chararray);

congress = LOAD '/user/centos/congress/' AS 
(full_title:chararray,
district:chararray,
title:chararray,
fname:chararray,
lname:chararray,
party:chararray);

--congress_limit = LIMIT congress 10;
--DUMP congress_limit;

congress_data = FOREACH congress GENERATE district,
UPPER(lname) AS lname,
UPPER(fname) AS fname, 
party;

join_contact_congress = JOIN visitors BY (lname,fname), 
congress_data BY (lname,fname) USING 'replicated';

--STORE join_contact_congress INTO 'joinresult';
join_group = GROUP join_contact_congress BY congress_data::party;
counters = FOREACH join_group GENERATE group, COUNT(join_contact_congress);
--DUMP counters;

-- Understanding Job results
--EXPLAIN counters;
