-- ============================================================
-- Процедуры расчёта скидок по праздничным дням
-- Правило: цена <= 50 → скидка 10%; 51-99 → 15%; >= 100 → 20%
-- ============================================================

-- Пункт 1: суммарная стоимость проданных единиц КОНКРЕТНОГО товара
-- с учётом скидки, товар и дата передаются параметрами
create or replace procedure calculate_discounts(
    p_id_pr int,
    p_date date
)
language plpgsql as $$
declare
    v_name varchar(255);
    v_cena int;
    v_total_quantity int;
    v_discount int;
    v_total_cost numeric;
begin
    select name_pr, cena into v_name, v_cena
    from products
    where id = p_id_pr;

    if not found then
        raise notice 'product with id % not found.', p_id_pr;
        return;
    end if;

    if v_cena <= 50 then
        v_discount := 10;
    elsif v_cena >= 51 and v_cena <= 99 then
        v_discount := 15;
    else
        v_discount := 20;
    end if;

    select coalesce(sum(quantity_sales), 0) into v_total_quantity
    from sales
    where id_pr = p_id_pr and date_sales = p_date;

    v_total_cost := v_total_quantity * v_cena * (1 - v_discount / 100.0);

    raise notice 'product: %, price: %', v_name, v_cena;
    raise notice 'quantity sold: %', v_total_quantity;
    raise notice 'total cost with discount % %%: %', v_discount, v_total_cost;
end;
$$;

call calculate_discounts(1, '2022-04-01');


-- Пункт 2: суммарный размер скидки, предоставленной клиентам
-- за праздничный день, отдельно по каждой из трёх категорий скидки
-- (переименовано из calculate_discounts(p_date date) в
-- calculate_discount_summary — чтобы не совпадать по имени
-- с процедурой пункта 1, у которой другая задача)
create or replace procedure calculate_discount_summary(p_date date)
language plpgsql as $$
declare
    v_discount_10 numeric := 0;
    v_discount_15 numeric := 0;
    v_discount_20 numeric := 0;
begin
    select coalesce(sum(s.quantity_sales * p.cena * 0.10), 0)
    into v_discount_10
    from sales s
    join products p on s.id_pr = p.id
    where s.date_sales = p_date and p.cena <= 50;

    select coalesce(sum(s.quantity_sales * p.cena * 0.15), 0)
    into v_discount_15
    from sales s
    join products p on s.id_pr = p.id
    where s.date_sales = p_date and p.cena between 51 and 99;

    select coalesce(sum(s.quantity_sales * p.cena * 0.20), 0)
    into v_discount_20
    from sales s
    join products p on s.id_pr = p.id
    where s.date_sales = p_date and p.cena >= 100;

    raise notice 'Discount 20: %', v_discount_20;
    raise notice 'Discount 15: %', v_discount_15;
    raise notice 'Discount 10: %', v_discount_10;
end;
$$;

call calculate_discount_summary('2022-04-01');
