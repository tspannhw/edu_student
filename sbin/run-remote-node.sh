#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: run-remote-node.sh
# Author: WKD
# Date: 1MAR18
# Purpose: Script to run any script in the user's home directory on 
# every node contained in the node list.  

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
NUMARGS=$#
DIR=${HOME}
OPTION=$1
INPUT=$2
HOSTS=${DIR}/conf/listhosts.txt
APPSLIST=${DIR}/conf/listapp.txt
DATETIME=$(date +%Y%m%d%H%M)
LOGFILE=${DIR}/log/run-remote-nodes.log

# FUNCTIONS
function usage() {
	echo "Usage: $(basename $0) [connect|rename|reboot|update|cleanlogs]" 
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


function runConnect() {
# Rename the host name of the node

        echo "Answer 'yes' if asked to remote connect"

        for HOST in $(cat ${HOSTS}); do
                ssh ${HOST} echo "Testing" > /dev/null 2>&1
                if [ $? = "0" ]; then
                        echo "Connected to ${HOST}"
                else
                        echo "Failed to connect to ${HOST}"
                fi
        done
}

function renameHosts() {
# Rename the host name of the node

        for HOST in $(cat ${HOSTS}); do
                echo "Rename host on ${HOST}"
                ssh -t ${HOST} "sudo hostnamectl set-hostname ${HOST}" >> ${LOGFILE} 2>&1
        echo "rename done"
        done
}

function runReboot() {
# Run a script on the remote nodes

        for HOST in $(cat ${HOSTS}); do
                echo "Reboot ${HOST}" | tee -a ${LOGFILE}
                ssh -tt ${HOST} "sudo reboot" >> ${LOGFILE} 2>&1
        done
}

function runUpdate() {
# Run a script on the remote nodes

        for HOST in $(cat ${HOSTS}); do
                ssh -tt ${HOST} "sudo yum -y update" >> ${LOGFILE} 2>&1
                echo "Run yum update on ${HOST}" | tee -a ${LOGFILE}
        done
}

function runCleanLogs() {
# Run a script clean out logs on all nodes

        for HOST in $(cat ${HOSTS}); do
    		while read -r APP; do
                        ssh -tt ${HOST} "sudo rm -r /var/log/${APP}/*" < /dev/null >> ${LOGFILE} 2>&1
                done < ${APPSLIST}
                echo "Cleaned all logs on ${HOST}" | tee -a ${LOGFILE}
        done
}

function runOption() {
# Case statement for options

	case "${OPTION}" in
		-h | --help)
			usage
			;;
  		connect)
                        checkArg 1
                        runConnect
			;;
                rename)
                        checkArg 1
                        renameHosts
                        ;;
                reboot)
                        checkArg 1
                        runReboot
                        ;;
                update)
                        checkArg 1
                        runUpdate
                        ;;
                cleanlogs)
                        checkArg 1
                        runCleanLogs
                        ;;
		*)
			usage
			;;
	esac
}

# MAIN
# Source functions
callInclude

# Run checks
checkSudo

# Run setups
setupLog ${LOGFILE}

# Run option
runOption

# Review log file
echo "Review log file at ${LOGFILE}"
