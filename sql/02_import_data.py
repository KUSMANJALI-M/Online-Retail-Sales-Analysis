import pandas as pd
import sqlite3

df = pd.read_csv("D:\Ecommerce-Sales-Intelligence\data\cleaned_retail_data.csv")

conn = sqlite3.connect("retail_analytics.db")

df.to_sql("transactions",conn,index=False,if_exists="replace")

conn.close()

print("Database Created")

