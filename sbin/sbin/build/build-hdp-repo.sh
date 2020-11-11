#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: build-hdp-repo.sh
# Author: WKD 
# Date: 18 Aug 2017
# Purpose: This is a build script to create the ambari and hdp repo
# on the admin server. This is a fragile script, you must get all of the
# versions correct to make this work. Check carefully against 
# Hortonworks docs. See Ambari install repo instructions for additional
# guidance.

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# CHANGES

# VARIABLES
NUMARGS=$#
DIR=${HOME}
WEBDIR=/var/www/html
AMBARIVER=2.5.1.0
HDPVER=2.6.2.0
HDPUTILVER=1.1.0.21
HDFVER=3.0.1.1
DATETIME=$(date +%Y%m%d%H%M)
LOGDIR=${DIR}/log
LOGFILE=${LOGDIR}/build-hdp-repo.log

# FUNCTIONS
function usage() {
        echo "Usage: $(basename $0) [install|add|delete|test]"
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

function installhttpd() {
# Install httpd 
	sudo yum -y install httpd
	sudo systemctl enable httpd.service
	sudo systemctl restart httpd.service
	echo "You can check the httpd server is running with"
	echo "http://<webserver>"
	echo -n "Did this work?"
	checkcontinue
}

function installyumutil() {
# Install yum utils for the repo
	sudo yum -y install yum-utils createrepo
	yum repolist
	echo "Use the repo list to validate your version numbers."
	echo -n "Are the yum repos for Ambari and HDP available?"
	checkcontinue
}

function repoFiles() {
# Install the repo files, again check the versions carefully. 
	# Yum repo file for Ambari
	sudo wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/${AMBARIVER}/ambari.repo -O /etc/yum.repos.d/ambari.repo

	# Yum repo file for HDP, this repo file also contains HDP-UTILS.
	sudo wget -nv http://public-repo-1.hortonworks.com/HDP/centos7/2.x/updates/${HDPVER}/hdp.repo -O /etc/yum.repos.d/HDP.repo

	# Yum repo file for HDF
	sudo wget -nv http://public-repo-1.hortonworks.com/HDF/centos7/3.x/updates/${HDFVER}/hdf.repo -O /etc/yum.repos.d/HDF.repo
}

function repoAmbari() {
# Create the repo for Ambari
	echo 
	echo "*** Install Repo for Ambari"

	sudo mkdir -p ${WEBDIR}/ambari/centos7
	cd ${WEBDIR}/ambari/centos7

	# Create repo for ambari
	sudo reposync -r ambari-${AMBARIVER}
	sudo createrepo ${WEBDIR}/ambari/centos7/ambari-${AMBARIVER}
}

function repoHDP() {
# Create the repo for HDP
	echo 
	echo "*** Install Repo for HDP"

	sudo mkdir -p ${WEBDIR}/hdp/centos7
	cd ${WEBDIR}/hdp/centos7

	# Create repo for hdp
	sudo reposync -r HDP-${HDPVER} 
	sudo createrepo ${WEBDIR}/hdp/centos7/HDP-${HDPVER}
}

function repoHDPUtils() {
# Create the repo for HDP
	echo 
	echo "*** Install Repo for HDP-UTIL"

	sudo mkdir -p ${WEBDIR}/hdp/centos7
	cd ${WEBDIR}/hdp/centos7

	# Create repo for hdp utilities
	sudo reposync -r HDP-UTILS-${HDPUTILVER}
	sudo createrepo ${WEBDIR}/hdp/centos7/HDP-UTILS-${HDPUTILVER}
}

function repoHDF() {
# Create the repo for HDF
	echo 
	echo "*** Install Repo for HDF"

	sudo mkdir -p ${WEBDIR}/hdf/centos7
	cd ${WEBDIR}/hdf/centos7

	sudo reposync -r HDF-${HDFVER} 
	sudo createrepo ${WEBDIR}/hdf/centos7/HDF-${HDFVER}
}
	
function repoTest() {
	echo
	echo "Open a browser and test access to all of the repos"
	echo "http://<webserver>/ambari/centos7/ambari-${AMBARIVER}/"
	echo "http://<webserver>/hdp/centos7/HDP-${HDPVER}/"
	echo "http://<webserver>/hdp/centos7/HDP-UTILS-${HDPUTILVER}/"
	echo "http://<webserver>/hdf/centos7/HDF-${HDFVER}/" 
}

function repoDelete() {
# Remove the Ambari, HDP, and HDF repos, this will allow you to reinstall
	echo -n "Do you want to remove the Ambari, HDP and HDF repos?"
	checkcontinue

	sudo rm -r ${WEBDIR}/Ambari ${WEBDIR}/hdp ${WEBDIR}/hdf

	sudo yum clean metadata

	sudo rm /etc/yum.repos.d/ambari.repo 
	sudo rm /etc/yum.repos.d/HDP.repo
	sudo rm /etc/yum.repos.d/HDF.repo
}

function runOption() {
# Case statement for install software and to add, delete, or test repos
        case "$option" in
                -h | --help)
                        usage
                        ;;
                install)
                        checkArgs 1
			installhttpd
			installyumutil
                        ;;
                add)
                        checkArgs 1
			repoFiles
			repoAmbari
			repoHDP
			repoHDPUtils
			repoHDF
                        ;;
                delete)
                        checkArgs 1
                        repoDelete
                        ;;
                test)
                        checkArgs 1
                        repoTest
                        ;;
                *)
                        usage
                        ;;
        esac
}

# MAIN
# Source functions
callInclude

# Run option
runOption
