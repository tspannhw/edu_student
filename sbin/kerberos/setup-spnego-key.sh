#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: setup-spnego-key.sh
# Author: WKD
# Date: 150318
# Purpose: Setup the SPENGO on the Ambari server. This is to be
# run only on the ambari server. This script creates a http_secret 
# key and place it into Ambari resources for distro
# The ambari server will distribute this file to all of the agents

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
NUMARGS=$#
DIR=${HOME}
DATETIME=$(date +%Y%m%d%H%M)
LOGFILE=${DIR}/log/setup-spnego-key.log

# FUNCTIONS
function usage() {
        echo "Usage: $(basename $0)" 
        exit 1
}

function callInclude() {
# Test for script and run functions

        if [ -f ${DIR}/sbin/include.sh ]; then
                source ${DIR}/sbin/include.sh
        else
                echo "ERROR: The file ${DIR}/sbin/functions not found."
                echo "This required file provides supporting functions."
        fi
}

function configKey() {
# Create secret key for distro

	sudo dd if=/dev/urandom of=/etc/security/http_secret bs=1024 count=1 
	sudo chown hdfs:hadoop /etc/security/http_secret 
	sudo chmod 440 /etc/security/http_secret 
}

function distroKey() {
# Copy secret key into the Ambari distro directory

	sudo cp /etc/security/http_secret /var/lib/ambari-server/resources/host_scripts/
}

function restartAmbari() {
# Restart the ambari server

	sudo ambari-server restart 
}

# MAIN
# Source functions
callInclude

# Run checks
checkSudo
checkArg 0

# Config SPNEGO
configKey
distroKey
restartAmbari
