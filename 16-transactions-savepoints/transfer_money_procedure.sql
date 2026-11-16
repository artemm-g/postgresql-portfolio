-- ============================================================
-- Процедура: перевод денег между пользователями по имени,
-- с записью в историю транзакций одним вызовом
-- ============================================================

create or replace procedure transfer_money(
    from_name varchar,
    to_name varchar,
    amount decimal
)
language plpgsql
as $$
begin
    update users set balance = balance - amount where name = from_name;
    update users set balance = balance + amount where name = to_name;

    insert into transactions (from_user_id, to_user_id, amount) values
    ((select id from users where name = from_name), (select id from users where name = to_name), amount);
end;
$$;

call transfer_money('Анна', 'Борис', 150.00);
