#!/bin/sh

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: setup-quicklinks.sh 
# Author: WKD
# Date: 200425
# Purpose: This is a retro script to correct the quicklinks error. Use
# this if the quicklinks are showing IP addresses.

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
NUMARGS=$#
DIR=${HOME}
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

function setHostname() {

	sudo sed -i "/\[agent\]/ a public_hostname_script=\/etc\/ambari-agent\/conf\/public-hostname.sh" /etc/ambari-agent/conf/ambari-agent.ini
	sudo sed -i "/\[agent\]/ a hostname_script=\/etc\/ambari-agent\/conf\/internal-hostname.sh" /etc/ambari-agent/conf/ambari-agent.ini

}

function setSecurity () (

	sudo sed -i "/\[security\]/ a force_https_protocol=PROTOCOL_TLSv1_2" /etc/ambari-agent/conf/ambari-agent.ini
)

#MAIN
setHostname
setSecurity
