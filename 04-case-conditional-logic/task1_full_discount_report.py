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
cursor.execute("""select
    car_brand,
    model,
    sold_num as sold_units,
    price as price_usd,
    discount as current_discount_percent,
    round(price * (1 - discount / 100.0), 2) as price_with_current_discount,
    case
        when sold_num > 50 then 17
        when sold_num > 35 then 7
        else 3
    end as new_discount_percent,
    round(price * (1 -
        case
            when sold_num > 50 then 17
            when sold_num > 35 then 7
            else 3
        end / 100.0), 2) as price_with_new_discount,
    round(price * sold_num, 2) as total_sales_old_price,
    round((price * (1 -
        case
            when sold_num > 50 then 17
            when sold_num > 35 then 7
            else 3
        end / 100.0)) * sold_num, 2) as total_sales_new_price,
    round((price * sold_num) - ((price * (1 -
        case
            when sold_num > 50 then 17
            when sold_num > 35 then 7
            else 3
        end / 100.0)) * sold_num), 2) as total_discount_amount
from car_dealer_7
order by car_brand;
""")

rows = cursor.fetchall()
for row in rows:
    print(row)

conn.close()
