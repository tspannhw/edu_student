cd $DEVSH/exercises/spark-application/
spark-submit python-stubs/accounts-by-state.py CA


spark-submit --name "Accounts by State 1" python-stubs/accounts-by-state.py CA
# Run solution
spark-submit --name "Accounts by State 1" python-solution/accounts-by-state.py CA

hdfs dfs -ls /devsh_loudacre/accounts_by_state/CA/
hdfs dfs -get /devsh_loudacre/accounts_by_state/CA/ /tmp/accounts_CA
parquet-tools head /tmp/accounts_CA

spark-submit --name "Accounts by State 2" --conf spark.default.parallelism=4 python-stubs/accounts-by-state.py CA
spark-submit --verbose --name "Accounts by State 3" --conf spark.default.parallelism=4 python-stubs/accounts-by-state.py CA

