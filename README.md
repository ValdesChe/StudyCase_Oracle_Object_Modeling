# Oracle 11g Object Modeling 

## Project description
Project for understanding the main concept in object modeling approach with Oracle database 11g 
Case of study :  [Football Championship mangement](http://lecurseur.e-monsite.com/medias/files/etude-de-cas.pdf
)


## Exampe of requests 
  

-- a -- Give the detailled result of a given match
   ~~~~sql 
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
   ~~~~
-- d -- Give the players who scored more than a goal
   ~~~~sql 
          SELECT
            DEREF(VALUE(bt).joueur_).nom AS nomJoueur,
            DEREF(VALUE(bt).joueur_).prenom AS prenomJoueur,
            DEREF(VALUE(bt).joueur_).nationalite AS nationaliteJoueur,
            COUNT(VALUE(bt)) AS total 
           FROM matches_ m, TABLE(m.buts) bt GROUP BY DEREF(VALUE(bt).joueur_)  ORDER BY total DESC;
