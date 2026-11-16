-- ============================================================
-- Тема: JOIN / UNION — product/pc/laptop/printer
-- Проверено на реальной БД, результаты сверены вручную
-- ============================================================

-- Задача 1: производители ноутбуков с HDD >= 10 Гб и их скорости
select
    product.maker,
    laptop.speed
from product
join laptop on product.model = laptop.model
where hd >= 10;

-- Задача 2: модели и цены всех товаров производителя B (ПК + ноутбуки)
select pc.model, pc.price
from pc
join product p on p.model = pc.model
where maker = 'B'
union
select l.model, l.price
from laptop l
join product p on p.model = l.model
where maker = 'B'
order by price;

-- Задача 3: производители ПК с частотой процессора не менее 450 МГц
select distinct product.maker
from pc
join product on product.model = pc.model
where pc.speed >= 450
order by maker;

-- Задача 4: средняя скорость ПК производителя A
select round(avg(pc.speed), 4) as avg_speed
from pc
join product on pc.model = product.model
where maker = 'A';
