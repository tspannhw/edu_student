#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: refresh-services.sh
# Author: WKD
# Date: 141116
# Purpose: Refresh HDFS and YARN for SSSD. 
# Note: This script is intended to be run on remote nodes in the cluster

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
NUMARGS=$#
DIR=${HOME}
OPTION=$1
HOST=$2
REALM=CLOUDAIR.LAN
ADMIN_USER=sysadmin
AMBARI_USER=sysadmin
AMBARI_PASSWORD="BadPass%1"
AMBARI_SERVER=admin01.cloudair.lan
DATETIME=$(date +%Y%m%d%H%M)
LOGFILE=${DIR}/log/refresh-services.log

# FUNCTIONS
function usage() {
        echo "Usage: $(basename $0) [hdfs|https|yarn] [host]" 1>&2
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
# Check if arguments exits

        if [ ${NUMARGS} -ne "$1" ]; then
                usage 1>&2
        fi
}

function curlHTTP() {
# curl using http

	OUTPUT=$(curl -u ${AMBARI_USER}:${AMBARI_PASSWORD} -i -s -H 'X-Requested-By: ambari' http://${AMBARI_SERVER}:8080/api/v1/clusters)
}

function curlHTTPS() {
# curl using https

	OUTPUT=$(curl -u ${AMBARI_USER}:${AMBARI_PASSWORD} -i -s -k -H 'X-Requested-By: ambari' https://${AMBARI_SERVER}:8443/api/v1/clusters)
}

function printCluster() {
# print out cluster name

	export CLUSTER=$( echo ${OUTPUT} | sed -n 's/.*"cluster_name" : "\([^\"]*\)".*/\1/p')
	#echo ${CLUSTER}
}

function testHDFS() {
# Testing for the HDFS keytab

	ssh -tt ${ADMIN_USER}@${HOST} -C "
	if [ ! -f /etc/security/keytabs/hdfs.headless.keytab ]; then
		echo "HDFS keytab not found, did you run this on the namenode?"
		exit
	fi"
	EXIT=$?

	if [ ${EXIT} -eq 0 ]; then
		usage
	fi
} 

function refreshHDFS() {
# Refresh user and group mappings with LDAP/AD

#	ssh -tt ${ADMIN_USER}@${HOST} -C "sudo sudo -u hdfs kinit -kt /etc/security/keytabs/hdfs.headless.keytab hdfs-${CLUSTER}"
	ssh -tt ${ADMIN_USER}@${HOST} -C "sudo sudo -u hdfs hdfs dfsadmin -refreshUserToGroupsMappings"
}

function testYARN() {
# Test for YARN keytab

	ssh -tt ${ADMIN_USER}@${HOST} -C "
	if [ ! -f /etc/security/keytabs/yarn.service.keytab ]; then
		echo "Yarn keytab not found, did you run this on the ResourceManager node?"
	fi"
	EXIT=$?

	if [ ${EXIT} -eq 0 ]; then
		usage
	fi
} 

function refreshYARN() {
# Run yarn rmadmin to sync the group mappings with LDAP/AD

#	ssh -tt ${ADMIN_USER}@${HOST} -C "sudo sudo -u yarn kinit -kt /etc/security/keytabs/yarn.service.keytab yarn/${HOST}@${REALM}"
	ssh -tt ${ADMIN_USER}@${HOST} -C "sudo sudo -u yarn yarn rmadmin -refreshUserToGroupsMappings"
}

function runOption() {
# Case statement for option

        case ${OPTION} in
                -h | --help)
                        usage
			;;
                hdfs)
                        checkArg 2
			#testHDFS
			curlHTTP
			printCluster
			refreshHDFS
			;;
                https)
                        checkArg 2
			#testHDFS
			curlHTTPS
			printCluster
			refreshHDFS
			;;
                yarn)
			checkArg 2
                       	#testYARN
			refreshYARN
			;; 
                *)
                        usage
			;;
        esac
}

# MAIN
# Run check
checkSudo

# Run option
runOption
