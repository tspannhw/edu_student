#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: rebuild-ats-hbase.sh
# Author: WKD
# Date: 1MAR18
# Purpose: This script rebuilds the hbase for yarn-ats. This is a 
# PIA.

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLE
NUMARGS=$#
DIR=${HOME}
COUNTER=0
#AMBARI_URL=http://admin01.cloudair.lan:8080
AMBARI_URL=https://admin01.cloudair.lan:8443
AMBARI_USER=admin
AMBARI_PASSWORD=admin
DATETIME=$(date +%Y%m%d%H%M)
LOGDIR=/var/log/ambari-server
LOGFILE=${LOGDIR}/log/checkpoint-hdfs.log

# FUNCTIONS
function usage() {
        echo "Usage: $(basename $0)"
        exit 
}

function callInclude() {
# Test for script and run functions

        if [ -f ${DIR}/sbin/include.sh ]; then
                source ${DIR}/sbin//include.sh
        else
                echo "ERROR: The file ${DIR}/sbin/include.sh not found."
                echo "This required file provides supporting functions."
		exit 1
        fi
}

function cleanATS() {
	sudo -u yarn-ats kinit -kt /etc/security/keytabs/yarn-ats.hbase-client.headless.keytab "yarn-ats-cloudair@CLOUDAIR.LAN"

	sudo -u yarn-ats yarn app -destroy ats-hbase
	sudo -u yarn-ats hdfs dfs -rm -r ./3.1.5.0-152/*
}

function cleanHDFS() {
# Clean up HDFS 
	sudo -u hdfs kinit -kt /etc/security/keytabs/hdfs.headless.keytab "hdfs-cloudair@CLOUDAIR.LAN"

	sudo -u hdfs hdfs dfs -rm -r -skipTrash /services/sync/yarn-ats/hbase.yarnfile
}

function setClusterName() {
# Set the name of the cluster to a variable

        CLUSTER_NAME=$(curl -k -u ${AMBARI_USER}:${AMBARI_PASSWORD} -H "X-Requested-By: ambari" -i ${AMBARI_URL}/api/v1/clusters | grep '"cluster_name" :' | awk '{ print $3 }' | sed 's/,//g' | sed 's/"//g')
}

function stopYARN() {
# Start the cluster

        echo "Ambari Server stopping YARN on ${CLUSTER_NAME} at $(date)" | tee -a ${LOGFILE}

        /usr/bin/curl -k -s -u ${AMBARI_USER}:${AMBARI_PASSWORD} -i -H 'X-Requested-By: ambari' -X PUT -d '{"RequestInfo": {"context" :"Stop YARN via REST"}, "Body": {"ServiceInfo": {"state": "INSTALLED"}}}' ${AMBARI_URL}/api/v1/clusters/${CLUSTER_NAME}/services/YARN
}

function startYARN() {
# Start the cluster

        echo "Ambari Server starting YARN on ${CLUSTER_NAME} at $(date)" | tee -a ${LOGFILE}

        /usr/bin/curl -k -s -u ${AMBARI_USER}:${AMBARI_PASSWORD} -i -H 'X-Requested-By: ambari' -X PUT -d '{"RequestInfo": {"context" :"Start YARN via REST"}, "Body": {"ServiceInfo": {"state": "STARTED"}}}' ${AMBARI_URL}/api/v1/clusters/${CLUSTER_NAME}/services/YARN
}

# MAIN
# Source Functions
callInclude

# Run checks
checkSudo
checkArg 0

# Clean
cleanATS
cleanHDFS
setClusterName
stopYARN
sleep 30
startYARN
