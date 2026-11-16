import os
import psycopg2
from dotenv import load_dotenv

load_dotenv()


class SqlQw:
    def __init__(self):
        try:
            self.con = psycopg2.connect(
                host=os.getenv('DB_HOST'),
                user=os.getenv('DB_USER'),
                password=os.getenv('DB_PASSWORD'),
                dbname=os.getenv('DB_NAME'),
                port=os.getenv('DB_PORT'),
                client_encoding='UTF8'
            )
            self.cur = self.con.cursor()
        except Exception as e:
            print(f'error: {e}')

    def create(self):
        sql = """
        create table if not exists deliveryman (
            id_man serial primary key,
            phone varchar(40),
            tariff_of_gramm integer
        );
        create table if not exists delivery (
            id_delivery serial primary key,
            date_d date,
            id_man integer,
            foreign key (id_man) references deliveryman(id_man)
        );
        create table if not exists delivery_position (
            id_del_pos serial primary key,
            tovar varchar(40),
            tovar_weight integer,
            address varchar(100),
            id_delivery integer,
            foreign key (id_delivery) references delivery(id_delivery)
        );
        """
        try:
            self.cur.execute(sql)
            self.con.commit()
            return "Таблицы успешно созданы!"
        except Exception as e:
            self.con.rollback()
            return f"Ошибка: {e}"

    def insert_into(self):
        sql = """
        insert into deliveryman (phone, tariff_of_gramm) values
        ('89255252535', 5),
        ('89771224139', 4),
        ('89655587269', 3);

        insert into delivery (date_d, id_man) values
        ('2026-10-15', 1),
        ('2026-03-24', 2),
        ('2025-12-19', 1);

        insert into delivery_position (tovar, tovar_weight, address, id_delivery) values
        ('Огурчики', 500, 'Москва', 1),
        ('Помидорки', 400, 'Питер', 2),
        ('Капуста', 400, 'Новгород', 1);
        """
        try:
            self.cur.execute(sql)
            self.con.commit()
            return "Данные успешно добавлены!"
        except Exception as e:
            self.con.rollback()
            return f"Ошибка: {e}"

    def first_task(self):
        sql = """
        create materialized view first_task as
        select dm.phone, d.date_d, dp.address
        from deliveryman dm
        join delivery d on dm.id_man = d.id_man
        join delivery_position dp on dp.id_delivery = d.id_delivery
        where dm.phone = '89255252535';
        """
        try:
            self.cur.execute(sql)
            self.con.commit()
            return "Представление first_task создано!"
        except Exception as e:
            self.con.rollback()
            return f"Ошибка запроса: {e}"

    def second_task(self):
        sql = """
        create materialized view second_task as
        select dm.phone, count(dp.id_del_pos) as count_tovar
        from deliveryman dm
        left join delivery d on dm.id_man = d.id_man
        left join delivery_position dp on d.id_delivery = dp.id_delivery
        group by dm.phone
        having count(dp.id_del_pos) = 0;
        """
        try:
            self.cur.execute(sql)
            self.con.commit()
            return "Представление second_task создано!"
        except Exception as e:
            self.con.rollback()
            return f"Ошибка запроса: {e}"

    def third_task(self):
        sql = """
        create materialized view third_task as
        select dm.phone, dm.tariff_of_gramm,
        sum(dp.tovar_weight * dm.tariff_of_gramm) as total_earnings
        from deliveryman dm
        left join delivery d on dm.id_man = d.id_man
        left join delivery_position dp on d.id_delivery = dp.id_delivery
        group by dm.phone, dm.tariff_of_gramm;
        """
        try:
            self.cur.execute(sql)
            self.con.commit()
            return "Представление third_task создано!"
        except Exception as e:
            self.con.rollback()
            return f"Ошибка запроса: {e}"

    def last_task(self):
        sql = """
        create materialized view last_task as
        select dm.phone, dm.tariff_of_gramm, null as tovar, null as address
        from deliveryman dm
        left join delivery d on dm.id_man = d.id_man
        where d.id_delivery is null

        union all

        select null as phone, null as tariff_of_gramm, dp.tovar, dp.address
        from delivery_position dp
        where dp.id_delivery is null;
        """
        try:
            self.cur.execute(sql)
            self.con.commit()
            return "Представление last_task создано!"
        except Exception as e:
            self.con.rollback()
            return f"Ошибка запроса: {e}"

    def show_view(self, view_name):
        """Вывести результат запроса к любому представлению по имени."""
        sql = f"select * from {view_name};"
        try:
            self.cur.execute(sql)
            res = self.cur.fetchall()
            return res
        except Exception as e:
            self.con.rollback()
            return f"Ошибка запроса: {e}"

    def refresh_view(self, view_name):
        """Обновить материализованное представление по имени."""
        sql = f"refresh materialized view {view_name};"
        try:
            self.cur.execute(sql)
            self.con.commit()
            return f"Представление {view_name} обновлено!"
        except Exception as e:
            self.con.rollback()
            return f"Ошибка запроса: {e}"
