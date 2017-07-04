use pp2707_Lezhenko;

/*��������� ����� ������ �� ����������, ������� ������� ����������
	����������:
	-����� ����������� �������� ������ ��������� � ���������(�������)
	-�������� � �����������
	-������������ ������ �� ����
*/

CREATE PROCEDURE getExpansiveProducts
WITH ENCRYPTION
AS
SELECT _name, price
FROM Products
WHERE price>500;

EXECUTE getExpansiveProducts;

CREATE PROCEDURE getProductsByProducerAndPrice
@Producer nvarchar(255),
@Price float
AS
BEGIN
	SELECT Products._name, Products.price,
	Producers._name
	FROM Products INNER JOIN Producers
		ON Products.idProducer = Producers.id
	WHERE price>@price AND
		Producers._name LIKE @Producer
END

sp_help getProductsByProducerAndPrice

EXECUTE getProductsByProducerAndPrice "LG",100;

CREATE PROCEDURE getCheepestProductAndClientByTel
@tel nvarchar(255),
@minPrice float out,
@client nvarchar(255) out
AS
BEGIN
	SELECT @minPrice = min(price)
	FROM Products
	SELECT @client = lastname
	FROM Clients
	WHERE tel = @tel
END

DECLARE @minPrice float
DECLARE @client nvarchar(255)
EXECUTE getCheepestProductAndClientByTel
	'54968', @minPrice, @client
SELECT @minPrice AS 'MIN', @client AS 'Client'

--�������� ����� ������� ����� �� �������� ���������
CREATE PROCEDURE getMaxPriceProductFromCategory
@Category nvarchar(255)
AS
BEGIN
	DECLARE @idCat int
	SELECT @idCat = id
		FROM Categories
		WHERE _name LIKE @Category

	DECLARE @maxPrice float
	SELECT @maxPrice = max(price)
		FROM Products
		WHERE idCategory = @idCat
	
	SELECT Products._name AS 'Product'
	FROM Products
	WHERE idCategory =  @idCat
		AND price = @maxPrice
END

EXECUTE getMaxPriceProductFromCategory '��������';

CREATE PROCEDURE Discount
@percent float
AS
UPDATE Products
SET price = price * @percent;

--FUNCTION
--������� ������ ���������� ������� ��������� N ������
CREATE FUNCTION ProductByQuantity
(@q int)
RETURNS @res table(name nvarchar(255),
					price float,
					q int)
AS
BEGIN
	INSERT @res
	SELECT _name, price, quantity
	FROM Products
	WHERE quantity > @q
return
END

SELECT * FROM ProductByQuantity(2);

--�������� ������ � �������� �� ���� ������
CREATE FUNCTION ReviewsAndClientsByProduct
(@idProd int)
RETURNS @res TABLE(Client nvarchar(255),
					Reviews nvarchar(255))
AS
BEGIN
	INSERT @res
	SELECT firstname+' '+lastname, Reviews._name
	FROM Reviews INNER JOIN Clients
	ON Reviews.idClient = Clients.id
	WHERE Reviews.id = 
		(SELECT idReview 
		FROM Products
		WHERE id=@idProd)
	return
END

SELECT * FROM ReviewsAndClientsByProduct(2);

--������� ���� �� N% ������� �� ������ � ������� ��� �����
--��� ���� �������� ���� �� M% �� ������ 
--� ������� ������ ������������� %S

CREATE PROCEDURE ChangePrice
@N int,
@M int,
@S nvarchar(255)
AS
BEGIN
BEGIN TRANSACTION
	UPDATE Products
	SET price=price*(@N/100)
	WHERE photo IS NOT NULL

	UPDATE Products
	SET price=price*(@M/100)
	WHERE idProducer = 
		(SELECT id
		FROM Producers
		WHERE _name LIKE @S)

	COMMIT TRANSACTION
END

EXECUTE ChangePrice 25,11,'LG'

--�� -1,2 ���� ���������� ��������