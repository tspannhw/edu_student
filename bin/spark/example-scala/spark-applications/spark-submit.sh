
hdfs dfs -put $DEVSH/examples/example-data/people.json

# run Python application
spark-submit --master yarn  --deploy-mode cluster $DEVSH/examples/spark-applications/NameList.py people.json namelist/

spark-submit --conf spark.pyspark.python=/usr/bin/python2.7

spark-submit --properties-file=$DEVSH/examples/spark-applications/my-properties.conf