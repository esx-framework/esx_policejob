INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_police', 'Policija', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_police', 'Policija', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_police', 'Policija', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('police', 'Policija')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('police',0,'recruit','Regrut',20,'{}','{}'),
	('police',1,'officer','Oficir',40,'{}','{}'),
	('police',2,'sergeant','Narednik',60,'{}','{}'),
	('police',3,'lieutenant','Poručnik',85,'{}','{}'),
	('police',4,'boss','Načelnik',100,'{}','{}')
;

CREATE TABLE `fine_types` (
	`id` int NOT NULL AUTO_INCREMENT,
	`label` varchar(255) DEFAULT NULL,
	`amount` int DEFAULT NULL,
	`category` int DEFAULT NULL,

	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


INSERT INTO `fine_types` (label, amount, category) VALUES
	('Zloupotreba sirene', 30, 0),
	('Prelazak preko pune linije', 40, 0),
	('Vožnja u pogrešnom smeru', 250, 0),
	('Skretanje u U', 250, 0),
	('Vožnja van puta', 170, 0),
	('Odbijanje naredbe', 30, 0),
	('Ilegalno zaustavljanje vozila', 150, 0),
	('Ilegalno parkiranje', 70, 0),
	('Ne propuštanje udesno', 70, 0),
	('Netačne informacije o vozilu', 90, 0),
	('Ne zaustavljanje na STOP znak ', 105, 0),
	('Prolazak kroz crveno svetlo', 130, 0),
	('Ilegalni prolazak', 100, 0),
	('Vožnja ilegalnog vozila', 100, 0),
	('Vožnja bez vozačke dozvole', 1500, 0),
	('Bežanje sa mesta nesreće', 800, 0),
	('Prekoračenje brzine < 5 kmh', 90, 0),
	('Prekoračenje brzine 5-15 kmh', 120, 0),
	('Prekoračenje brzine 15-30 kmh', 180, 0),
	('Prekoračenje brzine > 30 kmh', 300, 0),
	('Ometanje saobraćaja', 110, 1),
	('Javna intoksikacija', 90, 1),
	('Napastvovanje', 90, 1),
	('Nepoštovanje suda', 130, 1),
	('Uvrede prema civilima', 75, 1),
	('Uvrede prema službenom licu', 110, 1),
	('Napad na civila', 90, 1),
	('Napad na službeno lice', 150, 1),
	('Davanje lažne izjave', 250, 1),
	('Pokušaj korupcije', 1500, 1),
	('Mahanje oružjem u gradu', 120, 2),
	('Mahanje smrtonosnim oružjem u gradu', 300, 2),
	('Posedovanje oružja bez dozvole', 600, 2),
	('Posedovanje ilegalnog oružja', 700, 2),
	('Posedovanje alata za provalu', 300, 2),
	('Luda vožnja', 1800, 2),
	('Pokušaj prodaje ilegalnih supstanci', 1500, 2),
	('Prodaja ilegalnih supstanci', 1500, 2),
	('Posedovanje ilegalnih supstanci ', 650, 2),
	('Kidnapovanje civila', 1500, 2),
	('Kidnapovanje službenog lica', 2000, 2),
	('Pljačka', 650, 2),
	('Oružana pljačka prodavnice', 650, 2),
	('Oružana pljačka banke', 1500, 2),
	('Oružani napad na civila', 2000, 3),
	('Oružani napad na službeno lice', 2500, 3),
	('Pokusaj ubistva civila', 3000, 3),
	('Pokusaj ubistva službenog lica', 5000, 3),
	('Ubistvo civila', 10000, 3),
	('Ubistvo službenog lica', 30000, 3),
	('Ubistvo bez predomišljaja', 1800, 3),
	('Prevara', 2000, 2);
;
