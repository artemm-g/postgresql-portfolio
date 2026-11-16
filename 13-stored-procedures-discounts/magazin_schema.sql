-- ============================================================
-- Тема: хранимые процедуры с бизнес-логикой (расчёт скидок)
-- Предметная область: магазин продуктов
-- ============================================================

create database magazin;
\c magazin;

create table categories (
    id_cat serial primary key,
    name varchar(255)
);

create table products (
    id serial primary key,
    name_pr varchar(255),
    ed_izmer varchar(255),
    cena int,
    quantity int,
    nds int,
    id_cat_pr int,
    foreign key (id_cat_pr) references categories(id_cat)
);

create table sales (
    id_sale serial primary key,
    date_sales date,
    id_pr int,
    quantity_sales int,
    foreign key (id_pr) references products(id)
);

insert into categories (name) values
('Молочные'),
('Мукомольные');

insert into products (name_pr, ed_izmer, cena, quantity, nds, id_cat_pr) values
('Молоко', 'литр', 100, 50, 10, 1),
('Творог', 'грамм', 120, 25, 18, 1),
('Мука в/сорт', 'килограмм', 80, 100, 10, 2),
('Мука п/сорт', 'килограмм', 90, 90, 10, 2);

insert into sales (date_sales, quantity_sales, id_pr) values
('2022-04-01', 5, 1),
('2022-04-01', 5, 2),
('2022-04-01', 8, 3),
('2022-04-01', 2, 1),
('2022-04-05', 15, 4),
('2022-04-05', 5, 3);
