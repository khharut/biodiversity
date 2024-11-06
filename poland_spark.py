from pyspark.sql import SparkSession

spark = SparkSession.builder.master("local[*]").appName("biodiversity").getOrCreate()

occurence_df = spark.read.option("delimiter", ",").option("header", True).csv("occurence.csv")
occurence_df_pol = occurence_df.filter("countryCode = 'PL'")
multimedia_df = spark.read.option("delimiter", ",").option("header", True).csv("multimedia.csv")
final_df = occurence_df_pol.join(multimedia_df,multimedia_df["CoreId"]==occurence_df_pol["id"],how="left")
occur_pd_df = final_df.toPandas()
occur_pd_df.to_csv("poland_biodiversity.csv", index=False, sep=",")
