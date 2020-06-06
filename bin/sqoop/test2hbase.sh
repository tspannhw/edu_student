#!/bin/bash
# WKD script to import into HBase

# Variables
# Set "e" to fail script if a line fails
# set -e

echo "Begin HBase import using Sqoop"

# First Column FirstName
if [ $? -eq 0 ]; then
sqoop import 
--connect jdbc:postgresql://db01.cloudair.lan/cloudair
--username devuser --password BadPass%1 
--table us_customers 
--columns "rownum, firstname" 
--hbase-table us_customers 
--column-family pers 
--hbase-row-key rownum 
--num-mappers 1
fi
