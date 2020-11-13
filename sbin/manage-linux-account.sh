#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: manage-linux-users.sh
# Author: WKD
# Date: 1MAR18
# Purpose: Create or delete Linux power users in support of HDP. This 
# script will create and delete users for every node in the node list.

# DEBUG
# set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
NUMARGS=$#
DIR=${HOME}
OPTION=$1
HOSTS=${DIR}/conf/listhosts.txt
GROUPFILE=${DIR}/conf/listgroups.txt
USERS=${DIR}/conf/listusers.txt
DATETIME=$(date +%Y%m%d%H%M)
LOGDIR=${DIR}/log
LOGFILE=${LOGDIR}/linux-users.log

# FUNCTIONS
function usage() {
        echo "Usage: $(basename $0) [addgrps|addusers|delgrps|delusers|addkeys]"
        exit 1
}

function callInclude() {
# Test for script and run functions

        if [ -f ${DIR}/sbin/include.sh ]; then
                source ${DIR}/sbin/include.sh
        else
		echo "Include file not found"
        fi
}

function checkGroups() {
# Check groups exist before adding users

	grep biz /etc/group > /dev/null 2>&1 
	FLAG=$(echo $?)

	if [ ${FLAG} -eq 1 ]; then
		echo "You must add groups first"
		usage
	fi
}

function addGroups() {
# Add groups contained in the groups file       

        for HOST in $(cat ${HOSTS}); do
                echo "Adding Linux groups on ${HOST}" | tee -a "${LOGFILE}"
                while read -r NEWGROUP; do
                ssh -tt ${HOST} "sudo groupadd ${NEWGROUP}" < /dev/null >> ${LOGFILE} 2>&1
                done < ${GROUPFILE}
        done
}

function addUsers() {
# use this CLI for standard users

	#echo -n "Create user accounts?"
	#checkcontinue

	for HOST in $(cat ${HOSTS}); do
		echo "Creating user accounts on ${HOST}"
		while IFS=: read -r NEWUSER NEWGROUP; do
			ssh -tt ${HOST} "sudo useradd -d /home/${NEWUSER} -g ${NEWGROUP} -m ${NEWUSER}" < /dev/null  >> ${LOGFILE} 2>&1
		done < ${USERS}
	done
}

function addKeys() {
# Add the authorized_keys file

	for HOST in $(cat ${HOSTS}); do
		echo "Adding authorized keys on ${HOST}"
		while IFS=: read -r NEWUSER NEWGROUP; do
			ssh -tt ${HOST} "sudo mkdir -p /home/${NEWUSER}/.ssh" < /dev/null  >> ${LOGFILE} 2>&1
			ssh -tt ${HOST} "sudo cp ${HOME}/.ssh/id_rsa /home/${NEWUSER}/.ssh/id_rsa" < /dev/null  >> ${LOGFILE} 2>&1
			ssh -tt ${HOST} "sudo cp ${HOME}/.ssh/id_rsa.pub /home/${NEWUSER}/.ssh/id_rsa.pub" < /dev/null  >> ${LOGFILE} 2>&1
			ssh -tt ${HOST} "sudo cp ${HOME}/.ssh/authorized_keys /home/${NEWUSER}/.ssh/authorized_keys" < /dev/null  >> ${LOGFILE} 2>&1
			ssh -tt ${HOST} "sudo cp ${HOME}/.bash_profile /home/${NEWUSER}/.bash_profile" < /dev/null  >> ${LOGFILE} 2>&1
			ssh -tt ${HOST} "sudo cp ${HOME}/.bashrc /home/${NEWUSER}/.bashrc" < /dev/null  >> ${LOGFILE} 2>&1
			ssh -tt ${HOST} "sudo chown -R ${NEWUSER}:${NEWGROUP} /home/${NEWUSER}" < /dev/null  >> ${LOGFILE} 2>&1
		done < ${USERS}
	done
}

function deleteGroups() {
# Delete groups contained in the groups file    

        for HOST in $(cat ${HOSTS}); do
                echo "Deleting Linux groups on ${HOST}" | tee -a "${LOGFILE}"
                while read -r NEWGROUP; do
                        ssh -tt ${HOST} "sudo groupdel ${NEWGROUP}" < /dev/null >> ${LOGFILE} 2>&1
                done < ${GROUPFILE}
        done
}

function deleteUsers() {
	#echo -n "Delete user accounts?"
	#checkcontinue
	
	for HOST in $(cat ${HOSTS}); do
		echo "Deleting user accounts on ${HOST}"
		while IFS=: read -r NEWUSER NEWGROUP; do
			ssh -tt ${HOST} "sudo userdel -r ${NEWUSER}" < /dev/null >> ${LOGFILE} 2>&1
			ssh -tt ${HOST} "sudo rm -r /home/${NEWUSER}" < /dev/null >> ${LOGFILE} 2>&1

		done < ${USERS}
	done
}

function runOption() {
# Case statement for add or delete Linux users

        case "${OPTION}" in
                -h | --help)
                        usage
			;;
                addgrps)
                        checkArg 1
                        addGroups
                        ;;
                addusers)
			checkArg 1
			checkGroups
                        addUsers
			;;
                delgrps)
                        checkArg 1
                        deleteGroups
                        ;;
                delusers)
			checkArg 1
                        deleteUsers
			;;
                addkeys)
			checkArg 1
                        addKeys 
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
checkLogDir
checkFile ${USERS}
checkFile ${HOSTS}

# Run option
runOption
