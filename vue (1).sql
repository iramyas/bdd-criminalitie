-- Vue 1 : Crimes par ville
-- Cette vue affiche pour chaque ville le nombre total de crimes enregistrés.
CREATE VIEW V_CRIMES_PAR_VILLE AS
SELECT L.VILLE, COUNT(C.ID_CRIME) AS TOTAL_CRIMES
FROM CRIME C
JOIN LIEU L ON C.ID_LIEU = L.ID_LIEU
GROUP BY L.VILLE;

-- Vue 2 : Détails des interventions pour chaque crime
-- Cette vue fournit les types de crimes, les descriptions des interventions associées et les unités de police impliquées.
CREATE VIEW V_INTERVENTIONS_CRIME AS
SELECT C.TYPE_CRIME, I.DESCRIPTION_INTERVENTION, U.NOM_UNITE
FROM CRIME C
JOIN INTERVENTION I ON C.ID_CRIME = I.ID_CRIME
JOIN UNITE_DE_POLICE U ON I.ID_UNITE = U.ID_UNITE;

-- Vue 3 : Crimes et preuves
-- Cette vue relie les types de crimes aux descriptions des preuves associées.
CREATE VIEW V_CRIMES_PREUVES AS
SELECT C.TYPE_CRIME, PJ.DESCRIPTION_PF
FROM CRIME C
JOIN PIECES_JUSTIFICATIF PJ ON C.ID_CRIME = PJ.ID_CRIME;

-- Vue 4 : Gravité moyenne des crimes par région
-- Cette vue calcule la gravité moyenne des crimes pour chaque région.
CREATE VIEW V_CRIMES_GRAVITE AS
SELECT L.REGION, AVG(C.GRAVITE) AS GRAVITE_MOYENNE
FROM CRIME C
JOIN LIEU L ON C.ID_LIEU = L.ID_LIEU
GROUP BY L.REGION;

-- Vue 5 : Affectations actuelles des individus
-- Cette vue liste les individus actuellement affectés à une unité de police, en précisant la date de début de leur affectation.
CREATE VIEW V_AFFECTATIONS_ACTUELLES AS
SELECT I.NOM, I.PRENOM, U.NOM_UNITE, F.DATE_DEBUT
FROM INDIVIDU I
JOIN FAIT_PARTIE_DE F ON I.ID_INDIVIDU = F.ID_INDIVIDU
JOIN UNITE_DE_POLICE U ON F.ID_UNITE = U.ID_UNITE
WHERE F.DATE_FIN IS NULL;

-- Vue 6 : Crimes en attente de verdict
-- Cette vue identifie les crimes pour lesquels aucun verdict n'a encore été rendu.
CREATE VIEW pending_verdicts AS
SELECT 
    C.ID_CRIME, 
    C.TYPE_CRIME, 
    A.VERDICT
FROM 
    CRIME C
LEFT JOIN 
    AFFAIRE_JUDICIAIRE A ON C.ID_CRIME = A.ID_CRIME
WHERE 
    A.VERDICT IS NULL;

-- Vue 7 : Policiers avec le plus grand nombre d'interventions
-- Cette vue affiche les policiers classés par le nombre d'interventions auxquelles ils ont participé.
CREATE VIEW top_policiers_interventions AS
SELECT 
    I.NOM,
    I.PRENOM,
    COUNT(INTER.ID_INTERVENTION) AS intervention_count
FROM 
    INDIVIDU I
JOIN 
    INTERVENTION INTER ON I.ID_INDIVIDU = INTER.ID_INDIVIDU
WHERE 
    I.TYPE_INDIVIDU = 'Policier'
GROUP BY 
    I.ID_INDIVIDU, I.NOM, I.PRENOM
ORDER BY 
    intervention_count DESC;

-- Vue 8 : Suspects jugés coupables
-- Cette vue donne la liste des suspects déclarés coupables, leur crime, le verdict et la durée de leur emprisonnement.
CREATE VIEW guilty_suspects AS
SELECT 
    I.PRENOM || ' ' || I.NOM AS SUSPECT_NAME,   -- Nom complet du suspect
    C.TYPE_CRIME,                              -- Type de crime
    A.VERDICT,                                 -- Verdict de l'affaire
    CO.DUREE_EMPRISONNEMENT                    -- Durée d'emprisonnement
FROM 
    INDIVIDU I
JOIN 
    COMMIS CO ON I.ID_INDIVIDU = CO.ID_CRIME   -- Jointure pour les informations de l'emprisonnement
JOIN 
    CRIME C ON CO.ID_CRIME = C.ID_CRIME        -- Jointure pour les détails des crimes
JOIN 
    AFFAIRE_JUDICIAIRE A ON C.ID_CRIME = A.ID_CRIME -- Jointure pour les informations judiciaires
WHERE 
    A.VERDICT = 'Coupable';                    -- Filtrer uniquement les coupables

-- Requêtes pour afficher les résultats des vues créées
SELECT * FROM V_CRIMES_PAR_VILLE;
SELECT * FROM V_INTERVENTIONS_CRIME;
SELECT * FROM V_CRIMES_PREUVES;
SELECT * FROM V_CRIMES_GRAVITE;
SELECT * FROM V_AFFECTATIONS_ACTUELLES;
SELECT * FROM top_policiers_interventions;
SELECT * FROM pending_verdicts;
SELECT * FROM guilty_suspects;
