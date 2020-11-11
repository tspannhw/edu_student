#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.
# Author: WKD
# Date: 190406
# Title: public-hostname.sh 
# Purpose: Display the public hostname 

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

STATUS=$(curl -s -m 5 -w "%{http_code}" http://169.254.169.254/latest/meta-data/public-ipv4 -o /dev/null)
if [ "$STATUS" == "200" ]; then
	curl -s -m 5 http://169.254.169.254/latest/meta-data/public-ipv4 
else
	dig +short myip.opendns.com @resolver1.opendns.com
fi
