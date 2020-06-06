#!/bin/bash

# Hortonworks University
# This script is for training purposes only and is to be used only
# in support of approved Hortonworks University exercises. Hortonworks
# assumes no liability for use outside of our training environments.
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Name: setup-blueprints.sh
# Author: WKD
# Date: 26NOV18
# Purpose: 

# VARIABLES
NUMARGS=$#
DIR=${HOME}
OPTION=$1
VERSION=$2
AMBARI_URL=http://admin01.cloudair.lan:8080
AMBARI_USER=admin
AMBARI_PASSWORD=admin
CLUSTER_NAME=cloudair
BLUEPRINT=multi-hdp${VERSION}
BLUEPRINT_FILE=blueprint-multi-hdp${VERSION}.json
HOSTMAP_FILE=hostmap-multi-hdp${VERSION}.json
DATETIME=$(date +%Y%m%d%H%M)
LOGDIR=${DIR}/log
LOGFILE=${LOGDIR}/run-blueprint.log

# FUNCTIONS
function usage() {
        echo "Usage: $(basename $0) [ all|check|delete|export|register|install|status] [2.6|3.1]"
        exit
}

function callInclude() {
# Test for script and run functions

        if [ -f ${DIR}/sbin/include.sh ]; then
                source ${DIR}/sbin/include.sh
        else
                echo "ERROR: The file ${DIR}/sbin/include not found."
                echo "This required file provides supporting functions."
        fi
}

function checkBlueprint() {
	curl -i -u ${AMBARI_USER}:${AMBARI_PASSWORD} -H "X-Requested-By: ambari" -X GET ${AMBARI_URL}/api/v1/blueprints/${BLUEPRINT}
}

function exportBlueprint() {
	curl -i -u ${AMBARI_USER}:${AMBARI_PASSWORD} -H "X-Requested-By: ubuntu" -X GET ${AMBARI_URL}/api/v1/clusters/${CLUSTER_NAME}?format=blueprint -o ${BLUEPRINT}.blueprint 
}

function registerBlueprint() {
	curl -i -u ${AMBARI_USER}:${AMBARI_PASSWORD} -H "X-Requested-By: ambari" -d @${DIR}/conf/${BLUEPRINT_FILE} -X POST ${AMBARI_URL}/api/v1/blueprints/${BLUEPRINT} 
}

function deleteBlueprint() {
	curl -i -u ${AMBARI_USER}:${AMBARI_PASSWORD} -H "X-Requested-By: ambari" -X DELETE ${AMBARI_URL}/api/v1/blueprints/${BLUEPRINT}
}

function installCluster() {
	curl -i -u ${AMBARI_USER}:${AMBARI_PASSWORD} -H "X-Requested-By: ambari" -d @${DIR}/conf/${HOSTMAP_FILE} -X POST ${AMBARI_URL}/api/v1/clusters/${CLUSTER_NAME}
}

function statusInstall() {
	curl -i -u ${AMBARI_USER}:${AMBARI_PASSWORD} -H "X-Requested-By: ambari" -X GET ${AMBARI_URL}/api/v1/clusters/${CLUSTER_NAME}
}

function runAll() {
	registerBlueprint
	installCluster
	statusInstall
}

function runOption() {
# Case statement

        case "${OPTION}" in
                -h | --help)
                        usage
                        ;;
                all)
                        runAll
                        ;;
                check)
                       	checkBlueprint
                        ;;
                delete)
                       	deleteBlueprint 
                        ;;
                export)
                        exportBlueprint
                        ;;
                register)
                        registerBlueprint
                        ;;
                install)
                        installCluster
                        ;;
                status)
                        statusInstall
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
checkArg 2
checkSudo

# Run option
runOption
