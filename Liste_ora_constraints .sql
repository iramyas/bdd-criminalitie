-- Création de la vue liste_ora_constraints
CREATE OR REPLACE VIEW liste_ora_constraints AS
SELECT
    ac.owner AS schema_name,               -- Nom du schéma
    ac.table_name AS table_name,           -- Nom de la table
    ac.constraint_name AS constraint_name, -- Nom de la contrainte
    CASE ac.constraint_type                -- Type de contrainte
        WHEN 'P' THEN 'Primary Key'
        WHEN 'U' THEN 'Unique'
        WHEN 'C' THEN 'Check'
        WHEN 'R' THEN 'Foreign Key'
        ELSE 'Autre'
    END AS constraint_type,
    NULL AS constraint_body,               -- Placeholder pour éviter les problèmes avec LONG
    ac.r_constraint_name AS referenced_constraint, -- Contrainte référencée (pour FOREIGN KEY)
    ac.delete_rule AS on_delete_rule,      -- Règle de suppression (pour FOREIGN KEY)
    ac.status AS constraint_status         -- Statut de la contrainte (ENABLED/DISABLED)
FROM
    all_constraints ac
WHERE
    ac.owner = USER -- Limiter aux objets appartenant à l'utilisateur courant
ORDER BY
    ac.table_name,
    ac.constraint_type;

-- Pour récupérer le corps des contraintes CHECK uniquement
-- car elles contiennent la colonne LONG.
SELECT
    ac.owner AS "Schéma",
    ac.table_name AS "Table",
    ac.constraint_name AS "Nom de la Contrainte",
    'Check' AS "Type de Contrainte",
    cc.search_condition AS "Corps de la Contrainte"
FROM
    all_constraints ac
    JOIN all_cons_columns cc ON ac.constraint_name = cc.constraint_name
WHERE
    ac.owner = USER
    AND ac.constraint_type = 'C';

-- Exécution pour afficher les contraintes
SELECT
    schema_name AS "Schéma",
    table_name AS "Table",
    constraint_name AS "Nom de la Contrainte",
    constraint_type AS "Type de Contrainte",
    COALESCE(referenced_constraint, 'N/A') AS "Contrainte Référencée",
    COALESCE(on_delete_rule, 'N/A') AS "Règle de Suppression",
    constraint_status AS "Statut"
FROM
    liste_ora_constraints;
