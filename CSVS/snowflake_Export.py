import snowflake.connector
import zipfile
import os
import csv
import warnings 

warnings.filterwarnings(
    action='ignore',
    category=UserWarning,
    module='snowflake.connector'
)

conn = snowflake.connector.connect(
    user = 'SRISAILAAS',
    password = 'Srisaila@14',
    account= 'szdekhr-jf39697',
    warehouse= 'COMPUTE_WH',
    database = 'CASESTUDY_WORKING',
    schema='PUBLIC'
)

cur = conn.cursor()
cur.execute("SHOW TABLES IN CASESTUDY_WORKING.PUBLIC")
tables = cur.fetchall()

for table in tables:
    table_name = table[1]
    output_file = f"{table_name}.csv"
    select_query = f"select * from {table_name}"
    cur.execute(select_query)
    result = cur.fetchall()
    column_names = [desc[0] for desc in cur.description]
    with open(output_file, mode='w', newline = '') as file:
        writer = csv.writer(file)
        writer.writerow(column_names)
        writer.writerows(result)
    
