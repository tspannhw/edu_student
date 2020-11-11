#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: install-spnego-key.sh
# Author: WKD
# Date: 150318
# Purpose: Setup SPENGO on the nodes. This script runs after the 
# setup-ambari-server.sh script, which distros the secret key.
# This script must be run on every node to locate the secret key
# into the /etc/security directory.
# Note: This script is intended to be run on every node in the Cluster

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES

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
                usage 1>&2
                exit 1
        fi
}

function checkFile() {
# Check for a file

        FILE=$1
        if [ ! -f ${FILE} ]; then
                echo "ERROR: Input file ${FILE} not found"
                usage
        fi
}

function copyKey() {
# Copy in the http_secret file

	sudo cp /var/lib/ambari-agent/cache/host_scripts/http_secret /etc/security
	sudo chown hdfs:hadoop /etc/security/http_secret 
	sudo chmod 440 /etc/security/http_secret
}

function listKey() {
# List the keys

	ls -l /etc/security/http_secret
}

# MAIN
# Run checks
checkSudo
checkArg 0
checkFile /var/lib/ambari-agent/cache/host_scripts/http_secret

# Move key
copyKey
listKey
