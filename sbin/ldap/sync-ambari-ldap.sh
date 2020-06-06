#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: sync-ambari-ldap.sh
# Author: WKD
# Date: 160719
# Purpose: Sync Ambari with Active Directory
# This script could be put into a cron job to run on a regular basis.
# See Hortonworks documentation for suggested periodicity.

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

#VARIABLES
NUMARGS=$#
OPTION=$1
DIR=${HOME}
ADMIN=admin
PASSWORD=admin
DATETIME=$(date +%Y%m%d%H%M)
LOGFILE=${DIR}/log/sync-ambari-ldap.log

# FUNCTIONS
function usage() {
        #echo "Usage: $(basename $0) [ambari-admin] [ambari-password] [all|exit|groups]"
        echo "Usage: $(basename $0) [all|exist|groups]"
        exit 1
}

function callInclude() {
# Test for script and run functions

        if [ -f ${DIR}/sbin/include.sh ]; then
                source ${DIR}/sbin/include.sh
        else
                echo "ERROR: The file ${DIR}/sbin/functions not found."
                echo "This required file provides supporting functions."
		exit 1
        fi
}

function runAll() {
# Sync Ambari with ldap. Uncomment the line you intend to run.

	sudo ambari-server sync-ldap --ldap-sync-admin-name=${ADMIN} --ldap-sync-admin-password=${PASSWORD} --all
	echo "Ambari Sync all ran" | tee -a ${LOGFILE}
}

function runExist() {
# Sync Ambari with ldap. Uncomment the line you intend to run.

	sudo ambari-server sync-ldap --ldap-sync-admin-name=${ADMIN} --ldap-sync-admin-password=${PASSWORD} --existing
	echo "Ambari Sync existing ran" | tee -a ${LOGFILE}
}

function runGroup() {
# Sync Ambari with ldap. Uncomment the line you intend to run.

	checkFile ${DIR}/conf/syncgroups.txt

	if [ -f ${DIR}/conf/syncgroups.txt ]; then
		sudo ambari-server sync-ldap --ldap-sync-admin-name=${ADMIN} --ldap-sync-admin-password=${PASSWORD} --groups ${DIR}/conf/syncgroups.txt
		echo "Ambari Sync groups ran" | tee -a ${LOGFILE}
	else
		echo "ERROR: File ${DIR}/conf/syncgroups.txt not found." | tee -a ${LOGFILE}
		exit 1
	fi
}

function runOption() {
# Case statement for options

        case "${OPTION}" in
                -h | --help)
                        usage
                        ;;
                all)
                        checkArg 1
                        runAll
                        ;;
                exist)
                        checkArg 1
                        runExist
                        ;;
                groups)
                        checkArg 1
                        runGroup
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

# Run option
runOption
