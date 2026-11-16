-- ============================================================
-- Задание 1: роли и права доступа
-- ============================================================

create role manager;
create role app_role;
create role super_user;

-- manager: только чтение (для аналитики/отчётов)
grant connect on database shop to manager;
grant usage on schema public to manager;
grant select on products to manager;
grant select on orders to manager;

-- app_role: по заданию только права на изменение данных
-- (INSERT/UPDATE/DELETE), без SELECT. На практике для реального
-- приложения обычно нужен и SELECT — иначе приложение изменяет
-- данные "вслепую", не имея возможности их прочитать. Здесь
-- оставлено строго по условию задания.
grant connect on database shop to app_role;
grant usage on schema public to app_role;
grant insert, update, delete on orders to app_role;
grant insert, update, delete on products to app_role;

-- super_user: полные права уровня суперпользователя СУБД
alter role super_user with superuser;

-- Пользователи под каждую роль
-- Пароли-заглушки: перед использованием замените на свои.
create user qwerty password 'change_me' in role manager;
create user admin password 'change_me' in role app_role;
create user superadmin password 'change_me' in role super_user;
