-- Таблицы магазина для заданий 1 и 3: товары, покупатели, корзина, чеки, продажи
create table products (
    id serial primary key,
    name varchar(30),
    price decimal(8, 2),
    count int,
    sold int
);

create table customers (
    id serial primary key,
    login varchar(30)
);

create table cheque (
    id serial primary key,
    idcustomer int references customers(id),
    timedat timestamp,
    summ decimal(8, 2)
);

create table sales (
    id serial primary key,
    idcheque int references cheque(id),
    idproduct int references products(id),
    countsale int,
    delivered int
);

create table baskets (
    id serial primary key,
    idcustomer int references customers(id),
    idproduct int references products(id),
    basketcount int
);

insert into products (name, price, count, sold) values
('Laptop', 75000.00, 10, 2),
('iPhone', 85000.00, 15, 5),
('Keyboard', 7000.00, 25, 10);

insert into customers (login) values
('ivan123'),
('anna456'),
('petr789');

insert into cheque (idcustomer, timedat, summ) values
(1, current_timestamp, 75000.00),
(2, current_timestamp, 85000.00);

insert into sales (idcheque, idproduct, countsale, delivered) values
(1, 1, 1, 0),
(2, 2, 1, 1);

insert into baskets (idcustomer, idproduct, basketcount) values
(1, 2, 1),
(2, 3, 2),
(3, 1, 1);
