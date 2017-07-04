CREATE PROCEDURE TransferMoney
@Payment float,
@idFrom int,
@idTo int
AS
BEGIN
BEGIN TRANSACTION
	DECLARE @Sum float --payer's balance
	SELECT @Sum = balance
		FROM Accounts WHERE id = 1
	if (@Sum < @Payment)
		BEGIN
		PRINT 'Not enough money'
		ROLLBACK TRANSACTION
		END
	ELSE
		BEGIN
		UPDATE Accounts
		SET balance = balance - @Payment
		WHERE id = @idFrom
		if (@@ERROR <> 0)
			BEGIN
			PRINT 'Can not charge card'
			ROLLBACK TRANSACTION
			END
		ELSE
			BEGIN
			UPDATE Accounts
			SET balance = balance + 0.98 * @Payment
			WHERE id = @idTo
			if (@@ERROR <> 0)
				BEGIN
				PRINT 'Can not transfer funds'
				ROLLBACK TRANSACTION
				END
			ELSE
				BEGIN
				UPDATE Accounts
				SET balance = balance + 0.02 * @Payment
				WHERE id = 3
				if (@@ERROR <> 0)
					BEGIN
					PRINT 'Internal error. Try again later'
					ROLLBACK TRANSACTION
					END
				ELSE
					COMMIT TRANSACTION
				END
			END
		END
END

EXECUTE TransferMoney 50,2,1