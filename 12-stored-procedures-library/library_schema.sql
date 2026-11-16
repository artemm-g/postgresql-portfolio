-- ============================================================
-- Тема: хранимые процедуры (CREATE PROCEDURE, CALL, OUT-параметры)
-- Предметная область: библиотека (выдача и возврат книг)
-- ============================================================

create database library;
\c library;

-- Читатели
create table readers (
    id serial primary key,
    name varchar(100) not null,
    phone varchar(20)
);

-- Книги
create table books (
    id serial primary key,
    title varchar(100) not null,
    author varchar(100) not null,
    total_copies int default 1,      -- всего экземпляров
    available_copies int default 1   -- доступно
);

-- Выдача книг
create table loans (
    id serial primary key,
    reader_id int references readers(id),
    book_id int references books(id),
    loan_date date default current_date,
    return_date date
);

insert into readers (name, phone) values
('Иван Петров', '89123456789'),
('Мария Сидорова', '89234567890');

insert into books (title, author, total_copies, available_copies) values
('Мастер и Маргарита', 'Булгаков', 3, 3),
('Война и мир', 'Толстой', 2, 2),
('Преступление и наказание', 'Достоевский', 2, 2);

-- Дополнительная выдача для проверки процедуры sp_reader_debts:
-- Мария Сидорова взяла книгу с id=3 05.05.2026 и вернула 05.08.2026 —
-- это на 2 месяца позже срока (1 месяц), то есть просрочка
insert into loans (reader_id, book_id, loan_date, return_date) values
(2, 3, '2026-05-05', '2026-08-05'),
(1, 1, '2026-10-20', null);
