-- ============================================================
-- 4 материализованных представления по заданию (вариант 1)
-- ============================================================

-- Задача 1: доставки конкретного доставщика по телефону
create materialized view first_task as
select dm.phone, d.date_d, dp.address
from deliveryman dm
join delivery d on dm.id_man = d.id_man
join delivery_position dp on dp.id_delivery = d.id_delivery
where dm.phone = '89255252535';

-- Задача 2: доставщики, не доставившие ни одного товара
create materialized view second_task as
select dm.phone, count(dp.id_del_pos) as count_tovar
from deliveryman dm
left join delivery d on dm.id_man = d.id_man
left join delivery_position dp on d.id_delivery = dp.id_delivery
group by dm.phone
having count(dp.id_del_pos) = 0;

-- Задача 3: заработок каждого доставщика (включая тех, у кого 0 доставок)
create materialized view third_task as
select dm.phone, dm.tariff_of_gramm,
       sum(dp.tovar_weight * dm.tariff_of_gramm) as total_earnings
from deliveryman dm
left join delivery d on dm.id_man = d.id_man
left join delivery_position dp on d.id_delivery = dp.id_delivery
group by dm.phone, dm.tariff_of_gramm;

-- Задача 4: доставщики без доставок + товары без доставки (UNION ALL)
create materialized view last_task as
select dm.phone, dm.tariff_of_gramm, null as tovar, null as address
from deliveryman dm
left join delivery d on dm.id_man = d.id_man
where d.id_delivery is null

union all

select null as phone, null as tariff_of_gramm, dp.tovar, dp.address
from delivery_position dp
where dp.id_delivery is null;
