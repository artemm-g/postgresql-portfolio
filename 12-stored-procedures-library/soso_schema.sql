-- База soso: пользователи для авторизации
create database soso;
\c soso;

create extension if not exists pgcrypto;

create table reg (
    id serial primary key,
    login text not null unique,
    password text not null,
    email text not null,
    last_enter timestamp,
    login_error varchar(55) default null,
    error_date timestamp default null
);

insert into reg (login, password, email, last_enter) values
('b4n', crypt('123', gen_salt('bf')), 'b4n@example.com', '2026-04-05 14:20:35'),
('velianator', crypt('456', gen_salt('bf')), 'velianator@example.com', '2026-04-05 14:25:35'),
('lyapis', crypt('789', gen_salt('bf')), 'lyapis@example.com', '2026-04-05 14:30:55');
