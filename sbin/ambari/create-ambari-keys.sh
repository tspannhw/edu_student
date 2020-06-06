#!/bin/sh

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: create-ambari-keys.sh 
# Author: WKD
# Date: 190406
# Purpose: Script to install ssl certificate, both public and private
# key, into /etc/pki/tls on the Ambari server. This is required before
# ambari-server setup-security for HTTPS.

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
NUMARGS=$#
DIR=${HOME}
KEYOWNER=ambari
AMBARI_SERVER=$(curl icanhazptr.com)
DATETIME=$(date +%Y%m%d%H%M)
LOGDIR=${DIR}/log
LOGFILE=${LOGDIR}/create-ambari-keys.log

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
                echo "ERROR: The file ${DIR}/sbin/include.sh not found."
                echo "This required file provides supporting functions."
		exit 1
        fi
}

function createKey() {
# Use openssl to generate a key and a crt file

	sudo openssl req -x509 -newkey rsa:4096 -keyout ${KEYOWNER}.key -out ${KEYOWNER}.crt -days 365 -nodes -subj "/CN=${AMBARI_SERVER}"
}

function mvKey() {
# Move the key and the crt into /etc/pki/tls

	sudo chown ${KEYOWNER} ${KEYOWNER}.crt ${KEYOWNER}.key   
	sudo chmod 0400 ${KEYOWNER}.crt ${KEYOWNER}.key   
	sudo mv ${KEYOWNER}.crt /etc/pki/tls/certs/   
	sudo mv ${KEYOWNER}.key /etc/pki/tls/private/
}

function listKey() {
# List the keys
	
	echo "Certificates are built" | tee -a ${LOGFILE}
	ls /etc/pki/tls/certs /etc/pki/tls/private >> ${LOGFILE} 2>&1
}

# MAIN
# Source functions
callInclude

# Run checks
checkSudo

# Create keys
cd /tmp
createKey
mvKey
listKey
