-- Création d'une vue pour lister les triggers classés par nom de table
CREATE OR REPLACE VIEW liste_ora_triggers AS
SELECT 
    TABLE_NAME AS Nom_de_table,       -- Nom de la table associée
    TRIGGER_NAME AS Nom_du_trigger,  -- Nom du trigger
    STATUS AS Etat,                  -- État du trigger (ACTIVE/DISABLED)
    TRIGGER_TYPE AS Type_du_trigger, -- Type du trigger (BEFORE, AFTER, INSTEAD OF)
    TRIGGERING_EVENT AS Evenement,   -- Événement déclencheur (INSERT, UPDATE, DELETE)
    DESCRIPTION                      -- Description (texte court du trigger)
FROM 
    USER_TRIGGERS                    -- Vue système contenant les informations sur les triggers
ORDER BY 
    TABLE_NAME,                      -- Tri par nom de table
    TRIGGER_NAME;                    -- Puis par nom de trigger
/

-- Exécution pour afficher la liste des triggers
SELECT * FROM liste_ora_triggers;
