#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: find_and_replace.sh
# Author: WKD
# Date: 1MAR18
# Purpose: This script runs a recursive find and replace for text 
# within a file. There is no back up made.

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

echo "Find and replace in current directory!"
echo "File pattern to look for? (eg '*.txt')"
read filepattern
echo "Existing string?"
read existing
echo "Replacement string?"
read replacement
echo "Replacing all occurences of $existing with $replacement in files matching $filepattern"

find . -type f -name $filepattern -print0 | xargs -0 sed -i '' -e "s/$existing/$replacement/g"
