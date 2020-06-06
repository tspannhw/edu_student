-- FirstScript.pig
-- Load, Dump, and Store

-- Remove previous output to allow for overwrite
rmf petstore/out;

sales = LOAD 'petstore/sales/sales.csv' using PigStorage(',') as (custid:int, customer:chararray, state:chararray, zip:chararray, industry:chararray, repid:int, sales:int);
--dump sales;

-- Group by state and display
stateGroup = GROUP sales BY state;
--DUMP stateGroup;

-- Filter and count group
stateSales = FOREACH stateGroup GENERATE group, SUM(sales.sales);
--DUMP stateSales;

--Store output
STORE stateSales into 'petstore/out' using PigStorage(',');
