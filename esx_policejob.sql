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
	('cia',0,'Senior Agent ','Trainer',10,'{}','{}'),
	('cia',1,'Agent','Agent',25,'{}','{}'),
	('cia',2,'Special agent','Special agent',35,'{}','{}'),
	('cia',3,'leader special agent','leader special agent',50,'{}','{}'),
	('cia',4,'boss','Chief',100,'{}','{}')
;

CREATE TABLE `fine_types` (
	`id` int NOT NULL AUTO_INCREMENT,
	`label` varchar(255) DEFAULT NULL,
	`amount` int DEFAULT NULL,
	`category` int DEFAULT NULL,

	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


INSERT INTO `fine_types` (label, amount, category) VALUES
        ("dudával való visszaélése", 30, 0),
	("Folytonos vonal átlépése", 40, 0),
	("Vezetés az út rossz oldalán", 250, 0),
	("jogellenes visszafordulás", 250, 0),
	("Illegálisan közlekedő terepjáró", 170, 0),
	("Törvényes parancs megtagadása", 30, 0),
	("jármű jogellenes megállítása", 150, 0),
	("illegális parkolás", 70, 0),
	("A jobbra engedés elmulasztása", 70, 0),
	("A járműinformációk be nem tartása", 90, 0),
	("Stoptáblánál való megállás elmulasztása", 105, 0),
	("A piros lámpánál való megállás elmulasztása", 130, 0)
        ("Piros lámpánál való megállás elmulasztása", 130, 0),
	("Illegális áthaladás", 100, 0),
	("Illegális jármű vezetése", 100, 0),
	("Jogosítvány nélküli vezetés", 1500, 0),
	("Hit and Run", 800, 0),
	("5 mph-<t meghaladó sebesség túllépése", 90, 0),
        ("5–15 mph-t meghaladó sebesség túllépése", 120, 0),
        ("15–30 mph-t meghaladó sebesség túllépése", 180, 0),
        ("> 30 mph-t meghaladó sebesség túllépése", 300, 0),
	("A forgalom áramlásának akadályozása", 110, 1),
	("Nyilvános mérgezés", 90., 1.),
	("Rendbontó magatartás", 90., 1.),
	("Az igazságszolgáltatás akadályozása", 130., 1.),
	("Az igazságszolgáltatás akadályozása", 130., 1.),
	("Civilek elleni sértések", 75, 1),
	("A LEO tiszteletlensége", 110, 1),
	("Civillel szembeni szóbeli fenyegetés", 90, 1),
	("Szóbeli fenyegetés egy LEO felé", 150, 1),
	("Hamis információk szolgáltatása", 250, 1),
	("Korrupciós kísérlet", 1500, 1),
	("Fegyverrel hadonászni a város határaiban", 120, 2),
	("Halálos fegyver viselése a város határaiban", 300, 2),
	("Nincs lőfegyvertartási engedély", 600, 2),
	("Illegális fegyver birtoklása", 700, 2),
	("Betöréses szerszámok birtoklása", 650, 2),
	("Egy polgári személy elrablása", 1500, 2),
	("Egy LEO elrablása", 2000, 2),
	("Rablás", 650, 2),
	("Bolt fegyveres kirablása", 650, 2),
	("Bankrablás" fegyveres rablás, 1500, 2),
	("Támadás egy polgári személy ellen", 2000, 3),
	("Egy OROSZLÁN támadása", 2500, 3),
	("Polgári személy elleni gyilkossági kísérlet", 3000, 3),
	("LEO elleni gyilkossági kísérlet", 5000, 3),
	("Egy polgári személy meggyilkolása", 10000, 3),
	("LEO meggyilkolása", 30000, 3),
	("Gondatlanságból elkövetett emberölés", 1800, 3),
	("Csalás", 2000, 2);
;
