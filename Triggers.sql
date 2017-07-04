use pp2707_Lezhenko;

CREATE Trigger noProductInsertionByAddress
ON Products
FOR INSERT
AS
BEGIN
	DECLARE @id int
	SELECT @id = idProducer
	FROM inserted
	WHERE idProducer NOT IN
		(SELECT id FROM Producers
		WHERE address LIKE '%Wonderland%')
	IF(@id IS NULL) ROLLBACK;
END

CREATE Trigger noProductUpdatingByAddress
ON Products
FOR UPDATE
AS
BEGIN
	DECLARE @id int
	SELECT @id = idProducer
	FROM inserted
	WHERE idProducer NOT IN
		(SELECT id FROM Producers
		WHERE address LIKE '%Wonderland%')
	IF(@id IS NULL) ROLLBACK;
END

insert into Products VALUES(1,1,'Стул',452,3,'descr','photo',NULL,NULL,'world');

UPDATE Products SET idProducer = 1 WHERE idProducer=2;

CREATE TRIGGER noDeleteReview
ON Reviews
INSTEAD OF DELETE
AS
BEGIN
	PRINT 'You can not delete a review'
	ROLLBACK
END

DELETE FROM Reviews;

CREATE Trigger noProductDeleteByCategory
ON Products
FOR DELETE
AS
BEGIN
	DECLARE @id int
	SELECT @id = idCategory
	FROM deleted
	WHERE idCategory NOT IN
		(SELECT id FROM Categories
		WHERE _name LIKE '%Телефоны%')
	IF(@id IS NULL) ROLLBACK;
END

DELETE FROM Products WHERE id=2;

--Если цена товара меньше среднерыночной то ставить среднерыночкую
CREATE TRIGGER AVGPrice
ON Products
FOR INSERT
AS
BEGIN
	declare @price float
	DECLARE @actualPrice float
	SELECT @price=AVG(price)
	FROM Products;
	SELECT @actualPrice=price
	FROM inserted;
	IF(@actualPrice<@price)
	BEGIN
		DECLARE @data TABLE(idCategory int, idProducer int, _name nvarchar(255),
			price float, quantity int, photo nvarchar(255),
			idReview int, barcode nvarchar(255), delivery nvarchar(255))
		INSERT INTO @data
		SELECT idCategory, idProducer, _name,
			price, quantity, photo,
			idReview, barcode, delivery FROM inserted;
		UPDATE @data set price = @price;
		INSERT INTO Products(idCategory, idProducer, _name,
			price, quantity, photo,
			idReview, barcode, delivery)
		SELECT idCategory, idProducer, _name,
			price, quantity, photo,
			idReview, barcode, delivery from @data;
		ROLLBACK;
	END
END

CREATE TRIGGER AVGPriceProduct
ON Products
AFTER INSERT
AS
BEGIN
	Declare @price float
	DECLARE @actualPrice float
	SELECT @price=avg(price)
	FROM Products
	SELECT @actualPrice=price from inserted
	if(@actualPrice<@price)
	BEGIN
		UPDATE Products
		SET price=@price
		WHERE id=(SELECT id FROM inserted)
	END
END

--ПОСЛЕ вставке товара категории 3 вывести сообщение
CREATE TRIGGER PrintOn
ON Products
AFTER INSERT
AS
BEGIN
	DECLARE @idCat int;
	SELECT @idCat = idCategory
	FROM inserted;
	DECLARE @name nvarchar(255);
	SELECT @name = _name
	FROM inserted;
	IF(@idCat=3)
	PRINT 'Inserted ' + @name;
END

insert into Products VALUES(3,1,'Стул',452,3,'descr','photo',NULL,NULL,'world');