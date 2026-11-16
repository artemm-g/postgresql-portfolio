-- База shop: товары, заказы, журнал администратора
create database shop;
\c shop;

create table products (
    id serial primary key,
    name varchar(255),
    price decimal(10, 2)
);

create table orders (
    id serial primary key,
    id_product int references products(id),
    id_customer int
);

create table admin_log (
    id serial primary key,
    date timestamp,
    operation varchar(255),
    tablee varchar(255)
);

insert into products (name, price) values
('Apple', 50.00),
('Orange', 30.00);
