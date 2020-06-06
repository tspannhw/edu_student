#!/bin/bash

if [ -z "$HBASE_HOME" ] ; then
    echo "HBASE_HOME not set ...exiting"
    exit 1
fi

CLASSPATH="$(hadoop classpath):$HBASE_HOME/*:$HBASE_HOME/lib/*:/home/hduser/hbase/lib/*"

java -cp $CLASSPATH hbase.UserGet
