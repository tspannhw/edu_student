#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: install-non-root.sh
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
DIR=/var/local
TMPDIR=/tmp
DATETIME=$(date +%Y%m%d%H%M)
LOGDIR=/var/log/ambari-agent
LOGFILE=${LOGDIR}/install-non-root.log

# FUNCTIONS
function usage() {
        echo "Usage: $(basename $0)" 
        exit 1
}

function checkSudo() {
# Testing for sudo access to root

        sudo ls /root > /dev/null
        if [ "$?" != 0 ]; then
                echo "ERROR: You must have sudo to root to run this script"
                usage
        fi
}

function checkArg() {
# Check that the arguments exits

        if [ ${NUMARGS} -ne $1 ]; then
                echo "ERROR: Incorrect number of arguments"
                usage 
        fi
}

function copyAmbariSudo() {
# Copy in the Ambari agent file for sudo

	if [ -f ${TMPDIR}/ambari/ambari-agent ]; then
		sudo cp ${DIR}/ambari/ambari-agent /etc/sudoers.d/ambari-agent
	else
	   	echo "ERROR: The sudo file for ambari-agent was not found"
		usage
	fi
}

function changeToAmbariUser() {
# Edit the Ambari user in the ambari-agent property file

	sudo cp /etc/ambari-agent/conf/ambari-agent.ini /etc/ambari-agent/conf/ambari-agent.org
	sudo sed -i 's/root/ambari/' /etc/ambari-agent/conf/ambari-agent.ini 
}

function reinstallAmbari() {
# Reinstall the Ambari agent. This is a troubleshooting function.

	sudo rpm -qa | grep ambari-agent
	sudo yum clean all
	sudo yum -y reinstall ambari-agent
}


function restartAmbariAgent() {
# Restart the agent

	sudo chown -R ambari /var/lib/ambari-agent
	sudo ambari-agent restart
}


# MAIN
# Run checks
checkSudo
checkArg 0

# Move ini file
copyAmbariSudo

# This is for troubleshooting purposes
#reinstallAmbari

# Enable Ambari as non-root user
changeToAmbariUser
restartAmbariAgent
