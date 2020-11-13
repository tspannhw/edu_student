#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: setup-non-root-agent.sh
# Author: WKD
# Date: 181207
# Purpose: Setup Ambari agent for non-root. Please note once you have
# restarted this agent you will have to manage it as the user ambari
# going forward.
# NOTE: This script is intended to be run all nodes of the cluster.

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

#VARIABLES
NUMARGS=$#
OPTION=$1
DIR=${HOME}
HOSTS=${DIR}/conf/listhosts.txt
NEWUSER=ambari
NEWGRP=hadoop
LOGDIR=${DIR}/log
LOGFILE=${LOGDIR}/setup-non-root-agents.log

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
        ssh -tt ${HOST} "sudo useradd -g hadoop -m ${NEWUSER}" < /dev/null  >> ${LOGFILE} 2>&1
	ssh -tt ${HOST} "sudo mkdir /home/${NEWUSER}/.ssh" < /dev/null  >> ${LOGFILE} 2>&1
        ssh -tt ${HOST} "sudo cp /home/sysadmin/.ssh/authorized_keys /home/${NEWUSER}/.ssh" < /dev/null  >> ${LOGFILE} 2>&1
        ssh -tt ${HOST} "sudo chown -R ${NEWUSER} /home/${NEWUSER}/.ssh" < /dev/null  >> ${LOGFILE} 2>&1
}

function delUser() {
# Deleting the user ambari from all hosts

        echo "Deleting user ${NEWUSER} on ${HOST}"
        ssh -tt ${HOST} "sudo userdel -r ${NEWUSER}" < /dev/null >> ${LOGFILE} 2>&1
}


function copyAgentSudo() {
# Copy in the Ambari agent file for sudo

	if [ -f ${HOME}/conf/ambari/ambari-agent ]; then
                echo "Copy Ambari Agent sudo file to ${HOST}"  | tee -a ${LOGFILE} 
		ssh -tt ${HOST} -C "sudo rm /etc/sudoers.d/ambari-agent" < /dev/null  >> ${LOGFILE} 2>&1
		scp ${HOME}/conf/ambari/ambari-agent ${HOST}:${HOME} < /dev/null  >> ${LOGFILE} 2>&1
		ssh -tt ${HOST} -C "sudo mv ${HOME}/ambari-agent /etc/sudoers.d/ambari-agent" < /dev/null  >> ${LOGFILE} 2>&1
                ssh -tt ${HOST} "sudo chown root:root /etc/sudoers.d/ambari-agent" < /dev/null  >> ${LOGFILE} 2>&1
	else
	   	echo "ERROR: Ambari Agent sudo file not found" < /dev/null  >> ${LOGFILE} 2>&1
		usage
	fi
}

function editAgentIni() {
# Edit the Ambari user in the ambari-agent property file

        echo "Edit the Ambari Agent sudo file on ${HOST}"  | tee -a ${LOGFILE} 
	ssh -tt ${HOST} -C "sudo cp /etc/ambari-agent/conf/ambari-agent.ini /etc/ambari-agent/conf/ambari-agent.bak" < /dev/null  >> ${LOGFILE} 2>&1
	ssh -tt ${HOST} -C "sudo sed -i 's/root/ambari/' /etc/ambari-agent/conf/ambari-agent.ini" < /dev/null  >> ${LOGFILE} 2>&1 
}

function chownAgent() {
# Change ownership of /var/lib/ambari-agent. The directory with service files

	ssh -tt ${HOST} -C "sudo chown -R ${NEWUSER}:${NEWGRP} /var/lib/ambari-agent" < /dev/null  >> ${LOGFILE} 2>&1
}

function chownRoot() {
# Change ownership of /var/lib/ambari-agent. The directory with service files

	ssh -tt ${HOST} -C "sudo chown -R root:root /var/lib/ambari-agent" < /dev/null  >> ${LOGFILE} 2>&1
}

function restoreAgent() {
# Restore the agent ini file to root
	
        echo "Restore Ambari Agent to root on ${HOST}"  | tee -a ${LOGFILE} 
	ssh -tt ${HOST} -C "sudo rm /etc/ambari-agent/conf/ambari-agent.ini" < /dev/null  >> ${LOGFILE} 2>&1
	ssh -tt ${HOST} -C "sudo cp /etc/ambari-agent/conf/ambari-agent.bak /etc/ambari-agent/conf/ambari-agent.ini" < /dev/null  >> ${LOGFILE} 2>&1
}

function restartAgent() {
# Restart the agent
 
        echo "Restart Ambari Agent on ${HOST}"  | tee -a ${LOGFILE} 
	ssh -tt ${HOST} -C "sudo ambari-agent restart" < /dev/null  >> ${LOGFILE} 2>&1
}

function reenableAgent() {
# Reenable the Ambari agent. This is a troubleshooting function.

	sudo rpm -qa | grep ambari-agent
	sudo yum clean all
	sudo yum -y reenable ambari-agent
}

function testSudo() {
# You can test if the sudo works

	echo "Test the sudo file works for the user ${NEWUSER}"
	echo "sudo su - ${NEWUSER}"
	echo "sudo -l"
}

function runOption() {
# Case statement for options

        case "${OPTION}" in
                -h | --help)
                        usage
                        ;;
		adduser)
			for HOST in $(cat ${HOSTS}); do
				addUser	
			done
			;;
		deluser)
			for HOST in $(cat ${HOSTS}); do
				delUser	
			done
			;;
                enable)
			for HOST in $(cat ${HOSTS}); do
                        	copyAgentSudo 
				editAgentIni
				restartAgent
			done
			testSudo
                        ;;
                disable)
			for HOST in $(cat ${HOSTS}); do
                        	restoreAgent
				restartAgent 
			done
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
