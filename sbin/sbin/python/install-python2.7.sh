#!/bin/bash
#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: run-agents.sh
# Author: WKD
# Date: 1MAR18
# Purpose: This script restarts all of the ambari agents in the cluster.
# The hostname for the node must be in the listhosts.txt file.
# The root user is not required to run this script. Sudo is used
# for the remote commands.
# Command line
# bash -x -e ./python2.7.sh 2>&1 | tee install_python.log
# cat ./python2.7.sh

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
NUMARGS=$#
DIR=${HOME}
OPTION=$1
HOSTS=${DIR}/conf/listhosts.txt
DATETIME=$(date +%Y%m%d%H%M)
LOGFILE=${DIR}/log/run-agents.log

# FUNCTIONS
function usage() {
        echo "Usage: $(basename $0) [status|start|stop|restart]"
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

TMP_PATH=/tmp/tmp_install_python
# Versions section

PYTHON_MAJOR=2.7
PYTHON_VERSION=$PYTHON_MAJOR.10

rm -rf $TMP_PATH
mkdir -p $TMP_PATH
cd $TMP_PATH
# Update yum and libraries

yum -y update
yum groupinstall -y development
yum install -y zlib-devel openssl-devel sqlite-devel bzip2-devel
# Download and extract Python and Setuptools

wget --no-check-certificate https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz
wget --no-check-certificate https://bootstrap.pypa.io/ez_setup.py
wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py
tar -zxvf Python-$PYTHON_VERSION.tgz
# Compile Python

cd $TMP_PATH/Python-$PYTHON_VERSION
./configure --prefix=/usr/local
make && make altinstall
export PATH="/usr/local/bin:$PATH"
# Install Setuptools and PIP

cd $TMP_PATH
wget --no-check-certificate https://bootstrap.pypa.io/ez_setup.py
wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py
/usr/local/bin/python$PYTHON_MAJOR ez_setup.py
/usr/local/bin/python$PYTHON_MAJOR get-pip.py
# Finish installation

rm /usr/local/bin/python
ln -s /usr/local/bin/python2.7 /usr/local/bin/python
rm /usr/bin/pip
ln -s /usr/local/bin/pip /usr/bin/pip

pip install virtualenv
cd
rm -rf $TMP_PATH
