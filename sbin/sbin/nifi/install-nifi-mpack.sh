#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: install-nifi-mpack.sh
# Author: WKD
# Date: 15FEB19
# Purpose: This script installs the NiFi mpack for Ambari
# I have loaded the mpack tar.gz into volume:lib/nifi to save
# the time and cost of downloading it.

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
NUMARGS=$#
DIR=${HOME}
NIFI_VER=3.5.1.0-17
NIFI_FILE=hdf-ambari-mpack-${NIFI_VER}.tar.gz
DATETIME=$(date +%Y%m%d%H%M)
LOGFILE=${DIR}/log/install-nifi-mpack.log

# FUNCTIONS
function usage() {
        echo "Usage: $(basename $0) ]"
        exit
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

function backupResources() {
# Good practice

	if [ -f /var/lib/ambari-server/backup.resources ]; then
		return
	else
		sudo cp -r /var/lib/ambari-server/resources /var/lib/ambari-server/backup.resources
	fi
}

function download() {
# Download the mpack, this now requires you to have a key to the paywall

	echo "Downloading the NiFi mpack - a moment please"

	cd ${DIR}/lib 

	#wget -nv https://PAYWALL_ID:PAYWALL_PASSWORD@archive.cloudera.com/p/HDF/centos7/3.x/updates/3.5.1.0/tars/hdf_ambari_mp/${NIFI_FILE}

	if [ ! -f ${DIR}/lib/${NIFI_FILE} ]; then
		echo "ERROR: No NiFi tar file downloaded"
		usage
	fi
}

function install() {
# The following will be the output:
# Using python /usr/bin/python
# Installing management pack
# Ambari Server 'install-mpack' completed successfully.

	sudo ambari-server install-mpack --mpack=${DIR}/lib/${NIFI_FILE} --verbose
}

function restart() {
# Restart Ambari

	sleep 5
	sudo ambari-server restart
}

# MAIN
callInclude
checkArg 0
checkSudo
# download
install
restart
