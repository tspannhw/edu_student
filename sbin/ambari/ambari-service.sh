#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: setup-ambari-user.sh
# Author: WKD
# Date: 26NOV18
# Purpose: This script sets the hdfs hooks for Ambari and then creates
# two users, sysadmin and devuser, in Ambari DB. This is a good example
# of using the Ambari REST api.

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
NUMARGS=$#
DIR=${HOME}
OPTION=$1
AMBARI_HOST=admin01.cloudair.lan
AMBARI_URL=http://admin01.cloudair.lan:8080
AMBARI_USER=admin
AMBARI_PASSWORD=admin
AMBARI_CLUSTER=cloudair
DATETIME=$(date +%Y%m%d%H%M)
LOGDIR=${DIR}/log
LOGFILE=${LOGDIR}/setup-ambari-users.log

# FUNCTIONS
function usage() {
        echo "Usage: $(basename $0)"
        exit
}

function callInclude() {
# Test for script and run functions

        if [ -f ${DIR}/sbin/include.sh ]; then
                source ${DIR}/sbin/include.sh
        else
                echo "ERROR: The file ${DIR}/sbin/include.sh not found."
                echo "This required file provides supporting functions."
		exit 1
        fi
}

# MAIN
# Source functions
callInclude

# Run checks
checkArg 0 
checkSudo
checkLogDir

# Run option
runSetup
