-- Script pour lister les relations entre les tables via les clés étrangères
SELECT
    fk.owner AS "Schéma",
    fk.table_name AS "Table Enfant",
    fk.constraint_name AS "Nom de la Contrainte",
    rcons.table_name AS "Table Référencée",
    rcons.constraint_name AS "Contrainte Référencée",
    fkcol.column_name AS "Colonne Enfant",
    rcol.column_name AS "Colonne Référencée",
    fk.delete_rule AS "Règle de Suppression"
FROM
    all_constraints fk
    JOIN all_cons_columns fkcol
        ON fk.constraint_name = fkcol.constraint_name
        AND fk.owner = fkcol.owner
    JOIN all_constraints rcons
        ON fk.r_constraint_name = rcons.constraint_name
        AND fk.owner = rcons.owner
    JOIN all_cons_columns rcol
        ON rcons.constraint_name = rcol.constraint_name
        AND rcons.owner = rcol.owner
        AND fkcol.position = rcol.position
WHERE
    fk.constraint_type = 'R' -- Filtrer uniquement les clés étrangères
    AND fk.owner = USER -- Limiter aux contraintes appartenant à l'utilisateur courant
ORDER BY
    fk.table_name, fk.constraint_name;
