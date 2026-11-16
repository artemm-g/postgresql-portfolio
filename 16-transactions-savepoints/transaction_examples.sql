-- ============================================================
-- Разобранные примеры: BEGIN/COMMIT, SAVEPOINT/ROLLBACK TO
-- ============================================================

-- Пример 1: простой перевод, две команды UPDATE + запись в историю
-- в рамках одной транзакции — либо применится всё, либо ничего
begin;
update users set balance = balance - 200
where name = 'Анна';

update users set balance = balance + 200
where name = 'Борис';

insert into transactions (from_user_id, to_user_id, amount) values
(1, 2, 200);

commit;


-- Пример 2: перевод, где видно текущее состояние через SELECT
-- ещё до COMMIT (в рамках той же транзакции)
begin;
update users set balance = balance - 1000
where name = 'Борис';

update users set balance = balance + 1000
where name = 'Виктор';

select * from users;

commit;


-- Пример 3: SAVEPOINT — можно откатить только часть транзакции,
-- не всю целиком. Здесь списание у Анны остаётся в силе, а списание
-- у Виктора отменяется через ROLLBACK TO SAVEPOINT, при этом
-- транзакция продолжается дальше (зачисление Борису) и коммитится.
begin;
update users set balance = balance - 100 where name = 'Анна';

savepoint before_viktor;

update users set balance = balance - 50 where name = 'Виктор';

rollback to before_viktor;

update users set balance = balance + 100 where name = 'Борис';
commit;
