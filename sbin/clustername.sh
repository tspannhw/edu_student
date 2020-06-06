#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.
# Title: cluster-name.sh
# Author: WKD
# Date: 14NOV16
# Purpose: Script to print the name of the cluster. This script can be
# called within other scripts. The script will run for http or https.
# The root user is not required for this script.

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLE
NUMARGS=$#
DIR=${HOME}
OPTION=$1
AMBARI_ADMIN=$2
AMBARI_PASSWORD=$3
AMBARI_SERVER=$4

# FUNCTIONS
function usage() {
        echo "Useage: $(basename $0) [http|https] [ambari_admin] [ambari_password] [ambari_server]"
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

function curlHTTP() {
# curl using http
	output=$(curl -u ${AMBARI_ADMIN}:${AMBARI_PASSWORD} -i -s -H 'X-Requested-By: ambari' http://${AMBARI_SERVER}:8080/api/v1/clusters )
}

function curlHTTPS() {
# curl using https
	output=$(curl -u ${AMBARI_ADMIN}:${AMBARI_PASSWORD} -i -s -k -H 'X-Requested-By: ambari' https://${AMBARI_SERVER}:8443/api/v1/clusters)
}

function printCluster() {
# print out cluster name
	export cluster=$( echo $output | sed -n 's/.*"cluster_name" : "\([^\"]*\)".*/\1/p')
	echo $cluster
}

function runOption() {
# Case statement for {OPTION}s.
        case "${OPTION}" in
                -h | --help)
                        usage
			;;
                http)
                        curlHTTP
			printCluster
			;;
                https)
			curlHTTPS
                        printCluster
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
checkArg 4

# Run options
runOption
