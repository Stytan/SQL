use pp2707_Lezhenko; --выбор базы на сервере

INSERT INTO Clients VALUES('Vasya','Ivanov','1342214');

/*
Операторы обновления данных в таблицах
INSERT
UPDATE
DELETE
DROP
CREATE
ALTER
*/

--Множественная вставка - работает с 2012 версии сервера
INSERT INTO Clients(firstName,tel) VALUES('Petya','4654'),
('Kolya','Petrov');

UPDATE Producers 
SET _name='Samsung'
WHERE id=2 AND (address LIKE '%Gyeongg%')

/*На все товары цена которых выше вредней по рынку
применить скидку 10%, т.е. изменить их цену*/
UPDATE Products
SET price=price*0.9
WHERE price > (SELECT AVG(price) FROM Products);

/*Для всех товаров у которых фото не задано
в поле фото написать НЕТ фото*/

UPDATE Products
SET photo='нет фото'
WHERE photo IS NULL;

DELETE FROM Clients
WHERE lastName IS NULL;

/*Создаёт таблицы, представления, таблицы, базы, процедуры
тригеры, органичения, индексы*/
CREATE TABLE Sales(id int identity(1,1) primary key,
					idProduct int NOT NULL,
					quantity int NOT NULL,
					idClient int NOT NULL,
					_date smalldatetime NOT NULL);

INSERT INTO Sales(idProduct, quantity, idClient, _date)
			VALUES(5,6,23,'01/02/2017');
INSERT INTO Sales(idProduct, quantity, idClient, _date)
			VALUES(2,3,2,'05/04/2017');
INSERT INTO Sales(idProduct, quantity, idClient, _date)
			VALUES(1,5,2,'01/01/2017');

/*изменить структуру таблицы, функции, процедуры*/
ALTER TABLE Sales ADD discount float;

ALTER TABLE Sales ALTER COLUMN discount int;

ALTER TABLE SALES DROP COLUMN discount;

DROP TABLE Sales;

--statement.executeNonQuerry("ALTER TABLE SALES DROP COLUMN discount");