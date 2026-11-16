-- ============================================================
-- Хранимые процедуры для библиотеки
-- ============================================================

-- Процедура 1: выдача книги читателю
create or replace procedure sp_issue_book(
    p_reader_name varchar,
    p_book_title varchar
)
language plpgsql as $$
declare
    v_reader_id int;
    v_book_id int;
begin
    select id into v_reader_id from readers where name = p_reader_name;
    if not found then
        raise exception 'Chitatel % ne naiden', p_reader_name;
    end if;

    select id into v_book_id from books where title = p_book_title;
    if not found then
        raise exception 'Kniga % ne naidena', p_book_title;
    end if;

    if (select available_copies from books where id = v_book_id) <= 0 then
        raise exception 'Knigi % net v nalichii', p_book_title;
    end if;

    update books
    set available_copies = available_copies - 1
    where id = v_book_id;

    insert into loans (reader_id, book_id, return_date)
    values (v_reader_id, v_book_id, current_date + interval '1 month');
end;
$$;

call sp_issue_book('Иван Петров', 'Мастер и Маргарита');


-- Процедура 2: возврат книги читателем
-- Ищем активную выдачу именно этого читателя и этой книги (return_date IS NULL).
create or replace procedure sp_return_book(
    p_reader_name varchar,
    p_book_title varchar
)
language plpgsql as $$
declare
    v_reader_id int;
    v_book_id int;
    v_loan_id int;
begin
    select id into v_reader_id from readers where name = p_reader_name;
    if not found then
        raise exception 'Chitatel % ne naiden', p_reader_name;
    end if;

    select id into v_book_id from books where title = p_book_title;
    if not found then
        raise exception 'Kniga % ne naidena', p_book_title;
    end if;

    -- находим именно активную (ещё не возвращённую) выдачу
    -- этого читателя этой книги
    select id into v_loan_id
    from loans
    where reader_id = v_reader_id
      and book_id = v_book_id
      and return_date is null
    order by loan_date desc
    limit 1;

    if not found then
        raise exception 'Aktivnaya vidacha dlya chitatelya % i knigi % ne naidena', p_reader_name, p_book_title;
    end if;

    update loans
    set return_date = current_date
    where id = v_loan_id;

    update books
    set available_copies = available_copies + 1
    where id = v_book_id;

    raise notice 'Kniga % vozvrashena chitatelem %', p_book_title, p_reader_name;
end;
$$;

call sp_return_book('Иван Петров', 'Мастер и Маргарита');


-- Процедура 3: проверка долгов читателя (OUT-параметр)
-- Считаем займы, по которым книга возвращена позже срока или ещё не возвращена, а срок уже прошёл.
create or replace procedure sp_reader_debts(
    p_reader_name varchar,
    out debts_count int
)
language plpgsql as $$
begin
    select count(*)
    into debts_count
    from loans
    join readers on loans.reader_id = readers.id
    where readers.name = p_reader_name
      and (
            (return_date is null and current_date > loan_date + interval '1 month')
         or (return_date is not null and return_date > loan_date + interval '1 month')
          );

    if debts_count = 0 then
        raise notice 'Y chitatelya % net dolgov', p_reader_name;
    else
        raise notice 'Y chitatelya % - % dolgov', p_reader_name, debts_count;
    end if;
end;
$$;

-- Вызов процедуры с OUT-параметром выполняется через DO-блок
do $$
declare
    cnt int;
begin
    call sp_reader_debts('Мария Сидорова', cnt);
    raise notice 'Vsego dolgov (OUT-parametr): %', cnt;
end;
$$;
