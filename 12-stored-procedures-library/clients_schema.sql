-- Таблица clients и тестовые данные
create table clients (
    id serial primary key,
    first_name varchar(55) not null,
    last_name varchar(55) not null
);

insert into clients (first_name, last_name) values
('Анна', 'Иванова'),
('Ольга', 'Петрова');
