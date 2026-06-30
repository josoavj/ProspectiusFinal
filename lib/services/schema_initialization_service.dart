import 'package:mysql1/mysql1.dart' as mysql;
import '../utils/app_logger.dart';

/// Service d'initialisation du schéma de base de données
/// Crée les tables principales si elles n'existent pas
class SchemaInitializationService {
  final mysql.MySqlConnection _connection;

  SchemaInitializationService(this._connection);

  /// Initialise le schéma complet de la base de données
  Future<void> initializeSchema() async {
    try {
      AppLogger.info('Initialisation du schéma de la base de données...');

      await _createAccountsTable();
      await _createProspectsTable();
      await _createInteractionsTable();
      await _createStatusHistoryTable();
      await _createTransferHistoryTable();
      await _createAuditLogsTable();
      await _createTasksTable();
      await _createDocumentsTable();
      await _createCustomFieldsTables();

      AppLogger.success('✓ Schéma de base de données initialisé avec succès');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de l\'initialisation du schéma', e, stackTrace);
      rethrow;
    }
  }

  /// Crée la table accounts
  Future<void> _createAccountsTable() async {
    try {
      await _connection.query('''
        CREATE TABLE IF NOT EXISTS Account (
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
      ''');
      AppLogger.success('Table Account créée/vérifiée');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la création de la table Account', e, stackTrace);
      rethrow;
    }
  }

  /// Crée la table prospects
  Future<void> _createProspectsTable() async {
    try {
      await _connection.query('''
        CREATE TABLE IF NOT EXISTS Prospect (
          id_prospect INT AUTO_INCREMENT PRIMARY KEY,
          nomp VARCHAR(50) NOT NULL,
          prenomp VARCHAR(50),
          telephone VARCHAR(30),
          email VARCHAR(100),
          adresse VARCHAR(100),
          type ENUM ('particulier', 'societe', 'organisation') NOT NULL,
          status ENUM ('nouveau', 'interesse', 'negociation', 'perdu', 'converti') DEFAULT 'nouveau',
          priorite ENUM ('basse', 'moyenne', 'haute') DEFAULT 'moyenne',
          source VARCHAR(100),
          nom_entreprise VARCHAR(100),
          poste VARCHAR(100),
          linkedin_url VARCHAR(255),
          site_web VARCHAR(255),
          description TEXT,
          creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          date_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
          deleted_at TIMESTAMP NULL,
          assignation INT,
          FOREIGN KEY (assignation) REFERENCES Account(id_compte) ON DELETE SET NULL,
          INDEX idx_assignation (assignation),
          INDEX idx_status (status),
          INDEX idx_prospect_full_name (nomp, prenomp),
          INDEX idx_email (email),
          INDEX idx_deleted (deleted_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      ''');
      AppLogger.success('Table Prospect créée/vérifiée avec index');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la création de la table Prospect', e, stackTrace);
      rethrow;
    }
  }

  /// Crée la table interactions
  Future<void> _createInteractionsTable() async {
    try {
      await _connection.query('''
        CREATE TABLE IF NOT EXISTS Interaction (
          id_interaction INT AUTO_INCREMENT PRIMARY KEY,
          id_prospect INT,
          id_compte INT,
          id_assigne INT,
          type ENUM('email', 'appel', 'sms', 'reunion', 'message', 'autre'),
          note TEXT,
          suivi TEXT,
          date_interaction DATETIME DEFAULT CURRENT_TIMESTAMP,
          deleted_at TIMESTAMP NULL,
          FOREIGN KEY (id_prospect) REFERENCES Prospect(id_prospect) ON DELETE CASCADE,
          FOREIGN KEY (id_compte) REFERENCES Account(id_compte) ON DELETE CASCADE,
          FOREIGN KEY (id_assigne) REFERENCES Account(id_compte) ON DELETE SET NULL,
          INDEX idx_prospect (id_prospect),
          INDEX idx_compte (id_compte),
          INDEX idx_assigne (id_assigne),
          INDEX idx_prospect_date (id_prospect, date_interaction)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      ''');
      AppLogger.success('Table Interaction créée/vérifiée avec suivi et assignation');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la création de la table Interaction', e, stackTrace);
      rethrow;
    }
  }

  /// Crée la table audit_logs
  Future<void> _createAuditLogsTable() async {
    try {
      await _connection.query('''
        CREATE TABLE IF NOT EXISTS audit_logs (
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
      ''');
      AppLogger.success('Table audit_logs créée/vérifiée');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la création de la table audit_logs', e, stackTrace);
      rethrow;
    }
  }

  /// Crée la table StatusHistory
  Future<void> _createStatusHistoryTable() async {
    try {
      await _connection.query('''
        CREATE TABLE IF NOT EXISTS StatusHistory (
          id_status_history INT AUTO_INCREMENT PRIMARY KEY,
          id_prospect INT NOT NULL,
          old_status ENUM('nouveau', 'interesse', 'negociation', 'perdu', 'converti'),
          new_status ENUM('nouveau', 'interesse', 'negociation', 'perdu', 'converti') NOT NULL,
          changed_by INT NOT NULL,
          changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (id_prospect) REFERENCES Prospect(id_prospect) ON DELETE CASCADE,
          FOREIGN KEY (changed_by) REFERENCES Account(id_compte) ON DELETE RESTRICT,
          INDEX idx_prospect (id_prospect),
          INDEX idx_changed_by (changed_by)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      ''');
      AppLogger.success('Table StatusHistory créée/vérifiée');
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de la création de la table StatusHistory', e,
          stackTrace);
      rethrow;
    }
  }

  /// Crée la table TransferHistory
  Future<void> _createTransferHistoryTable() async {
    try {
      await _connection.query('''
        CREATE TABLE IF NOT EXISTS TransferHistory (
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
          FOREIGN KEY (to_user_id) REFERENCES Account(id_compte) ON DELETE RESTRICT,
          INDEX idx_prospect (id_prospect),
          INDEX idx_from_user (from_user_id),
          INDEX idx_to_user (to_user_id),
          INDEX idx_transfer_date (transfer_date),
          INDEX idx_transfer_prospect_date_user (id_prospect, transfer_date, to_user_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      ''');
      AppLogger.success('Table TransferHistory créée/vérifiée');
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de la création de la table TransferHistory',
          e, stackTrace);
      rethrow;
    }
  }

  /// Crée la table taches
  Future<void> _createTasksTable() async {
    try {
      await _connection.query('''
        CREATE TABLE IF NOT EXISTS taches (
          id_tache INT AUTO_INCREMENT PRIMARY KEY,
          id_prospect INT NOT NULL,
          titre VARCHAR(255) NOT NULL,
          description TEXT,
          date_echeance DATETIME NOT NULL,
          est_complete BOOLEAN DEFAULT FALSE,
          creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          deleted_at TIMESTAMP NULL,
          FOREIGN KEY (id_prospect) REFERENCES Prospect(id_prospect) ON DELETE CASCADE,
          INDEX idx_prospect (id_prospect),
          INDEX idx_echeance (date_echeance),
          INDEX idx_status_date (est_complete, date_echeance)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      ''');
      AppLogger.success('Table taches créée/vérifiée');
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de la création de la table taches', e, stackTrace);
      rethrow;
    }
  }

  /// Crée la table documents
  Future<void> _createDocumentsTable() async {
    try {
      await _connection.query('''
        CREATE TABLE IF NOT EXISTS documents (
          id_document INT AUTO_INCREMENT PRIMARY KEY,
          id_prospect INT NOT NULL,
          nom VARCHAR(255) NOT NULL,
          chemin_fichier VARCHAR(512) NOT NULL,
          type_mime VARCHAR(100),
          taille INT,
          creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          deleted_at TIMESTAMP NULL,
          FOREIGN KEY (id_prospect) REFERENCES Prospect(id_prospect) ON DELETE CASCADE,
          INDEX idx_prospect (id_prospect),
          INDEX idx_creation (creation)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      ''');
      AppLogger.success('Table documents créée/vérifiée');
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de la création de la table documents', e, stackTrace);
      rethrow;
    }
  }

  /// Crée les tables pour les champs personnalisés
  Future<void> _createCustomFieldsTables() async {
    try {
      await _connection.query('''
        CREATE TABLE IF NOT EXISTS champs_personnalises (
          id_champ INT AUTO_INCREMENT PRIMARY KEY,
          nom VARCHAR(100) NOT NULL,
          type_donnee ENUM('texte', 'nombre', 'date', 'booleen') DEFAULT 'texte'
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      ''');

      await _connection.query('''
        CREATE TABLE IF NOT EXISTS valeurs_champs_personnalises (
          id_prospect INT NOT NULL,
          id_champ INT NOT NULL,
          valeur TEXT,
          PRIMARY KEY (id_prospect, id_champ),
          FOREIGN KEY (id_prospect) REFERENCES Prospect(id_prospect) ON DELETE CASCADE,
          FOREIGN KEY (id_champ) REFERENCES champs_personnalises(id_champ) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      ''');
      AppLogger.success('Tables des champs personnalisés créées/vérifiées');
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de la création des tables de champs personnalisés', e, stackTrace);
      rethrow;
    }
  }
}
