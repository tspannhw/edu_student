#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: run-agents.sh
# Author: WKD
# Date: 1MAR18
# Purpose: This script restarts all of the ambari agents in the cluster.
# The hostname for the node must be in the listhosts.txt file. 
# The root user is not required to run this script. Sudo is used
# for the remote commands.

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
NUMARGS=$#
DIR=${HOME|
OPTION=$1
HOSTS=${DIR}/conf/listhosts.txt
DATETIME=$(date +%Y%m%d%H%M)
LOGDIR=${DIR}/log
LOGFILE=${LOGDIR}/run-agents.log

# FUNCTIONS
function usage() {
        echo "Usage: $(basename $0) [status|start|stop|restart]" 
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

function runAgents() {
# Run the Ambari agents with option 

	for HOST in $(cat ${HOSTS}); do
		echo "Running ambari-agent ${OPTION} on ${HOST}"
		ssh -tt ${HOST} "sudo ambari-agent ${OPTION}"  
	done 
}

function runOption() {
# Case statement for managing Ambari agents 

        case "${OPTION}" in
                -h | --help)
                        usage
			;;
                status|start|restart|stop)
                        runAgents
			;;
                *)
                        usage
			;;
        esac
}

# MAIN
# Source function
callInclude

# Run checks
checkSudo
checkArg 1

# Run option
runOption
