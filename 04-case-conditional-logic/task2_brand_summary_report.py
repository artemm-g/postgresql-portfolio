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
cursor.execute("""with brand_aggr as (
    select
        car_brand,
        sum(sold_num) as total_units_sold,
        round(avg(price), 2) as avg_price,
        round(avg(discount), 2) as avg_current_discount,
        round(avg(price * (1 - discount / 100.0)), 2) as avg_price_with_current_discount,
        round(sum(price * sold_num), 2) as total_sales_old_price
    from car_dealer_7
    group by car_brand
)
select
    car_brand as brand,
    total_units_sold,
    avg_price,
    avg_current_discount,
    avg_price_with_current_discount,
    case
        when total_units_sold > 50 then 17
        when total_units_sold > 30 then 7
        else 3
    end as new_discount_percent,
    round(avg_price * (1 -
        case
            when total_units_sold > 50 then 17
            when total_units_sold > 30 then 7
            else 3
        end / 100.0), 2) as avg_price_with_new_discount,
    total_sales_old_price,
    round(total_sales_old_price * (1 -
        case
            when total_units_sold > 50 then 17
            when total_units_sold > 30 then 7
            else 3
        end / 100.0), 2) as total_sales_new_price,
    round(total_sales_old_price - total_sales_old_price * (1 -
        case
            when total_units_sold > 50 then 17
            when total_units_sold > 30 then 7
            else 3
        end / 100.0), 2) as total_discount_amount
from brand_aggr
order by brand;""")

rows = cursor.fetchall()
for row in rows:
    print(row)

conn.close()
