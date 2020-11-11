#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: build-devl-env.sh
# Author: WKD  
# Date: 150212 
# Purpose: Admin script to setup Dev environment by downloading and installing
# various required packages. 
# Used to add gcc, curl, wget, ant, maven, and supporting libraries. 
# Ensure you check the version of Maven within this script.

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# CHANGES
# RFC-1274 Script Maintenance 

# VARIABLES
NUMARGS=$#
DIR=${HOME}
MAVENVER=apache-maven-3.0.5
DATETIME=$(date +%Y%m%d%H%M)
LOGDIR=${DIR}/log
LOGFILE=${LOGDIR}/build-devl-env.log

# FUNCTIONS
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

function installTools() {
# Install tools 
	sudo yum -y install vim 
	sudo yum -y install curl 
	sudo yum -y install wget
	sudo yum -y install zip unzip 
	sudo yum -y install bzip2 bzip2-devel
}

function installlibs() {
# Install libs 
	sudo yum -y install libxml2-devel
	sudo yum -y install libxsit-devel 
	sudo yum -y install libsqlite3-devel 
	sudo yum -y install libldap2-devel
}

function installDev() {
# Install dev tools
	sudo yum -y install gcc gcc-c++
	sudo yum -y install git
	sudo yum -y install ant
}

function installmaven() {
	cd /usr/share
	# Pull down the maven code
	sudo wget http://www.apache.org/dist/maven/binaries/$MAVENVER-bin.tar.gz

	# Extract maven
	sudo tar -zxvf $MAVENVER-bin.tar.gz

	# Create links
	sudo ln -s $MAVENVER maven

	# clean up
	sudo rm apache-maven-3.0.5-bin.tar.gz

	# add paths to .bashrc
    	echo -r "Do you want to modify hdadmin .bashrc for maven? (Y/N) " 
    	read ans
		if [ ans = "Y" -o ans = "y" ]; then
			echo export M2_DIR=/usr/local/maven >> ${HOME}/.bashrc
			echo export PATH=${PATH}:${M2_DIR}/bin >> ${HOME}/.bashrc
		fi

}

function installPython() {
# Install python tools
	sudo yum -y install python2.6-devel
	sudo yum -y install python-pip
}

function validateDevl() {
# Validate install

        echo
        echo "***POST BUILD INSTRUCTIONS"
        echo
        echo "1. Test you tools: curl, wget, zip, bzip2 ."
	echo "2. Test your dev tools: git, ant, gcc, maven."
        echo
}

# MAIN
# Source functions
callInclude

# Run install
installTools
installDev
[ mvn -v &> /dev/null ] || installmaven
installPython

# Next steps
validateDevl
