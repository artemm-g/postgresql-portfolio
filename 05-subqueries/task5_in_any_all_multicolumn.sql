-- ============================================================
-- Задача 5 (лабораторная по подзапросам):
-- по 1 запросу на IN, ANY, ALL и два многостолбцовых подзапроса.
-- База данных — прокат автомобилей из ЛР.5/6
-- (см. ../02-schema-design/car_rental_schema.sql)
-- ============================================================

-- 1) IN
-- Назначение: найти клиентов, у которых есть хотя бы одно
-- бронирование дороже 5000 (сравнение с набором значений
-- из подзапроса — ценами всех "дорогих" бронирований).
select Full_name
from Customer
where ID_Customer in (
    select ID_Customer from Booking where Rental_price > 5000
);

-- 2) ANY
-- Назначение: найти клиентов, у которых хотя бы одно бронирование
-- дороже хотя бы одного бронирования Toyota Camry (ID_Cars = 1).
-- ANY вернёт TRUE, если сравнение выполняется хотя бы для одного
-- значения из набора, полученного подзапросом.
select distinct Full_name
from Customer
where ID_Customer in (
    select ID_Customer
    from Booking
    where Rental_price > any (
        select Rental_price from Booking where ID_Cars = 1
    )
);

-- 3) ALL
-- Назначение: найти бронирования, которые дороже ВСЕХ бронирований
-- BMW X5 (ID_Cars = 2) — то есть дороже даже самого дорогого из них.
-- ALL вернёт TRUE только если сравнение верно для каждого значения
-- из набора подзапроса.
select *
from Booking
where Rental_price > all (
    select Rental_price from Booking where ID_Cars = 2
);

-- 4) Многостолбцовый подзапрос №1
-- Назначение: найти пары (клиент, автомобиль), по которым была
-- оплата картой — сравниваем сразу два столбца одновременно
-- через (ID_Customer, ID_Cars) IN (...).
select distinct ID_Customer, ID_Cars
from Booking
where (ID_Customer, ID_Cars) in (
    select b.ID_Customer, b.ID_Cars
    from Booking b
    join Receipt r on b.ID_Booking = r.ID_Booking
    where r.Payment_method = 'card'
);

-- 5) Многостолбцовый подзапрос №2
-- Назначение: найти модель и год выпуска автомобилей, у которых
-- есть хотя бы одно бронирование дороже 4000 — сравнение пары
-- (ID_Cars, Year_of_manufacture) с результатом подзапроса.
select Model, Year_of_manufacture
from Cars
where (ID_Cars, Year_of_manufacture) in (
    select c.ID_Cars, c.Year_of_manufacture
    from Cars c
    join Booking b on c.ID_Cars = b.ID_Cars
    where b.Rental_price > 4000
);
