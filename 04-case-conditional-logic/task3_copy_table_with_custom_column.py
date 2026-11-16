import os
import psycopg2
from dotenv import load_dotenv

load_dotenv()

conn = psycopg2.connect(
    host=os.getenv('DB_HOST'),
    user=os.getenv('DB_USER'),
    password=os.getenv('DB_PASSWORD'),
    dbname=os.getenv('DB_NAME'),
    port=os.getenv('DB_PORT')
)
cursor = conn.cursor()
cursor.execute("""
create table car_dealer_second as
select *
from car_dealer_7;

alter table car_dealer_second
add column custom integer default 0;

update car_dealer_second
set custom = sold_num * 3;
""")
conn.commit()

cursor.execute("SELECT * FROM car_dealer_second;")
rows = cursor.fetchall()
for row in rows:
    print(row)

conn.close()
