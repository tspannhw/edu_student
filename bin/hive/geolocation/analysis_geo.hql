-- Run Analysis
CREATE TABLE risk_factor (driverid string, events bigint, totmiles bigint, riskfactor float) STORED AS ORC;

-- RUN Pig script Geo Analysis

SELECT truckid, avg(mpg) avgmpg FROM truck_mileage GROUP BY truckid;

SELECT driverid, events, totmiles, riskfactor FROM risk_factor ORDER BY driverid;
