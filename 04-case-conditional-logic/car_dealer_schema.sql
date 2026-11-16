-- ============================================================
-- Тема: CASE / условная логика
-- Предметная область: автосалон (скидки по объёму продаж)
-- ============================================================

create table car_dealer_7 (
    car_brand varchar(50) not null,
    model varchar(50) not null,
    price decimal(8, 2) not null,
    sold_num integer not null
);

insert into car_dealer_7 (car_brand, model, price, sold_num) values
('Toyota', 'Camry', 25000.00, 50),
('Honda', 'Civic', 23000.00, 45),
('Ford', 'Mustang', 35000.00, 55),
('Tesla', 'Model S', 80000.00, 60),
('Chevrolet', 'Corvette', 65000.00, 30),
('BMW', 'X5', 70000.00, 70),
('Mercedes-Benz', 'C-Class', 60000.00, 40),
('Audi', 'A4', 55000.00, 25),
('Lexus', 'RX', 62000.00, 35),
('Subaru', 'Outback', 30000.00, 65),
('Volkswagen', 'Golf', 21000.00, 50),
('Hyundai', 'Elantra', 22000.00, 48),
('Kia', 'Sorento', 33000.00, 42),
('Mazda', 'CX-5', 28000.00, 57),
('Nissan', 'Altima', 27000.00, 52),
('Volvo', 'XC60', 55000.00, 38),
('Porsche', '911', 100000.00, 20),
('Jaguar', 'F-Type', 90000.00, 18),
('Infiniti', 'Q50', 48000.00, 33),
('Land Rover', 'Range Rover', 95000.00, 15),
('Mitsubishi', 'Outlander', 26000.00, 62),
('Toyota', 'RAV4', 27000.00, 40),
('Honda', 'Accord', 28000.00, 52),
('Ford', 'Explorer', 40000.00, 25),
('Tesla', 'Model 3', 45000.00, 38),
('Chevrolet', 'Silverado', 48000.00, 47),
('BMW', '3 Series', 50000.00, 44),
('Mercedes-Benz', 'E-Class', 55000.00, 35),
('Toyota', 'RAV4', 27000.00, 10),
('Honda', 'Accord', 28000.00, 32),
('Ford', 'Explorer', 40000.00, 26),
('Tesla', 'Model 3', 45000.00, 32),
('Chevrolet', 'Silverado', 48000.00, 7),
('BMW', '3 Series', 50000.00, 14),
('Mercedes-Benz', 'E-Class', 55000.00, 5);

-- Добавление столбца discount со значением по умолчанию 7
alter table car_dealer_7 add column discount integer default 7;
