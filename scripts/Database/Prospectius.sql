/*
    Auteur: Josoa (josoavj sur GitHub)
    Ce script est la source de la base de données du projet Prospectius
    Veuillez vous réferer à la documentation ou envoyer un mail à l'auteur si vous avez besoin d'aide
*/

-- Suppression complète de la base de données
DROP DATABASE IF EXISTS Prospectius;

-- Création de la DB
CREATE DATABASE Prospectius;
USE Prospectius;

/*
    Table Account : Pour les comptes utilisateurs
*/
CREATE TABLE Account (
    id_compte INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(70) NOT NULL,
    prenom VARCHAR(70) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    type_compte ENUM('Administrateur', 'Utilisateur', 'Commercial') NOT NULL,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (nom, prenom)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Triggers pour Account (Email validation, Password length, etc.)
DELIMITER $$

CREATE TRIGGER avant_ajout_compte BEFORE INSERT ON Account FOR EACH ROW
BEGIN
    IF NEW.type_compte = 'Administrateur' AND (SELECT COUNT(*) FROM Account WHERE type_compte = 'Administrateur') >= 3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La limite de 3 comptes Administrateur est atteinte.';
    END IF;
    IF NEW.email NOT LIKE '%@%.%' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'L\'email doit contenir un "@" et un "."';
    END IF;
    IF CHAR_LENGTH(NEW.password) < 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Le mot de passe doit contenir au moins 8 caractères.';
    END IF;
END$$

CREATE TRIGGER avant_maj_compte BEFORE UPDATE ON Account FOR EACH ROW
BEGIN
    IF OLD.type_compte != NEW.type_compte THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Le type de compte ne peut pas être modifié.';
    END IF;
    IF NEW.email NOT LIKE '%@%.%' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'L\'email doit contenir un "@" et un "."';
    END IF;
    IF CHAR_LENGTH(NEW.password) < 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Le mot de passe doit contenir au moins 8 caractères.';
    END IF;
END$$

CREATE TRIGGER avant_suppression_compte_administrateur BEFORE DELETE ON Account FOR EACH ROW
BEGIN
    IF OLD.type_compte = 'Administrateur' AND (SELECT COUNT(*) FROM Account WHERE type_compte = 'Administrateur') = 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La suppression du dernier compte Administrateur est interdite.';
    END IF;
END$$

DELIMITER ;

/*
    Table Prospect : Fiche détaillée du prospect CRM
*/
CREATE TABLE Prospect (
    id_prospect INT AUTO_INCREMENT PRIMARY KEY,
    nomp        VARCHAR(50) NOT NULL,
    prenomp     VARCHAR(50),
    telephone   VARCHAR(30),
    email       VARCHAR(100),
    adresse     VARCHAR(100),
    type        ENUM ('particulier', 'societe', 'organisation') NOT NULL,
    status      ENUM ('interesse', 'negociation', 'perdu', 'converti') DEFAULT 'interesse',
    priorite    ENUM ('basse', 'moyenne', 'haute') DEFAULT 'moyenne',
    source      VARCHAR(100),
    nom_entreprise VARCHAR(100),
    poste       VARCHAR(100),
    linkedin_url VARCHAR(255),
    site_web    VARCHAR(255),
    description TEXT,
    consentement_date DATETIME NULL,
    consentement_source VARCHAR(100) NULL,
    version     INT DEFAULT 1,
    creation    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at  TIMESTAMP NULL DEFAULT NULL,
    assignation INT,
    created_by  INT,
    updated_by  INT,
    FOREIGN KEY (assignation) REFERENCES Account(id_compte) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES Account(id_compte) ON DELETE SET NULL,
    FOREIGN KEY (updated_by) REFERENCES Account(id_compte) ON DELETE SET NULL,
    INDEX idx_prospect_full_name (nomp, prenomp),
    INDEX idx_assignation (assignation),
    INDEX idx_status (status),
    INDEX idx_email (email),
    INDEX idx_deleted (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*
    Table Interaction : Historique des échanges avec les prospects
*/
CREATE TABLE Interaction (
    id_interaction INT AUTO_INCREMENT PRIMARY KEY,
    id_prospect INT NOT NULL,
    id_compte INT NOT NULL,
    id_assigne INT,
    type ENUM('email', 'appel', 'sms', 'reunion', 'message', 'autre'),
    note TEXT,
    suivi TEXT,
    date_interaction DATETIME DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (id_prospect) REFERENCES Prospect(id_prospect) ON DELETE CASCADE,
    FOREIGN KEY (id_compte) REFERENCES Account(id_compte) ON DELETE CASCADE,
    FOREIGN KEY (id_assigne) REFERENCES Account(id_compte) ON DELETE SET NULL,
    INDEX idx_prospect (id_prospect),
    INDEX idx_compte (id_compte),
    INDEX idx_assigne (id_assigne),
    INDEX idx_prospect_date (id_prospect, date_interaction)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*
    Table Taches : Rappels et actions à faire
*/
CREATE TABLE taches (
    id_tache INT AUTO_INCREMENT PRIMARY KEY,
    id_prospect INT NOT NULL,
    titre VARCHAR(255) NOT NULL,
    description TEXT,
    date_echeance DATETIME NOT NULL,
    est_complete BOOLEAN DEFAULT FALSE,
    creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (id_prospect) REFERENCES Prospect(id_prospect) ON DELETE CASCADE,
    INDEX idx_prospect (id_prospect),
    INDEX idx_echeance (date_echeance),
    INDEX idx_status_date (est_complete, date_echeance)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*
    Table Documents : Fichiers joints aux prospects
*/
CREATE TABLE documents (
    id_document INT AUTO_INCREMENT PRIMARY KEY,
    id_prospect INT NOT NULL,
    nom VARCHAR(255) NOT NULL,
    chemin_fichier VARCHAR(512) NOT NULL,
    type_mime VARCHAR(100),
    taille INT,
    creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (id_prospect) REFERENCES Prospect(id_prospect) ON DELETE CASCADE,
    INDEX idx_prospect (id_prospect),
    INDEX idx_creation (creation)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*
    Table Champs Personnalisés : Flexibilité des données
*/
CREATE TABLE champs_personnalises (
    id_champ INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    type_donnee ENUM('texte', 'nombre', 'date', 'booleen') DEFAULT 'texte'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE valeurs_champs_personnalises (
    id_prospect INT NOT NULL,
    id_champ INT NOT NULL,
    valeur TEXT,
    PRIMARY KEY (id_prospect, id_champ),
    FOREIGN KEY (id_prospect) REFERENCES Prospect(id_prospect) ON DELETE CASCADE,
    FOREIGN KEY (id_champ) REFERENCES champs_personnalises(id_champ) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*
    Tables d'Audit et Historique
*/
CREATE TABLE StatusHistory (
    id_status_history INT AUTO_INCREMENT PRIMARY KEY,
    id_prospect INT NOT NULL,
    old_status ENUM('interesse', 'negociation', 'perdu', 'converti'),
    new_status ENUM('interesse', 'negociation', 'perdu', 'converti') NOT NULL,
    changed_by INT NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_prospect) REFERENCES Prospect(id_prospect) ON DELETE CASCADE,
    FOREIGN KEY (changed_by) REFERENCES Account(id_compte) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE TransferHistory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_prospect INT NOT NULL,
    from_user_id INT NOT NULL,
    to_user_id INT NOT NULL,
    transfer_reason VARCHAR(255),
    transfer_notes TEXT,
    transfer_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('completed', 'pending', 'cancelled') DEFAULT 'completed',
    FOREIGN KEY (id_prospect) REFERENCES Prospect(id_prospect) ON DELETE CASCADE,
    FOREIGN KEY (from_user_id) REFERENCES Account(id_compte) ON DELETE RESTRICT,
    FOREIGN KEY (to_user_id) REFERENCES Account(id_compte) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE audit_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_id INT NOT NULL,
    action VARCHAR(50) NOT NULL,
    user_id INT,
    old_values JSON,
    new_values JSON,
    change_description TEXT,
    ip_address VARCHAR(45),
    user_agent VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Account(id_compte) ON DELETE SET NULL,
    INDEX idx_table_record (table_name, record_id),
    INDEX idx_user (user_id),
    INDEX idx_timestamp (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE migrations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*
    Optimisation Finale : Indexations composites
*/
CREATE INDEX idx_prospect_assignation_creation ON Prospect(assignation, creation);
CREATE INDEX idx_prospect_assignation_status ON Prospect(assignation, status);
CREATE INDEX idx_interaction_prospect_date ON Interaction(id_prospect, date_interaction);
CREATE INDEX idx_transfer_prospect_date_user ON TransferHistory(id_prospect, transfer_date, to_user_id);
