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
    Quatre tables présentes dans la base de données : Account, Prospect, Interaction
    Table Account : Pour les comptes utilisateurs
    Table Prospect : Pour les prospects
    Table Interaction : Pour les interactions avec les prospects
    Table StatusHistory : Pour l'historique des changements de statut des prospects
*/

-- Table Compte
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
);

/*
    Pour la table Account:
    - Il est recommandé d'utiliser un mot de passe crypté: veuillez crypter votre mot de passe en fonction du techno ou langage utilisé
    - Le mot de passe ne doit pas contenir des informations sensibles (Informations personnelles)
    - Un seul compte Administrateur est requis.
    - Seul l'administrateur qui possède le droit de supprimer des comptes dans la base de données.
*/

-- Compte administrateur unique
DELIMITER $$

CREATE TRIGGER avant_ajout_compte
    BEFORE INSERT ON Account
    FOR EACH ROW
BEGIN
    IF NEW.type_compte = 'Administrateur' AND (SELECT COUNT(*) FROM Account WHERE type_compte = 'Administrateur') > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un compte Administrateur existe déjà.';
    END IF;
END$$

DELIMITER ;

-- Vérification du mail
DELIMITER $$

CREATE TRIGGER ajout_compte
    BEFORE INSERT ON Account
    FOR EACH ROW
BEGIN
    IF NEW.email NOT LIKE '%@%.%' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'L\'email doit contenir un "@" et un "."';
    END IF;
END$$

CREATE TRIGGER maj_compte
    BEFORE UPDATE ON Account
    FOR EACH ROW
BEGIN
    IF NEW.email NOT LIKE '%@%.%' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'L\'email doit contenir un "@" et un "."';
    END IF;
END$$

DELIMITER ;

-- Modification du type de compte
DELIMITER $$

CREATE TRIGGER avant_maj_compte
    BEFORE UPDATE ON Account
    FOR EACH ROW
BEGIN
    IF OLD.type_compte != NEW.type_compte THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Le type de compte ne peut pas être modifié.';
    END IF;
END$$

DELIMITER ;


-- Pour le mot de passe

DELIMITER $$

CREATE TRIGGER avant_ajout_password
    BEFORE INSERT ON Account
    FOR EACH ROW
BEGIN
    IF CHAR_LENGTH(NEW.password) < 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Le mot de passe doit contenir au moins 8 caractères.';
    END IF;
END$$

CREATE TRIGGER avant_maj_password
    BEFORE UPDATE ON Account
    FOR EACH ROW
BEGIN
    IF CHAR_LENGTH(NEW.password) < 8 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Le mot de passe doit contenir au moins 8 caractères.';
    END IF;
END$$

DELIMITER ;

-- Empêcher la suppression du dernier compte administrateur présent dans la base de données
DELIMITER $$

CREATE TRIGGER avant_suppression_compte_administrateur
    BEFORE DELETE ON Account
    FOR EACH ROW
BEGIN
    IF OLD.type_compte = 'Administrateur' AND (SELECT COUNT(*) FROM Account WHERE type_compte = 'Administrateur') = 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La suppression du dernier compte Administrateur est interdite.';
    END IF;
END$$

DELIMITER ;

CREATE TABLE Prospect
(
    id_prospect INT AUTO_INCREMENT PRIMARY KEY,
    nomp        VARCHAR(50),
    prenomp     VARCHAR(50),
    telephone   VARCHAR(30),
    email       VARCHAR(100),
    adresse     VARCHAR(100),
    type        ENUM ('particulier', 'societe', 'organisation'),
    status      ENUM ('nouveau', 'interesse', 'negociation', 'perdu', 'converti') DEFAULT 'nouveau',
    creation    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_update    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    assignation INT,
    FOREIGN KEY (assignation) REFERENCES Account(id_compte)
);

CREATE TABLE Interaction (
    id_interaction INT AUTO_INCREMENT PRIMARY KEY,
    id_prospect INT,
    id_compte INT,
    type ENUM('email', 'appel', 'sms', 'reunion'),
    note TEXT,
    date_interaction TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_prospect) REFERENCES Prospect(id_prospect),
    FOREIGN KEY (id_compte) REFERENCES Account(id_compte)
);

-- Historique des statuts
CREATE TABLE StatusHistory (
    id_status_history INT AUTO_INCREMENT PRIMARY KEY,
    id_prospect INT NOT NULL,
    old_status ENUM('nouveau', 'interesse', 'negociation', 'perdu', 'converti'),
    new_status ENUM('nouveau', 'interesse', 'negociation', 'perdu', 'converti') NOT NULL,
    changed_by INT NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_prospect) REFERENCES Prospect(id_prospect),
    FOREIGN KEY (changed_by) REFERENCES Account(id_compte)
);

-- Historique des transferts de prospects
CREATE TABLE TransferHistory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_prospect INT NOT NULL,
    from_user_id INT NOT NULL,
    to_user_id INT NOT NULL,
    transfer_reason VARCHAR(255),
    transfer_notes TEXT,
    transfer_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('completed', 'pending', 'cancelled') DEFAULT 'completed',
    FOREIGN KEY (id_prospect) REFERENCES Prospect(id_prospect),
    FOREIGN KEY (from_user_id) REFERENCES Account(id_compte),
    FOREIGN KEY (to_user_id) REFERENCES Account(id_compte)
);

-- Index pour les recherches rapides
CREATE INDEX idx_prospect_status ON Prospect(id_prospect, status);
CREATE INDEX idx_prospect_assignation ON Prospect(assignation);
CREATE INDEX idx_interaction_prospect ON Interaction(id_prospect);
CREATE INDEX idx_status_history_prospect ON StatusHistory(id_prospect);
CREATE INDEX idx_transfer_prospect ON TransferHistory(id_prospect);
CREATE INDEX idx_transfer_from_user ON TransferHistory(from_user_id);
CREATE INDEX idx_transfer_to_user ON TransferHistory(to_user_id);
CREATE INDEX idx_transfer_date ON TransferHistory(transfer_date);

/*
    Modifié le 7 Décembre 2025
    - Ajout de la table TransferHistory pour l'historique des transferts de prospects
*/