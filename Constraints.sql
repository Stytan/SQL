use pp2707_Lezhenko;

--Полная запись
CREATE TABLE CPU(id int identity(1,1) not null
				Constraint PK_1 primary key(id),
				model varchar(25));

--Краткая запись
CREATE TABLE CPU(id int identity(1,1) not null primary key(id),
				model varchar(25));

CREATE TABLE VideoCards(id int identity(1,1) not null constraint MyPk primary key(id),
	model varchar(25),
	frequency int not null constraint fr_chk check(frequency>1000),
	interface varchar(5) not null constraint int_chk check(interface in('AGP','PCI-E')));

INSERT INTO VideoCards(model,frequency,interface)
	VALUES('NVIDIA GTX460',1500,'AGP');

CREATE TABLE Vendors(id int identity(1,1) not null constraint MyPk2 primary key(id),
	vendor varchar(25) constraint myUnique unique(vendor));

INSERT INTO Vendors(vendor)
	VALUES('Palit');

CREATE TABLE Motherboard(id int identity(1,1) not null constraint PK_3 primary key(id),
	name varchar(25),
	idCPU int constraint FK_1 foreign key(idCPU)
		references CPU(id) 
			on update cascade 
			on delete cascade);

INSERT INTO CPU(model) VALUES('Q6600');

DECLARE @idCPU int;
SET @idCPU = (SELECT id FROM CPU WHERE model = 'Q6600');

INSERT INTO Motherboard(name,idCPU)
	VALUES('ASUS P5B',@idCPU);

SELECT * FROM Products
WHERE price > 100
GROUP BY
HAVING count(*)<5;

--Составной первичный ключ
Passport

CREATE TABLE Passport(
	num int not null,
	ser varchar(2) not null,
	name varchar(15),
	constraint PK_MULTI1
	primary key(num, ser));

SELECT name 
	FROM Passport 
	WHERE num=6575 AND ser='SA';

EXECUTE sp_help Passport;

EXECUTE sp_help Products;
