import sys

from pyspark.sql import SparkSession

if __name__ == "__main__":
  if len(sys.argv) < 2:
    print >> sys.stderr, "Usage: accounts-by-state.py <state-code>"
    sys.exit()

  stateCode = sys.argv[1]

  spark = SparkSession.builder.getOrCreate()
  spark.sparkContext.setLogLevel("WARN")
  
  accountsDF = spark.read.table("devsh.accounts")
  stateAccountsDF = accountsDF.where(accountsDF.state == stateCode)
  stateAccountsDF.write.mode("overwrite").save("/devsh_loudacre/accounts_by_state/" + stateCode)

  spark.stop()