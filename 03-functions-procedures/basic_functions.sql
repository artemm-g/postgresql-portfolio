-- ============================================================
-- Тема: Функции PostgreSQL (язык SQL и PL/pgSQL)
-- ============================================================

\c tutu;

-- Функция на языке SQL с переменным числом аргументов (variadic)
create function sum_all(
    variadic numbers integer[]
)
returns integer language sql
as $$
    select sum(n) from unnest(numbers) as n;
$$;

select sum_all(10, 20, 30);

-- Функция на SQL: расчёт НДС (20%) от цены
create or replace function calculate_vat(
    price decimal(10, 2)
)
returns decimal language sql
as $$
    select price * 0.20;
$$;

select name, price, calculate_vat(price) as vat from products;

-- Функция на PL/pgSQL с условной логикой
create function get_price_category(
    price decimal
)
returns text language plpgsql
as $$
declare
    category text;
begin
    if price < 50 then
        category := 'Budget';
    else
        category := 'Premium';
    end if;
    return category;
end;
$$;

select name, price, get_price_category(price) from products;
