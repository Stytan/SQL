--Создаём базу
CREATE DATABASE MarriageAgency;

USE MarriageAgency;

--Создаём таблицу стран
CREATE TABLE Countries
	(id int identity(1,1) not null
		Constraint PK_Countries primary key(id),
	name varchar(80) not null
		Constraint UniCountries UNIQUE(name));

--Создаём таблицу городов
CREATE TABLE Cities
	(id int identity(1,1) not null
		Constraint PK_Cities primary key(id),
	name varchar(50) not null
		Constraint UniCities UNIQUE(name),
	idCountry int not null
		Constraint FK_Counties foreign key(idCountry)
			references Countries(id));		

--Создаём таблицу цветов кожи
CREATE TABLE SkinColors
	(id int identity(1,1) not null
		Constraint PK_SkinColors primary key(id),
	name varchar(80) not null
		Constraint UniSkinColors UNIQUE(name));

--Создаём таблицу цветов волос
CREATE TABLE HairColors
	(id int identity(1,1) not null
		Constraint PK_HairColors primary key(id),
	name varchar(80) not null
		Constraint UniHairColors UNIQUE(name));

--Создаём таблицу профессий
CREATE TABLE Professions
	(id int identity(1,1) not null
		Constraint PK_Professions primary key(id),
	name varchar(255) not null
		Constraint UniProfessions UNIQUE(name));

--Создаём таблицу хобби
CREATE TABLE Hobbies
	(id int identity(1,1) not null
		Constraint PK_Hobbies primary key(id),
	name varchar(255) not null
		Constraint UniHobbies UNIQUE(name));

--Создаём таблицу требований
CREATE TABLE Requirements
	(id int identity(1,1) not null
		Constraint PK_Requirements primary key(id),
	age int,
	male boolean not null,
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

--Создаём таблицу партнеров/соискателей
CREATE TABLE Partners
	(id int identity(1,1) not null
		Constraint PK_Partners primary key(id),
	name varchar(80) not null,
	age int,
	male boolean not null,
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

--Функция возвращает id страны по названию
CREATE FUNCTION getIdCountry
(@country varchar(80))
RETURNS int
AS
BEGIN
	DECLARE @idCountry int;
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
	RETURN(@idCountry);
END

--Функция возвращает id города по названию
CREATE FUNCTION getIdCity
(@city varchar(50), @country varchar(80))
RETURNS int
AS
BEGIN
	DECLARE @idCity int;
	--Если город заполнен
	IF(@city IS NOT NULL)
	BEGIN
		DECLARE @idCountry int;
		--Если страна заполнена
		SELECT @idCountry = getIdCountry(@country);
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
	RETURN(@idCity);
END;

--Функция возвращает id цвета кожи
CREATE FUNCTION getIdSkinColor
(@skinColor varchar(80))
RETURNS int
AS
BEGIN
	DECLARE @idSkinColor int;
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
	RETURN(@idSkinColor);
END

--Функция возвращает id цвета волос
CREATE FUNCTION getIdHairColor
(@hairColor varchar(80))
RETURNS int
AS
BEGIN
	DECLARE @idHairColor int;
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
	RETURN(@idHairColor);
END

--Функция возвращает id профессии
CREATE FUNCTION getIdProfession
(@profession varchar(255))
RETURNS int
AS
BEGIN
	DECLARE @idProfession int;
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
	RETURN(@idProfession);
END

--Функция возвращает id хобби
CREATE FUNCTION getIdHobby
(@hobby varchar(255))
RETURNS int
AS
BEGIN
	DECLARE @idHobby int;
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
	RETURN(@idHobby);
END

--Функция возвращает id партнера
CREATE FUNCTION getIdPartner
(@partner varchar(80))
RETURNS int
AS
BEGIN
	DECLARE @idPartner int;
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
			PRINT("ERROR: Found more than one partner with that name. Partner set to NULL.";
			SET @idPartner = NULL;
		END
	END
	RETURN(@idPartner);
END

--Процедура вставки нового соискателя без требований
CREATE PROCEDURE addPartner
@name varchar(80),
@age int,
@male boolean,
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
	SELECT @idCity = getIdCity(@city,@country);
	SELECT @idSkinColor = getIdSkinColor(@skinColor);
	SELECT @idHairColor = getIdHairColor(@hairColor);
	SELECT @idProfession = getIdProfession(@profession);
	SELECT @idHobby = getIdHobby(@hobby);
	SELECT @idPartner = getIdPartner(@partner);
	INSERT INTO Partners
	VALUES(@name,@age,@male,@salary,@height,@weight,NULL,
		@idCity,@idSkinColor,@idHairColor,@idProfession,
		@idHobby,@idPartner,@photo);
END

--Процедура вставки требований соискателя
CREATE PROCEDURE addRequirement
@name varchar(80),
@age int,
@male boolean,
@salary int,
@height int,
@weight int,
@country varchar(80),
@skinColor varchar(80),
@hairColor varchar(80),
@profession varchar(255),
@hobby varchar(255)
AS
BEGIN
	DECLARE @idPartner int;
	SELECT @idPartner = getIdPartner(@name);
	IF(@idPartner IS NOT NULL)
	BEGIN
		DECLARE @idCountry int;
		DECLARE @idSkinColor int;
		DECLARE @idHairColor int;
		DECLARE @idProfession int;
		DECLARE @idHobby int;	
		SELECT @idCountry = getIdCountry(@country);
		SELECT @idSkinColor = getIdSkinColor(@skinColor);
		SELECT @idHairColor = getIdHairColor(@hairColor);
		SELECT @idProfession = getIdProfession(@profession);
		SELECT @idHobby = getIdHobby(@hobby);
		INSERT INTO Requirements
		VALUES(@age,@male,@salary,@height,@weight,@idCountry,
			@idSkinColor,@idHairColor,@idProfession,
			@idHobby);
		DECLARE @idRequirement int;
		SELECT @idRequirement = id
		FROM Requirements
		WHERE age=@age AND male = @male AND salary = @salary
			AND height = @height AND weight = @weight
			AND idCountry = @idCountry AND idSkinColor = @idSkinColor
			AND idHairColor = @idHairColor AND idProfession = @idProfession
			AND idHobby = @idHobby;
	END
END



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
	
