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
DATETIME=$(date +%Y%m%d%H%M)
LOGFILE=${DIR}/log/checkpoint-hdfs.log

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
# Clean up ATS
	sudo -u yarn-ats kinit -kt /etc/security/keytabs/yarn-ats.hbase-client.headless.keytab "yarn-ats-cloudair@CLOUDAIR.LAN"

	sudo -u yarn-ats yarn app -destroy ats-hbase
	sudo -u yarn-ats hdfs dfs -rm -R ./3.1.5.0-152/*
}

function cleanHDFS() {
# Clean up HDFS 
	sudo -u hdfs kinit -kt /etc/security/keytabs/hdfs.headless.keytab "hdfs-cloudair@CLOUDAIR.LAN"

	sudo -u hdfs hdfs dfs -rm -R /services/sync/yarn-ats/hbase.yarnfile
}

function restartYARN() {

	echo "Restart YARN"
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
restartYARN
