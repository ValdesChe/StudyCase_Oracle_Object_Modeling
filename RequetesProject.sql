-- a -- Stade de la demi-finale
SELECT stade FROM matches_ WHERE phase = 'DEMI-FINAL';

-- b -- Object arbitre ayant arbitre la  finale
SELECT DEREF(VALUE(arb)) FROM matches_ m , TABLE(m.arbitres) arb WHERE m.phase = 'FINALE' AND DEREF(VALUE(arb)).positon = 'Central';

-- c -- Les joueurs qui ont pris un carton jaune
SELECT DEREF(VALUE(carton).joueur_) FROM matches_ m , TABLE(m.cartons) carton WHERE VALUE(carton).couleur = 'ROUGE';


-- d -- Donner tous les joueurs qui ont marqu�s au moins un but
SELECT
            DEREF(VALUE(bt).joueur_).nom AS nomJoueur,
            DEREF(VALUE(bt).joueur_).prenom AS prenomJoueur,
            DEREF(VALUE(bt).joueur_).nationalite AS nationaliteJoueur,
            COUNT(VALUE(bt)) AS total 
           FROM matches_ m, TABLE(m.buts) bt GROUP BY DEREF(VALUE(bt).joueur_)  ORDER BY total DESC;
         
         
          
-- e -- Donner le meilleur buteur de l��quipe du Maroc
SELECT *    
  FROM  (SELECT
            DEREF(VALUE(bt).joueur_).nom AS nomJoueur,
            DEREF(VALUE(bt).joueur_).prenom AS prenomJoueur,
            DEREF(VALUE(bt).joueur_).nationalite AS nationaliteJoueur,
            COUNT(VALUE(bt)) AS total 
           FROM matches_ m, TABLE(m.buts) bt WHERE DEREF(VALUE(bt).joueur_).nationalite = 'Marocain' GROUP BY DEREF(VALUE(bt).joueur_)  ORDER BY total DESC
        )
    WHERE  ROWNUM = 1;
         
-- f -- Donner le meilleur buteur du championnat
SELECT *    
  FROM  (SELECT
            DEREF(VALUE(bt).joueur_).nom AS nomJoueur,
            DEREF(VALUE(bt).joueur_).prenom AS prenomJoueur,
            DEREF(VALUE(bt).joueur_).nationalite AS nationaliteJoueur,
            COUNT(VALUE(bt)) AS total 
           FROM matches_ m, TABLE(m.buts) bt  GROUP BY DEREF(VALUE(bt).joueur_)  ORDER BY total DESC
        )
    WHERE  ROWNUM = 1;
    
-- g --- Donner le nom du gardien qui a reçu moins de buts
SELECT DEREF(VALUE(j)).nom AS nom
FROM equipes_ e, 
    TABLE(e.joueurs) j ,  
    (SELECT *    
    FROM  (SELECT
            DEREF(VALUE(bt).joueur_).nationalite  AS nationalite,
            COUNT(VALUE(bt)) AS totalButEncaisse
           FROM matches_ m, TABLE(m.buts) bt GROUP BY DEREF(VALUE(bt).joueur_).nationalite  ORDER BY totalButEncaisse ASC
        )
    WHERE  ROWNUM = 1) de 
WHERE DEREF(VALUE(j)).nationalite = de.nationalite  AND DEREF(VALUE(j)).poste = 'Gardien';
    
-- h -- Donner l'équipe qui possède la meilleur attaque
SELECT VALUE(eq).pays FROM equipes_ eq, TABLE(eq.joueurs) jrs, (SELECT nationalite_meilleur    
  FROM  (SELECT
            DEREF(VALUE(bt).joueur_).nationalite AS nationalite_meilleur,
            COUNT(VALUE(bt)) AS total 
           FROM matches_ m, TABLE(m.buts) bt  GROUP BY DEREF(VALUE(bt).joueur_).nationalite  ORDER BY total DESC
        )
        WHERE  ROWNUM = 1) best WHERE DEREF(VALUE(jrs)).nationalite = best.nationalite_meilleur  AND ROWNUM = 1;
         
          

