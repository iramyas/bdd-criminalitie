-- ########################
-- 1. Contraintes d'intégrité
-- ########################

-- Cette contrainte garantit qu'il n'est pas possible d'enregistrer deux crimes ayant 
-- le même type, lieu, date et heure. Cela empêche les doublons pour des événements identiques.
ALTER TABLE CRIME
ADD CONSTRAINT UQ_TYPE_LIEU_DATE_HEURE UNIQUE (TYPE_CRIME, ID_LIEU, DATE_CRIME, HEURE_CRIME);

-- Cette contrainte assure que les durées d’emprisonnement ou autres quantités (comme des amendes) 
-- sont toujours positives. Cela protège contre des valeurs incohérentes ou invalides.
ALTER TABLE COMMIS
ADD CONSTRAINT CHK_DUREE_EMPRISONNEMENT_POSITIVE
CHECK (DUREE_EMPRISONNEMENT >= 0);

-- Cette contrainte garantit qu'une personne ne peut avoir qu'un seul rôle (par exemple, 
-- "suspect", "témoin") dans un crime donné. Cela évite les conflits de rôle dans un même événement.
ALTER TABLE IMPLIQUE
ADD CONSTRAINT UQ_ID_INDIVIDU_ROLE UNIQUE (ID_INDIVIDU, ID_CRIME, ROLE_PARTICIPANT);

-- ########################
-- 2. Validation des dates
-- ########################

-- Ce trigger vérifie la cohérence des dates dans les affaires judiciaires. Par exemple, 
-- une date de verdict ne peut pas être incohérente avec d'autres données temporelles.
CREATE OR REPLACE TRIGGER trg_date_affaire_chrono
BEFORE INSERT OR UPDATE ON AFFAIRE_JUDICIAIRE
FOR EACH ROW
BEGIN
    IF :NEW.DATE_VERDICT < :NEW.DATE_VERDICT THEN
        RAISE_APPLICATION_ERROR(-20007, 'Les dates des affaires judiciaires doivent respecter une chronologie logique.');
    END IF;
END;
/

-- Ce trigger garantit que la date de début d’une affectation (par exemple, 
-- l’entrée dans une unité de police) est toujours antérieure ou égale à la date de fin. 
-- Cela empêche des périodes d'affectation incohérentes.
CREATE OR REPLACE TRIGGER trg_validate_dates_affectation
BEFORE INSERT OR UPDATE ON FAIT_PARTIE_DE
FOR EACH ROW
BEGIN
    IF :NEW.DATE_FIN IS NOT NULL AND :NEW.DATE_DEBUT > :NEW.DATE_FIN THEN
        RAISE_APPLICATION_ERROR(-20011, 'La date de début doit être antérieure ou égale à la date de fin.');
    END IF;
END;
/

-- ########################
-- 3. Empêchement de modifications ou suppressions non autorisées
-- ########################

-- Ce trigger empêche la modification ou suppression d'une affaire judiciaire ayant déjà reçu 
-- un verdict. Cela protège l'intégrité des décisions juridiques une fois prises.
CREATE OR REPLACE TRIGGER trg_prevent_update_judged_case
BEFORE UPDATE OR DELETE ON AFFAIRE_JUDICIAIRE
FOR EACH ROW
BEGIN
    IF :OLD.VERDICT IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(-20014, 'Impossible de modifier ou supprimer une affaire déjà jugée.');
    END IF;
END;
/

-- Ce trigger interdit la suppression d'un crime si des preuves (pièces justificatives) y sont associées. 
-- Cela évite la perte d'informations cruciales dans une enquête.
CREATE OR REPLACE TRIGGER trg_prevent_delete_crime_with_evidence
BEFORE DELETE ON CRIME
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM PIECES_JUSTIFICATIF
    WHERE ID_CRIME = :OLD.ID_CRIME;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20019, 'Impossible de supprimer un crime qui possède des preuves associées.');
    END IF;
END;
/

-- Ce trigger empêche la modification des pièces justificatives une fois qu'elles sont insérées. 
-- Cela garantit leur authenticité et empêche toute altération de preuves.
CREATE OR REPLACE TRIGGER trg_prevent_update_proof
BEFORE UPDATE ON PIECES_JUSTIFICATIF
FOR EACH ROW
BEGIN
    RAISE_APPLICATION_ERROR(-20011, 'Les pièces justificatives ne peuvent pas être modifiées une fois ajoutées.');
END;
/

-- ########################
-- 4. Validation des entités liées
-- ########################

-- Ce trigger vérifie que l'unité de police mentionnée dans une intervention existe réellement. 
-- Si l'unité n'existe pas, la mise à jour est bloquée.
CREATE OR REPLACE TRIGGER trg_check_unite_intervention
BEFORE UPDATE ON INTERVENTION
FOR EACH ROW
DECLARE
    v_unite_count NUMBER;
BEGIN
    SELECT COUNT(1)
    INTO v_unite_count
    FROM UNITE_DE_POLICE
    WHERE ID_UNITE = :NEW.ID_UNITE;

    IF v_unite_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20030, 'L’unité de police associée n’existe pas ou a été supprimée.');
    END IF;
END;
/

-- Ce trigger garantit que chaque pièce justificative est associée à un crime existant. 
-- Si aucun crime n'est précisé, l'insertion est bloquée.
CREATE OR REPLACE TRIGGER trg_check_crime_for_proof
BEFORE INSERT ON PIECES_JUSTIFICATIF
FOR EACH ROW
BEGIN
    IF :NEW.ID_CRIME IS NULL THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chaque pièce justificative doit être associée à un crime.');
    END IF;
END;
/

-- ########################
-- 5. Validation des champs et plages de valeurs
-- ########################

-- Ce trigger vérifie que les champs NOM et PRENOM d'un procureur ne sont ni vides ni NULL 
-- lors de l'insertion ou de la mise à jour. Cela garantit des données valides et complètes.
CREATE OR REPLACE TRIGGER trg_check_nom_prenom
BEFORE INSERT OR UPDATE ON PROCUREUR
FOR EACH ROW
BEGIN
    IF :NEW.NOM IS NULL OR :NEW.NOM = '' OR :NEW.PRENOM IS NULL OR :NEW.PRENOM = '' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Les champs NOM et PRENOM sont obligatoires.');
    END IF;
END;
/

-- Ce trigger garantit que la gravité d’un crime est toujours comprise entre 1 et 10. 
-- Cela évite des valeurs incohérentes ou en dehors de la plage définie.
CREATE OR REPLACE TRIGGER trg_check_gravity_crime
BEFORE INSERT OR UPDATE ON CRIME
FOR EACH ROW
BEGIN
    IF :NEW.GRAVITE < 1 OR :NEW.GRAVITE > 10 THEN
        RAISE_APPLICATION_ERROR(-20010, 'La gravité doit être comprise entre 1 et 10.');
    END IF;
END;
/
