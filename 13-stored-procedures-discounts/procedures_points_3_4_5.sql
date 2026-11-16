-- ============================================================
-- Задача "Магазин продуктов", пункты 3-5
-- ============================================================

-- Пункт 3: в первый понедельник месяца самый ходовой товар
-- дорожает на 6%, самый неходовой — на 12%.
-- Популярность считается по всей истории продаж: SUM(quantity_sales) по таблице sales.
create or replace procedure third(v_date date)
language plpgsql as $$
declare
    f_id_pr_max int;
    f_id_pr_min int;
begin
    if extract(dow from v_date) = 1 and extract(day from v_date) <= 7 then

        select id_pr into f_id_pr_max
        from sales
        group by id_pr
        order by sum(quantity_sales) desc
        limit 1;

        select id_pr into f_id_pr_min
        from sales
        group by id_pr
        order by sum(quantity_sales) asc
        limit 1;

        update products set cena = cena + cena * 0.06 where id = f_id_pr_max;
        update products set cena = cena + cena * 0.12 where id = f_id_pr_min;

        raise notice 'Samiy hodovoy tovar id % podorozhal na 6%%', f_id_pr_max;
        raise notice 'Samiy nehodovoy tovar id % podorozhal na 12%%', f_id_pr_min;
    else
        raise notice 'Data ne yavlyaetsya pervym ponedelnikom mesyaca';
    end if;
end;
$$;

call third('2022-04-04');


-- Пункт 4: во вторую пятницу месяца весь товар уценивают на 8%.
-- Уценка: цена уменьшается на 8%.
create or replace procedure fourth(v_date date)
language plpgsql as $$
begin
    if extract(dow from v_date) = 5 and extract(day from v_date) between 8 and 14 then
        update products
        set cena = cena - cena * 0.08;

        raise notice 'Vse tovary uceneny na 8%%';
    else
        raise notice 'Data ne yavlyaetsya vtoroy pyatnicey mesyaca';
    end if;
end;
$$;

call fourth('2022-04-08');


-- Пункт 5: ежеквартальный отчёт по сумме продаж и НДС к уплате
-- (товары категории 1 — ставка 10%, категории 2 — ставка 18%),
-- отчётный период — март, июнь, сентябрь, декабрь.
--
-- НАПИСАНО С НУЛЯ по текстовому описанию задания — авторский код
-- от пользователя по этому пункту не был прислан, поэтому
-- процедура не проверена на реальной БД. Нужно прогнать самому
-- и свериться с ожидаемым результатом.
create or replace procedure fifth(v_date date)
language plpgsql as $$
declare
    v_month int := extract(month from v_date);
    v_sum_cat1 numeric;
    v_sum_cat2 numeric;
    v_nds_cat1 numeric;
    v_nds_cat2 numeric;
begin
    if v_month in (3, 6, 9, 12) then
        select coalesce(sum(s.quantity_sales * p.cena), 0)
        into v_sum_cat1
        from sales s
        join products p on s.id_pr = p.id
        where p.id_cat_pr = 1;

        select coalesce(sum(s.quantity_sales * p.cena), 0)
        into v_sum_cat2
        from sales s
        join products p on s.id_pr = p.id
        where p.id_cat_pr = 2;

        v_nds_cat1 := v_sum_cat1 * 0.10;
        v_nds_cat2 := v_sum_cat2 * 0.18;

        raise notice 'NDS s tovarov 1 kategorii (10%%): %', v_nds_cat1;
        raise notice 'NDS s tovarov 2 kategorii (18%%): %', v_nds_cat2;
        raise notice 'Obshiy NDS k uplate: %', v_nds_cat1 + v_nds_cat2;
    else
        raise notice 'Otchetnyy period ne nastupil';
    end if;
end;
$$;

call fifth('2022-04-30');  -- апрель, не конец квартала -> "не наступил"
call fifth('2022-06-30');  -- июнь, конец квартала -> считает НДС
