--Создаём базу
CREATE DATABASE MarriageAgency;

GO

USE MarriageAgency;

GO

--Создаём таблицу стран
CREATE TABLE Countries
	(id int identity(1,1) not null
		Constraint PK_Countries primary key(id),
	name varchar(80) not null
		Constraint UniCountries UNIQUE(name));

GO

--Создаём таблицу городов
CREATE TABLE Cities
	(id int identity(1,1) not null
		Constraint PK_Cities primary key(id),
	name varchar(50) not null
		Constraint UniCities UNIQUE(name),
	idCountry int not null
		Constraint FK_Counties foreign key(idCountry)
			references Countries(id));		
GO

--Создаём таблицу цветов кожи
CREATE TABLE SkinColors
	(id int identity(1,1) not null
		Constraint PK_SkinColors primary key(id),
	name varchar(80) not null
		Constraint UniSkinColors UNIQUE(name));
GO

--Создаём таблицу цветов волос
CREATE TABLE HairColors
	(id int identity(1,1) not null
		Constraint PK_HairColors primary key(id),
	name varchar(80) not null
		Constraint UniHairColors UNIQUE(name));
GO

--Создаём таблицу профессий
CREATE TABLE Professions
	(id int identity(1,1) not null
		Constraint PK_Professions primary key(id),
	name varchar(255) not null
		Constraint UniProfessions UNIQUE(name));
GO

--Создаём таблицу хобби
CREATE TABLE Hobbies
	(id int identity(1,1) not null
		Constraint PK_Hobbies primary key(id),
	name varchar(255) not null
		Constraint UniHobbies UNIQUE(name));
GO

--Создаём таблицу требований
CREATE TABLE Requirements
	(id int identity(1,1) not null
		Constraint PK_Requirements primary key(id),
	age int,
	male bit not null,
	salary int,
	height int,
	weight int,
	idCountry int
		Constraint FK_ReqCountry foreign key(idCountry)
			references Countries(id),
	idSkinColor int
		Constraint FK_ReqSkinColor foreign key(idSkinColor)
			references SkinColors(id),
	idHairColor int
		Constraint FK_ReqHairColor foreign key(idHairColor)
			references HairColors(id),
	idProfession int
		Constraint FK_ReqProfession foreign key(idProfession)
			references Professions(id),
	idHobby int
		Constraint FK_ReqHobby foreign key(idHobby)
			references Hobbies(id));
GO

--Создаём таблицу партнеров/соискателей
CREATE TABLE Partners
	(id int identity(1,1) not null
		Constraint PK_Partners primary key(id),
	name varchar(80) not null,
	age int,
	male bit not null,
	salary int,
	height int,
	weight int,
	idRequirement int
		Constraint FK_Requirement foreign key(idRequirement)
			references Requirements(id),
	idCity int
		Constraint FK_PartnerCity foreign key(idCity)
			references Cities(id),
	idSkinColor int
		Constraint FK_PartnerSkinColor foreign key(idSkinColor)
			references SkinColors(id),
	idHairColor int
		Constraint FK_PartnerHairColor foreign key(idHairColor)
			references HairColors(id),
	idProfession int
		Constraint FK_PartnerProfession foreign key(idProfession)
			references Professions(id),
	idHobby int
		Constraint FK_PartnerHobby foreign key(idHobby)
			references Hobbies(id),
	idPartner int
		Constraint FK_Partner foreign key(idPartner)
			references Partners(id),
	photo varchar(255));
GO

--Создаём триггер который после добавления соискателя
--со ссылкой на партнера проставляет партнёру
--обратную ссылку на вставленного соискателя
CREATE TRIGGER updateIdPartnerOnInserted
ON Partners
AFTER INSERT
AS
BEGIN
	--Выбираем id партнёра
	DECLARE @idPartner int;
	SELECT @idPartner = idPartner
		FROM inserted;
	--Если он заполнен
	IF(@idPartner IS NOT NULL)
	BEGIN
		--Выбираем id вставленного соискателя
		DECLARE @idInserted int;
		SELECT @idInserted = id
			FROM Partners
			WHERE idPartner = @idPartner;
		--Поставляем партнёру в поле пары id вставленного
		UPDATE Partners 
			SET idPartner = @idInserted
			WHERE id = @idPartner;
	END
END;
GO

--Создаём триггер который после обновления соискателя
--со ссылкой на партнера проставляет партнёру
--обратную ссылку на обновленного соискателя
CREATE TRIGGER updateIdPartnerOnUpdated
ON Partners
AFTER UPDATE
AS
BEGIN
	--Выбираем id партнёра до обновления
	DECLARE @idOldPartner int;
	SELECT @idOldPartner = idPartner
		FROM deleted;
	--Выбираем id партнёра после обновления
	DECLARE @idNewPartner int;
	SELECT @idNewPartner = idPartner
		FROM inserted;
	--Если партнёр изменился
	IF(@idOldPartner != @idNewPartner)
	BEGIN
		--Выбираем id обновленного соискателя
		DECLARE @idUpdated int;
		SELECT @idUpdated = id
			FROM deleted;
		--Обновляем поле пары новому партнёру
		IF(@idNewPartner IS NOT NULL)
		BEGIN
			UPDATE Partners
			SET idPartner = @idUpdated
			WHERE id = @idNewPartner;
		END
		--Обновляем поле пары старому партнёру
		IF(@idOldPartner IS NOT NULL)
		BEGIN
			UPDATE Partners
			SET idPartner = NULL
			WHERE id = @idOldPartner;
		END
	END
END;
GO

--Функция возвращает id страны по названию
CREATE PROCEDURE getIdCountry
@country varchar(80),
@idCountry int OUTPUT
AS
BEGIN
	--Если страна заполнена
	IF(@country IS NOT NULL)
	BEGIN
		SELECT @idCountry = id
		FROM Countries
		WHERE name = @country;
		--Если это новая страна добавляем
		IF(@idCountry IS NULL)
		BEGIN
			INSERT INTO Countries
			VALUES(@country);
			SELECT @idCountry = id
			FROM Countries
			WHERE name = @country;
		END
	END
	RETURN;
END
GO

--Функция возвращает id города по названию
CREATE PROCEDURE getIdCity
@city varchar(50),
@country varchar(80),
@idCity int OUTPUT
AS
BEGIN
	--Если город заполнен
	IF(@city IS NOT NULL)
	BEGIN
		DECLARE @idCountry int;
		--Если страна заполнена
		EXECUTE getIdCountry @country, @idCountry OUTPUT;
		SELECT @idCity = id
		FROM Cities
		WHERE name = @city AND idCountry = @idCountry;
		--Если это новый город в этой стране добавляем
		IF(@idCity IS NULL)
		BEGIN
			INSERT INTO Cities
			VALUES(@city,@idCountry);
			SELECT @idCity = id
			FROM Cities
			WHERE name = @city AND idCountry = @idCountry;
		END
	END
	RETURN;
END;
GO

--Функция возвращает id цвета кожи
CREATE PROCEDURE getIdSkinColor
@skinColor varchar(80),
@idSkinColor int OUTPUT
AS
BEGIN
	IF(@skinColor IS NOT NULL)
	BEGIN
		SELECT @idSkinColor = id
		FROM SkinColors
		WHERE name = @skinColor;
		IF(@idSkinColor IS NULL)
		BEGIN
			INSERT INTO SkinColors
			VALUES(@skinColor);
			SELECT @idSkinColor = id
			FROM SkinColors
			WHERE name = @skinColor;
		END
	END
	RETURN;
END
GO

--Функция возвращает id цвета волос
CREATE PROCEDURE getIdHairColor
@hairColor varchar(80),
@idHairColor int OUTPUT
AS
BEGIN
	IF(@hairColor IS NOT NULL)
	BEGIN
		SELECT @idHairColor = id
		FROM HairColors
		WHERE name = @hairColor;
		IF(@idHairColor IS NULL)
		BEGIN
			INSERT INTO HairColors
			VALUES(@hairColor);
			SELECT @idHairColor = id
			FROM HairColors
			WHERE name = @hairColor;
		END
	END
	RETURN;
END
GO

--Функция возвращает id профессии
CREATE PROCEDURE getIdProfession
@profession varchar(255),
@idProfession int OUTPUT
AS
BEGIN
	IF(@profession IS NOT NULL)
	BEGIN
		SELECT @idProfession = id
		FROM Professions
		WHERE name = @profession;
		IF(@idProfession IS NULL)
		BEGIN
			INSERT INTO Professions
			VALUES(@profession);
			SELECT @idProfession = id
			FROM Professions
			WHERE name = @profession;
		END
	END
	RETURN;
END
GO

--Функция возвращает id хобби
CREATE PROCEDURE getIdHobby
@hobby varchar(255),
@idHobby int OUTPUT
AS
BEGIN
	IF(@hobby IS NOT NULL)
	BEGIN
		SELECT @idHobby = id
		FROM Hobbies
		WHERE name = @hobby;
		IF(@idHobby IS NULL)
		BEGIN
			INSERT INTO Hobbies
			VALUES(@hobby);
			SELECT @idHobby = id
			FROM Hobbies
			WHERE name = @hobby;
		END
	END
	RETURN;
END
GO

--Процедура возвращает id партнера
CREATE PROCEDURE getIdPartner
@partner varchar(80),
@idPartner int OUTPUT
AS
BEGIN
	IF(@partner IS NOT NULL)
	BEGIN
		SELECT @idPartner = COUNT(id)
		FROM Partners
		WHERE name = @partner;
		IF(@idPartner=1)
		BEGIN
			SELECT @idPartner = id
			FROM Partners
			WHERE name = @partner;
		END
		ELSE
		BEGIN
			PRINT('ERROR: Found more than one partner with that name. Partner set to NULL.');
			SET @idPartner = NULL;
		END
	END
	RETURN;
END
GO

--Процедура вставки нового соискателя без требований
CREATE PROCEDURE addPartner
@name varchar(80),
@age int,
@male bit,
@salary int,
@height int,
@weight int,
@city varchar(50),
@country varchar(80),
@skinColor varchar(80),
@hairColor varchar(80),
@profession varchar(255),
@hobby varchar(255),
@partner varchar(80),
@photo varchar(255)
AS
BEGIN
	DECLARE @idCity int;
	DECLARE @idSkinColor int;
	DECLARE @idHairColor int;
	DECLARE @idProfession int;
	DECLARE @idHobby int;
	DECLARE @idPartner int;
	EXECUTE getIdCity @city, @country, @idCity OUTPUT;
	EXECUTE getIdSkinColor @skinColor, @idSkinColor OUTPUT;
	EXECUTE getIdHairColor @hairColor, @idHairColor OUTPUT;
	EXECUTE getIdProfession @profession, @idProfession OUTPUT;
	EXECUTE getIdHobby @hobby, @idHobby OUTPUT;
	EXECUTE getIdPartner @partner, @idPartner OUTPUT;
	INSERT INTO Partners
	VALUES(@name,@age,@male,@salary,@height,@weight,NULL,
		@idCity,@idSkinColor,@idHairColor,@idProfession,
		@idHobby,@idPartner,@photo);
END
GO

--Процедура вставки требований соискателя
CREATE PROCEDURE addRequirement
@name varchar(80),
@age int,
@male bit,
@salary int,
@height int,
@weight int,
@country varchar(80),
@skinColor varchar(80),
@hairColor varchar(80),
@profession varchar(255),
@hobby varchar(255),
@idRequirement int  OUTPUT
AS
BEGIN
	DECLARE @idPartner int;
	EXECUTE getIdPartner @name, @idPartner OUTPUT;
	IF(@idPartner IS NOT NULL)
	BEGIN
		DECLARE @idCountry int;
		DECLARE @idSkinColor int;
		DECLARE @idHairColor int;
		DECLARE @idProfession int;
		DECLARE @idHobby int;	
		EXECUTE getIdCountry @country, @idCountry OUTPUT;
		EXECUTE getIdSkinColor @skinColor, @idSkinColor OUTPUT;
		EXECUTE getIdHairColor @hairColor, @idHairColor OUTPUT;
		EXECUTE getIdProfession @profession, @idProfession OUTPUT;
		EXECUTE getIdHobby @hobby, @idHobby OUTPUT;
		INSERT INTO Requirements
		VALUES(@age, @male, @salary, @height, @weight, @idCountry,
			@idSkinColor, @idHairColor, @idProfession, @idHobby);
		SELECT @idRequirement = id
		FROM Requirements
		WHERE age = @age AND male = @male AND salary = @salary
			AND height = @height AND weight = @weight
			AND idCountry = @idCountry AND idSkinColor = @idSkinColor
			AND idHairColor = @idHairColor AND idProfession = @idProfession
			AND idHobby = @idHobby;
	END
	RETURN;
END
GO

EXECUTE addPartner 'Василий Иванович Аношкин', 42, TRUE, 500, 180, 85,
	'Киев', 'Украина', 'светлый', 'чёрный', 'водитель автотранспортных средств',
	'садоводство', NULL, NULL;
	
EXECUTE addPartner 'Анна Петровна Каренина', 38, FALSE, 550, 165, 66,
	'Харьков', 'Украина', 'белый', 'русый', 'менеджер по продажам',
	'вышивка', NULL, 'e:\photos\KareninaAP.jpg';
	
EXECUTE addPartner 'Федор Алексеевич Пимкин', 36, TRUE, 600, 173, 76,
	'Запорожье', 'Украина', 'смуглый', 'каштановый', 'слесарь по ремонту автомобилей',
	NULL, NULL, 'e:\photos\PimkinFP.jpg';

EXECUTE addPartner 'Василиса Васильевна Прекрасная', 33, FALSE, 500, 175, 68,
	'Уфа', 'Россия', 'белый', 'рыжий', 'швея',
	'стрельба из лука', NULL, 'e:\photos\PrekrasnayaVV.jpg';

EXECUTE addPartner 'Пётр Игнатьевич Рыжий', 37, TRUE, 1200, 183, 80,
	'Уфа', 'Россия', 'белый', 'чёрный', 'начальник цеха',
	'охота', 'Василиса Васильевна Прекрасная', 'e:\photos\RuzhiyPI.jpg';

EXECUTE addPartner 'Игорь Сергеевич Беспалый', 54, TRUE, 850, 177, 74,
	'Луганск', 'Украина', 'светлый', 'седой', 'танкист',
	'вымогательство', NULL, NULL;
	
EXECUTE addPartner 'Алексей Кирилович Вахненко', 45, TRUE, 600, 156, 64,
	'Запорожье', 'Украина', 'светлый', 'русый', 'водопроводчик доменной печи',
	NULL, NULL, 'e:\photos\VahnenkoAK.jpg';
	
EXECUTE addPartner 'Максим Тимурович Палько', 42, TRUE, 630, 171, 87,
	'Львов', 'Украина', 'смуглый', 'каштановый', 'хирург',
	'живопись', NULL, 'e:\photos\PalkoMT.jpg';
	
EXECUTE addPartner 'Михаил Михайлович Михайлов', 43, TRUE, 520, 167, 71,
	'Херсон', 'Украина', 'светлый', 'русый', 'инженер-конструктор',
	'настольный теннис', NULL, 'e:\photos\MihailovMM.jpg';
	
EXECUTE addPartner 'Раиса Ивановна Светличная', 52, FALSE, 300, 165, 83,
	'Луганск', 'Украина', 'белый', 'чёрный', 'домохозяйка',
	'самогоноварение', 'Игорь Сергеевич Беспалый', 'e:\photos\SvetlichnayaRI.jpg';
	
EXECUTE addPartner 'Джори Випаски', 38, TRUE, 2500, 173, 78,
	'Париж', 'Франция', 'черный', 'черный', 'монтажник',
	'рыбалка', NULL, 'e:\photos\VipaskiD.jpg';

