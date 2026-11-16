-- ============================================================
-- Тема: материализованные представления, работа из Python
-- Вариант 1: доставщики, доставки, товары в доставках
-- ============================================================

create table if not exists deliveryman (
    id_man serial primary key,
    phone varchar(40),
    tariff_of_gramm integer
);

create table if not exists delivery (
    id_delivery serial primary key,
    date_d date,
    id_man integer,
    foreign key (id_man) references deliveryman(id_man)
);

create table if not exists delivery_position (
    id_del_pos serial primary key,
    tovar varchar(40),
    tovar_weight integer,
    address varchar(100),
    id_delivery integer,
    foreign key (id_delivery) references delivery(id_delivery)
);

insert into deliveryman (phone, tariff_of_gramm) values
('89255252535', 5),
('89771224139', 4),
('89655587269', 3);

insert into delivery (date_d, id_man) values
('2026-10-15', 1),
('2026-03-24', 2),
('2025-12-19', 1);

insert into delivery_position (tovar, tovar_weight, address, id_delivery) values
('Огурчики', 500, 'Москва', 1),
('Помидорки', 400, 'Питер', 2),
('Капуста', 400, 'Новгород', 1);
