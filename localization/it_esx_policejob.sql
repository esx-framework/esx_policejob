INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_police', 'Polizia', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_police', 'Polizia', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_police', 'Polizia', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('police', 'Polizia')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('police',0,'recruit','Recluta',20,'{}','{}'),
	('police',1,'officer','Agente',40,'{}','{}'),
	('police',2,'sergeant','Sergente',60,'{}','{}'),
	('police',3,'lieutenant','Tenente',85,'{}','{}'),
	('police',4,'boss','Capo',100,'{}','{}')
;

CREATE TABLE `fine_types` (
	`id` int NOT NULL AUTO_INCREMENT,
	`label` varchar(255) DEFAULT NULL,
	`amount` int DEFAULT NULL,
	`category` int DEFAULT NULL,

	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


INSERT INTO `fine_types` (label, amount, category) VALUES
	('Utilizzo improprio del clacson', 30, 0),
	('Attraversamento illegale di una linea continua', 40, 0),
	('Guida contromano', 250, 0),
	('Inversione di marcia illegale', 250, 0),
	('Guida illegale fuoristrada', 170, 0),
	('Rifiuto di un ordine di un LEO (Law Enforcement Officer)', 30, 0),
	('Arresto illegale di un veicolo', 150, 0),
	('Parcheggio illegale', 70, 0),
	('Mancata precedenza a destra', 70, 0),
	('Mancato rispetto delle informazioni sul veicolo', 90, 0),
	('Mancato arresto ad un segnale di stop', 105, 0),
	('Mancato arresto a un semaforo rosso', 130, 0),
	('Sorpasso illegale', 100, 0),
	('Guida di un veicolo illegale', 100, 0),
	('Guida senza patente', 1500, 0),
	('Investire e fuggire', 800, 0),
	('Eccesso di velocità oltre < 5 mph', 90, 0),
	('Eccesso di velocità oltre 5-15 mph', 120, 0),
	('Eccesso di velocità oltre 15-30 mph', 180, 0),
	('Eccesso di velocità oltre > 30 mph', 300, 0),
	('Ostacolo al flusso del traffico', 110, 1),
	('Ubriachezza molesta', 90, 1),
	('Comportamento disordinato', 90, 1),
	('Intralcio alla giustizia', 130, 1),
	('Insulti verso i civili', 75, 1),
	('Mancato rispetto nei confronti di un LEO (Law Enforcement Officer)', 110, 1),	
	('Minaccia verbale verso un civile', 90, 1),
	('Minaccia verbale verso un LEO (Law Enforcement Officer)', 150, 1),
	('Fornito informazioni false', 250, 1),
	('Tentativo di corruzione', 1500, 1),
	('Sfoggiato un arma in città', 120, 2),
	('Sfoggiato un arma letale in città', 300, 2),
	('Assenza di licenza per porto d armi', 600, 2),
	('Possesso di un arma illegale', 700, 2),
	('Possesso di attrezzi per scasso', 300, 2),
	('Furto di un auto', 1800, 2),
	('Tentativo di vendita/distribuzione di una sostanza illegale', 1500, 2),
	('Falsificazione di una sostanza illegale', 1500, 2),
	('Possesso di una sostanza illegale', 650, 2),
	('Sequestro di un civile', 1500, 2),
	('Sequestro di un LEO (Law Enforcement Officer)', 2000, 2),
	('Rapina', 650, 2),
	('Rapina armata di un negozio', 650, 2),
	('Rapina armata di una banca', 1500, 2),
	('Aggressione a un civile', 2000, 3),
	('Aggressione a un LEO (Law Enforcement Officer)', 2500, 3),
	('Tentativo di omicidio di un civile', 3000, 3),
	('Tentativo di omicidio di un LEO (Law Enforcement Officer)', 5000, 3),
	('Omicidio di un civile', 10000, 3),
	('Omicidio di un LEO (Law Enforcement Officer)', 30000, 3),
	('Omicidio colposo', 1800, 3),
	('Frode', 2000, 2);
;
