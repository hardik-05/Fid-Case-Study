from pyspark import SparkConf, SparkContext, SQLContext
conf = SparkConf().setAppName('Word Counts') #Makes a spark configuration with a name
sc = SparkContext.getOrCreate(conf=conf) #Uses that config to make a spark context
sqlCon = SQLContext(sc) # SQL context that makes our fake db
myStates = "Alabama Alaska Arizona Arkansas California Colorado" # bogus data to play with

rdd = sc.parallelize(myStates.split(" ")) # Create our RDD by spliting the string on spaces and then Parallelizing it off to our cluster

# This is to make a data frame out of this data
from pyspark.sql import Row # import a row for a data frame 
rowData = rdd.map(lambda x: Row(StateName = x)) # map goes over each state and makes dataframe row with Column Name "StateName" value x
df = sqlCon.createDataFrame(rowData) # Combines all of those rows into a data frame

df.registerTempTable("tblStates") # This registers that datafame as a table in the sql context

# Run some sql. Only returns California due to case sensitivity
mySQL = sqlCon.sql("select StateName from tblStates where StateName like '%al%'") 
mySQL.show(10)