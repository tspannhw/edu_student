#!/bin/sh

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.
#
# Title: setup-hdp-tls.sh
# Author:  WKD
# Date: 190410
# Purpose: Master script for running generate-tls.sh

# DEBUG
# set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
DIR=/tmp/hdp-tls

# FUNCTIONS
function usage() {
        echo "Usage: sudo $(basename $0)"
        exit 2
}

function checkRoot() {
# Testing for sudo access to root

        if [ "$EUID" -ne 0 ]; then
                echo "ERROR: This script must be run as root" 
                usage
        fi
}

function runCACert() {
# Run the certificate generator for local authority and for Ranger

	./generate-hdp-tls.sh GenerateCACert ./configs
}

function runKeystore() {
# Run the certificate generator for local authority and for Ranger

	./generate-hdp-tls.sh GenerateKeystore ./configs
}

function runTruststore() {
# Run the certificate generator for local authority and for Ranger

	./generate-hdp-tls.sh GenerateTruststore ./configs
}

function runJCEKS() {
# Run the certificate generator for local authority and for Ranger

	./generate-hdp-tls.sh GenerateJCEKS ./configs
}

function runKeyPair() {
# Run the certificate generator for local authority and for Ranger

	./generate-hdp-tls.sh GenerateKeyPair ./configs
}

function runRanger() {
# Run the certificate generator for local authority and for Ranger

	./generate-hdp-tls.sh GenerateRanger ./configs
}

# MAIN
checkRoot
cd ${DIR}

# Run
runCACert
runKeystore
runTruststore
runJCEKS
runKeyPair
runRanger
