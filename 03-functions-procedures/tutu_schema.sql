-- База tutu: таблица товаров для примеров функций
create database tutu;
\c tutu;

-- Тестовая таблица товаров
create table products (
    id serial primary key,
    name varchar(255),
    price decimal(10, 2)
);

insert into products (name, price) values
('Apple', 50.0),
('Orange', 70.0),
('Banana', 100.0);
