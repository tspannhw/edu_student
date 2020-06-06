--load the Hive table called geolocation
geo = LOAD 'geolocation' 
    USING org.apache.hive.hcatalog.pig.HCatLoader();

--get rid of non risky behavior
riskyEvents = FILTER geo BY event != 'normal';

--get rid of attributes we don't need and create a counter one
thinRiskies = FOREACH riskyEvents GENERATE 
    driverid, event, (int) '1' as occurance; 

--lump all events uniquely for each driver
driverGroupings = GROUP thinRiskies BY driverid;

-- Total up the events for each driver
countsByDriver = FOREACH driverGroupings GENERATE 
    group as driverid, SUM(thinRiskies.occurance) as total_occurrences;

--load the driver_mileage Hive table
mileage = LOAD 'driver_mileage' 
    USING org.apache.hive.hcatalog.pig.HCatLoader();

--join the calculated driver counts with previously created driver's mileage
joinResult = JOIN countsByDriver BY driverid, mileage BY driverid;

--results from "describe joinResult"
--   joinResult: {countsByDriver::driverid: chararray,
--                countsByDriver::total_occurrences: long,
--                mileage::driverid: chararray,
--                mileage::totmiles: long}

--calculate the risk factor as total miles / # of risky events
final_data = foreach joinResult generate 
    countsByDriver::driverid as driverid, 
    countsByDriver::total_occurrences as events, 
    mileage::totmiles as totmiles, 
    (float) mileage::totmiles / countsByDriver::total_occurrences as riskfactor;

--save the results into the risk_factor Hive table
STORE final_data INTO 'risk_factor' 
    USING org.apache.hive.hcatalog.pig.HCatStorer();
