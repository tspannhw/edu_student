#!/bin/bash

###############################################
# RunOozieJob.sh
#
# Author: WKD
# Date: 6 Feb 2015
#
# Run oozie jobs.
################################################


# VARIABLES 
job=$1
wrkDir=/home/hdadmin/bin/oozie
hdfsDir=/user/hdadmin/oozie
OOZIE_URL=http://client01.invalid:11000/oozie

# FUNCTIONS
# usage()
#
usage() {
        echo "Useage: $(basename $0) [app]" 
        exit 1
}

# checkArgs() 
# Check arguments exits
checkArgs() {
    if [ "$numArgs" != "1" ]; then
        usage
    fi
}

# load()
# Refresh the oozie workflow on HDFS
loadJob() {
  if [ -f $wrkDir/$job/job.properties ]; then
	hdfs dfs -rm -r $hdfsDir/$job
	hdfs dfs -mkdir $hdfsDir/$job
	hdfs dfs -copyFromLocal $wrkDir/$job/* $hdfsDir/$job
	hdfs dfs -ls $hdfsDir/$job
  else
	echo "Did not find the property file for $job"
  fi
}

# runJob()
# Run the Oozie Workflow
runJob() {
  #oozie job -oozie http://client01.invalid:11000/oozie -config $wrkDir/$job/job.properties -run
  oozie job -config $wrkDir/$job/job.properties -run
}

# Main
#
checkArgs

echo "Running Oozie app: $job"
loadJob
runJob
echo
echo "Check status: oozie job -info [job_id]"
