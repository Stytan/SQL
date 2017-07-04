use pp2707_Lezhenko;

--������ ������
CREATE VIEW BriefInfo
AS
SELECT Products.id AS 'id',
		Categories._name AS 'category',
		Producers._name AS 'produce',
		Products._name AS 'product',
		Products.price AS 'price',
		Products.delivery AS 'delivery'
FROM (Producers
	INNER JOIN Products ON Producers.id = Products.idProducer)
	INNER JOIN Categories ON Categories.id=Products.idCategory;
--ORDER BY Products.price

SELECT id, product, price FROM BriefInfo;

UPDATE BriefInfo
SET PRICE=Price*1.1;

INSERT INTO BriefInfo
VALUES(product = '�����');

--������� ������ ������� ������� ������ � ������� ������������� = �������� � ���������� ������ 2
CREATE VIEW Tovars
AS
SELECT _name AS 'Product', quantity AS 'Quant', price AS 'Price' 
FROM Products
WHERE idProducer = 
	(SELECT id
	FROM Producers
	WHERE _name LIKE 'Samsung')
	AND quantity>2;

--�������� �������� ������� �������� ����� � ������� ����� 20 ��������
CREATE VIEW ClientsRev
AS
SELECT CONCAT(CAST(firstname AS varchar(20)), CAST(lastname AS varchar(20))) AS 'Name',
	tel AS 'Telephone'
FROM Clients
WHERE EXISTS 
	(SELECT id
	FROM Reviews
	WHERE Reviews.idClients=Clients.id AND LEN(_name)>20);

--�� � ��� ��� �������� ������ � ������� ������