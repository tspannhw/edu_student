#!/bin/bash

sqoop import \
--connect jdbc:postgresql://db01.cloudair.lan/cloudair \
--username devuser -P \
--table ww_customers \
--input-fields-terminated-by '\001' \
--lines-terminated-by '\n' \
--hive-import \
--hive-table cloudair.ww_customers \
--num-mappers 1
