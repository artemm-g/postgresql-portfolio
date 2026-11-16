-- ============================================================
-- Задача "Авторизация/регистрация"
-- Если логина нет в базе — регистрируем нового пользователя.
-- Если логин есть и пароль верный — успешный вход, сброс ошибки.
-- Если логин есть, а пароль неверный — фиксируем ошибку и дату.
-- ============================================================

\c soso;

create or replace procedure login_correct(
    t_login varchar,
    t_password varchar
)
language plpgsql as $$
declare
    v_for_password varchar;
begin
    select password into v_for_password from reg where login = t_login;

    if not found then
        -- логина нет в базе — регистрируем нового пользователя
        insert into reg (login, password, email, last_enter, login_error)
        values (t_login, crypt(t_password, gen_salt('bf')), t_login || '@example.com', now(), 'Registered');

    elsif v_for_password = crypt(t_password, v_for_password) then
        -- пароль верный — успешный вход, ошибка сбрасывается
        update reg
        set login_error = null,
            error_date = null,
            last_enter = now()
        where login = t_login;

    else
        -- логин есть, пароль неверный — фиксируем ошибку
        update reg
        set login_error = 'Authorization error',
            error_date = now()
        where login = t_login;
    end if;
end;
$$;

-- Тестовый вызов: у lyapis пароль '789', здесь передан неверный '123',
-- сработает ветка ELSE — login_error и error_date будут заполнены
call login_correct('lyapis', '123');
