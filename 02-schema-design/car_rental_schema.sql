-- ============================================================
-- Тема: Проектирование БД в 3НФ, PK/FK, CHECK, UNIQUE, DEFAULT
-- Предметная область: прокат автомобилей
-- Таблицы: Cars, Customer, Booking, Receipt
-- ============================================================

create database lr_5_6_rental;
\c lr_5_6_rental;

-- Автомобили
create table Cars (
    ID_Cars serial primary key,
    Model varchar(50) not null,
    Year_of_manufacture int not null,
    constraint min_year_of_manufacture check (Year_of_manufacture >= 2012 and Year_of_manufacture <= 2025)
);

-- Клиенты
create table Customer (
    ID_Customer serial primary key,
    Full_name varchar(50) not null,
    Phone_number varchar(20) unique not null,
    driving_experience int not null default 0,
    bank_card varchar(20) unique not null,
    constraint chk_driving_experience check (driving_experience >= 0),
    constraint chk_phone_length check (length(Phone_number) >= 5)
);

-- Бронирования — связывают клиента и авто
create table Booking (
    ID_Booking serial primary key,
    ID_Customer int,
    ID_Cars int,
    Rental_period int not null,
    Rental_price decimal(10,2) not null,
    Rental_date date not null default current_date,
    foreign key (ID_Customer) references Customer (ID_Customer) on delete cascade on update cascade,
    foreign key (ID_Cars) references Cars (ID_Cars) on delete cascade on update cascade,
    constraint min_max_rental_period check (Rental_period <= 360 and Rental_period >= 12)
);

-- Чеки — один чек на одно бронирование
create table Receipt (
    ID_Check serial primary key,
    ID_Booking int unique,
    Payment_method varchar(50) not null,
    Payment_date date not null default current_date,
    foreign key (ID_Booking) references Booking (ID_Booking) on update cascade on delete cascade
);

-- Заполнение данными
insert into Cars (Model, Year_of_manufacture) values
('Toyota Camry', 2022),
('BMW X5', 2023);

insert into Customer (Full_name, Phone_number, driving_experience, bank_card) values
('Ivanov Ivan Ivanovich', '+79161234567', 5, '1234567812345678'),
('Petrov Petr Petrovich', '+79169876543', 2, '8765432187654321');

insert into Booking (ID_Customer, ID_Cars, Rental_period, Rental_price, Rental_date) values
(1, 1, 30, 5000.00, '2024-01-10'),
(1, 2, 15, 8000.00, '2024-01-12'),
(2, 1, 20, 3000.00, '2024-01-15'),
(2, 2, 25, 6000.00, default);

insert into Receipt (ID_Booking, Payment_method, Payment_date) values
(1, 'card', '2024-01-10'),
(2, 'cash', '2024-01-12'),
(3, 'card', '2024-01-15'),
(4, 'transfer', '2024-01-16');
