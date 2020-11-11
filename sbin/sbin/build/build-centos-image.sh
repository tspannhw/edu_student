#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: build-centos-image.sh
# Author: WKD 
# Date: 18 Aug 2017
# Purpose: This is a build script to create a baseline server.
# Run this script on a EC2 instance to create a baseline
# server, gold image, and then create an AMI baseline on AWS.
# Before running this script you must copy into the working directory 
# the build-centos.sh script, the bashrc, the bash_profile, and the 
# authorized_key file, ie the public key. 

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
NUMARGS=$#
DIR=${HOME}
WRKDIR=${DIR}
ADMIN_USER=$1
ADMIN_DIR=/home/${ADMIN_USER}
DATETIME=$(date +%Y%m%d%H%M)
LOGDIR=${DIR}/log
LOGFILE=${LOGDIR}/build-centos-image.log

# FUNCTIONS
function usage() {
# usage
	echo "Usage: sudo $(basename $0) [admin_user]"
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

function intro() {
# Intro remarks.
	echo "This script will build a baseline server.You must have a copy"
	echo "of the bash_profile, bashrc, and the authorized key located"
	echo -n "in /home/sysadmin. Continue"
	checkContinue
}

function setNTP() {
# Set the Network Time Protocol. This is important for inter node 
# communications. 
	echo "***Install and configure NTP"
	yum -y install ntp
	chkconfig ntpd on
	systemctl start ntpd
	
	# set ulimit to 10000
	ulimit -n 10000
}

function setIPTables() {
# Turn off Iptables firewall for Linux 7.
# You can restart this after the setup is complete. But it is typically
# left off.
	echo
	echo "***Turn off firewalld"
	systemctl stop firewalld 
	systemctl disable firewalld	
}

function setSELinux() {
# Disable SELinux, this is really required within our Hadoop cluster.
	echo
	echo "***Disable SELinux"
	setenforce 0
	sed 's/enforcing/disabled/' /etc/selinux/config > /tmp/selinux.tmp
	cp /tmp/selinux.tmp /etc/selinux/config
	rm /tmp/selinux.tmp
}

function installBind() {
# Install the bind utils for all servers
	echo
	echo "***Install bind"
	yum -y install bind bind-utils
}

function installCompression() {
# Run a script on the remote nodes
		echo
                echo "Install yum install compression"
                sudo yum -y install snappy snappy-devel
                sudo yum -y install lzo lzo-devel hadoop-lzo hadoop-lzo-native
}

function installJDK() {
# If you elect to install Open JDK then you will need to install the JDK 
# manually. In this environment we will use Oracle JDK and this will be 
# installed by Ambari
	echo
	echo "***Install OpenJDK"
	yum -y install java-1.8.0-openjdk
	yum -y install java-1.8.0-openjdk-devel
}

function updateYum() {
# Update packages and add additional packages as required. 
	echo
	echo "***Updating software with yum"
	yum -y install epel-release
	yum -y install vim wget
	yum -y update
}

function createAdmin() {
# Create the administrative user eduadmin. This is the primary administrator 
# for the cluster. Ensure access to root through sudo without a password.
	echo
	echo "***Create admin user ${ADMIN_USER}"
	groupadd -g 1500 ${ADMIN_USER}
	useradd -u 1500 -g 1500 -c "Edu Admin" -p "hadoop" ${ADMIN_USER}
	# This locks the password
	usermod -L ${ADMIN_USER}

	# Wheel group for sudo
	# This allows us to have sudo access with no password. This is an admin
	usermod -aG wheel ${ADMIN_USER}

	# environmental decision.
	sed -e '/NOPASSWD/s/# %wheel/%wheel/' /etc/sudoers > /tmp/sudoers.tmp
	cp /tmp/sudoers.tmp /etc/sudoers
	rm /tmp/sudoers.tmp
}

function setupAdmin() {
# Setup the admin user $admin
# This will only work if a copy of the bashrc and authorized_keys file are 
# located in /tmp.

	# setup bashrc
	if [ -f ${WRKDIR}/etc/bashrc ]; then
		cp ${WRKDIR}/etc/bash_profile ${ADMIN_DIR}/.bash_profile
		cp ${WRKDIR}/etc/bashrc ${ADMIN_DIR}/.bashrc
	fi

	# setup public keys access 
	if [ ! -d ${ADMIN_DIR}/.ssh ]; then
		mkdir ${ADMIN_DIR}/.ssh
		chmod 700 ${ADMIN_DIR}/.ssh
	fi

	# Allow access to the admin user from the local host
	# This may be a security consideration for your environment
	if [ -f ${WRKDIR}/certs/authorized_keys ]; then
		cp ${WRKDIR}/certs/authorized_keys ${ADMIN_DIR}/.ssh/authorized_keys
		chown -R ${ADMIN_USER}:${ADMIN_USER} ${ADMIN_DIR}/.ssh
		chmod 600 ${ADMIN_DIR}/.ssh/authorized_keys
	fi

	# Make standard directories
	mkdir ${ADMIN_DIR}/etc ${ADMIN_DIR}/sbin ${ADMIN_DIR}/log ${ADMIN_DIR}/tmp

	# change ownership
	chown -R ${ADMIN_USER}:${ADMIN_USER} ${ADMIN_DIR} 
}

function lockRoot() {
# Lock the root password, there should be no ssh access either. 
	echo
	echo "***Lock the root password"
	passwd --lock root
}

function cleanUp() {
# Cleanup the working directory
        rm  ${WRKDIR}/certs/authorized_keys
        rm  ${WRKDIR}/sbin/build-centos.sh
}

function validateAdmin() {
# Post the follow on instructions, primarily testing the success 
# of the build.
	echo
	echo "***POST BUILD INSTRUCTIONS"
	echo "1. Login to hdpadmin and test sudo."
	echo "2. Test with a reboot."
	echo "3. Build an AMI image."
}

function rebootServer() {
# Offer the choice to reboot the server.
	echo
	echo -n "Reboot?" 
	checkContinue
	reboot
}

# MAIN
# Source functions
callInclude

# Run checks
checkRoot
checkArgs 1
checkFile bashrc
checkFile authorized_keys

# Run setups
intro
setNTP
setIPTables
setSELinux

# Run installs
installBind
installCompression
installJDK
updateYum

# Run user
createAdmin
setupAdmin
lockRoot

# Validate 
cleanUp
validateAdmin
rebootServer
