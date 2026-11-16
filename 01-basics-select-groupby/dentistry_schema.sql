-- Схема таблицы dentistry (стоматология)
create table dentistry (
    service_date date not null,
    service_category varchar(100) not null,
    service_name varchar(100) not null,
    service_price decimal(10, 2) not null,
    medication_name varchar(100),
    medication_cost decimal(10, 2)
);
