-- ============================================================
-- Тема: функции — RETURNS TABLE, OUT-параметры, RECORD
-- Предметная область: фитнес-клуб
--
-- Столбцы, которые используют функции:
--   clubs: id, name, max_capacity
--   members: id, first_name, last_name, club_id, membership_type,
--            is_active
--   workouts: id, name, calories_per_hour
--   visits: id, member_id, workout_id, visit_date, duration_minutes
--   subscriptions: member_id, end_date, is_paid, price_paid
--   personal_trainings: member_id, price
-- ============================================================

-- 1.2: сожжённые калории за тренировку по её длительности
create or replace function calculate_calories_burned(
    p_workut_id int,
    p_duration_minutes int
)
returns int language plpgsql strict
as $$
declare
    v_calories_per_hour numeric;
    v_calories_burned numeric;
begin
    select calories_per_hour into v_calories_per_hour from workouts where p_workut_id = id;

    v_calories_burned := (p_duration_minutes::numeric / 60) * v_calories_per_hour;
    return v_calories_burned;
end;
$$;

select calculate_calories_burned(1, 45);


-- 1.3: процент заполненности клуба
create or replace function get_club_occupancy_percent(
    p_club_id int
)
returns decimal language plpgsql
as $$
declare
    max_cap int;
    active_count int;
    percent_occupied numeric;
begin
    select max_capacity into max_cap from clubs where p_club_id = id;
    select count(club_id) into active_count from members where p_club_id = club_id;

    percent_occupied := (active_count::numeric / max_cap::numeric) * 100;

    return round(percent_occupied, 1);
end;
$$;

select get_club_occupancy_percent(1);


-- 1.5: стоимость абонемента на N месяцев с учётом типа членства
create or replace function for_1_4(
    p_id_client int,
    p_count_mounth int
)
returns decimal language plpgsql
as $$
declare
    v_price numeric;
    v_type varchar;
    v_return numeric;
begin
    select monthly_fee into v_price
    from clubs
    join members on members.club_id = clubs.id
    where p_id_client = members.id and club_id = clubs.id;

    select membership_type into v_type from members where p_id_client = id;

    if v_type = 'premium' then
        v_return := (p_count_mounth::numeric * v_price - (p_count_mounth::numeric * v_price) * 0.05);
    elsif v_type = 'vip' then
        v_return := (p_count_mounth::numeric * v_price - (p_count_mounth::numeric * v_price) * 0.10);
    else
        v_return := (p_count_mounth::numeric * v_price);
    end if;

    return v_return;
end;
$$;

select for_1_4(5, 3);


-- 2.1: самый активный участник клуба за месяц (OUT-параметры)
-- Функция принимает два IN-параметра: p_club_id и p_date.
create or replace function get_most_popular(
    p_club_id int,
    p_date date,
    out first_name varchar,
    out last_name varchar,
    out visit_counts int
)
language plpgsql
as $$
begin
    select members.first_name, members.last_name, count(visits.id)
    into first_name, last_name, visit_counts
    from members
    join visits on visits.member_id = members.id
    where members.club_id = p_club_id
        and extract(month from visits.visit_date) = extract(month from p_date)
        and extract(year from visits.visit_date) = extract(year from p_date)
    group by members.first_name, members.last_name
    order by count(visits.id) desc
    limit 1;
end;
$$;

select get_most_popular(1, '2024-06-01');


-- 2.2: самая популярная тренировка клуба
create or replace function most_popular_training(
    p_club_id int,
    out workout_name varchar,
    out visit_count int
)
language plpgsql
as $$
begin
    select workouts.name, count(visits.workout_id)
    into workout_name, visit_count
    from visits
    join workouts on workouts.id = visits.workout_id
    join members on members.id = visits.member_id
    where p_club_id = members.club_id
    group by members.club_id, workouts.name
    order by count(visits.workout_id) desc
    limit 1;
end;
$$;

select * from most_popular_training(1);


-- 2.3: месячная статистика участника (RECORD)
create or replace function get_member_monthly_stats(
    p_member_id int,
    p_date date
)
returns record language plpgsql
as $$
declare
    result record;
begin
    select
        sum((v.duration_minutes::numeric / 60) * w.calories_per_hour),
        avg(v.duration_minutes),
        count(v.id)
    into result
    from visits v
    join workouts w on w.id = v.workout_id
    where v.member_id = p_member_id
        and extract(month from v.visit_date) = extract(month from p_date)
        and extract(year from v.visit_date) = extract(year from p_date);

    return result;
end;
$$;

select * from get_member_monthly_stats(1, '2024-06-01')
as (total_calories numeric, avg_duration numeric, visits_count bigint);


-- 3.1: подписки, истекающие в ближайшие N дней и ещё не оплаченные
create or replace function get_expiring_subscriptions(
    p_days_ahead int,
    p_date date
)
returns table(
    member_name varchar,
    email varchar,
    end_date date,
    club_name varchar
)
language plpgsql
as $$
begin
    return query
    select
        (m.first_name || ' ' || m.last_name)::varchar,
        ('email_' || m.id || '@fitness.ru')::varchar,
        s.end_date,
        c.name::varchar
    from subscriptions s
    join members m on m.id = s.member_id
    join clubs c on c.id = m.club_id
    where s.is_paid = false
        and s.end_date between p_date and p_date + p_days_ahead;
end;
$$;

select * from get_expiring_subscriptions(3000, '2024-06-01');


-- 3.2: полный отчёт по клубу (участники, заполненность, выручка)
-- Суммы считаются отдельными подзапросами: два JOIN на одного участника дублировали бы строки.
create or replace function get_club_full_report(
    p_club_id int
)
returns table(
    club_name varchar,
    active_members bigint,
    occupancy_percent numeric,
    subscription_revenue numeric,
    training_revenue numeric,
    total_revenue numeric
)
language plpgsql
as $$
begin
    return query
    select
        c.name::varchar,
        (select count(*) from members m where m.club_id = c.id and m.is_active = true),
        round(
            (select count(*) from members m where m.club_id = c.id and m.is_active = true)::numeric
            / c.max_capacity * 100, 1
        ),
        (select coalesce(sum(s.price_paid), 0)
         from subscriptions s
         join members m on m.id = s.member_id
         where m.club_id = c.id and m.is_active = true),
        (select coalesce(sum(pt.price), 0)
         from personal_trainings pt
         join members m on m.id = pt.member_id
         where m.club_id = c.id and m.is_active = true),
        (select coalesce(sum(s.price_paid), 0)
         from subscriptions s
         join members m on m.id = s.member_id
         where m.club_id = c.id and m.is_active = true)
        +
        (select coalesce(sum(pt.price), 0)
         from personal_trainings pt
         join members m on m.id = pt.member_id
         where m.club_id = c.id and m.is_active = true)
    from clubs c
    where c.id = p_club_id;
end;
$$;

select * from get_club_full_report(1);


-- 3.3: топ-N участников по сожжённым калориям за период
create or replace function get_top_calories_members(
    p_n int,
    p_start_date date,
    p_end_date date
)
returns table(
    member_name varchar,
    total_calories numeric
)
language plpgsql
as $$
begin
    return query
    select
        (m.first_name || ' ' || m.last_name)::varchar,
        sum((v.duration_minutes::numeric / 60) * w.calories_per_hour)
    from visits v
    join members m on m.id = v.member_id
    join workouts w on w.id = v.workout_id
    where v.visit_date between p_start_date and p_end_date
    group by m.first_name, m.last_name
    order by total_calories desc
    limit p_n;
end;
$$;

select * from get_top_calories_members(3, '2024-06-01', '2024-06-30');
