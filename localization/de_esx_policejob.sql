INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_police', 'Polizei', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_police', 'Polizei', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_police', 'Polizei', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('police', 'Polizei')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('police',0,'recruit','Rekrut',20,'{}','{}'),
	('police',1,'officer','Polizist',40,'{}','{}'),
	('police',2,'sergeant','Feldwebel',60,'{}','{}'),
	('police',3,'lieutenant','Leutnant',85,'{}','{}'),
	('police',4,'boss','Chef',100,'{}','{}')
;

CREATE TABLE `fine_types` (
	`id` int NOT NULL AUTO_INCREMENT,
	`label` varchar(255) DEFAULT NULL,
	`amount` int DEFAULT NULL,
	`category` int DEFAULT NULL,

	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


INSERT INTO `fine_types` (label, amount, category) VALUES
	('Falsche nutzung der Hupe', 30, 0),
	('Unerlaubtes Überschreiten einer durchgezogenen Linie', 40, 0),
	('Auf der Falschen Straßenseite fahren', 250, 0),
	('Illegaler U-Turn', 250, 0),
	('Illegal Off-Road fahren', 170, 0),
	('Anweisung eines Gesetzeshüter missachtet', 30, 0),
	('Illegales Fahrzeuganhalten', 150, 0),
	('Illegales Parken', 70, 0),
	('Missachtung des Rechtsabbiegegebot', 70, 0),
	('Nichteinhaltung der Fahrzeuginformationen', 90, 0),
	('Nicht am Stopschild gehalten', 105, 0),
	('Rote Ampel überfahren', 130, 0),
	('Illegales Überfahren', 100, 0),
	('Fahren eines illegalen Fahrzeuges', 100, 0),
	('Fahren ohne Führerschein', 1500, 0),
	('Fahrerflucht', 800, 0),
	('Geschwindigkeitsüberschreitung über < 5 mph', 90, 0),
	('Geschwindigkeitsüberschreitung über 5-15 mph', 120, 0),
	('Geschwindigkeitsüberschreitung über 15-30 mph', 180, 0),
	('Geschwindigkeitsüberschreitung über > 30 mph', 300, 0),
	('Beeinträchtigung des Straßenvehrkehrs', 110, 1),
	('Betrunkenes Fahren', 90, 1),
	('Ordnungswidriges Verhalten', 90, 1),
	('Behinderung der Justiz', 130, 1),
	('Beleidigungen gegenüber Zivilisten', 75, 1),
	('Respektloses Verhalten gegenüber eines Polizisten', 110, 1),
	('Verbale Drohung gegenüber einer Zivilperson', 90, 1),
	('Verbale Drohung gegenüber eines Polizisten', 150, 1),
	('Verbreiten von Falschinformationen', 250, 1),
	('Versuchte Kurroption', 1500, 1),
	('Führen einer Waffe innerhalb der Stadt', 120, 2),
	('Einsatz einer tödlichen Waffe im Stadtgebiet', 300, 2),
	('Kein Waffenschein', 80000, 2),
	('Besitz einer illegalen Waffe', 700, 2),
	('Besitz von Einbruchswerkzeug', 300, 2),
	('Auto Diebstahl', 1800, 2),
	('Absicht zum Verkauf/Distribution einer illegalen Substanz', 1500, 2),
	('Betrug einer illegalen Substanz', 1500, 2),
	('Besitz einer illegalen Substanz ', 6520, 2),
	('Entführung eines Zivilisten', 15000, 2),
	('Entführung eines Polizisten', 20000, 2),
	('Diebstahl', 650, 2),
	('Bewaffneter Raubüberfall auf einen Laden', 650, 2),
	('Bewaffneter Raubüberfall auf eine Bank', 1500, 2),
	('Angriff auf einen Zivilisten', 2000, 3),
	('Angriff auf einen Polizisten', 2500, 3),
	('Versuchter Mord eines Zivilisten', 3000, 3),
	('Versuchter Mord eines Polizisten', 5000, 3),
	('Mörder eines Zivilisten', 100000, 3),
	('Mörder eines Polizisten', 300000, 3),
	('Unfreiwillige Tötung', 1800, 3),
	('Betrug', 2000, 2);
;
