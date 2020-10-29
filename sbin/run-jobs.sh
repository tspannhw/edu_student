#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: run-jobs.sh
# Author: WKD  
# Date: 1MAR18
# Purpose: Provide MapReduce workload on the Hadoop cluster by running 
# a series of MR jobs in the background. This script is used to for 
# validation of YARN queues, YARN ACL's, and YARN default queue mappings.
# This tool is intended as a simple benchmark for fast comparision.
# This script sets the user and the job queue. This script runs one of 
# the following jobs [pi|wordcount|queue|container]. 
# For pi jobs adjust the number of loops, the number of mappers and 
# the number of calculations to increase stress on the cluster. 
# The time delay (sleep) between jobs should be adjusted to
# map to cluster resources and the configuration of
# the scheduler queues. 
#
# For wordcount set the number of loops, the input directory,
# and the output directory. When setting up for wordcount create a 
# hdfs://data/dirname directory and set the permissions to 777.
#
# For queue you may want to edit the function runqueuejob to adjust
# the number and location of the jobs.
#
# For container you will set the memory size for the mapper and for
# the reducer. Memory sizes must be in units of 1024, 2048, 3072, 4096,
# 5120, 6144, 7168, 8192, etc. A standard ratio is for the reducer memory
# to be twice that of the mapper.
#

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
NUMARGS=$#
DIR=${HOME}
PASSWORD=BadPass%1
JARFILE=/usr/hdp/current/hadoop-mapreduce-client/hadoop-mapreduce-examples.jar
DATETIME=$(date +%Y%m%d%H%M)
LOGFILE="${DIR}/log/run-jobs.log"

# FUNCTION
function usage() {
        echo "Usage: $(basename $0)" 1>&2
        exit 1
}

function callInclude() {
# Test for script and run functions

        if [ -f /var/local/sbin/include.sh ]; then
                source /var/local/sbin/include.sh
        else
                echo "ERROR: The file /var/local/sbin/include.sh not found."
                echo "This required file provides supporting functions."
		exit 1
        fi
}

function intro() {
	echo "Job Runner may be a long running script."
	echo "If required terminate this script with Ctrl-C "
	echo
	read -p "Set the type of job to run [pi|wordcount]: " OPTION
}

function setJobs() {
# Set job inputs

	read -p "Set name of job submitter: " USERNAME
        read -p "Set name of queue: " QUEUENAME
	echo "Memory: 1024, 2048, 3072, 4096, 6144, 8192, 10240, 12288" 
        read -p "Set mapper memory: " MAPRAM 
        read -p "Set reducer memory: " REDRAM 
	echo "Vcore: 1, 2, 3, 4"
        read -p "Set vcore: " VCORE 
        read -p "Set number of job loops: " LOOPS
        read -p "Set seconds between jobs: " TIMELAG
}

function setKinit() {

	if  yesno "Does this user need to kinit? " ; then
		sudo -H -u ${USERNAME} bash -c "echo ${PASSWORD} | kinit ${USERNAME}/EDU"
	fi
}

function setPiJobs() {
        read -p "Set number of mappers: " MAPPERS
        read -p "Set number of pi calculations: " CALCS
}

function runPiJobs() {
# Run the pi job in a loop

        for ((i=1;i <= ${LOOPS}; i++)) ; do
                echo
                echo "Starting cycle $i of ${LOOPS} at $(date +"%T")"
                echo >> ${LOGFILE}
                echo "****Cycle $i of ${LOOPS} at $(date +"%T")" >> ${LOGFILE}
		sudo -u ${USERNAME} nohup yarn jar ${JARFILE} pi -D mapreduce.job.queuename=${QUEUENAME} -D mapreduce.map.memory.mb=${MAPRAM} -D mapreduce.reduce.memory.mb=${REDRAM} -D yarn.scheduler.maximum-allocation-vcores=${VCORES} ${MAPPERS} ${CALCS} >> ${LOGFILE} 2>&1 &
                sleep ${TIMELAG}
		echo ${TIMELAG} seconds
        done
}

function setWordJobs() {
# Set job inputs

	read -p "Set input directory: " INPUTDIR 
	read -p "Set output directory: " OUTPUTDIR
}

function runWordJobs() {
# Run wordcount jobs	

	for ((i=1;i <= ${LOOPS};i++)) ; do
		echo
        	echo "Starting cycle $i of ${LOOPS} at $(date +"%T")"
        	echo >> ${LOGFILE}
        
		sudo -u ${USERNAME} nohup yarn jar ${JARFILE} wordcount -D mapreduce.job.queuename=${QUEUENAME} -D mapreduce.map.memory.mb=${MAPRAM} -D mapreduce.reduce.memory.mb=${REDRAM} -D yarn.scheduler.maximum-allocation-vcores=${VCORES} ${INPUTDIR} ${OUTPUTDIR}$i >> ${LOGFILE} 2>&1 &
		PID=$!
		echo pid equals $PID
		sleep ${TIMELAG}
	done
}

function cleanOutDir() {
# Remove the output directories	

	for ((i=1;i <= ${LOOPS};i++)) ; do
        	echo "Deleting the output directory $i"
        	echo "****Deleting output directory $i" >> ${LOGFILE}
		wait $PID
		sudo -u ${USERNAME} hdfs dfs -rm -r -skipTrash /user/${USERNAME}/${OUTPUTDIR}$i >> ${LOGFILE} 2>&1
	done
}

function runOption() {
# Case statement for run jobs

        case "${OPTION}" in
                -h | --help)
                        usage
                        ;;
                pi)
			setJobs
			setKinit
			setPiJobs
			runPiJobs
                        ;;
                wordcount)
			setJobs
			setKinit
			setWordJobs
			cleanOutDir
			runWordJobs
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
trap "interrupt 1" 1 2 3 15
intro
runOption
