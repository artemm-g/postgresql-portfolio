-- ============================================================
-- Задачи 5-6: неявное соединение, INNER/LEFT/RIGHT/FULL JOIN, UNION
-- Выполнено на учебной БД с авторами, книгами, издательствами и заказами.
--
-- Скрипт создания таблиц (authors, books, publishers, editiontypes, incomes, orderitems, customers, orders) в папке отсутствует.
-- Файл оставлен как демонстрация синтаксиса JOIN/UNION.
-- ============================================================

-- Задача 5, пример 1: неявное соединение — автор и его произведения
select authors.author_name, books.title
from authors
join books on authors.author_id = books.author_id
order by title;

-- Задача 5, пример 2: год издания и название произведений с объёмом <= 400 страниц
select authors.author_name, books.pages
from authors
join books on authors.author_id = books.author_id
where pages <= 400
order by pages;

-- Задача 6, INNER JOIN №1: заказы клиентов за конкретные даты
select customers.delivery_address, orders.order_date, orders.order_status
from customers
inner join orders using (customer_id)
where order_date = '2022-03-10' or order_date = '2022-03-12'
order by order_date;

-- Задача 6, INNER JOIN №2: поступления товаров с ценой продажи < 700
select incomes.income_date, orderitems.quantity, orderitems.sale_price_at_order
from incomes
inner join orderitems using (income_id)
where sale_price < 700
order by sale_price;

-- Задача 6, RIGHT JOIN №1: книги определённых издательств
select books.title, editiontypes.edition_type_id, editiontypes.edition_type_name,
       publisher_id, publishers.publisher_name
from books
right join editiontypes using (edition_type_id)
right join publishers using (publisher_id)
where publisher_name = 'INFRA-M' or publisher_name = 'ID FORUM'
order by title;

-- Задача 6, RIGHT JOIN №2: книги и поступления после 2010 года издания
select authors.author_name, books.book_id, books.author_id, books.publisher_id,
       books.edition_type_id, books.title, books.pages, books.publication_year,
       incomes.income_id, incomes.book_id, incomes.income_date, incomes.sale_price
from authors
right join books using (author_id)
right join incomes using (book_id)
where publication_year > 2010
order by author_name;

-- Задача 6, LEFT JOIN №1: авторы и книги объёмом от 400 страниц
select authors.author_id, authors.author_name, books.edition_type_id,
       books.title, books.pages, books.publication_year
from authors
left join books on authors.author_id = books.author_id
where pages >= 400;

-- Задача 6, LEFT JOIN №2: авторы, книги и продажи дороже 500
select authors.author_id, authors.author_name, books.title,
       incomes.income_date, incomes.sale_price
from authors
left join books on authors.author_id = books.author_id
left join incomes on incomes.book_id = books.book_id
where sale_price > 500
order by sale_price;

-- Задача 6, FULL JOIN №1: авторы и книги объёмом менее 500 страниц
select *
from authors
full join books using (author_id)
where pages < 500
order by title;

-- Задача 6, FULL JOIN №2: заказы и клиенты с id от 5 и выше
select *
from orders
full join customers using (customer_id)
where customer_id >= 5
order by customer_id;
