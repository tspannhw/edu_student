package example

import org.apache.spark.sql.SparkSession

object NameList {
  def main(args: Array[String]) {
    if (args.length < 2) {
      System.err.println("Usage: example.NameList <input-data-source> <output-data-source>")
      System.exit(1)
    }

    val spark = SparkSession.builder.getOrCreate()
    spark.sparkContext.setLogLevel("WARN")

    val peopleDF = spark.read.json(args(0))
    val namesDF = peopleDF.select("firstName","lastName")
    namesDF.write.option("header","true").csv(args(1))

    spark.stop()
  }
}

