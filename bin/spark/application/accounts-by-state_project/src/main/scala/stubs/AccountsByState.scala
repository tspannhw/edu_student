package stubs

import org.apache.spark.sql.SparkSession

object AccountsByState {
  def main(args: Array[String]) {
    if (args.length < 1) {
      System.err.println("Usage: stubs.AccountByState <state-code>")
      System.exit(1)
    }
 
    val stateCode = args(0)

    println("TODO: Solution not yet implemented")
    
  }
}

