-- ============================================================
-- Тема: DO-блок, условный выбор записи (IF + ORDER BY + LIMIT),
-- фиксация результата через INSERT, RAISE NOTICE
-- Предметная область: бронирование номеров в отеле (hotel_booking)
-- ============================================================

-- Блок 1: создание структуры и наполнение данными
do $$
declare
    standard_id int;
    lux_id int;
begin
    create table room_type (
        id serial primary key,
        name varchar(50)
    );

    create table room (
        id serial primary key,
        number int,
        price decimal(10, 2),
        capacity int,
        id_type int,
        foreign key (id_type) references room_type (id)
    );

    create table booking (
        id serial primary key,
        check_in_date date,
        id_room int,
        foreign key (id_room) references room (id)
    );

    insert into room_type (name) values ('Стандарт') returning id into standard_id;
    insert into room_type (name) values ('Люкс') returning id into lux_id;

    insert into room (number, price, capacity, id_type) values
    (101, 3500.00, 2, standard_id),
    (102, 3200.00, 2, standard_id),
    (201, 6000.00, 3, lux_id);
end;
$$;

-- Блок 2: поиск и бронирование самого дешёвого свободного
-- стандартного номера на дату '2026-05-20'
do $$
declare
    free_count int;
    chosen_room_id int;
    chosen_number int;
    chosen_price decimal(10, 2);
    standard_type_id int;
begin
    select id into standard_type_id from room_type where name = 'Стандарт';

    select count(*) into free_count
    from room r
    where r.id_type = standard_type_id
      and r.id not in (
          select id_room from booking where check_in_date = '2026-05-20'
      );

    if free_count > 0 then
        select r.id, r.number, r.price
        into chosen_room_id, chosen_number, chosen_price
        from room r
        where r.id_type = standard_type_id
          and r.id not in (
              select id_room from booking where check_in_date = '2026-05-20'
          )
        order by r.price asc
        limit 1;

        insert into booking (check_in_date, id_room)
        values ('2026-05-20', chosen_room_id);

        raise notice 'Из % свободных стандартных номеров выбран номер №% с ценой % руб.',
            free_count, chosen_number, chosen_price;
    else
        raise notice 'Нет подходящего номера';
    end if;
end;
$$;
