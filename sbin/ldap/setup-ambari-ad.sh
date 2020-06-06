#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: setup-ambari-ad.sh
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
ad_host=ad01.cloudair.lan  
ad_root=ou=CorpUsers,dc=cloudair,dc=lan 
ad_user=cn=ldap-reader,ou=ServiceUsers,dc=cloudair,dc=lan
DATETIME=$(date +%Y%m%d%H%M)
LOGFILE=${DIR}/log/setup-ambari-ad.log

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
--ldap-url=${ad_host}:389 \
--ldap-secondary-url= \
--ldap-ssl=false \
--ldap-user-class=user \
--ldap-user-attr=sAMAccountName \
--ldap-group-class=group \
--ldap-group-attr=cn \
--ldap-dn=distinguishedName \
--ldap-base-dn=${ad_root} \
--ldap-referral= \
--ldap-bind-anonym=false \
--ldap-manager-dn=${ad_user} \
--ldap-member-attr=member \
--ldap-save-settings
}

# MAIN
# Source functions
callInclude

# Config LDAP
configLDAP

# pause "Restarting the ambari-server" 
sudo ambari-server restart
