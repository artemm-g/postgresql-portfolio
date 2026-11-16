-- ============================================================
-- Тема: анонимные блоки (DO), ENUM, массивы, RETURNING,
-- RAISE NOTICE / RAISE EXCEPTION, транзакционность
-- Предметная область: интернет-магазин обуви
-- ============================================================

do $$
declare
    id_category_1 int;
    id_category_2 int;

    ch_id int;

    vm_1 int := 1;
    vm_2 int := 2;

    v_cnt_1 int := 2;
    v_cnt_2 int := 3;

    count_id_1 int;
    count_id_2 int;
    total_count int;
    total_sum decimal(10, 2);  -- было INT, исправлено — иначе теряются копейки
begin
    -- Создание структуры БД
    create table category (
        id_category serial primary key,
        name_category varchar(255)
    );

    create type season as enum ('autumn', 'winter', 'summer', 'spring');
    create type gender as enum ('female', 'male');

    create table models (
        id_model serial primary key,
        cat_id int,
        season_m season,
        gender_m gender,
        model varchar(25),
        size_m int[],
        color_m text[],
        price_m decimal(10, 2),
        count_m int,
        foreign key (cat_id) references category (id_category)
    );

    create table cheques (
        id_check serial primary key,
        date_ch timestamp,
        summ_ch decimal(10, 2) default (null),
        count_ch int default (null)
    );

    create table items_ch (
        id_items_ch serial primary key,
        id_check int,
        id_model int,
        count_it int,
        foreign key (id_check) references cheques (id_check),
        foreign key (id_model) references models (id_model)
    );

    raise notice 'Table category, models, cheques, items_ch - successful create';

    -- Наполнение БД
    insert into category (name_category) values ('boots')
    returning id_category into id_category_1;

    insert into category (name_category) values ('shoes')
    returning id_category into id_category_2;

    insert into models (cat_id, season_m, gender_m, model, size_m, color_m, price_m, count_m) values
    (id_category_1, 'autumn', 'female', 'ModelA', array[54, 49], array['black'], 450.50, 10),
    (id_category_1, 'winter', 'male', 'ModelB', array[48, 46], array['red'], 400.00, 8),
    (id_category_2, 'summer', 'female', 'ModelC', array[50, 42], array['orange'], 300.00, 6),
    (id_category_2, 'spring', 'male', 'ModelD', array[44, 40], array['pink'], 750.00, 4);

    raise notice 'Table I1(category), I2(models) successful insert and add this id%, id%', id_category_1, id_category_2;

    -- Оформление чека
    insert into cheques (date_ch) values (now())
    returning id_check into ch_id;

    raise notice 'Check successful add';

    -- Товар №1: проверка наличия, добавление в чек, списание со склада
    select count_m into count_id_1 from models where id_model = vm_1;
    if count_id_1 < v_cnt_1 then
        raise exception 'Need more goods id % na sklade', vm_1;
    end if;

    insert into items_ch (id_check, id_model, count_it) values (ch_id, vm_1, v_cnt_1)
    returning count_it into count_id_1;

    update models
    set count_m = count_m - v_cnt_1
    where id_model = vm_1;

    raise notice 'Tovar dobavlen v colve %', v_cnt_1;

    -- Товар №2: та же логика
    select count_m into count_id_2 from models where id_model = vm_2;
    if count_id_2 < v_cnt_2 then
        raise exception 'Need more goods id % na sklade', vm_2;
    end if;

    insert into items_ch (id_check, id_model, count_it) values (ch_id, vm_2, v_cnt_2)
    returning count_it into count_id_2;

    update models
    set count_m = count_m - v_cnt_2
    where id_model = vm_2;

    raise notice 'Tovar dobavlen v colve %', v_cnt_2;

    -- Расчёт итогов чека
    select sum(m.price_m * i.count_it)
    into total_sum
    from items_ch i
    join models m on m.id_model = i.id_model
    where i.id_check = ch_id;

    select sum(count_it)
    into total_count
    from items_ch
    where id_check = ch_id;

    update cheques
    set summ_ch = total_sum,
        count_ch = total_count
    where id_check = ch_id;

    raise notice 'Itog: sum = %, count = %', total_sum, total_count;
end;
$$;
