-- ============================================================
-- Тема: GROUP BY / HAVING на примере чеков (receipts)
-- Не проверено на реальной БД — прогони у себя и поправь при
-- расхождениях (особенно задачи 4 и 13, где формулировка
-- в задании допускает разное толкование)
-- ============================================================

-- Задача 1: добавить receipt_id (PK) и discount (по умолчанию 0)
alter table receipts add column receipt_id serial primary key;
alter table receipts add column discount decimal(10,2) default 0;

-- Задача 2: макс/мин/средняя цена, кол-во записей, общая выручка (одной строкой)
select
    max(product_price) as макс_цена,
    min(product_price) as мин_цена,
    round(avg(product_price), 1) as средняя_цена,
    count(*) as всего_покупок,
    sum(product_price * quantity) as общая_выручка
from receipts;

-- Задача 3: 3 чека с наименьшей выручкой
select
    receipt_number as номер_чека,
    sum(product_price * quantity) as выручка
from receipts
group by receipt_number
order by выручка asc
limit 3;

-- Задача 4: максимальное кол-во товара за раз по каждому чеку
-- Формулировка допускает два прочтения (ORDER BY по цене или по максимальному
-- количеству); здесь сортировка по максимальному количеству.
select
    receipt_number as номер_чека,
    round(max(quantity), 1) as макс_количество_за_раз
from receipts
group by receipt_number
order by макс_количество_за_раз asc;

-- Задача 5: сумма чека и сумма налога (18%) по всей таблице
select
    sum(product_price * quantity) as "Сумма чека",
    sum(product_price * quantity) * 0.18 as "Сумма налога"
from receipts;

-- Задача 6: добавление новых чеков + повтор задачи 5 по каждому чеку
-- с добавлением поля "всего товаров"
insert into receipts (receipt_date, receipt_number, product_name, product_price, quantity) values
('2024-01-19', 'CHK-006', 'Smartwatch', 299.00, 1),
('2024-01-19', 'CHK-007', 'Socks', 8.00, 3),
('2024-01-19', 'CHK-008', 'Tea', 9.50, 2),
('2024-01-19', 'CHK-009', 'Bookshelf', 220.00, 1),
('2024-01-19', 'CHK-010', 'Doll', 28.00, 2),
('2024-01-19', 'CHK-011', 'Bananas', 3.20, 5);

select
    receipt_number as номер_чека,
    sum(product_price * quantity) as "Сумма чека",
    sum(product_price * quantity) * 0.18 as "Сумма налога",
    sum(quantity) as всего_товаров
from receipts
group by receipt_number;

-- Задача 7: даты с выручкой > 2000 и < 3000
select
    receipt_date as дата,
    sum(product_price * quantity) as выручка
from receipts
group by receipt_date
having sum(product_price * quantity) > 2000 and sum(product_price * quantity) < 3000;

-- Задача 8: чеки, где куплено 5 и более товаров (по количеству штук)
select
    receipt_number as номер_чека,
    sum(quantity) as всего_товаров
from receipts
group by receipt_number
having sum(quantity) >= 5;

-- Задача 9: чеки, где максимальная цена товара выше 1000
select
    receipt_number as номер_чека,
    max(product_price) as максимальная_цена
from receipts
group by receipt_number
having max(product_price) > 1000;

-- Задача 10: номер чека и кол-во товаров, разброс цен > 5
select
    receipt_number as номер_чека,
    count(*) as количество_товаров,
    max(product_price) - min(product_price) as разброс_цен
from receipts
group by receipt_number
having max(product_price) - min(product_price) > 5;

-- Задача 11: чеки с более чем одной разновидностью товара
select
    receipt_number as номер_чека,
    count(distinct product_name) as видов_товара
from receipts
group by receipt_number
having count(distinct product_name) > 1;

-- Задача 12: чеки, где макс. цена > 7 и товаров в чеке больше 5
select
    receipt_number as номер_чека,
    max(product_price) as максимальная_цена
from receipts
group by receipt_number
having max(product_price) > 7 and sum(quantity) > 5;

-- Задача 13: коэффициент полезности (выручка / кол-во товаров) > 30
select
    receipt_number as номер_чека,
    sum(product_price * quantity) / sum(quantity) as коэффициент_полезности
from receipts
group by receipt_number
having sum(product_price * quantity) / sum(quantity) > 30;

-- Задача 14: номер чека и кол-во товаров, где макс. цена в 3+ раза больше мин. цены
select
    receipt_number as номер_чека,
    count(*) as количество_товаров
from receipts
group by receipt_number
having max(product_price) > 3 * min(product_price);
