#!/bin/bash

sqoop import \
--connect jdbc:postgresql://db01.cloudair.lan:5432/cloudair \
--username devuser \
--password BadPass%1 \
--table us_customers \
--num-mappers 2 \
--driver org.postgresql.Driver


