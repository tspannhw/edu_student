# Creating Topics from the Command Line
kafka-topics --create --zookeeper zkhost1:2181,zkhost2:2181,zkhost3:2181  --replication-factor 3  --partitions 5  --topic device_status

# Displaying Topics from the Command Line
kafka-topics --list --zookeeper zkhost1:2181,zkhost2:2181,zkhost3:2181

# Running a Producer from the Command Line
kafka-console-producer --broker-list brokerhost1:9092,brokerhost2:9092  --topic device_status

# Writing File Contents to Topics Using the Command Line
cat alerts.txt | kafka-console-producer --broker-list brokerhost1:9092,brokerhost2:9092  --topic device_status