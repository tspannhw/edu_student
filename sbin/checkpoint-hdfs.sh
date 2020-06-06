#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: checkpoint-hdfs.sh
# Author: WKD
# Date: 1MAR18
# Purpose: This script checkPoints the NameNode. 
# Alert. This can be done if the checkPoint alert comes out due 
# to no current checkPoint. This script should be run on the 
# ACTIVE NAMEHOST. The alert will clear.

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

function checkPoint() {
# Place NN in safemode and the merge editlogs into fsimage
	sudo -u hdfs kinit -kt /etc/security/keytabs/hdfs.headless.keytab "hdfs-cloudair"

	sudo -u hdfs hdfs dfsadmin -safemode enter
	sudo -u hdfs hdfs dfsadmin -saveNamespace
	sudo -u hdfs hdfs dfsadmin -safemode leave
}

# MAIN
# Source Functions
callInclude

# Run checks
checkSudo
checkArg 0

# Checkpoint
checkPoint
