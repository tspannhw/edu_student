#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: install-sssd-ldap.sh
# Author: WKD
# Date: 1MAR18
# Purpose: Install and configure sssd for the support of OS connection
# to LDAP/AD. 
# Note: This script is intended to be run on every node in the cluster

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
NUMARGS=$#
DIR=${HOME}
LDAP_HOST=infra01.cloudair.lan
LDAP_BASE="dc=cloudair,dc=lan"
LDAP_REALM=CLOUDAIR.LAN
KPASSWORD=BadPass%1
DATETIME=$(date +%Y%m%d%H%M)
LOGFILE=${DIR}/log/install-sssd.log

# FUNCTIONS
function usage() {
        echo "Usage: $(basename $0)" 
        exit 
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
# Check arguments exits

        if [ ${NUMARGS} -ne "$1" ]; then
                usage
        fi
}

function initKadmin() {
# Must kinit for Kerberos

	echo "${KADMIN_PASSWD}" | sudo kinit ${KADMIN}/admin
	if [ $? -eq 1 ]; then
		usage
	fi
}

function installOddjob() {
# This package provides the pam_oddjob_mkhomedir.so 
# library, which the authconfig command uses to create 
# home directories. 

	sudo yum install -y oddjob-mkhomedir
	sudo systemctl enable  oddjobd
	sudo authconfig --enablemkhomedir --update
}

function installSSSD() {
# Install sssd software

	# Install sssd
	sudo yum install -y sssd sssd-krb5 
	sudo systemctl enable sssd
}

function cleanSSSD() {
# test if the config file exists and delete

	if [ -f /etc/sssd/sssd.conf ]; then
		sudo rm /etc/sssd/sssd.conf
	fi
}

function configSSSD() {
# Note: The master & data nodes only require nss. 
# Edge nodes require pam. Configure sssd.conf

	sudo tee /etc/sssd/sssd.conf > /dev/null <<EOF
[sssd]
config_file_version = 2
domains = cloudair.lan
services = nss, pam, ssh, pac
reconnection_retries = 3
sbus_timeout = 30
override_space = _

[domain/cloudair.lan]
id_provider = ldap
access_provider = ldap
ldap_uri = ldap://${LDAP_HOST}
ldap_search_base = ${LDAP_BASE}
ldap_group_name = cn
ldap_referrals = false

ldap_id_use_start_tls = false
ldap_tls_reqcert = allow
ldap_tls_cacert = /etc/openldap/certs/ldap-cert.pem

fallback_homedir = /home/%u
default_shell = /bin/bash

auth_provider = krb5
chpass_provider = krb5
krb5_realm = ${LDAP_REALM}
krb5_server = ${LDAP_HOST} 
krb5_kpasswd = ${KPASSWORD}
cache_credentials = true

[domain/LDAP]
id_provider = ldap
ldap_uri = ldap://${LDAP_HOST}
ldap_search_base = ${LDAP_BASE}

auth_provider = krb5
krb5_realm = ${LDAP_REALM}
krb5_server = ${LDAP_HOST}
cache_credentials = true

min_id = 1000
max_id = 20000
enumerate = false

[nss]
filter_groups = root
filter_users = root
reconnection_retries = 3
EOF
}

function setupSSSD() {
# This offers a choice for the configuration file. This
# function copies the file from the local etc directory instead
# of creating the function with EOF.

	# sudo cp ${HOME}/conf/sssd.conf /etc/sssd/sssd.conf

	# Setup permissions on configuration files
	sudo chown root:root /etc/sssd/sssd.conf
	sudo chmod 0600 /etc/sssd/sssd.conf
}

function authConfig() {
# set authconfig to enable ssh login using LDAP

	authconfig --enablesssd --update
}

function restartSSSD() {
# Config sssd

	# Restart oddjobd
	sudo systemctl restart oddjobd 

	# Restart sssd
	sudo systemctl restart sssd
}


# MAIN
# Run checks
checkSudo
checkArg 0

# Kinit
#initKadmin

echo "Begin installing SSSD, please wait"

# Install oddjob
installOddjob

# Install sssd
installSSSD
cleanSSSD
configSSSD
setupSSSD
restartSSSD

# Destroy Kerberos TGT
#sudo kdestroy
