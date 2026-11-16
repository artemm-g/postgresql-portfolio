-- ============================================================
-- Тема: JOIN / UNION — БД интернет-магазина (store_schema.sql)
-- Таблицы: category, good, category_has_good, client, sale,
--          sale_has_good, source, status, sale_history
-- ============================================================

-- Задача 1: товары с их категориями (INNER JOIN), сортировка
-- по названию товара и категории
select category.name, g.name
from category
join category_has_good on category.id = category_has_good.category_id
join good g on category_has_good.good_id = g.id
order by category.name, g.name;

-- Задача 2: клиенты и количество их заказов со статусом 'new'
select c.first_name, c.last_name, count(s.id) as total_sale
from client c
join sale s on c.id = s.client_id
join status on status.id = s.status_id
where status.name = 'new'
group by c.first_name, c.last_name;

-- Задача 3: все товары с категориями, включая товары без категории
-- (LEFT JOIN — сохраняем все строки из good)
select good.name, category.name
from good
left join category_has_good on category_has_good.good_id = good.id
left join category on category.id = category_has_good.category_id;

-- Задача 4: полное соответствие товаров и категорий, включая
-- товары без категории и категории без товаров (FULL JOIN)
select category.name, good.name
from category
full join category_has_good on category_has_good.category_id = category.id
full join good on good.id = category_has_good.good_id;

-- Задача 5: источники клиентов и суммарный объём заказов по каждому,
-- включая источники без единого заказа
select source.name, sum(sale.sale_sum)
from source
left join client on source.id = client.source_id
left join sale on client.id = sale.client_id
group by source.name;

-- Задача 6: товары категории 'Cakes' ИЛИ товары из заказов
-- со статусом 'delivering' (UNION убирает дубликаты)
select good.name
from good
join category_has_good on category_has_good.good_id = good.id
join category on category.id = category_has_good.category_id
where category.name = 'Cakes'
union
select good.name
from good
join sale_has_good on sale_has_good.good_id = good.id
join sale on sale.id = sale_has_good.sale_id
join status on status.id = sale.status_id
where status.name = 'delivering';

-- Задача 7: категории и количество проданных единиц товара
-- (суммарно по всем заказам, любой статус)
select category.name, count(sale_has_good.good_id) as total_sale
from category
left join category_has_good on category.id = category_has_good.category_id
left join good on category_has_good.good_id = good.id
left join sale_has_good on good.id = sale_has_good.good_id
group by category.name;
