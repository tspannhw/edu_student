#!/bin/bash

if [ -z "$HBASE_HOME" ] ; then
    echo "HBASE_HOME not set ...exiting"
    exit 1
fi

CLASSPATH="$(hadoop classpath):$HBASE_HOME/*:$HBASE_HOME/lib/*"

javac -cp $CLASSPATH -d ../lib *.java 
