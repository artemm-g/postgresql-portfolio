-- ============================================================
-- Тема: CASE / условная логика — запросы к car_dealer_7
-- ============================================================

-- Задача 1: полный расчёт по каждому автомобилю —
-- текущая скидка, новая скидка, суммы продаж со старой и новой скидкой
select
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

-- Задача 2: сводный отчёт по брендам (агрегация через CTE)
with brand_aggr as (
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
order by brand;

-- Задача 3: копия таблицы + новый столбец custom = sold_num * 3
create table car_dealer_second as
select *
from car_dealer_7;

alter table car_dealer_second
add column custom integer default 0;

update car_dealer_second
set custom = sold_num * 3;

select * from car_dealer_second;
