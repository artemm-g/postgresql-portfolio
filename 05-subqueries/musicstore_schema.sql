-- ============================================================
-- Тема: подзапросы (в WHERE, вложенные, скалярные)
-- Предметная область: музыкальный магазин
-- ============================================================

create table musicstore (
    track_title varchar(255) not null,
    genre varchar(255) not null,
    price decimal(18, 2) not null,
    sold_num integer not null
);

insert into musicstore (track_title, genre, price, sold_num) values
('Bohemian Rhapsody', 'Rock', 150.00, 50),
('Thriller', 'Pop', 125.00, 45),
('Billie Jean', 'Pop', 100.00, 55),
('Hotel California', 'Rock', 800.00, 60),
('Stairway to Heaven', 'Rock', 200.00, 30),
('Rolling in the Deep', 'Pop', 970.00, 70),
('Smells Like Teen Spirit', 'Rock', 143.00, 40),
('Imagine', 'Pop', 187.00, 25),
('Sweet Child o'' Mine', 'Rock', 163.00, 35),
('Boogie Wonderland', 'Disco', 110.00, 65),
('Bad', 'Pop', 750.00, 75),
('Another Brick in the Wall', 'Rock', 130.00, 50),
('Stayin'' Alive', 'Disco', 140.00, 40),
('Purple Rain', 'Pop', 190.00, 28),
('Like a Prayer', 'Pop', 100.00, 60),
('We Will Rock You', 'Rock', 170.00, 33),
('Dancing Queen', 'Disco', 215.00, 22),
('Crazy', 'Pop', 155.00, 38),
('Let''s Dance', 'Disco', 120.00, 48),
('Every Breath You Take', 'Rock', 900.00, 68),
('I Will Always Love You', 'Pop', 185.00, 26),
('Bohemian Rhapsody', 'Rock', 150.00, 5),
('Thriller', 'Pop', 125.00, 3),
('Billie Jean', 'Pop', 100.00, 8),
('Hotel California', 'Rock', 800.00, 6),
('Stairway to Heaven', 'Rock', 200.00, 2),
('Bohemian Rhapsody', 'Rock', 150.00, 5),
('Thriller', 'Pop', 125.00, 3),
('Billie Jean', 'Pop', 100.00, 8),
('Hotel California', 'Rock', 800.00, 6),
('Stairway to Heaven', 'Rock', 200.00, 2),
('Bohemian Rhapsody', 'Rock', 150.00, 12),
('Hotel California', 'Rock', 800.00, 60);
