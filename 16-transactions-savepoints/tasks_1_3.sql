-- ============================================================
-- Задания 1 и 3
--
-- Схема таблиц products/baskets/cheque/sales не включена в папку. Столбцы, которые используют запросы:
--   products: id, count, sold
--   baskets: idcustomer, idproduct, basketcount
--   cheque: id, idcustomer, timedat, summ
--   sales: idcheque, idproduct, countsale, delivered
-- ============================================================

-- Задание №1: при изменении количества товара в корзине
-- (basketcount) синхронно обновлять остаток и продажи товара.
--
-- Версия функции совпадает с примером из transaction_examples.sql.
create or replace function trigger_trans()
returns trigger language plpgsql
as $$
begin
    update products
    set count = count - (new.basketcount - old.basketcount),
        sold = sold + (new.basketcount - old.basketcount)
    where id = new.idproduct;
    return new;
end;
$$;

create or replace trigger triggerz
after update on baskets
for each row
execute function trigger_trans();


-- Задание №3: оформление чека из корзины с проверкой остатков.
-- Использует явные COMMIT/ROLLBACK внутри процедуры — это разрешено
-- в PostgreSQL 11+ только для процедур (не функций), и только если
-- процедура вызывается "верхнеуровнево" через CALL, не изнутри
-- другой транзакции и не из функции.
--
-- Логика: создаём чек и переносим в него позиции из корзины,
-- затем проверяем, не превышает ли где-то заказанное количество
-- остаток на складе (countsale > products.count). Если превышает —
-- откатываем всё (чек и позиции исчезают, корзина остаётся как была).
-- Если всё в порядке — очищаем корзину и фиксируем чек.
create or replace procedure for_task_3(
    in p_customer_id int
)
language plpgsql
as $$
declare
    v_cheque_id int;
    v_over_limit int;
begin
    insert into cheque (idcustomer, timedat, summ)
    values (p_customer_id, current_timestamp, 0)
    returning id into v_cheque_id;

    insert into sales (idcheque, idproduct, countsale, delivered)
    select v_cheque_id, idproduct, basketcount, 0
    from baskets
    where idcustomer = p_customer_id;

    select count(*) into v_over_limit
    from sales s
    join products p on p.id = s.idproduct
    where s.idcheque = v_cheque_id
      and s.countsale > p.count;

    if v_over_limit > 0 then
        rollback;
    else
        delete from baskets where idcustomer = p_customer_id;
        commit;
    end if;
end;
$$;

call for_task_3(1);
