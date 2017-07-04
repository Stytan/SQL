/*Транзакция - единая неделимая атомарная операция, может состоять из мелких действий, если любое из них выполнилось не успешно, то вся транзакция считается неуспешной - обычно откатывается в начало.
Подключаясь к СУБД вызываются процедуры или функции в теле которых реализованы транзакции.
*/

COMMIT - подтвердить/закрыть
ROLLBACK - откатить

Create 
TABLE Accounts(
		id int identity(1,1) primary key,
		idCard int, 
		firstName varchar(20),
		lastName varchar(20),
		balance float)

INSERT INTO Accounts VALUES(1,'Vasya','Pupkin',105)
INSERT INTO Accounts VALUES(2,'Petya','Vasilyev',106)
INSERT INTO Accounts VALUES(3,'Linker','Finelov',107)

BEGIN TRANSACTION NameTransaction
	DECLARE @summa float --баланс списываемого счёта
	DECLARE @payment float --необходимо списать (платёж)
	SET @peyment = 100
	SELECT @summa=balance
	FROM Accounts
	WHERE id=1
	IF(@summa<@peyment) 
		BEGIN
		PRINT 'Not enough money'
		ROLLBACK TRANSACTION NameTransaction
		END
	ELSE
		BEGIN
		UPDATE Accounts
		SET balance=balance-@payment
		WHERE id=1
		IF(@@ERROR<>0)
			BEGIN
			PRINT 'Can not charge card'
			ROLLBACK TRANSACTION NameTransaction
			END
		ELSE
			BEGIN
			UPDATE Accounts
			balance=balance+0.98*@payment
			WHERE id=2
			IF(@@ERROR<>)
				BEGIN
				PRINT 'Can not transfer funds'
				ROLLBACK TRANSACTION NameTransaction
				END
			ELSE
				BEGIN
					BEGIN TRY
						UPDATE Accounts
						balance=balance + 0.02*@payment
						WHERE id=3
					END TRY
					BEGIN CATCH
						PRINT 'INTERNAL ERROR, try again'
						SELECT ERROR_NUMBER() AS ErrorNumber
						ROLLBACK TRANSACTION NameTransaction
					END CATCH
					COMMIT TRANSACTION NameTransaction
				END
			END
		END
END	TRANSACTION
	

/*товары до 300 грн поднять на 2%
больше	300 снизить на 2%*/

BEGIN TRANSACTION
	DECLARE @average float
	SELECT @average=AVG(price) FROM Products
	IF(@average IS NOT NULL)
	BEGIN
		BEGIN TRY
			UPDATE Products
			SET price=price*1.02
			WHERE price<@average
			UPDATE Products
			SET price=price*0.98
			WHERE price>@average
		END TRY
		BEGIN CATCH
			PRINT 'ERROR'
			ROLLBACK TRANSACTION
		END CATCH
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
	END
	COMMIT TRANSACTION
END TRANSACTION


ДЗ
1.Уничтожить все отзывы на всех товарах от одного юзера и удалить самого юзера
2. На все товары от указанного поставщика которых на складе более 5 единиц сделать скидку, а тех которых меньше 5 единиц сделать бесплатную доставку	