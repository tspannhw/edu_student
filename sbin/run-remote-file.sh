#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: run-remote-file.sh
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
INPUT=$2
OUTPUT=$3
HOSTS=${DIR}/conf/listhosts.txt
DATETIME=$(date +%Y%m%d%H%M)
LOGFILE=${DIR}/log/run-remote-file.log

# FUNCTIONS
function usage() {
	echo "Usage: $(basename $0) [push <path/file> <path/file>]" 
        echo "                          [extract <path/tar-file> <path>]"
        echo "                          [run <path/remote_script>]"
        echo "                          [delete <path/file_name>]"
        echo "                          [repo <file_name>  <path>]"
	exit 
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

function pushFile() {
# push a file into remote node

	FILE=${INPUT}
	OUTPUT=${OUTPUT}

	checkFile ${FILE}

        for HOST in $(cat ${HOSTS}); do
                scp -r ${FILE} ${HOST}:${OUTPUT} >> ${LOGFILE} 2>&1
		RESULT=$?
		if [ ${RESULT} -eq 0 ]; then
                	echo "Push ${FILE} to ${HOST}" | tee -a ${LOGFILE}
		else
                	echo "ERROR: Failed to push ${FILE} to ${HOST}" | tee -a ${LOGFILE}
		fi
        done
}

function runTar() {
# Run a script on a remote node
# Command to extract a tar file in the working directory 

	FILE=${INPUT}
	DIR=${OUTPUT}

	for HOST in $(cat ${HOSTS}); do
		ssh -tt ${HOST} "sudo tar xf ${FILE} -C ${DIR}"  >> ${LOGFILE} 2>&1
		RESULT=$?
		if [ ${RESULT} -eq 0 ]; then
			echo "Run tar extract ${FILE} on ${HOST}" | tee -a ${LOGFILE}
		else
			echo "ERROR: Failed to tar extract ${FILE} on ${HOST}" | tee -a ${LOGFILE}
		fi
	done 
}

function runScript() {
# Run a script on a remote node

	FILE=${INPUT}
	
	echo "Begin installing, this takes time"

        for HOST in $(cat ${HOSTS}); do
                ssh -tt ${HOST} "sudo ${FILE}" < /dev/null >> ${LOGFILE} 2>&1
		RESULT=$?
		if [ ${RESULT} -eq 0 ]; then
                	echo "Run ${FILE} on ${HOST}" | tee -a ${LOGFILE}
		else
                	echo "ERROR: Failed to run ${FILE} on ${HOST}" | tee -a ${LOGFILE}
		fi
        done
}

function deleteFile() {
# Run a script on a remote node
# Command to delete a file in the working directory 

	FILE=${INPUT}

	for HOST in $(cat ${HOSTS}); do
		ssh -tt ${HOST} "sudo rm -r ${FILE}" < /dev/null >> ${LOGFILE} 2>&1
		RESULT=$?
		if [ ${RESULT} -eq 0 ]; then
			echo "Delete ${FILE} on ${HOST}" | tee -a ${LOGFILE}
		else
                	echo "ERROR: Failed to remove ${FILE} on ${HOST}" | tee -a ${LOGFILE}
		fi
        done
}
function pushRepo() {
# push the repo file into the remote nodes

        PUSHFILE=${INPUT}
        PUSHDIR=${OUTPUT}
        checkFile ${HOME}/${PUSHFILE}

        for HOST in $(cat ${HOSTS}); do
                scp ${HOME}/${PUSHFILE} ${HOST}:/tmp/${PUSHFILE}  >> ${LOGFILE} 2>&1
                ssh -tt ${HOST} "sudo mv /tmp/${PUSHFILE} ${PUSHDIR}/${PUSHFILE}"  2>&1 >> ${LOGFILE}
                ssh -tt ${HOST} "sudo chown root:root ${PUSHDIR}/${PUSHFILE}" >> ${LOGFILE} 2>&1
                RESULT=$?
                if [ ${RESULT} -eq 0 ]; then
                        echo "Push ${PUSHFILE} to ${HOST}" | tee -a ${LOGFILE}
                else
                        echo "ERROR: Failed to push ${PUSHFILE} to ${HOST}" | tee -a ${LOGFILE}
                fi
        done
}

function runOption() {
# Case statement for options

	case "${OPTION}" in
		-h | --help)
			usage
			;;
  		push)
                        checkArg 3
                        pushFile
			;;
                extract)
                        checkArg 3
                        runTar
			;;
                run)
                        checkArg 2
                        runScript
			;;
                delete)
                        checkArg 2
                        deleteFile
			;;
                repo)
                        checkArg 3
                        pushRepo
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

# Run option
runOption

# Review log file
echo "Review log file at ${LOGFILE}"
