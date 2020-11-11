#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: manage-hdfs-users.sh
# Author: WKD
# Date: 180318
# Purpose: Create HDFS users in support of HDP. Add a list of HDFS 
# users from the users.txt file. Create hdfs user working directory 
# and set quotas. 

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
NUMARGS=$#
DIR=${HOME}
OPTION=$1
FILEQ=$2
SPACEQ=$3
USERS=${DIR}/conf/listusers.txt
DATETIME=$(date +%Y%m%d%H%M)
LOGFILE=${DIR}/log/manage-hdfs-users.log

# FUNCTIONS
function usage() {
        echo "Usage: $(basename $0) [add]"
        echo "			     [delete]"
        echo "			     [list]"
        echo "			     [setquota <file_quota> <space_quota>]"
        echo "			     [clearquota]"
        echo "			     [listquota]"
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

function addUsers() {
# Add a block of working directories for HDFS users 
# from the users.txt.

	while IFS=: read -r NEWUSER NEWGROUP; do
		echo "Adding working directory for ${NEWUSER}"
		sudo -u hdfs hdfs dfs -mkdir /user/${NEWUSER}
        	sudo -u hdfs hdfs dfs -chown ${NEWUSER}:${NEWGROUP} /user/${NEWUSER}
	done < ${USERS}
}

function deleteUsers() {
# Delete a block of working directories for HDFS users 
# from the users.txt file.

	while IFS=: read -r NEWUSER NEWGROUP; do
		echo "Deleting working directory for ${NEWUSER} from HDFS."
		sudo -u hdfs hdfs dfs -rm -r -skipTrash /user/${NEWUSER}
	done < ${USERS}
}

function listUsers() {
# List hdfs users

        sudo -u hdfs hdfs dfs -ls /user
}

function setquota() {
# Setting quotas for users from the users.txt file

	while IFS=: read -r NEWUSER NEWGROUP; do
		echo "Setting quotas for ${NEWUSER}"
        	sudo -u hdfs hdfs dfsadmin -setQuota ${FILEQ} /user/${NEWUSER}
        	sudo -u hdfs hdfs dfsadmin -setSpaceQuota ${SPACEQ} /user/${NEWUSER}
	done < ${USERS}
}

function clearquota() {
# Clearing the quotas for users from the users.txt file

	while IFS=: read -r NEWUSER NEWGROUP; do
		echo "Clearing quotas for ${NEWUSER}"
        	sudo -u hdfs hdfs dfsadmin -clrQuota /user/${NEWUSER}
        	sudo -u hdfs hdfs dfsadmin -clrSpaceQuota /user/${NEWUSER}
	done < ${USERS}
}

function listquota() {
# Setting quotas for users from the users.txt file

	while IFS=: read -r NEWUSER NEWGROUP; do
		echo "Listing quotas for ${NEWUSER}"
        	sudo -u hdfs hadoop fs -count -q -h /user/${NEWUSER}
	done < ${USERS}
}

function runOption() {
# Case statement for add, delete or list working 
# directories for users

        case "${OPTION}" in
                -h | --help)
                        usage
			;;
                add)
			checkArg 1
                        addUsers
			;;
                delete)
			checkArg 1
                        deleteUsers
			;;
                list)
			checkArg 1
                        listUsers
			;;
                setquota)
			checkArg 3
                       	setQuotas 
			;;
                clearquota)
			checkArg 1
                       	clearQuotas 
			;;
                listquota)
			checkArg 1
                       	listQuotas 
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

# Run options
runOption
