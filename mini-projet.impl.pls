
--- Supprimer tous les types s'ils existent deja dans la base de données
DROP TABLE matches_ FORCE;
DROP TABLE arbitres_ FORCE;
DROP TYPE listArbitres FORCE;
DROP TABLE equipes_ FORCE;
DROP TYPE listButs FORCE;
DROP TYPE But FORCE;
DROP TYPE listCartons FORCE;
DROP TABLE joueurs_ FORCE;
DROP TYPE Carton FORCE;
DROP TYPE Joueur FORCE;
DROP TYPE Matchs_ FORCE;
DROP TYPE MatchO FORCE;
DROP TYPE Equipe FORCE;
DROP TYPE Arbitre FORCE;
DROP TYPE listJoueurs FORCE;

--- Type Arbitre
CREATE OR REPLACE TYPE Arbitre AS OBJECT(
    id NUMBER,
 	nom VARCHAR2(25),
 	prenom VARCHAR2(25),
 	nationalite VARCHAR2(25),
 	positon VARCHAR2(25),
	MAP MEMBER FUNCTION get_id RETURN NUMBER,
	MEMBER PROCEDURE get_details(SELF IN OUT NOCOPY Arbitre)
);
/

-- Object body Arbitre
CREATE OR REPLACE TYPE BODY Arbitre AS
	MAP MEMBER FUNCTION get_id  RETURN NUMBER IS 
	BEGIN
		RETURN id;
	END;
	MEMBER PROCEDURE get_details(SELF IN OUT NOCOPY Arbitre) IS 
	BEGIN
		DBMS_OUTPUT.PUT_LINE('Arbitre ' || TO_CHAR(SELF.positon) );
		DBMS_OUTPUT.PUT_LINE('Nom et prenom : ' ||  TO_CHAR(SELF.nom) || ' ' || TO_CHAR(SELF.prenom) );
		DBMS_OUTPUT.PUT_LINE('Nationaité : ' || TO_CHAR(SELF.nationalite) );
	END;
END;
/
--  Tables des arbitres
CREATE TABLE arbitres_ OF Arbitre;

--  Tables de références d'Objet Arbitre
CREATE OR REPLACE TYPE listArbitres AS TABLE OF REF Arbitre;
/
--- Fin déclaration type Arbitre



--- Type Joueur
 CREATE OR REPLACE TYPE  Joueur AS OBJECT(
    numJ NUMBER,
 	nom VARCHAR2(25),
 	prenom VARCHAR2(25),
 	poste VARCHAR2(25),
 	nationalite VARCHAR2(25),
	MAP MEMBER FUNCTION get_id RETURN VARCHAR2,
	-- Procedure renvoie des details sur un Joueur
	MEMBER PROCEDURE get_details(SELF IN OUT NOCOPY Joueur)
);
/
-- /

-- Object body Joueur
CREATE OR REPLACE TYPE BODY Joueur AS
	-- Map getter
	MAP MEMBER FUNCTION get_id  RETURN VARCHAR2 IS 
	BEGIN
		RETURN nom || prenom || poste;
	END;

	-- Details sur un joueur
	MEMBER PROCEDURE get_details(SELF IN OUT NOCOPY Joueur) IS 
	BEGIN
		DBMS_OUTPUT.PUT_LINE('-------- Details sur joueur ---------');
		DBMS_OUTPUT.PUT_LINE('Numero' || TO_CHAR(SELF.numJ) );
		DBMS_OUTPUT.PUT_LINE('Nom et prenom : '  || TO_CHAR(SELF.nom) || ' ' || TO_CHAR(SELF.prenom) );
		DBMS_OUTPUT.PUT_LINE('Poste : ' || TO_CHAR(SELF.poste) );
		DBMS_OUTPUT.PUT_LINE('-------   ----------   --------   ---------');
	END;
END;
/

--  Tables des joueurs
CREATE TABLE joueurs_ OF Joueur;
-- Table de references objets
CREATE OR REPLACE TYPE listJoueurs AS TABLE OF REF Joueur;
/

-- table d'objets
CREATE OR REPLACE TYPE listJoueursOb AS TABLE OF Joueur;
/

-- Type But
CREATE OR REPLACE TYPE But AS OBJECT(
  joueur_ REF Joueur,
	minutes_ NUMBER,
	MEMBER PROCEDURE get_details(SELF IN OUT NOCOPY But),
	MEMBER FUNCTION getJoueur(SELF IN OUT NOCOPY But) RETURN Joueur
);
/

CREATE OR REPLACE TYPE BODY But AS
	MEMBER PROCEDURE get_details(SELF IN OUT NOCOPY But) IS 
	BEGIN
		DBMS_OUTPUT.PUT_LINE('But de à la ' || TO_CHAR(minutes_) || ' minute !');
		DBMS_OUTPUT.PUT_LINE('-------   ----------   --------   ---------');
	END;

	MEMBER FUNCTION getJoueur(SELF IN OUT NOCOPY But) RETURN Joueur IS 
		joueur_v Joueur;
	BEGIN
		SELECT DEREF(joueur_) INTO joueur_v FROM dual;
		RETURN joueur_v;
	END;
END;
/

-- Table de but optionnelle 
-- CREATE TABLE buts_ OF But;

--  Liste de Buts
CREATE OR REPLACE TYPE listButs AS TABLE OF But;
/

--- Type Carton
CREATE OR REPLACE TYPE Carton AS OBJECT(
	joueur_ REF Joueur,
	minutes_ NUMBER,
	couleur VARCHAR2(25),
	MEMBER PROCEDURE get_details(SELF IN OUT NOCOPY Carton),
	MEMBER FUNCTION getJoueur(SELF IN OUT NOCOPY Carton) RETURN Joueur
);
/

CREATE OR REPLACE TYPE BODY Carton AS
	MEMBER PROCEDURE get_details(SELF IN OUT NOCOPY Carton) IS 
	BEGIN
		DBMS_OUTPUT.PUT_LINE( TO_CHAR(SELF.couleur) || ' : ' || 'à la ' || TO_CHAR(SELF.minutes_) || ' minute !');
		DBMS_OUTPUT.PUT_LINE('-------   ----------   --------   ---------');
	END;

	MEMBER FUNCTION getJoueur(SELF IN OUT NOCOPY Carton) RETURN Joueur IS 
		joueur_v Joueur;
	BEGIN
		SELECT DEREF(joueur_) INTO joueur_v FROM dual;
		RETURN joueur_v;
	END;
END;
/

-- Type liste de carton
CREATE OR REPLACE TYPE listCartons AS TABLE OF Carton;
/
-- End creation of carton
---

-- Type equipe
CREATE OR REPLACE TYPE Equipe AS OBJECT (
  id_ NUMBER,
	coach VARCHAR2(25),
	pays VARCHAR2(25),
	joueurs listJoueurs,
	MAP MEMBER FUNCTION get_pays RETURN VARCHAR2,
	MEMBER PROCEDURE get_details(SELF IN OUT NOCOPY Equipe),
	MEMBER PROCEDURE getNbreMatch(SELF IN OUT NOCOPY Equipe),
	MEMBER FUNCTION contains(SELF IN OUT NOCOPY Equipe, joueur_p IN OUT Joueur) RETURN BOOLEAN
);
/

-- Table de Equipes
CREATE TABLE equipes_ OF Equipe NESTED TABLE joueurs STORE AS list_of_joueurs;


-- 
--- CREATION DE Match
CREATE OR REPLACE TYPE MatchO AS OBJECT (
	id NUMBER,
	stade VARCHAR2(25),
	dateM DATE,
	heureM VARCHAR2(5),
	phase VARCHAR2(25),
	arbitres listArbitres,
	equipe1 REF Equipe,
	equipe2 REF Equipe,
	cartons listCartons,
	buts listButs,
	MAP MEMBER FUNCTION get_id RETURN NUMBER,
	-- Afficher les details sur un Match
	MEMBER PROCEDURE get_details(SELF IN OUT NOCOPY MatchO),
	
	-- ajouter un Carton à un Match
	MEMBER PROCEDURE addCarton(SELF IN OUT NOCOPY MatchO , carton IN OUT NOCOPY Carton ),
	
	-- Ajouter un but à un Match
	MEMBER PROCEDURE addBut(SELF IN OUT NOCOPY MatchO , but IN OUT NOCOPY But ),

	-- Afficher l'équipe gagnante d'un Match
	MEMBER PROCEDURE winningTeam(SELF IN OUT NOCOPY MatchO),
	
	-- Afficher le nombre de but 
	MEMBER PROCEDURE getCountGoal(SELF IN OUT NOCOPY MatchO),

	-- Retourne le gagnat du championat ! 
	-- STATIC car elle ne retourne pas besoin d'instancier un objet pour l'avoir
	STATIC PROCEDURE championshipWinners
);
/

CREATE TABLE matches_ OF MatchO NESTED TABLE arbitres STORE AS list_of_arbitres
 NESTED TABLE cartons STORE AS list_of_cartons
 NESTED TABLE buts STORE AS list_of_buts;
/



-- Type body de l'object Equipe
CREATE OR REPLACE TYPE BODY Equipe AS
	-- Map getter for pays
	MAP MEMBER FUNCTION get_pays  RETURN VARCHAR2 IS 
	BEGIN
		RETURN pays;
	END;
	
	-- show details of a Team
	MEMBER PROCEDURE get_details(SELF IN OUT NOCOPY Equipe) IS 
	BEGIN
		DBMS_OUTPUT.PUT_LINE('Affichage des details de l equipe : ');
		DBMS_OUTPUT.PUT_LINE('Pays : ' || TO_CHAR(SELF.pays));
		DBMS_OUTPUT.PUT_LINE('Coach : ' || TO_CHAR(SELF.coach));
	END;
    
    	-- Get total of matches of the team
	MEMBER PROCEDURE getNbreMatch(SELF IN OUT NOCOPY Equipe) IS 
		nbreMatch NUMBER := 0;
	BEGIN
		DBMS_OUTPUT.PUT_LINE('Affichage du nombre de match joués : ');
		SELECT COUNT(*) INTO nbreMatch FROM 
		(SELECT m.id FROM matches_ m WHERE DEREF(m.equipe1).pays = SELF.pays OR  DEREF(m.equipe2).pays = SELF.pays );
		
		DBMS_OUTPUT.PUT_LINE('Equipe du/de ' || TO_CHAR(SELF.pays) || ' a joué ' || TO_CHAR(nbreMatch) || ' matchs.');
	END;
    
    
	-- Is the team contains this player
	MEMBER FUNCTION contains(SELF IN OUT NOCOPY Equipe , joueur_p IN OUT Joueur) RETURN BOOLEAN IS 
		joueur_nom VARCHAR2(25) := NULL;
		joueur_v Joueur := NULL;
	BEGIN
    
        -- Requete obtention du joueur
        /* SELECT nom INTO joueur_nom 
         FROM TABLE(SELECT CAST( COLLECT(DEREF(VALUE(jrs))) AS listJoueursOb) FROM equipes_ e , TABLE(e.joueurs) jrs WHERE e.pays = SELF.pays)
         WHERE numJ = joueur_p.numJ AND nom = joueur_p.nom ;*/

				SELECT VALUE(jr) INTO joueur_v
				FROM TABLE(
					SELECT CAST(COLLECT(DEREF(VALUE(jrs))) AS listJoueursOb)
					FROM TABLE(SELECT joueurs FROM dual) jrs) jr
				WHERE VALUE(jr).numJ = joueur_p.numJ AND VALUE(jr).nom = joueur_p.nom;
        IF(joueur_v.nom = NULL ) THEN
            return false;
        END IF;
        
        -- Tout s'est bien passé
        return true;
    
	END;
END;
/
-- End creation of TYPE BODY Equipe


-- type body match


-- type body match
CREATE OR REPLACE TYPE BODY MatchO AS
	MAP MEMBER FUNCTION get_id  RETURN NUMBER IS 
	BEGIN
		RETURN id;
	END;
	-- Show match details
	MEMBER PROCEDURE get_details(SELF IN OUT NOCOPY MatchO) IS
		nbreButTeam1_v NUMBER := 0;
		nbreButTeam2_v NUMBER := 0; 
        team1 Equipe;
        team2 Equipe;
        arbitre_v Arbitre;
        joueur_v Joueur;
        but_v But;
	BEGIN
        SELECT DEREF(equipe1) INTO team1  FROM dual;
        SELECT DEREF(equipe2) INTO team2  FROM dual;
		DBMS_OUTPUT.PUT_LINE('AFFICHAGE MATCH');
		DBMS_OUTPUT.PUT_LINE('--------------------------------');
		DBMS_OUTPUT.PUT_LINE('=> Date ' || TO_CHAR(datem) || ' à ' || TO_CHAR(heureM));
		DBMS_OUTPUT.PUT_LINE('=> Stade ' || TO_CHAR(stade));
		DBMS_OUTPUT.PUT_LINE('=> Phase ' || TO_CHAR(phase));
		DBMS_OUTPUT.PUT_LINE('=> Arbitres --- ');
		FOR i IN 0..arbitres.COUNT loop
            SELECT DEREF( arbitres(i)) INTO arbitre_v  FROM dual;
			DBMS_OUTPUT.PUT_LINE('  - ' || TO_CHAR(arbitre_v.nom) || ' ' || TO_CHAR(arbitre_v.prenom) || ' ' || TO_CHAR(arbitre_v.positon) );
		end loop;

		DBMS_OUTPUT.PUT_LINE(' -  ' || TO_CHAR(team1.pays) || ' * Vs *  ' || TO_CHAR(team2.pays) );
		
        -- But du Match
        FOR i IN 0..buts.COUNT loop
            SELECT buts(i), DEREF(buts(i).joueur_) INTO but_v, joueur_v  FROM dual;
            IF(team1.contains(joueur_v)) THEN
                nbreButTeam1_v := nbreButTeam1_v+1;
            END IF;
            IF(team2.contains(joueur_v)) THEN
                nbreButTeam2_v := nbreButTeam2_v+1;
            END IF;
			DBMS_OUTPUT.PUT_LINE('  But de - ' || TO_CHAR(joueur_v.nom) || ' ' || TO_CHAR(joueur_v.prenom) || ' à la  ' || TO_CHAR(but_v.minutes_) );
		end loop;
        
		DBMS_OUTPUT.PUT_LINE(' -  ' || TO_CHAR(nbreButTeam1_v) || ' * - *  ' || TO_CHAR(nbreButTeam2_v) );
	END;
    
    
	-- add Carton to the match
	MEMBER PROCEDURE addCarton(SELF IN OUT NOCOPY MatchO , carton IN OUT NOCOPY Carton ) IS 
	BEGIN
		DBMS_OUTPUT.PUT_LINE('Ajout de carton');
		INSERT INTO TABLE 
		(select m_.cartons from matches_ m_ WHERE m_.id = id)
		 VALUES(carton);
	END;
    
    
	-- add Goal to the match
	MEMBER PROCEDURE addBut(SELF IN OUT NOCOPY MatchO , but IN OUT NOCOPY But ) IS 
	BEGIN
		DBMS_OUTPUT.PUT_LINE('Ajout de but au match');
		INSERT INTO TABLE 
		(select m_.buts from matches_ m_ WHERE m_.id = id)
		 VALUES(but);
	END;
    
    
	-- show the winning team
	MEMBER PROCEDURE winningTeam(SELF IN OUT NOCOPY MatchO) IS 
		joueur_v Joueur;
        team1 Equipe;
        team2 Equipe;
        goalPlayer Joueur;
		nbreButTeam1_v NUMBER := 0;
		nbreButTeam2_v NUMBER := 0;
	BEGIN
		DBMS_OUTPUT.PUT_LINE('Affichage equipe gagnante');
        
        SELECT DEREF(equipe1) INTO team1  FROM dual;
        SELECT DEREF(equipe2) INTO team2  FROM dual;
		FOR i IN 0..buts.COUNT loop
			SELECT DEREF(buts(i).joueur_) INTO goalPlayer from dual;
		  	IF(team1.contains(goalPlayer)) THEN
                nbreButTeam1_v := nbreButTeam1_v+1;
            END IF;
            IF(team2.contains(goalPlayer)) THEN
                nbreButTeam2_v := nbreButTeam2_v+1;
            END IF;
		end loop;
		if (nbreButTeam2_v > nbreButTeam1_v) THEN
			DBMS_OUTPUT.PUT_LINE('Equipe gagnante est : ' || TO_CHAR(team2.pays));
		END IF;
		if (nbreButTeam2_v < nbreButTeam1_v) THEN
			DBMS_OUTPUT.PUT_LINE('Equipe gagnante est : ' || TO_CHAR(team1.pays));
		END IF;
		if (nbreButTeam2_v = nbreButTeam1_v) THEN
			DBMS_OUTPUT.PUT_LINE('Match null ');
		END IF;
	END;
    
    
	-- Get count goals in the match
	MEMBER PROCEDURE getCountGoal(SELF IN OUT NOCOPY MatchO) IS 
		nbreBut NUMBER := 0;
	BEGIN
		DBMS_OUTPUT.PUT_LINE('Affichage du nombre buts marqués dans le match : ');
		nbreBut := buts.COUNT;
		DBMS_OUTPUT.PUT_LINE('Nombre de buts total : ' ||  TO_CHAR(nbreBut) );
	END;
    
    
-- show the winning team of championship and the best scorer
	STATIC PROCEDURE championshipWinners IS 
        finalMatch MatchO;
        -- Some best scorer info
        joueur_nom VARCHAR2(25);
        joueur_prenom VARCHAR2(25);
        joueur_nation VARCHAR2(25);
        joueur_nbre_but VARCHAR2(25);
        
	BEGIN
		DBMS_OUTPUT.PUT_LINE('Affichage equipe gagnante du championat');
        
        -- Recuperation du match de la finale
        SELECT CAST(VALUE(m) AS MatchO) INTO finalMatch  FROM matches_ m WHERE m.phase = 'DEMI-FINAL';
        
        -- Affichage de l'equipe gagnante
        finalMatch.winningTeam();
        
        
        -- Recherche du meilleur butteur
        SELECT * INTO joueur_nom, joueur_prenom, joueur_nation, joueur_nbre_but
        FROM 
          (SELECT
            DEREF(VALUE(bt).joueur_).nom AS nomJoueur,
            DEREF(VALUE(bt).joueur_).prenom AS prenomJoueur,
            DEREF(VALUE(bt).joueur_).nationalite AS nationaliteJoueur,
            COUNT(VALUE(bt)) AS total 
           FROM matches_ m, TABLE(m.buts) bt 
           GROUP BY DEREF(VALUE(bt).joueur_).nom 
           ORDER BY total DESC
          )
        WHERE  ROWNUM = 1;
        
        DBMS_OUTPUT.PUT_LINE('Le meilleur butteur du championat est : ');
        DBMS_OUTPUT.PUT_LINE(' '  || TO_CHAR(joueur_nom)|| ' sd ' || TO_CHAR(joueur_prenom) || ' de nationalite : ' || TO_CHAR(joueur_nation) );
        DBMS_OUTPUT.PUT_LINE( ' avec ' || TO_CHAR(joueur_nbre_but) || ' buts ');
        
	END;
END;
/
-- Fin type body match

-- End creation of Match
/*
---- ---------------------
------
*/
-- Bloc initialisation du match Maroc vs Argentine
DECLARE
begin
	-- Creation des arbitres 
	INSERT INTO arbitres_ VALUES(Arbitre(1,'Mr Mark' , 'Geiger', 'Anglais', 'Central'));
	INSERT INTO arbitres_ VALUES(Arbitre(2,'Mr Ricardo' , 'Montero', 'Francais', 'Touche'));
	INSERT INTO arbitres_ VALUES(Arbitre(3,'Mr John' , 'Pitti', 'Camerounais', 'Juge'));

	-- Creation des joueurs MAROC .. Juste les joueurs spécifiés
	INSERT INTO joueurs_ VALUES(Joueur(1, 'Yassine' , 'Bono', 'Gardien', 'Marocain'));
	INSERT INTO joueurs_ VALUES(Joueur(2, 'Achraf' , 'Hakimi', 'Défenseur', 'Marocain'));
	INSERT INTO joueurs_ VALUES(Joueur(19, 'Amine' , 'Harit', 'Milieu', 'Marocain'));
	INSERT INTO joueurs_ VALUES(Joueur(7, 'Hakim' , 'Ziyech', 'Milieu', 'Marocain'));
	INSERT INTO joueurs_ VALUES(Joueur(11, 'Fayçal' , 'Fajr', 'Milieu', 'Marocain'));
	INSERT INTO joueurs_ VALUES(Joueur(16, 'Noureddine' , 'Amrabet', 'Attaquant', 'Marocain'));
	-- ... 
	
	-- Creation des joueurs ARGENTINE .. Juste les joueurs spécifiés
	INSERT INTO joueurs_ VALUES(Joueur(1, 'Sergio' , 'Romero', 'Gardien', 'Argentain'));
	INSERT INTO joueurs_ VALUES(Joueur(6, 'Lucas ' , 'Biglia', 'Milieu', 'Argentain'));
	INSERT INTO joueurs_ VALUES(Joueur(4, 'Guido' , 'Pizarro', 'Milieu', 'Argentain'));

	INSERT INTO joueurs_ VALUES(Joueur(10, 'Leonel' , 'Messi', 'Attaquant', 'Argentain'));
	INSERT INTO joueurs_ VALUES(Joueur(21, 'Paulo' , 'Dybala', 'Attaquant', 'Argentain'));
	INSERT INTO joueurs_ VALUES(Joueur(11, 'Angel' , 'Di Maria', 'Attaquant', 'Argentain'));
	INSERT INTO joueurs_ VALUES(Joueur(20, 'Sergio' , 'Aguero', 'Attaquant', 'Argentain'));

	-- Creation des equipes du Maroc + Argentine
	INSERT INTO equipes_ VALUES(Equipe(1 , 'Hervé Renard', 'Maroc', listJoueurs()));
	INSERT INTO equipes_ VALUES(Equipe(2 , 'Lionel Scaloni', 'Argentine', listJoueurs()));

	-- Mis a jour de la liste des joueurs
	UPDATE equipes_ eq SET eq.joueurs =  ( 
		SELECT CAST(COLLECT( REF(jrs) )  as listJoueurs )
		FROM joueurs_ jrs where jrs.nationalite = 'Marocain') WHERE eq.id_ = 1;

	UPDATE equipes_ eq SET eq.joueurs =  ( 
		SELECT CAST( COLLECT( REF(jrs) )  as listJoueurs )
		FROM joueurs_ jrs where jrs.nationalite = 'Argentain')  WHERE eq.id_ = 2;

	-- Creation du Match Argentine - Maroc
	-- On insère une liste de cartons vide au debut du Match

	-- Changer la date en fontion du fuseau horaire PC
	INSERT INTO matches_ VALUES(
		MatchO(
			1, 'Loujniki', '2018-06-26', '19:00', 'DEMI-FINAL', 
			listArbitres(
				(SELECT REF(arb) FROM arbitres_ arb WHERE arb.nom = 'Mr Mark' AND  arb.prenom = 'Geiger'),
				(SELECT REF(arb) FROM arbitres_ arb WHERE  arb.nom = 'Mr Ricardo' AND  arb.prenom = 'Montero'),
				(SELECT REF(arb) FROM arbitres_ arb WHERE  arb.nom = 'Mr John' AND  arb.prenom = 'Pitti')
			),
			(SELECT REF(eqp) FROM equipes_ eqp WHERE eqp.pays = 'Maroc'),
			(SELECT REF(eqp) FROM equipes_ eqp WHERE eqp.pays = 'Argentine'),
			listCartons(),
			listButs()
		)
	);

	-- On met à jour le match en y ajoutant les buts inscrits

	-- But de Nourredine Amrabat
	INSERT INTO 
		TABLE(SELECT m_.buts from matches_ m_ WHERE m_.id = 1)
		 VALUES(
			But( 
				( SELECT REF(jr) 
				  FROM joueurs_ jr
				  WHERE jr.nationalite = 'Marocain' 
				    AND jr.nom = 'Noureddine' 
					AND jr.prenom = 'Amrabet'),
					32)
		 ); 

	-- But de Leonel Messi
	INSERT INTO
		TABLE(SELECT m_.buts from matches_ m_ WHERE m_.id = 1)
		 VALUES(
			But( 
				( SELECT REF(jr) 
				  FROM joueurs_ jr
				  WHERE jr.nationalite = 'Argentain' 
				    AND jr.nom = 'Leonel' 
					AND jr.prenom = 'Messi'),
					45)
		 ); 
	
	-- But de Sergio Aguero
	INSERT INTO
		TABLE(SELECT m_.buts from matches_ m_ WHERE m_.id = 1)
		 VALUES(
			But( 
				( SELECT REF(jr) 
				  FROM joueurs_ jr
				  WHERE jr.nationalite = 'Argentain' 
				    AND jr.nom = 'Sergio'
					AND jr.prenom = 'Aguero'),
					67)
		 ); 

	-- But de Fayçal Fajr
	INSERT INTO TABLE 
		(SELECT m_.buts from matches_ m_ WHERE m_.id = 1)
		 VALUES(
			But( 
				( SELECT REF(jr) 
				  FROM joueurs_ jr
				  WHERE jr.nationalite = 'Marocain' 
				    AND jr.nom = 'Fayçal' 
					AND jr.prenom = 'Fajr'),
					89)
		 ); 

	-- But de Hakim Ziyech
	INSERT INTO TABLE 
	(SELECT m_.buts from matches_ m_ WHERE m_.id = 1)
		 VALUES(
			But( 
				( SELECT REF(jr) 
				  FROM joueurs_ jr
				  WHERE jr.nationalite = 'Marocain' 
				    AND jr.nom = 'Hakim' 
					AND jr.prenom = 'Ziyech'),
					93)
		 ); 

	--- INSERTION CARTONS
	-- On met à jour le match en y ajoutant les cartons
	-- Carton de Achraf Hakimi 42e minute
	INSERT INTO TABLE 
		(SELECT m_.cartons from matches_ m_ WHERE m_.id = 1)
		 VALUES(
			Carton( 
				( SELECT REF(jr) 
				  FROM joueurs_ jr
				  WHERE jr.nationalite = 'Marocain' 
				    AND jr.nom = 'Achraf' 
					AND jr.prenom = 'Hakimi'),
				42,
				'JAUNE'
				)
		 ); 

	-- Carton de Angel Di Maria 58e minute
	INSERT INTO TABLE 
		(SELECT m_.cartons from matches_ m_ WHERE m_.id = 1)
		 VALUES(
			Carton( 
				( SELECT REF(jr) 
				  FROM joueurs_ jr
				  WHERE jr.nationalite = 'Argentain' 
				    AND jr.nom = 'Angel' 
					AND jr.prenom = 'Di Maria'),
				58,
				'JAUNE'
				)
		 ); 

	-- Carton de Amine Harit 74e minute
	INSERT INTO TABLE 
		(SELECT m_.cartons from matches_ m_ WHERE m_.id = 1)
		 VALUES(
			Carton( 
				( SELECT REF(jr) 
				  FROM joueurs_ jr
				  WHERE jr.nationalite = 'Marocain' 
				    AND jr.nom = 'Amine' 
					AND jr.prenom = 'Harit'),
				74,
				'ROUGE'
				)
		 ); 		
		--- Fin attribution des cartons aux joueurs
end;


/* Requetes SQL pour selection */


-- t