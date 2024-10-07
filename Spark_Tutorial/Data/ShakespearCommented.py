import sys, re
from pyspark import SparkConf, SparkContext
conf = SparkConf().setAppName('Word Counts') #Makes a spark configuration with a name
sc = SparkContext.getOrCreate(conf=conf) #Uses that config to make a spark context
#In a single step, Spark is reading the file, filtering, splitting up words, cleaning up data, and sorting
wordcounts = sc.textFile("shakespeare.txt") \
			   .filter(lambda line: len(line) > 0) \
			   .flatMap(lambda line: re.split('\W+', line)) \
			   .filter(lambda word: len(word) > 0) \
			   .map(lambda word:(word.lower(),1)) \
			   .reduceByKey(lambda t1, t2: t1 + t2) \
			   .map(lambda x: (x[1],x[0])) \
			   .sortByKey(ascending=False)\
			   .persist()

"""
wordcounts = sc.textFile("shakespeare.txt") \ # Loads in text file and turns it into an RDD
               .filter(lambda line: len(line) > 0) \ # Filter takes a function that returns T/F Only keeps True. Removes empty lines
			   .flatMap(lambda line: re.split('\W+', line)) \ # FlatMap runs "map" using the lambda and concatonates all the lists that are genrated
			   .filter(lambda word: len(word) > 0) \ # Filter Removes 0 length words. Maybe unnecessary
			   .map(lambda word:(word.lower(),1)) \ # Makes a list of ("word", 1) with each word lowercase
			   .reduceByKey(lambda t1, t2: t1 + t2) \ # Groups by the first element of the tuple and applies the reduce to the second	
			   .map(lambda x: (x[1],x[0])) \ # Inverts the order of the tuple
			   .sortByKey(ascending=False)\ # Sorts by First element of the tuple (count in this case)
			   .persist() #Persists the finished RDD into memory so that it can be queried later
"""
top5words = wordcounts.take(5) # Grabs the first 5 (counts, words)
print(top5words)

# '\W+' in the regular expression finds any series of charaters that are not a-z, A-Z, 0-9