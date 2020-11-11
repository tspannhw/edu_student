#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: build-postgresql.sh
# Author: WKD 
# Date: 170824
# Purpose: This is a build script to create the PostgreSQL server.
# This script must be run on the client hosting the PostgreSQL server.
# This script will install and configure PostgreSQL, but it is dependent
# upon a number of configuration files being posted into the ~/etc
# directory. Check for these files and their configurations prior to
# running this script. 
#
# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# CHANGES
# RFC-1274 Script Maintenance

# VARIABLES
NUMARGS=$#
DIR=/home/sysadmin
CONF=${DIR}/conf
OPTION=$1
PASSWORD=$2
DATETIME=$(date +%Y%m%d%H%M)
LOGFILE=${DIR}/log/build-postgresql.log

# FUNCTIONS
function usage() {
        echo "Usage: $(basename $0) [build] [password]" 
        echo " 			    [delete]" 
        echo " 			    [jdbc]"
        exit 
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
        FILE=$1
        if [ ! -f ${FILE} ]; then
                echo "ERROR: Input file ${FILE} not found"
                usage
        fi
}

function installPostgreSQL() {
# Install and configure postgreSQL
	echo "*** Install PostgreSQL"
	# Install the client
	sudo yum -y install postgresql-contrib

	# Install the server
	sudo yum -y install postgresql-server
}
	 
function initPostgreSQL() {
# Initialize postgre
	echo
	echo "*** Initialize PostgreSQL"

	sudo postgresql-setup initdb
	sudo systemctl enable postgresql
	sudo systemctl start postgresql
}

function configPostgreSQL() {
# Setup users access for PostgreSQL. 
        echo
        echo "***Create PostgresSQL"

	# This changes the authentication to a md5 encrypted password
	if [ -f ${CONF}/pg_hba.conf ]; then
		sudo cp ${CONF}/pg_hba.conf /var/lib/pgsql/data
		sudo chown postgres:postgres /var/lib/pgsql/data/pg_hba.conf
	fi

	# This opens the listener to all hosts
	if [ -f ${CONF}/postgresql.conf ]; then
		sudo cp ${CONF}/postgresql.conf /var/lib/pgsql/data
		sudo chown postgres:postgres /var/lib/pgsql/data/postgresql.conf
	fi
}

function createPostgreSQL() {
# Setup users access for PostgreSQL. 

	# Setup the postgres Linux user and database user
	sudo echo -e ${PASSWORD}\n${PASSWORD} | passwd postgres
	sudo -u postgres psql -U postgres -d postgres -c "ALTER USER  postgres WITH PASSWORD '${PASSWORD}';"
}	 

function restartPostgreSQL() {
# restart postgres
	sudo systemctl stop postgresql
	sudo systemctl start postgresql
}

function postInstructions() {
# Post instructions
	echo
	echo "*** Post Instructions ***"
	echo "On the Ambari server run the setup for the jdbc:"
        echo " $(basename $0) [jdbc]" 
	echo
}

function deletePostgreSQL() {
# These are to be run from the command line to uninstall postgres
	echo
	echo "*** Remove PostgreSQL"

	sudo systemctrl stop postgres
	sudo yum -y remove postgresql*
	sudo userdel -r postgres
}

function installJDBC() {
	echo "***Install PostgreSQL JDBC"
	sudo yum -y install postgresql-jdbc*
	sudo chmod 644 /usr/share/java/postgresql-jdbc.jar
	sudo ls -l /usr/share/java/postgresql-jdbc.jar
	sudo ambari-server setup --jdbc-db=postgres --jdbc-driver=/usr/share/java/postgresql-jdbc.jar
}

function runOption() {
# Case statement for add or delete user
        case "${OPTION}" in
                -h | --help)
                        usage
                        ;;
                build)
                        checkArg 2
			checkFile $CONF/postgresql.conf 
			checkFile $CONF/pg_hba.conf
			installPostgreSQL
			initPostgreSQL
			configPostgreSQL
			createPostgreSQL
			restartPostgreSQL
			postInstructions
                        ;;
                delete)
                        checkArg 1
			deletePostgreSQL
                        ;;
                jdbc)
                        checkArg 1
			installJDBC
                        ;;
                *)
                        usage
                        ;;
        esac
}
# MAIN
# Run checks
checkSudo

# Run
runOption 
