#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: merge-hdfs-data.sh
# Author: WKD
# Date: 1MAR18
# Purpose: Script to merge a large number of small files into a single
# HDFS data file. 
# Note: this can also be solved with Linux scripting and piping.
# hdfs dfs -text input/*fileName.txt | hdfs dfs -put - output/targetFilename.txt
# WARNING: This script is WIP

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
NUMARGS=$#
DIR=${HOME}
INPUT=$1
OUTPUT=$2
#QUEUE=Devl
JARFILE=/usr/hdp/current/hadoop-mapreduce/hadoop-streaming.jar
DATETIME=$(date +%Y%m%d%H%M)
LOGFILE=${DIR}/log/merge-hdfs-data.log

# FUNCTIONS
function usage() {
        echo "Usage: $(basename $0) [input_dir] [output_dir]"
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

function runMerge() {
# Create hdfs user working directory 

	sudo -u yarn yarn jar ${JARFILE} \
		-Dmapred.reduce.tasks=1 \
		#-Dmapred.job.queue.name=${QUEUE} \
		#-Dmapred.output.compress=true \ 
		#-Dmapred.output.compression.codec=org.apache.hadoop.io.compress.GzipCodec
		-input "${INPUTFILE}" \
		-output "${OUTPUT}" \
		-mapper cat \
		-reducer cat
}

function listOutput() {
# List hdfs users

	sudo -u hdfs hdfs dfs -ls ${OUTPUT} 
}

# MAIN
# Source functions
callInclude

# Run checks
checkSudo
checkArg 2

# Run 
runMerge
listOutput
