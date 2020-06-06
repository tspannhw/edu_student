val df =spark.read.format("csv").option("header", "true").load("/labs/data/dc-wikia-data.csv")
val df_new = df.select((col("page_id")),(col("name")),(col("urlslug")),(col("ID")),(col("ALIGN")),(col("EYE")),(col("HAIR")),(col("SEX")),(col("GSM")),(col("APPEARANCES")),(col("FIRST APPEARANCE").alias("FA")),
(col("YEAR"))) 
df_new.limit(2).show()
df_new.write.parquet("/labs/data/dc-wikia-data.parquet")
sys.exit
