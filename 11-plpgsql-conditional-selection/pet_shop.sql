-- ============================================================
-- Тема: DO-блок, условный выбор записи (IF + ORDER BY + LIMIT),
-- фиксация результата через INSERT, RAISE NOTICE
-- Предметная область: зоомагазин (pet_shop)
-- ============================================================

-- Блок 1: создание структуры и наполнение данными
do $$
begin
    create table pet_type (
        id_pet_type serial primary key,
        name varchar(255)
    );

    create table pet (
        id_pet serial primary key,
        name varchar(255),
        price decimal(10, 2),
        age int,
        color varchar(255),
        id_type int,
        foreign key (id_type) references pet_type (id_pet_type)
    );

    create table sale (
        id_sale serial primary key,
        date_now timestamp,
        id_pet int,
        foreign key (id_pet) references pet (id_pet)
    );

    insert into pet_type (name) values ('cat'), ('dog');

    -- по заданию нужно 2 кота и 1 собака; здесь для примера
    -- оставлено 2 кота и 2 собаки — лишняя собака не мешает
    -- логике выбора кота, но при желании убрать dog_2
    insert into pet (name, price, age, color, id_type) values
    ('cat_1', 10000.00, 1, 'gray', 1),
    ('cat_2', 15000.00, 2, 'white-gray', 1),
    ('dog_1', 25000.00, 3, 'red', 2),
    ('dog_2', 50000.00, 4, 'black', 2);
end;
$$;

-- Блок 2: выбор и продажа самого младшего кота из ещё не проданных
do $$
declare
    count_cat int;
    name_cat varchar(50);
    pet_id int;
begin
    select count(*) into count_cat
    from pet
    where id_type = 1 and id_pet not in (select id_pet from sale);

    if count_cat > 0 then
        select name, id_pet into name_cat, pet_id
        from pet
        where id_type = 1 and id_pet not in (select id_pet from sale)
        order by age asc
        limit 1;

        insert into sale (date_now, id_pet) values (now(), pet_id);

        raise notice 'Of the % cats, the youngest one, %', count_cat, name_cat;
    else
        raise notice 'there is no suitable pet';
    end if;
end;
$$;
