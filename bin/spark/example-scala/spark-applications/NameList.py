import sys
from pyspark.sql import SparkSession

if __name__ == "__main__":
  if len(sys.argv) < 3:
    print >> sys.stderr, "Usage: NameList.py <input-data-source> <output-data-source>"
    sys.exit()

  spark = SparkSession.builder.getOrCreate()
  spark.sparkContext.setLogLevel("WARN")

  peopleDF = spark.read.json(sys.argv[1])
  namesDF = peopleDF.select("firstName","lastName")
  namesDF.write.option("header","true").csv(sys.argv[2])

  spark.stop()

