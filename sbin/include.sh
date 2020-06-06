#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: include.sh
# Author: WKD  
# Date: 1MAR18
# Purpose: Provide a single location for all of the commonly called
# functions. This requires source ${DIR}/sbin/include.sh at
# the top of the MAIN for all scripts.

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
DIR=${HOME}
HOSTS=${DIR}/conf/listhosts.txt
LOGDIR=${DIR}/log
DATETIME=$(date +%Y%m%d%H%M)

# FUNCTIONS
function checkRoot() {
# Testing for root

        if [ "$(id -u)" != 0 ]; then
                echo "ERROR: This script must be run as user root" 1>&2
                usage
        fi
}

function checkSudo() {
# Testing for sudo access to root

        sudo ls /root > /dev/null 2>&1
	RESULT=$?
        if [ $RESULT -ne 0 ]; then
                echo "ERROR: You must have sudo to root to run this script"
                usage
        fi
}

function checkArg() {
# Check if arguments exits

        if [ ${NUMARGS} -ne "$1" ]; then
                usage 
        fi
}

function checkFile() {
# Check for a file

        FILE=$1
        if [ ! -f ${FILE} ]; then
                echo "ERROR: Input file ${FILE} not found"
                usage
        fi
}

function checkLogDir() {
# Check if the log dir exists if not make the log dir

	if [ ! -d "${LOGDIR}" ]; then
		mkdir ${LOGDIR}
	fi
}

function setupLog() {
# Check the existance of the log directory and setup the log file.

        checkLogDir

        echo "******LOG ENTRY FOR ${LOGFILE}******" >> ${LOGFILE}
        echo "" >> ${LOGFILE}
}

function yesno() {
	WORD=$1

        while :; do
                echo -n "${WORD}: (y/n) "
                read YESNO junk

                case ${YESNO} in
                        Y|y|YES|Yes|yes)
                                return 0
                        ;;
                        N|n|NO|No|no)
                                return 1
                        ;;
                        *)
                                echo "Enter y or n"
                        ;;
                esac
        done
}

function checkContinue() {
# Check if the program should continue or exit

        if ! yesno "Continue? "; then
                exit
        fi
}

function checkCorrect() {
# Check if answer is correct and then break from the loop

        if yesno "Correct? "; then
               break 
        fi
}

function pause() {
# A pause statement, used in troubleshooting

	echo -n "Press <ENTER> to continue: "
   	read junk
}

function interrupt() {
# Interrupt codes

        EXITCODE=$1

        echo -e "\nYou have terminated job-runner.sh."
        echo "MapReduces jobs will continue to run. If required"
	echo "use yarn or mapred to kill running jobs."

        exit ${EXITCODE}
}

function quit() {
# Prompt the user to exit the program.
# If they choose to exit, an exit code is provide in $1.

        code=$1
        exit $code
}

function validIP() {
# Test an IP address for validity:
# Usage: checkip IP_ADDRESS
#      if [[ $? -eq 0 ]]; then echo good; else echo bad; fi
#      if checkip IP_ADDRESS; then echo good; else echo bad; fi
#

	local  IP=$1
	local  STAT=1

	if [[ ${IP} =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        	OIFS=$IFS
        	IFS='.'
        	IP=($IP)
        	IFS=$OIFS
        	[[ ${IP[0]} -le 255 && ${IP[1]} -le 255 \
            		&& ${IP[2]} -le 255 && ${IP[3]} -le 255 ]]
        		STAT=$?
    	fi
    	return $stat
}

function checkIP() {
# Check if an IP is valid, use validIP function

        validIP ${INPUT1}
        if [ $? -eq 1 ]; then
                echo "ERROR: Incorrect IP address format"
                usage
        fi
}

function setTest() {
# Function for turning on shell script testing
	set -x
	
	set -o errexit #aka "set -e": exit if any line returns on-true value
	set -o nounset #aka "set -u": exit upon finding an unitialized variable

#	test -e /usr/local/share/domains || exit 0
#	test -x /usr/local/bin/domain-check || exit 0
}
