use pp2707_Lezhenko; --����� ���� �� �������

INSERT INTO Clients VALUES('Vasya','Ivanov','1342214');

/*
��������� ���������� ������ � ��������
INSERT
UPDATE
DELETE
DROP
CREATE
ALTER
*/

--������������� ������� - �������� � 2012 ������ �������
INSERT INTO Clients(firstName,tel) VALUES('Petya','4654'),
('Kolya','Petrov');

UPDATE Producers 
SET _name='Samsung'
WHERE id=2 AND (address LIKE '%Gyeongg%')

/*�� ��� ������ ���� ������� ���� ������� �� �����
��������� ������ 10%, �.�. �������� �� ����*/
UPDATE Products
SET price=price*0.9
WHERE price > (SELECT AVG(price) FROM Products);

/*��� ���� ������� � ������� ���� �� ������
� ���� ���� �������� ��� ����*/

UPDATE Products
SET photo='��� ����'
WHERE photo IS NULL;

DELETE FROM Clients
WHERE lastName IS NULL;

/*������ �������, �������������, �������, ����, ���������
�������, �����������, �������*/
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

/*�������� ��������� �������, �������, ���������*/
ALTER TABLE Sales ADD discount float;

ALTER TABLE Sales ALTER COLUMN discount int;

ALTER TABLE SALES DROP COLUMN discount;

DROP TABLE Sales;

--statement.executeNonQuerry("ALTER TABLE SALES DROP COLUMN discount");