#!/bin/sh

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: install-ldap-client.sh
# Author: WKD
# Date: 1MAR18
# Purpose: Script to install ldap software in support of LDAP client. 
# Script requires the input of the LDAP IPADDRESS address and the LDAP
# password. The script loads software, configures the connection, 
# and then runs tests to validate. 
# Note: This scripts is intended to be run on every node of the cluster

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
NUMARGS=$#
DIR=${HOME}
OPTION $1
WRKDIR=${HOME}
DATETIME=$(date +%Y%m%d%H%M)
LOGFILE=${DIR}/log/install-ldap-client.log

# FUNCTIONS
function usage() {
        echo "Usage: $(basename $0) [install\test]" 1>&2
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
# Check arguments exits

        if [ ${NUMARGS} -ne "$1" ]; then
                usage
                exit 1 
        fi
}

function installLDAP() {
# Install openldap package

	sudo yum -y install openldap-clients ca-certificates
	sudo cp ${WRKDIR}/certs/security/ca.crt /etc/pki/ca-trust/source/anchors/hortonworks-net.crt
	sudo update-ca-trust force-enable
	sudo update-ca-trust extract
	sudo update-ca-trust check
}

function testSSL() {
# test connection to AD using openssl client

	echo "Testing connection to LDAP using the openssl client"
	openssl s_client -connect infra01.cloudair.lan:636 </dev/null
}

function testLDAP() {
# test connection to AD using ldapsearch 
# when prompted for password, enter: BadPass%1

	echo "Testing ldapsearch using the ldap client"
	ldapsearch -w ${PASSWORD} -D ldapreader@cloudair.lan
}


function runOption() {
# Case statement for options

        case "${OPTION}" in
                -h | --help)
                        usage
                        ;;
                install)
			checkArg 3
			checkIP
			installLDAP
                        ;;
                test)
			checkArg 1
			# Run tests
			testSSL
			testLDAP
                        ;;
  		*)
                        usage
                        ;;
        esac
}

# MAIN
# Run checks
checkSudo

# Run option
runOption
