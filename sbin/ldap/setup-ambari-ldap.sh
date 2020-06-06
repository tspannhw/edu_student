#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: setup-ambari-ldap.sh
# Author: WKD
# Date: 1MAR18
# Purpose: Setup Ambari with Active Directory
# Changes:

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

#VARIABLES
NUMARGS=$#
DIR=${HOME}
LDAP_HOST=infra01.cloudair.lan  
LDAP_BASE=dc=cloudair,dc=lan 
LDAP_USER=cn=ldapadmin,dc=cloudair,dc=lan
LDAP_PASSWORD="BadPass%1"
DATETIME=$(date +%Y%m%d%H%M)
LOGFILE=${DIR}/log/setup-ambari-ldap.log

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

function configLDAP() {
# Set configuration file for ldap

	sudo ambari-server setup-ldap \
		--ldap-url=${LDAP_HOST}:389 \
		--ldap-secondary-url= \
		--ldap-ssl=false \
		--ldap-user-class=posixAccount \
		--ldap-user-attr=uid \
		--ldap-group-class=posixGroup \
		--ldap-group-attr=cn \
		--ldap-member-attr=memberuid \
		--ldap-dn=dn \
		--ldap-base-dn=${LDAP_BASE} \
		--ldap-referral=follow \
		--ldap-bind-anonym=false \
		--ldap-manager-dn=${LDAP_USER} \
		--ldap-manager-password=${LDAP_PASSWORD} \
		--ldap-sync-username-collisions-behavior=convert \
		--ldap-save-settings
}

# MAIN
# Source functions
callInclude

# Config LDAP
configLDAP

# pause "Restarting the ambari-server" 
sudo ambari-server restart
