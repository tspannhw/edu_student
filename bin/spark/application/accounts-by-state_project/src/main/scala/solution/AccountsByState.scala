package solution

import org.apache.spark.sql.SparkSession

object AccountsByState {
  def main(args: Array[String]) {
    if (args.length < 1) {
      System.err.println("Usage: solution.AccountsByState <state-code>")
      System.exit(1)
    }
 
    val stateCode = args(0)
    
    val spark = SparkSession.builder.getOrCreate()
    spark.sparkContext.setLogLevel("WARN")

    val accountsDF = spark.read.table("devsh.accounts")
    val stateAccountsDF = accountsDF.where(accountsDF("state") === stateCode)
    stateAccountsDF.write.mode("overwrite").save("/devsh_loudacre/accounts_by_state/"+stateCode)

    spark.stop
  }
}

