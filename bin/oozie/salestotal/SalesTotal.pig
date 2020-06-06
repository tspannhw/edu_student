-- SalesTotalByState.pig
-- Group

-- Remove previous output to allow for overwrite
rmf sales/out/salestotalbystate;

sales = LOAD '$INPUT' using PigStorage(',') as (custid:int, customer:chararray, state:chararray, zip:chararray, industry:chararray, repid:int, sales:int);
--dump sales;

-- Group by state and display
stateGroup = GROUP sales BY state;
--DUMP stateGroup;

-- Filter and count group
stateSales = FOREACH stateGroup GENERATE group, SUM(sales.sales);
DUMP stateSales;

--Store output
STORE stateSales into '$OUTOUT' using PigStorage(',');
