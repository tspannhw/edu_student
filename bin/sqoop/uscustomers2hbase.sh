#!/bin/bash
# WKD script to import into HBase

# Variables
# Set "e" to fail script if a line fails
# set -e

echo "Begin HBase import using Sqoop"

# First Column FirstName
if [ $? -eq 0 ]; then
sqoop import --connect jdbc:postgresql://db01.cloudair.lan/cloudair --username devuser --password BadPass%1 --table us_customers --columns "RepID, FirstName" --hbase-table us_customers --column-family FirstName --hbase-row-key RepID --num-mappers 1
fi

# Second Column LastName
if [ $? -eq 0 ]; then
sqoop import --connect jdbc:postgresql://db01.cloudair.lan/cloudair --username devuser --password BadPass%1 --table us_customers --columns "RepID, LastName" --hbase-table us_customers --column-family LastName --hbase-row-key RepID --num-mappers 1
fi

# Third Column Terrority
if [ $? -eq 0 ]; then
sqoop import --connect jdbc:postgresql://db01.cloudair.lan/cloudair --username devuser --password BadPass%1 --table us_customers --columns "RepID, Territory" --hbase-table us_customers --column-family Territory --hbase-row-key RepID --num-mappers 1
fi

# Fourth Column Commission
if [ $? -eq 0 ]; then
sqoop import --connect jdbc:postgresql://db01.cloudair.lan/cloudair --username devuser --password BadPass%1 --table us_customers --columns "RepID, Commission" --hbase-table us_customers --column-family Commission --hbase-row-key RepID --num-mappers 1
fi

# Fifth Column Salary
if [ $? -eq 0 ]; then
sqoop import --connect jdbc:postgresql://db01.cloudair.lan/cloudair --username devuser --password BadPass%1 --table us_customers --columns "RepID, Salary" --hbase-table us_customers --column-family Salary --hbase-row-key RepID --num-mappers 1
fi

# Sixth Column StartDate
if [ $? -eq 0 ]; then
sqoop import --connect jdbc:postgresql://db01.cloudair.lan/cloudair --username devuser --password BadPass%1 --table us_customers --columns "RepID, StartDate" --hbase-table us_customers --column-family StartDate --hbase-row-key RepID --num-mappers 1
fi

# Seventh Column EmpID
if [ $? -eq 0 ]; then
sqoop import --connect jdbc:postgresql://db01.cloudair.lan/cloudair --username devuser --password BadPass%1 --table us_customers --columns "RepID, EmpID" --hbase-table us_customers --column-family EmpID --hbase-row-key RepID --num-mappers 1
fi
