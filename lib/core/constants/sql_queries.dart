class SqlQueries {
  // Accounts
  static const String findUserByUsername = 'SELECT * FROM Account WHERE username = ?';
  static const String insertAccount = '''
    INSERT INTO Account (nom, prenom, email, username, password, type_compte, date_creation)
    VALUES (?, ?, ?, ?, ?, ?, NOW())
  ''';

  // Prospects
  static const String selectProspectsByUserId = '''
    SELECT * FROM Prospect
    WHERE (assignation = ? OR ? = 'Administrateur') AND deleted_at IS NULL
    ORDER BY creation DESC
    LIMIT ? OFFSET ?
  ''';
  
  static const String insertProspect = '''
    INSERT INTO Prospect 
    (nomp, prenomp, email, telephone, adresse, type, assignation, status, priorite, source, nom_entreprise, poste, linkedin_url, site_web, description, consentement_date, consentement_source, creation, date_update)
    VALUES (?, ?, ?, ?, ?, ?, ?, 'interesse', ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())
  ''';

  static const String softDeleteProspect = '''
    UPDATE Prospect SET deleted_at = NOW(), date_update = NOW() 
    WHERE id_prospect = ? AND deleted_at IS NULL
  ''';

  // Interactions
  static const String selectInteractionsByProspectId = '''
    SELECT * FROM Interaction 
    WHERE id_prospect = ? AND deleted_at IS NULL
    ORDER BY date_interaction DESC
  ''';

  static const String insertInteraction = '''
    INSERT INTO Interaction 
    (id_prospect, id_compte, id_assigne, type, note, suivi, date_interaction)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  ''';

  // Stats
  static const String prospectStatsByStatus = '''
    SELECT status, COUNT(*) as count 
    FROM Prospect 
    WHERE (assignation = ? OR ? = 'Administrateur') AND deleted_at IS NULL
    GROUP BY status
  ''';

  static const String conversionStats = '''
    SELECT 
      COUNT(*) as total,
      SUM(CASE WHEN status = 'converti' THEN 1 ELSE 0 END) as converted
    FROM Prospect 
    WHERE (assignation = ? OR ? = 'Administrateur') AND deleted_at IS NULL
  ''';

  // Tasks
  static const String selectTasksByProspectId = '''
    SELECT * FROM taches 
    WHERE id_prospect = ? AND deleted_at IS NULL
    ORDER BY date_echeance ASC
  ''';

  static const String insertTask = '''
    INSERT INTO taches (id_prospect, titre, description, date_echeance, est_complete, creation)
    VALUES (?, ?, ?, ?, ?, NOW())
  ''';

  static const String updateTaskStatus = '''
    UPDATE taches SET est_complete = ? WHERE id_tache = ? AND deleted_at IS NULL
  ''';

  // Documents
  static const String selectDocumentsByProspectId = '''
    SELECT * FROM documents 
    WHERE id_prospect = ? AND deleted_at IS NULL
    ORDER BY creation DESC
  ''';

  static const String insertDocument = '''
    INSERT INTO documents (id_prospect, nom, chemin_fichier, type_mime, taille, creation)
    VALUES (?, ?, ?, ?, ?, NOW())
  ''';

  // Custom Fields
  static const String selectCustomFields = 'SELECT * FROM champs_personnalises';
  
  static const String selectValuesByProspectId = '''
    SELECT v.*, c.nom as nom_champ 
    FROM valeurs_champs_personnalises v
    JOIN champs_personnalises c ON v.id_champ = c.id_champ
    WHERE v.id_prospect = ?
  ''';

  static const String upsertCustomFieldValue = '''
    INSERT INTO valeurs_champs_personnalises (id_prospect, id_champ, valeur)
    VALUES (?, ?, ?)
    ON DUPLICATE KEY UPDATE valeur = VALUES(valeur)
  ''';

  // Status History
  static const String selectStatusHistoryByProspectId = '''
    SELECT h.*, a.nom, a.prenom 
    FROM StatusHistory h
    JOIN Account a ON h.changed_by = a.id_compte
    WHERE h.id_prospect = ?
    ORDER BY h.changed_at DESC
  ''';

  static const String insertStatusHistory = '''
    INSERT INTO StatusHistory (id_prospect, old_status, new_status, changed_by, changed_at)
    VALUES (?, ?, ?, ?, NOW())
  ''';
}
