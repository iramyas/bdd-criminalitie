-- Script pour lister les index définis sur les tables
SELECT
    ind.owner AS "Schéma",
    ind.table_name AS "Table",
    ind.index_name AS "Nom de l'Index",
    ind.uniqueness AS "Type (Unique/Non Unique)",
    col.column_name AS "Colonne",
    ind.index_type AS "Type d'Index",
    ind.status AS "Statut"
FROM
    all_indexes ind
    JOIN all_ind_columns col
        ON ind.index_name = col.index_name
        AND ind.table_name = col.table_name
        AND ind.owner = col.index_owner
WHERE
    ind.owner = USER -- Limiter aux index appartenant à l'utilisateur courant
ORDER BY
    ind.table_name, ind.index_name, col.column_position;
