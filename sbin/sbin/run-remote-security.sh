#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: run-remote-security.sh
# Author: WKD
# Date: 1MAR18
# Purpose: Script to run any script in the user's home directory on 
# every node contained in the node list.  

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
NUMARGS=$#
DIR=${HOME}
OPTION=$1
INPUT1=$2
INPUT2=$3
HOSTS=/home/sysadmin/conf/listhosts.txt
PYFILE=cert-verification.cfg
KRBFILE=krb5.conf
DATETIME=$(date +%Y%m%d%H%M)
LOGDIR=${DIR}/log
LOGFILE=${LOGDIR}/run-remote-security.log

# FUNCTIONS
function usage() {
	echo "Usage: $(basename $0)" 
  	echo "                               [resolv <resolv.conf>]"
	echo "                               [ldap <ldap-hostname> <ldap-password>]" 
	echo "                               [test-ldap <ldap-password>]" 
	echo "                               [sssd <kerberos-password>]" 
        echo "                               [knox <path_gateway.pem>]"
	exit 
}

function callInclude() {
# Test for script and run functions

        if [ -f ${DIR}/sbin/include.sh ]; then
                source ${DIR}//sbin/include.sh
        else
                echo "ERROR: The file ${DIR}/sbin/include.sh not found."
                echo "This required file provides supporting functions."
		exit 1
        fi
}

function pushResolv() {
# push the /etc/resolv.conf file into the remote nodes

        PUSHFILE=${INPUT1}
        checkFile ${PUSHFILE}

        for HOST in $(cat ${HOSTS}); do
                scp ${PUSHFILE} ${HOST}:${HOME}  >> ${LOGFILE} 2>&1
                ssh -tt ${HOST} "sudo chattr -i /etc/resolv.conf"  >> ${LOGFILE} 2>&1
                ssh -tt ${HOST} "sudo mv ${HOME}/resolv.conf /etc/resolv.conf"  2>&1 >> ${LOGFILE}
                ssh -tt ${HOST} "sudo chattr +i /etc/resolv.conf" >> ${LOGFILE} 2>&1
                RESULT=$?
                if [ ${RESULT} -eq 0 ]; then
                        echo "Push ${PUSHFILE} to ${HOST}" | tee -a ${LOGFILE}
                else
                        echo "ERROR: Failed to push ${PUSHFILE} to ${HOST}" | tee -a ${LOGFILE}
                fi
        done
}

function runLDAP() {
# Run a script on a remote node 
# Command to run install-ldap.sh with Active Directory IP Address
# Add or remove # 2>$1 >> ${LOGFILE} to trim {OPTION} output

	IP=${INPUT1}
	PASSWORD=${INPUT2}

	for HOST in $(cat ${HOSTS}); do
		echo "Run install-ldap.sh on ${HOST}" | tee -a ${LOGFILE}
		ssh -tt ${HOST} "${HOME}/install-ldap.sh ${IP} ${PASSWORD}"  >> ${LOGFILE} 2>&1

		if [ $? -eq 1 ]; then
			usage
		fi
	done 
}

function testLDAP() {
# Run a script on a remote node 
# Command to test LDAP

	PASSWORD=${INPUT1}

	for HOST in $(cat ${HOSTS}); do
		echo
		echo "Testing LDAP connection on ${HOST}" | tee -a ${LOGFILE}
		ssh -tt ${HOST} " ldapsearch -w ${PASSWORD} -D ldap-reader@lab.hortonworks.net"  >> ${LOGFILE}  2>&1
		if [ $? -eq 1 ]; then
			usage
		fi
	done 
}

function runSSSD() {
# Run a script on a remote node 
# Command to run install-sssd.sh with Kerberos password 
# Add or remove # 2>$1 >> ${LOGFILE} to trim {OPTION} output

	PASSWORD=${INPUT1}

	for HOST in $(cat ${HOSTS}); do
		echo "Run install-sssd.sh on ${HOST}" | tee -a ${LOGFILE}
		ssh -tt ${HOST} "${HOME}/install-sssd-ldap.sh ${PASSWORD}"  >> ${LOGFILE}  2>&1
		if [ $? -eq 1 ]; then
			usage
		fi
	done 
}

function pushKnoxGatewayPem() {
# push the /etc/resolv.conf file into the remote nodes

        PUSHFILE=${INPUT1}
        checkFile ${PUSHFILE}

        for HOST in $(cat ${HOSTS}); do
                scp ${PUSHFILE} ${HOST}:${HOME}/gateway-identity.pem  >> ${LOGFILE} 2>&1
                ssh -tt ${HOST} "sudo mv ${HOME}/gateway-identity.pem /etc/pki/tls/certs/gateway-identity.pem"  2>&1 >> ${LOGFILE}
                RESULT=$?
                if [ ${RESULT} -eq 0 ]; then
                        echo "Push ${PUSHFILE} to ${HOST}" | tee -a ${LOGFILE}
                else
                        echo "ERROR: Failed to push ${PUSHFILE} to ${HOST}" | tee -a ${LOGFILE}
                fi
        done
}

function runOption() {
# Case statement for option

	case ${OPTION} in
		-h | --help)
			usage
			;;
                resolv)
                        checkArg 2
                        pushResolv
                        ;;
                ldap)
                        checkArg 3
			checkIP 
                        runLDAP
			;;
                test-ldap)
                        checkArg 2
                        testLDAP
			;;
                sssd)
                        checkArg 2
                        runSSSD
			;;
                knox)
                        checkArg 2
                        pushKnoxGatewayPem
			;;
		*)
			usage
			;;
	esac
}

# MAIN
# Source functions
callInclude

# Run checks
checkSudo

# Run setups
setupLog ${LOGFILE}

# Run options
runOption

# Review log file
echo "Review log file at ${LOGFILE}"
