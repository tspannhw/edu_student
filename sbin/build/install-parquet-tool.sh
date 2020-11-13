#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: install_parquet-tool.sh
# Author: WKD 
# Date: 180318 
# Purpose: Install the parquet tool.

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# CHANGES
# RFC-1274 Script Maintenance

# VARIABLES
DIR=${HOME}
DATETIME=$(date +%Y%m%d%H%M)
LOGDIR=${DIR}/log
LOGFILE=${LOGDIR}/build-ssh-keypairs.log

# FUNCTIONS
function usage() {
        echo "Usage: $(basename $0)" 
        exit 1
}

function callInclude() {
# Test for script and run functions

        if [ -f ${DIR}/sbin/include.sh ]; then
                source ${DIR}/sbin/include.sh
        else
                echo "ERROR: The file ${DIR}/sbin/functions not found."
                echo "This required file provides supporting functions."
		exit 1
        fi
}

function downloadParquet() {
# Download the parquet-tools
	cd /usr/lib
	sudo wget http://mirror.nbtelecom.com.br/apache/maven/maven-3/3.5.0/binaries/apache-maven-3.5.0-bin.tar.gz
}

function installParquet() {
# Compile parquet-tools

	cd /usr/lib
	sudo tar zxvf apache-maven-3.5.0-bin.tar.gz
	sudo yum install -y git java-devel
	sudo git clone https://github.com/Parquet/parquet-mr.git
	cd parquet-mr/parquet-tools/
	sudo sed  -i 's/1.6.0rc3-SNAPSHOT/1.6.0/g' pom.xml
	sudo ~/apache-maven-3.5.0/bin/mvn clean package -Plocal
	sudo java -jar target/parquet-tools-1.6.0.jar schema ~/000000_0
}

# MAIN
# Source functions
callInclude

# Run build
createSSHKey
