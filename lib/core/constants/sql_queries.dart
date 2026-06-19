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
    WHERE assignation = ? AND deleted_at IS NULL
    ORDER BY creation DESC
    LIMIT ? OFFSET ?
  ''';
  
  static const String insertProspect = '''
    INSERT INTO Prospect 
    (nomp, prenomp, email, telephone, adresse, type, assignation, status, creation, date_update)
    VALUES (?, ?, ?, ?, ?, ?, ?, 'nouveau', NOW(), NOW())
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
    (id_prospect, id_compte, type, note, date_interaction)
    VALUES (?, ?, ?, ?, ?)
  ''';

  // Stats
  static const String prospectStatsByStatus = '''
    SELECT status, COUNT(*) as count 
    FROM Prospect 
    WHERE assignation = ? AND deleted_at IS NULL
    GROUP BY status
  ''';

  static const String conversionStats = '''
    SELECT 
      COUNT(*) as total,
      SUM(CASE WHEN status = 'converti' THEN 1 ELSE 0 END) as converted
    FROM Prospect 
    WHERE assignation = ? AND deleted_at IS NULL
  ''';
}
