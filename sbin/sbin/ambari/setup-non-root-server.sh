#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: setup-non-root-server.sh
# Author: WKD
# Date: 181207
# Purpose: Setup Ambari agent for non-root. Please note once you have
# restarted this agent you will have to manage it as the user ambari
# going forward.

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

#VARIABLES
NUMARGS=$#
OPTION=$1
DIR=${HOME}
HOST=admin01.cloudair.lan
NEWUSER=ambari
NEWGRP=hadoop
LOGDIR=${DIR}/log
LOGFILE=${LOGDIR}/setup-non-root-agent.log

# FUNCTIONS
function usage() {
        echo "Usage: $(basename $0) [adduser|deluser|enable|disable]" 
        exit 1
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

function addUser() {
# Adding the user ambari to all hosts 

	echo "Creating user ${NEWUSER} on ${HOST}"  | tee -a ${LOGFILE} 
        sudo useradd -d /var/lib/ambari-server -G hadoop -M -r -s /sbin/nologin  ${NEWUSER} < /dev/null  >> ${LOGFILE} 2>&1
        sudo mkdir -p /var/lib/ambari-server/.ssh < /dev/null  >> ${LOGFILE} 2>&1
        sudo cp /home/sysadmin/.ssh/authorized_keys /var/lib/ambari-server/.ssh < /dev/null  >> ${LOGFILE} 2>&1
        sudo chown -R ${NEWUSER} /var/lib/ambari-server/.ssh < /dev/null  >> ${LOGFILE} 2>&1
}

function delUser() {
# Deleting the user ambari from all hosts

        echo "Deleting user ${NEWUSER} on ${HOST}"
        sudo userdel -r ${NEWUSER} < /dev/null >> ${LOGFILE} 2>&1
	sudo rm -r /var/lib/ambari-server} < /dev/null  >> ${LOGFILE} 2>&1
}

function copySudo() {
# Copy in the Ambari agent file for sudo

	if [ -f ${HOME}/conf/ambari/ambari-agent ]; then
                echo "Copy Ambari Server sudo file to ${HOST}"  | tee -a ${LOGFILE} 
		sudo rm /etc/sudoers.d/ambari-server < /dev/null  >> ${LOGFILE} 2>&1
		sudo cp ${HOME}/conf/ambari/ambari-server /etc/sudoers.d/ambari-server  < /dev/null  >> ${LOGFILE} 2>&1
                sudo chown root:root /etc/sudoers.d/ambari-server < /dev/null  >> ${LOGFILE} 2>&1
	else
	   	echo "ERROR: Ambari Server sudo file not found" < /dev/null  >> ${LOGFILE} 2>&1
		usage
	fi
}

function setupServer() {
# Restart the agent
 
        echo "Setup Ambari Server on ${HOST}"  | tee -a ${LOGFILE} 
        echo "Follow the setup instructions for Non Root for the Ambari Server"  | tee -a ${LOGFILE} 
	sudo ambari-server setup
}

function restartServer() {
# Restart the server 
 
        echo "Restart Ambari Server on ${HOST}"  | tee -a ${LOGFILE} 
	sudo ambari-server restart < /dev/null  >> ${LOGFILE} 2>&1
}

function runOption() {
# Case statement for options

        case "${OPTION}" in
                -h | --help)
                        usage
                        ;;
		adduser)
			addUser	
			;;
		deluser)
			delUser	
			;;
                enable)
                        copySudo 
			setupServer	
			restartServer
                        ;;
                disable)
			setupServer	
			restartServer
                        ;;
                *)
                        usage
                        ;;
        esac
}

# MAIN
# Run checks
callInclude
checkSudo
checkArg 1

# Run option
runOption
