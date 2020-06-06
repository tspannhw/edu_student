#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.
# Name: create-principal.sh
# Author: WKD
# Date:  140318
# Purpose: Used to create principals for Kerberos. This then
# creates and distributes the keytabs for the principal.
# CAUTION: This can be tricky if you are creating principals for 
# hyphenated users such as hive-webhcat. 
# IMPORTANT: The keytab must be placed into the correct conf directory. 
# In HDP this will be /etc/security/keytabs.

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
NUMARGS=$#
DIR=${HOME}
HOSTS=${DIR}/conf/listhosts.txt
PRINC=$1
REALM=$2
KADMIN=$3
PASSWORD=$4
DATETIME=$(date +%Y%m%d%H%M)
LOGFILE=${DIR}/log/create-princpal.log

# FUNCTIONS
function usage() {
	echo "Usage: $(basename $0) [principal] [REALM] [kadmin] [kadmin-password]"
	exit 1
}

function callInclude() {
# Test for script and run functions

        if [ -f ${DIR}/sbin/include.sh ]; then
                source ${DIR}/sbin/include.sh
        else
                echo "ERROR: The file ${DIR}/sbin/include.sh not found."
                echo "This required file provides supporting functions."
        fi
}

function createPrinc() {
# Create a principal for each host in the cluster.

	for HOST in $(cat $HOSTS); do
		echo "Creating principal ${PRINC} for ${HOST}"
		sudo kadmin -p ${KADMIN}/admin -w ${PASSWORD} -q "addprinc -randkey ${PRINC}/${HOST}@${REALM}"
	done
}

function createKeytab() {
# Create a keytab for each host in the cluster.

	for HOST in $(cat $HOSTS); do
		echo "Creating ${PRINC} keytab for ${HOST}"
   		sudo kadmin.local -p ${KADMIN}/admin -w  -q "ktadd -norandkey -k /tmp/${PRINC}.${HOST}.keytab ${PRINC}/${HOST}@${REALM}"
	done
}

function distroKeytab() {
# Distribute the keytabs to every node.
	
	for HOST in $(cat $HOSTS); do
		echo "Distributing ${PRINC} keytab to ${HOST}"
   		scp /tmp/${PRINC}.${HOST}.keytab ${HOST}:${HOME}/${PRINC}.keytab
		ssh ${HOST} -C "mv ${HOME}/${PRINC}.keytab /etc/security/keytabs/$PRINC.keytab" < /dev/null
		ssh ${HOST} -C "chown ${PRINC}:hadoop /etc/security/keytabs/${PRINC}.keytab" < /dev/null
		rm /tmp/${PRINC}.${HOST}.keytab
	done
}

function checkKeytab() {
# Test the Hadoop keytab for each HOST in the cluster.
	
	for HOST in $(cat $HOSTS); do
		echo "Listing ${PRINC} keytab on ${HOST}"
		ssh ${HOST} -C "kinit -ket /etc/security/keytabs/${PRINC}.keytab ${PRINC}/${HOST}@${REALM}" 
	done
}

#MAIN
# Source functions
callInclude

# Run checks
checkSudo
checkArg 3
checkFile ${HOSTS}

# Create principal
createPrinc
createKeytab
distroKeytab
checkKeytab
