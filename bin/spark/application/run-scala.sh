cd $DEVSH/exercises/spark-application/accounts-by-state_project
mvn package
spark-submit --class stubs.AccountsByState target/accounts-by-state-1.0.jar CA

# For solution use 
# spark-submit --class solution.AccountsByState target/accounts-by-state-1.0.jar CA

hdfs dfs -ls /devsh_loudacre/accounts_by_state/CA/
hdfs dfs -get /devsh_loudacre/accounts_by_state/CA/ /tmp/accounts_CA
parquet-tools head /tmp/accounts_CA

spark-submit --class stubs.AccountsByState target/accounts-by-state-1.0.jar CA
spark-submit --name "Accounts by State 1" --class stubs.AccountsByState target/accounts-by-state-1.0.jar CA
spark-submit --name "Accounts by State 2" --conf spark.default.parallelism=4 --class stubs.AccountsByState target/accounts-by-state-1.0.jar CA
spark-submit --verbose --name "Accounts by State 3" --conf spark.default.parallelism=4 --class stubs.AccountsByState target/accounts-by-state-1.0.jar CA
