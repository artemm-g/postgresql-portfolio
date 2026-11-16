-- ============================================================
-- Тема: роли и права доступа (GRANT, CREATE ROLE/USER)
-- Предметная область: магазин (shop) — товары, заказы, лог админа
-- ============================================================

\c shop;

-- Триггер аудита: логирует любую операцию INSERT/UPDATE/DELETE
-- над products.
-- Для DELETE значения NEW нет, поэтому возвращается COALESCE(NEW, OLD).
create or replace function t_t1_prd()
returns trigger language plpgsql
as $$
begin
    insert into admin_log (date, operation, tablee) values
    (current_timestamp, tg_op, tg_table_name);
    return coalesce(new, old);
end;
$$;

create or replace trigger f_t_t1_prd
after insert or update or delete on products
for each row
execute function t_t1_prd();

update products
set name = 'Banana'
where id = 5;
