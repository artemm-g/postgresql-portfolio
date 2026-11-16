-- ============================================================
-- Тема: подзапросы — musicstore
-- ============================================================

-- Задача 1: жанры, где суммарные продажи <= 43
select
    genre,
    sum(sold_num) as total_sold
from musicstore
group by genre
having sum(sold_num) <= 43;

-- Задача 2: треки дороже самой маленькой из максимальных цен по жанрам
select
    genre,
    track_title,
    price,
    price * 0.9 as price_with_discount
from musicstore
where price > (
    select min(max_price)
    from (
        select max(price) as max_price
        from musicstore
        group by genre
    ) as genre_max_prices
);

-- Задача 3: треки, где продажи выше самой маленькой из минимальных продаж по трекам
select
    track_title,
    price,
    price * 0.85 as price_with_discount
from musicstore
where sold_num > (
    select min(min_sold)
    from (
        select min(sold_num) as min_sold
        from musicstore
        group by track_title
    ) as track_min_sales
);

-- Задача 4: сколько докупить каждого трека, чтобы сравнять с максимумом по магазину
select
    genre,
    track_title,
    price,
    sold_num,
    (select max(sold_num) from musicstore) - sold_num as "Закупка"
from musicstore;

-- Задача 5: см. отдельный файл task5_in_any_all_multicolumn.sql
