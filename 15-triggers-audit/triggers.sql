-- ============================================================
-- Тема: триггеры (row-level, statement-level, event triggers),
-- аудит изменений (OLD/NEW, TG_OP, TG_TABLE_NAME), бизнес-правила
-- через BEFORE/AFTER триггеры
-- ============================================================

-- ---------- 7.1: аудит изменения job_id/salary у сотрудника ----------

create table if not exists employees (
    emp_id serial primary key,
    job_id int,
    salary decimal(10, 2),
    first_name varchar(50),
    last_name varchar(50)
);

create table if not exists audit_emp_values (
    audit_id serial primary key,
    currentuser varchar(50),
    change_time timestamp,
    employee_id int,
    first_name varchar(50),
    last_name varchar(50),
    old_job_id int,
    new_job_id int,
    old_salary decimal(10, 2),
    new_salary decimal(10, 2)
);

create or replace function f_7_1()
returns trigger language plpgsql
as $$
begin
    insert into audit_emp_values (currentuser, change_time, employee_id, first_name, last_name, old_job_id, new_job_id, old_salary, new_salary)
    values (current_user, current_timestamp, old.emp_id, old.first_name, old.last_name, old.job_id, new.job_id, old.salary, new.salary);
    return new;
end;
$$;

create or replace trigger t_f_7_1
after update of job_id, salary on employees
for each row
execute function f_7_1();

insert into employees (job_id, salary, first_name, last_name) values
(4, 50000.00, 'Иван', 'Иванов');
insert into employees (job_id, salary, first_name, last_name) values
(2, 70000.00, 'Иван', 'Иванов');
insert into employees (job_id, salary, first_name, last_name) values
(3, 80000.00, 'Иван', 'Иванов');

update employees
set job_id = 5, salary = 30000.00
where emp_id = 1;


-- ---------- 7.2: универсальный аудит INSERT/UPDATE/DELETE ----------
-- Функция аудита называется t_7_2_audit_all, чтобы не совпадать с
-- функцией проверки рейтинга из блока 7.5 (t_7_5_rating_check).

create table if not exists audit_emp_idu (
    id_audit serial primary key,
    currentuser varchar(50),
    change_time timestamp,
    employee_id int,
    first_name varchar(50),
    last_name varchar(50),
    name_operation varchar(50)
);

create or replace function t_7_2_audit_all()
returns trigger language plpgsql
as $$
begin
    insert into audit_emp_idu (currentuser, change_time, employee_id, first_name, last_name, name_operation)
    values (current_user, current_timestamp, coalesce(old.emp_id, new.emp_id), coalesce(old.first_name, new.first_name), coalesce(old.last_name, new.last_name), tg_op);
    return coalesce(new, old);
end;
$$;

create or replace trigger f_t_7_2
after insert or delete or update on employees
for each row
execute function t_7_2_audit_all();

delete from employees
where emp_id = 4;


-- ---------- 7.3: аудит INSERT/DELETE товаров ----------

create table if not exists products (
    id serial primary key,
    name varchar(50),
    price decimal(10, 2),
    quantity int
);

create table if not exists audit_prod (
    id serial primary key,
    currentuser varchar(50),
    change_time timestamp,
    product_id int,
    name varchar(50),
    price decimal(10, 2),
    quantity int,
    operation_name varchar(10)
);

create or replace function t_7_3()
returns trigger language plpgsql
as $$
begin
    insert into audit_prod (currentuser, change_time, product_id, name, price, quantity, operation_name)
    values (current_user, current_timestamp, coalesce(old.id, new.id), coalesce(old.name, new.name), coalesce(old.price, new.price), coalesce(old.quantity, new.quantity), tg_op);
    return coalesce(old, new);
end;
$$;

create or replace trigger f_t_7_3
after insert or delete on products
for each row
execute function t_7_3();

insert into products (name, price, quantity) values ('Orange', 50.00, 5);
delete from products
where id = 2;


-- ---------- 7.4: объединение дублирующихся позиций заказа ----------

create table if not exists order_items (
    id_order serial primary key,
    id_item int,
    name varchar(50),
    quantity int
);

create or replace function t_7_4()
returns trigger language plpgsql
as $$
begin
    if exists (select id_item from order_items where id_item = new.id_item) then
        update order_items set
            quantity = quantity + new.quantity;
        return null;
    end if;
    return new;
end;
$$;

create or replace trigger f_t_7_4
before insert on order_items
for each row
execute function t_7_4();

insert into order_items (id_item, name, quantity) values (1, 'phone', 5);
insert into order_items (id_item, name, quantity) values (1, 'phone', 5);


-- ---------- 7.5: запрет продажи, если рейтинг товара >= рейтинга продавца ----------
-- Таблица order_items_e: id_ord — первичный ключ, id_order — номер заказа,
-- по которому группируются товары (проверка: не более 5 товаров в заказе).
-- Функция проверки рейтинга: t_7_5_rating_check.

create table if not exists emp (
    id serial primary key,
    last_name varchar(50),
    rating int
);

create table if not exists items (
    id serial primary key,
    name varchar(50),
    rating int
);

create table if not exists order_items_e (
    id_ord serial primary key,
    id_order int,
    id_item int references items(id),
    id_emp int references emp(id),
    quantity int
);

create or replace function t_7_5_rating_check()
returns trigger language plpgsql
as $$
declare
    v_emp_rait int;
    v_itm_rait int;
begin
    select rating into v_emp_rait from emp where id = new.id_emp;
    select rating into v_itm_rait from items where id = new.id_item;

    if v_emp_rait <= v_itm_rait then
        raise exception 'Рейтинг товара, выше или равен рейтингу продавца';
    end if;
    return new;
end;
$$;

create or replace trigger f_t_7_5
after insert on order_items_e
for each row
execute function t_7_5_rating_check();


-- ---------- 7.6: не более 5 разных товаров в одном заказе ----------

create or replace function trg_check_items_count()
returns trigger as $$
declare
    cnt int;  -- было "count" — совпадает с именем агрегатной функции COUNT
begin
    select count(*) into cnt
    from order_items_e
    where id_order = new.id_order;

    if (cnt >= 5) then
        raise exception 'В заказе не может быть больше 5 разных товаров. Текущее количество: %', cnt;
    end if;

    return new;
end;
$$ language plpgsql;

create or replace trigger trg_check_items_count
before insert
on order_items_e
for each row
execute function trg_check_items_count();


-- ---------- 7.7: запрет покупки товара клиентом из чёрного списка ----------

create table if not exists customers (
    id serial primary key,
    last_name varchar(50)
);

create table if not exists item (
    id serial primary key,
    name varchar(50),
    price decimal(10, 2)
);

create table if not exists order_items_c (
    id serial primary key,
    id_order int,
    id_item int references item(id),
    id_cust int references customers(id),
    quantity int
);

create table if not exists limit_customers (
    id serial primary key,
    id_cust int references customers(id),
    id_item int references item(id)
);

create or replace function trg_check_limit_customers()
returns trigger
as $$
begin
    if exists (select 1 from limit_customers where id_cust = new.id_cust and id_item = new.id_item) then
        raise exception 'Клиенту (id=%) запрещено приобретать товар (id=%)', new.id_cust, new.id_item;
    end if;
    return new;
end;
$$ language plpgsql;

create or replace trigger trg_order_items_limit
before insert
on order_items_c
for each row
execute function trg_check_limit_customers();


-- ---------- 7.8: запрет DROP TABLE после 16:00 (event trigger) ----------
-- ВНИМАНИЕ: использует расширение dblink с явным подключением
-- ('host=localhost dbname=triggers user=postgres') — сработает
-- только если это расширение установлено (CREATE EXTENSION dblink)
-- и настроена аутентификация без пароля (или добавь пароль в
-- строку подключения). Это внешняя зависимость от окружения,
-- не баг кода как такового.
-- Если время раньше 16:00, функция завершается явным RETURN в конце.

create table if not exists qwe (
    id serial primary key,
    name varchar(50)
);

create table if not exists audit_drop_attempts (
    id serial primary key,
    currentuser varchar(50),
    attempt_time timestamp,
    object_name varchar(50),
    message varchar(255)
);

create or replace function trg_prevent_drop()
returns event_trigger
as $$
declare
    v_time int;
    rec record;
begin
    v_time := extract(hour from current_time);

    if v_time >= 16 then
        for rec in select * from pg_event_trigger_dropped_objects() where object_type = 'table'
        loop
            perform dblink_exec(
                'host=localhost dbname=triggers user=postgres',
                format(
                    'insert into audit_drop_attempts(currentuser, attempt_time, object_name, message) values(%L, %L, %L, %L)',
                    current_user,
                    current_timestamp,
                    rec.object_name,
                    'Попытка удаления таблицы после 16:00 запрещена'
                )
            );
        end loop;

        raise exception 'Удаление таблиц после 16:00 запрещено!';
    end if;

    return;
end;
$$ language plpgsql;

create event trigger trg_prevent_drop_after_16
on sql_drop
execute function trg_prevent_drop();


-- ---------- 7.9: логирование DML по выходным ----------
-- EXTRACT(DOW ...): 5 — пятница, 6 — суббота.

create table if not exists dml_weekend_log (
    id serial primary key,
    currentuser varchar(50),
    log_time timestamp,
    messange text
);

create or replace function trg_log_weekend_dml()
returns trigger as $$
begin
    if (extract(dow from current_date) in (5, 6)) then
        insert into dml_weekend_log (currentuser, log_time, messange) values
        (current_user, current_timestamp, tg_op || ' on ' || tg_table_name);
    end if;
    return coalesce(new, old);
end;
$$ language plpgsql;

create or replace trigger trg_weekend_dml
after insert or update or delete
on employees
for each row
execute function trg_log_weekend_dml();
