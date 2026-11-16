-- ============================================================
-- Задача "Смена фамилии"
-- Найти клиента по фамилии и имени, если найден — сменить
-- фамилию и сообщить об успехе через OUT-параметр, иначе —
-- сообщить, что пользователь не найден.
-- ============================================================

create or replace procedure change_last_name(
    t_old_last_name varchar,
    t_first_name varchar,
    t_new_last_name varchar,
    out t_result_message text
)
language plpgsql as $$
declare
    v_first_name varchar;
    v_last_name varchar;
begin
    select first_name, last_name into v_first_name, v_last_name
    from clients
    where last_name = t_old_last_name and first_name = t_first_name;

    -- Проверка через FOUND была бы чище, чем повторное сравнение значений,
    -- уже отфильтрованных в WHERE; текущий вариант даёт тот же результат.
    if v_first_name = t_first_name and v_last_name = t_old_last_name then
        update clients
        set last_name = t_new_last_name
        where last_name = t_old_last_name and first_name = t_first_name;

        t_result_message := 'Фамилия успешно изменена на ' || t_new_last_name;
    else
        t_result_message := 'Пользователь ' || t_old_last_name || ' ' || t_first_name || ' не найден';
    end if;
end;
$$;

-- Вызов с OUT-параметром напрямую из psql: NULL — плейсхолдер,
-- результат придёт отдельной строкой в t_result_message
call change_last_name('Иванова', 'Анна', 'Янова', null);
