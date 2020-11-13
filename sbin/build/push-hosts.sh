#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: push-hosts.sh
# Author: WKD
# Date: 14MAR17
# Purpose: Script to push hosts files into the /etc directory of the 
# root user on nodes contained in the nodes list. The node list 
# is a text file read in to a for loop. 

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
NUMARGS=$#
DIR=${HOME}
HOSTSFILE=${DIR}/conf/hosts.txt
HOSTS=${DIR}/conf/listhosts.txt
LOGDIR=/home/sysadmin/log
DATETIME=$(date +%Y-%m-%d:%H:%M:%S)
LOGDIR=${DIR}/log
LOGFILE=${LOGDIR}/push-hosts-file.log

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
        fi
}

function backupHosts() {
# backup hosts file 

        if [ -f ${HOSTSFILE} ]; then
              	cp ${HOSTSFILE} /tmp
        fi
}

function pushFile() {
# push the hosts file into remote sbin directory 

	for HOST in $(cat ${HOSTS}); do
		echo "Copy hosts file to ${HOST}"
		scp ${HOSTSFILE} ${HOST}:/tmp/hosts >> ${LOGFILE} 2>&1
	done 
}

function moveFile() {
# move the hosts file into remote /etc directory 

	for HOST in $(cat ${HOSTS}); do
		echo "Move hosts file on ${HOST}"
		ssh -t ${HOST} "sudo mv /tmp/hosts /etc/hosts" >> ${LOGFILE} 2>&1
	done 
}

# MAIN
# Source functions
callInclude

# Run checks
checkSudo
checkLogDir
checkArg 1
checkFile ${HOSTS}
checkFile ${HOSTS}
backupHosts

# Move file
pushFile
moveFile
