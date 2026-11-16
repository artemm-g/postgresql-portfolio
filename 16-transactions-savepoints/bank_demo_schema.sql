-- ============================================================
-- Тема: транзакции (BEGIN/COMMIT/ROLLBACK, SAVEPOINT)
-- Предметная область: банковские переводы между пользователями
-- ============================================================

create database bank_demo;
\c bank_demo;

-- Таблица пользователей
create table users (
    id serial primary key,
    name varchar(100) not null,
    balance decimal(10,2) default 0 check (balance >= 0)
);

-- Таблица транзакций (история переводов)
create table transactions (
    id serial primary key,
    from_user_id int references users(id),
    to_user_id int references users(id),
    amount decimal(10,2),
    created_at timestamp default current_timestamp
);

insert into users (name, balance) values
    ('Анна', 1000.00),
    ('Борис', 500.00),
    ('Виктор', 300.00);
