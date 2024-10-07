#Spark SQL on a CSV
from pyspark import SparkConf, SparkContext, SQLContext
sc = SparkContext.getOrCreate()
sqlCon = SQLContext(sc) # Pass the spark conext to an sql context and create a new one of those.
# SQL Context creates data frames and parse sql syntax into something spark can execute.
#Create a DataFrame from a CSV - column names from header and assumes data types
data = sqlCon.read.format("csv")\ # Uses the sql context to read a csv
    .option("header", "true")\ # Set options in the sql Context reader.
    .option("inferSchema", "true")\
    .load("mega city.csv")
#Create a named temp table for SQL to use 
data.registerTempTable("testData") # Registers "data" as a table named "testData" with the sqlContext
# sqlContext can now parse the sql and the table "testData" into spark commands
mySQL = sqlCon.sql("select * from testData where Patio > 300 order by Patio desc") 
mySQL.show(10)
