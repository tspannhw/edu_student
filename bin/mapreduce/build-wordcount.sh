#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.
# Author: WKD
# Date: 21MAR17
# Purpose: Script to build a wordcount jar file. First we compile using 
# javac and then we create a jar. The Java source files are located in
# src, the classes are located in bin, and the jar file in lib. 

# VARIABLES
numargs=$#
srcdir=${HOME}/src/java

# FUNCTIONS
function usage() {
# usage()
	echo "Useage: $(basename $0)" 1>&2
	exit 2
}

function checkargs() {
# Check arguments exits
        if [ $numargs -ne $1 ]; then
		echo "ERROR: Incorrect arugments"
                usage 
        fi
}

function checksrc() {
# Check src directory exits
        if [ ! -d $srcdir ]; then
		echo "ERROR: Incorrect source directory"
                usage 1>&2
        fi
}

function compilejava() {
# compile java source files in the source directory 
	sudo javac -d ${HOME}/bin -sourcepath $srcdir -cp $(hadoop classpath) $srcdir/lan/cloudair/*.java
}

function jarjava() {
# jar java classes in the bin directory to the lib directory 
	cd ${HOME}/bin
	sudo jar cvf ${HOME}/lib/wordcount.jar lan/cloudair/Word*
}

# MAIN
checkargs 0
checksrc
compilejava
jarjava
