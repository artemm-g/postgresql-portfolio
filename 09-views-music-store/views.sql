-- ============================================================
-- Тема: VIEW (представления)
-- Предметная область: музыкальный магазин Music (в духе Chinook)
-- Таблицы: customers, employees, sales, sales_items, artists,
--          albums, tracks, genres, media_types, playlists, playlist_track
--
-- Схема БД скачивается по ссылке из задания; её скрипт в этой папке не включён.
-- ============================================================

-- Задача 1: клиенты из Праги
create view view_FL_Prague as
select LastName, FirstName
from customers
where city = 'Prague';

-- Задача 2: клиенты, чьё имя начинается на M и содержит "ch"
create view view_FL_where_m_and_ch as
select LastName, FirstName
from customers
where FirstName like 'M%' and FirstName like '%ch%';

-- Задача 3: название и размер треков в мегабайтах
create view view_NameByte_forMB as
select Name, round(Bytes / 1024.0 / 1024.0, 2) as size_mb
from tracks;

-- Задача 4: сотрудники, нанятые в 2002 году, из Калгари
create view view_LF_YEAR_CITY as
select LastName, FirstName
from employees
where extract(year from HireDate) = 2002 and city = 'Calgary';

-- Задача 5: сотрудники в возрасте от 40 лет
create view view_empl_year40 as
select LastName, FirstName
from employees
where date_part('year', age(BirthDate)) >= 40;

-- Задача 6: клиенты, которых нет среди сотрудников — 3 способа

-- способ 1: подзапрос (NOT IN по email)
create view view_overgrown_task6 as
select firstname
from customers
where email not in (select email from employees);

-- способ 2: JOIN (LEFT JOIN + проверка на NULL по email)
create view view_join_task6 as
select c.FirstName
from customers c
left join employees e on c.Email = e.Email
where e.Email is null;

-- способ 3: логическое вычитание (EXCEPT по имени и фамилии)
create view view_logical_subtraction_task6 as
select firstname, lastname from customers
except
select firstname, lastname from employees;

-- Задача 7: количество треков в каждом альбоме — 2 способа

-- способ 1: подзапрос (скалярный COUNT в SELECT)
create view view_overgrown_task7 as
select title,
       (select count(*) from tracks where tracks.albumid = albums.albumid) as all_track
from albums
order by all_track;

-- способ 2: JOIN + GROUP BY
create view view_join_task7 as
select albums.title, count(tracks.albumID) as all_tracks
from albums
join tracks on tracks.albumID = albums.albumID
group by albums.title
order by all_tracks;

-- Задача 8: немецкие клиенты, заказавшие в 2009 году с доставкой в Берлин
create view view_join_task8 as
select customers.LastName, customers.FirstName
from customers
join sales on sales.customerid = customers.customerid
where customers.country = 'Germany'
  and extract(year from sales.salesdate) = 2009
  and sales.shipcity = 'Berlin';

-- Задача 9: клиенты, купившие более 30 треков — 2 способа

-- способ 1: подзапрос
create view view_task9_overgrown as
select lastname
from customers
where customerId in (
    select sales.customerID
    from sales
    join sales_items on sales_items.salesID = sales.salesID
    group by sales.CustomerID
    having count(sales_items.TrackId) >= 30
);

-- способ 2: JOIN + GROUP BY
create view view_task9_join as
select customers.LastName
from customers
join sales on sales.customerid = customers.customerid
join sales_items on sales_items.SalesId = sales.SalesId
group by customers.LastName
having count(sales_items.TrackId) >= 30;

-- Задача 10: средняя стоимость трека по каждому жанру
create view view_task10 as
select genres.name, round(avg(tracks.UnitPrice), 2) as avg_price_track
from genres
join tracks on genres.genreid = tracks.genreid
group by genres.name;

-- Задача 11: жанры со средней стоимостью трека от 1 рубля
create view view_task11 as
select genres.name
from genres
join tracks on genres.genreid = tracks.genreid
group by genres.name
having round(avg(tracks.UnitPrice), 2) >= 1.00;
