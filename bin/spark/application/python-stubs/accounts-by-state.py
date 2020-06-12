# Python application stub
import sys

from pyspark.sql import SparkSession

if __name__ == "__main__":
  if len(sys.argv) < 2:
    print(sys.stderr, "Usage: accounts-by-state.py <state-code>")
    sys.exit()
    
  stateCode = sys.argv[1]

  print("TODO: Solution not yet implemented")
