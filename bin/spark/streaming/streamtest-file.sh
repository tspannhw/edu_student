# Cloudera Developer Training
# This script simulates streaming data by copying a set of files into a target directory, one file per second

# Parameters:
#     source-directory: directory containing the files to copy
#     destination-directory: directory into which data should be copied (if directory does not exist, script will create it)
#.....sleep-seconds (optional): number of seconds to sleep between files copied
#.    (if not specified, default is one second)
SOURCEDIR=$1
DESTDIR=$2
SLEEPTIME=$3

if [ -z $SOURCEDIR ] || [ -z $DESTDIR ]
then
  echo "Usage: `basename $0` <source-directory> <destination-directory> [sleep-seconds]"
  exit $E_BADARGS
fi

if [ -z $SLEEPTIME ]
then
  echo "Using default one-second sleep time"
  SLEEPTIME=1
fi

# Source directory must exist

# Directory must exist
if [ ! -d $SOURCEDIR ]
then
  echo "$SOURCEDIR is not a directory"
  exit $E_BADARGS
fi

if [ ! -d $DESTDIR ]
then
  echo "Creating destination directory $DESTDIR"
  mkdir -p $DESTDIR
fi

# Directory must be empty (no *.COMPLETED files from prior run)
if [ "$(ls $DESTDIR)" ]; then
  echo "$DESTDIR exists and is not empty. Delete existing files and continue? (y/n)"
  read RESPONSE
  if [[ $RESPONSE == "Y" || $RESPONSE == "y" ]]; then
    rm -rf $DESTDIR/*
  else
    echo "Exiting."
    exit 1
  fi
fi

echo "Copying files from $SOURCEDIR to $DESTDIR"
for f in $SOURCEDIR/*
do
  echo "Copying file: $f at `date`"
  cp $f $DESTDIR
  sleep $SLEEPTIME
done

echo "All files copied"
exit 0