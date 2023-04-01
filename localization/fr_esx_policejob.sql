INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_police', 'Police', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_police', 'Police', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_police', 'Police', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('police', 'Police')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('police',0,'recruit','Recrue',20,'{}','{}'),
	('police',1,'officer','Officier',40,'{}','{}'),
	('police',2,'sergeant','Sergent',60,'{}','{}'),
	('police',3,'lieutenant','Lieutenant',85,'{}','{}'),
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
	("Utilisation abusive d'un klaxon", 30, 0),
	("Traversée illégale d'une ligne continue", 40, 0),
	("Conduite sur la mauvaise voie de circulation", 250, 0),
	("Demi-tour illégal", 250, 0),
	("Conduite illégale hors piste", 170, 0),
	("Refus d'obéir à un ordre légal", 30, 0),
	("Arrêt illégal d'un véhicule", 150, 0),
	("Stationnement illégal", 70, 0),
	("Ne pas céder le passage à droite", 70, 0),
	("Non-respect des informations du véhicule", 90, 0),
	("Ne pas s'arrêter à un panneau d'arrêt", 105, 0),
	("Ne pas s'arrêter à un feu rouge", 130, 0),
	("Dépassement illégal", 100, 0),
	("Conduite d'un véhicule illégal", 100, 0),
	("Conduite sans permis", 1500, 0),
	("Délit de fuite", 800, 0),
	("Excès de vitesse de moins de 5 mph", 90, 0),
	("Excès de vitesse de 5 à 15 mph", 120, 0),
	("Excès de vitesse de 15 à 30 mph", 180, 0),
	("Excès de vitesse de plus de 30 mph", 300, 0),
	("Obstruction de la circulation", 110, 1),
	("Ivresse publique", 90, 1),
	("Comportement désordonné", 90, 1),
	("Obstruction de la justice", 130, 1),
	("Insultes envers les civils", 75, 1),
	("Irrespect envers un agent de police", 110, 1),
	("Menace verbale envers un civil", 90, 1),
	("Menace verbale envers un agent de police", 150, 1),
	("Fourniture de fausses informations", 250, 1),
	("Tentative de corruption", 1500, 1),
	("Exhibition d'une arme en zone urbaine", 120, 2),
	("Exhibition d'une arme mortelle en zone urbaine", 300, 2),
	("Pas de licence pour les armes à feu", 600, 2),
	("Possession d'une arme illégale", 700, 2),
	("Possession d'outils de cambriolage", 300, 2),
	("Vol de voiture", 1800, 2),
	("Intention de vendre/distribuer une substance illégale", 1500, 2),
	("Fabrication d'une substance illégale", 1500, 2),
	("Possession d'une substance illégale", 650, 2),
	("Enlèvement d'un civil", 1500, 2),
	("Enlèvement d'un agent de police", 2000, 2),
	("Vol à main armée", 650, 2),
	("Vol à main armée d'un magasin", 650, 2),
	("Vol à main armée d'une banque", 1500, 2),
	("Agression sur un civil", 2000, 3),
	("Agression sur un agent de police", 2500, 3),
	("Tentative de meurtre sur un civil", 3000, 3),
	("Tentative de meurtre sur un agent de police", 5000, 3),
	("Meurtre d'un civil", 10000, 3),
	("Meurtre d'un agent de police", 30000, 3),
	("Homicide involontaire", 1800, 3),
	("Fraude", 2000, 2);
;
