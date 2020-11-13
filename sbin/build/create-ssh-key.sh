#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: build-ssh-key.sh
# Author: WKD 
# Date: 180318 
# Purpose: This creates the ssh keys to be used by Ambari for the Edu 
# cluster. These keys will have to be put into place manually.
# Do not confuse these keys used by AWS for the sysadmin users.

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# CHANGES
# RFC-1274 Script Maintenance

# VARIABLES
DIR=${HOME}
CERTDIR=${DIR}/pki/ref
DATETIME=$(date +%Y%m%d%H%M)
LOGDIR=${DIR}/log
LOGFILE=${LOGDIR}/build-ssh-keypairs.log

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
		exit 1
        fi
}

function createSSHKey() {
# Create a ssh private and public key, retain a copy in the certs directory.

	if [ -d ${CERTDIR} ]; then
		echo -n "The ${CERTDIR} directory exists. Remove it?"
		checkContinue
                rm -r ${CERTDIR}
		mkdir -p ${CERTDIR}
	else
		mkdir -p ${CERTDIR}
	fi

	# Create keys
	ssh-keygen -f ${CERTDIR}/reference-keypair.pem

	# Build keys
	cp ${CERTDIR}/reference-keypair.pem ${CERTDIR}/id_rsa 
	cp ${CERTDIR}/reference.pem.pub ${CERTDIR}/authorized_keys

	# Set permissions	
	chmod 400 ${CERTDIR}/reference-keypair.pem
	chmod 400 ${CERTDIR}/id_rsa
	chmod 600 ${CERTDIR}/authorized_keys
}

# MAIN
# Source functions
callInclude

# Run build
createSSHKey
