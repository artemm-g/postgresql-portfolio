-- ============================================================
-- Тема: GROUP BY / HAVING на примере учебной БД стоматологии
-- Таблица: dentistry (service_date, service_category,
--          service_name, service_price, medication_name, medication_cost)
-- ============================================================

-- Задание 1: 3 дня с наименьшей выручкой
select
    service_date as дата,
    sum(service_price) as выручка
from dentistry
group by service_date
order by выручка asc
limit 3;

-- Задание 2: максимальная цена услуги по каждому дню
select
    service_date as дата,
    max(service_price) as максимальная_цена
from dentistry
group by service_date
order by максимальная_цена asc;

-- Задание 3: сумма услуг за день + сумма налога (18%)
select
    service_date as дата,
    sum(service_price) as "сумма услуг за день",
    sum(service_price) * 0.18 as "сумма налога"
from dentistry
group by service_date;

-- Задание 4: добавление новых записей + повтор задания 3
-- с добавлением поля "всего услуг"
insert into dentistry (service_date, service_category, service_name, service_price, medication_name, medication_cost) values
('2024-01-22', 'Therapy', 'Filling', 120.00, 'Composite material', 25.00),
('2024-01-22', 'Hygiene', 'Professional Cleaning', 80.00, 'Polishing paste', 10.00),
('2024-01-23', 'Surgery', 'Tooth Extraction', 200.00, 'Anesthetic', 15.00),
('2024-01-23', 'Orthodontics', 'Consultation', 30.00, null, null),
('2024-01-24', 'Therapy', 'Caries Treatment', 150.00, 'Composite material', 25.00),
('2024-01-24', 'Hygiene', 'Whitening', 250.00, 'Whitening gel', 50.00);

select
    service_date as дата,
    sum(service_price) as "сумма услуг за день",
    sum(service_price) * 0.18 as "сумма налога",
    count(*) as "всего услуг"
from dentistry
group by service_date;

-- Задание 5: дни с выручкой от 2000 до 3000
select
    service_date as дата,
    sum(service_price) as выручка
from dentistry
group by service_date
having sum(service_price) between 2000 and 3000;

-- Задание 6: дни, где услуг меньше 5
select
    service_date as дата,
    count(*) as количество_услуг
from dentistry
group by service_date
having count(*) < 5;

-- Задание 7: дни, где максимальная цена услуги выше 1000
select
    service_date as дата,
    max(service_price) as максимальная_цена
from dentistry
group by service_date
having max(service_price) > 1000;

-- Задание 8: количество услуг + разброс цен (более 5) по дням
select
    service_date as дата,
    count(*) as количество_услуг,
    max(service_price) - min(service_price) as разброс_цен
from dentistry
group by service_date
having max(service_price) - min(service_price) > 5;

-- Задание 9: дни с более чем одной категорией услуг
select
    service_date as дата,
    count(distinct service_category) as количество_категорий
from dentistry
group by service_date
having count(distinct service_category) > 1;

-- Задание 10: дни, где макс. цена > 7 и услуг меньше 3
select
    service_date,
    max(service_price) as max_price
from dentistry
group by service_date
having max(service_price) > 7 and count(*) < 3;

-- Задание 11: дни с коэффициентом полезности (выручка/кол-во) > 30
select
    service_date as дата,
    sum(service_price) / count(*) as коэффициент_полезности
from dentistry
group by service_date
having sum(service_price) / count(*) > 30;

-- Задание 12: дни, где макс. цена превышает мин. цену более чем в 3 раза
select
    service_date,
    count(*) as total_services
from dentistry
group by service_date
having max(service_price) > 3 * min(service_price);
