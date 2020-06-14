# Cloudera Developer Training
# This script generates a simulated stream of Kafka messages 
# based on data from a set of files.
# Each line in the files is sent the the specified topic as a single
# message.
# 
# Parameters:
#     topic: the name of the Kafka topic to publish messages to
#     broker-list: a comma-separated list of Kafka brokers and ports
#       (e.g. host1:9092,host2:9092)
#     lines-per-second: how fast to generate messages
#     files: one or more files (e.g. datadirectory/*)


TOPIC=$1
BROKER_LIST=$2
LINES_PER_SECOND=$3
SOURCE_DIR=$4

SLEEP=`echo 1/$LINES_PER_SECOND | bc -l`
#echo DEBUG sleep for $SLEEP seconds between lines

echo "Topic: $TOPIC"
echo "Broker list: $BROKER_LIST"
echo "Lines per second: $LINES_PER_SECOND"
echo "Source directory: $SOURCE_DIR"
echo ""
echo "Is this correct? (y/n)"

read answer

if [[ $answer == "Y" || $answer == "y" ]]; then
  echo "Starting Kafka stream"
else 
  echo ""
  echo "Response: $answer. Exiting."
  exit
fi


# Loop through the list of files.
# Read each line of the each file, and send each line to stdout 
# (later to be piped to Kafka producer)

sendlines() {
  for f in $SOURCE_DIR/*; do
    >&2 echo ---- Reading file: $f

    # loop through each line from stdin
    # (stdin is redirected from file at end of loop: < $f)
    while read line; do

      # display info messages to stderr
      >&2 echo ---- Sending line --------------- $line

      # write current line to stdout
      echo $line
      
      # sleep for 1/lines-per-second seconds
      sleep $SLEEP

    done < $f
  done
}

# Pipe sendlines output to Kafka producer to generate Kafka messages

sendlines | kafka-console-producer --broker-list $BROKER_LIST --topic $TOPIC

