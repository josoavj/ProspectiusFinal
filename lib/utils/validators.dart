class ValidationResult {
  final bool isValid;
  final String? error;

  ValidationResult({required this.isValid, this.error});

  factory ValidationResult.valid() => ValidationResult(isValid: true);
  factory ValidationResult.invalid(String error) =>
      ValidationResult(isValid: false, error: error);
}

class Validators {
  // Email validation
  static ValidationResult validateEmail(String email) {
    if (email.isEmpty) {
      return ValidationResult.invalid('L\'email est obligatoire');
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return ValidationResult.invalid('Email invalide');
    }

    return ValidationResult.valid();
  }

  // Username validation
  static ValidationResult validateUsername(String username) {
    if (username.isEmpty) {
      return ValidationResult.invalid('Le nom d\'utilisateur est obligatoire');
    }

    if (username.length < 3) {
      return ValidationResult.invalid(
        'Le nom d\'utilisateur doit contenir au moins 3 caractères',
      );
    }

    if (username.length > 20) {
      return ValidationResult.invalid(
        'Le nom d\'utilisateur ne doit pas dépasser 20 caractères',
      );
    }

    final usernameRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!usernameRegex.hasMatch(username)) {
      return ValidationResult.invalid(
        'Le nom d\'utilisateur ne peut contenir que des lettres, chiffres, - et _',
      );
    }

    return ValidationResult.valid();
  }

  // Password validation
  static ValidationResult validatePassword(String password) {
    if (password.isEmpty) {
      return ValidationResult.invalid('Le mot de passe est obligatoire');
    }

    if (password.length < 8) {
      return ValidationResult.invalid(
        'Le mot de passe doit contenir au moins 8 caractères',
      );
    }

    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));

    if (!hasUppercase || !hasLowercase || !hasDigits) {
      return ValidationResult.invalid(
        'Le mot de passe doit contenir au moins une majuscule, une minuscule et un chiffre',
      );
    }

    return ValidationResult.valid();
  }

  // Name validation
  static ValidationResult validateName(String name, String fieldName) {
    if (name.isEmpty) {
      return ValidationResult.invalid('$fieldName est obligatoire');
    }

    if (name.length < 2) {
      return ValidationResult.invalid(
        '$fieldName doit contenir au moins 2 caractères',
      );
    }

    if (name.length > 50) {
      return ValidationResult.invalid(
        '$fieldName ne doit pas dépasser 50 caractères',
      );
    }

    return ValidationResult.valid();
  }

  // Phone validation
  static ValidationResult validatePhone(String phone) {
    if (phone.isEmpty) {
      return ValidationResult.valid(); // Optional field
    }

    final phoneRegex = RegExp(r'^[0-9\s+\-().]*$');
    if (!phoneRegex.hasMatch(phone)) {
      return ValidationResult.invalid('Numéro de téléphone invalide');
    }

    final digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length < 10) {
      return ValidationResult.invalid(
        'Le numéro doit contenir au moins 10 chiffres',
      );
    }

    return ValidationResult.valid();
  }

  // Company name validation
  static ValidationResult validateCompanyName(String companyName) {
    if (companyName.isEmpty) {
      return ValidationResult.valid(); // Optional field
    }

    if (companyName.length > 100) {
      return ValidationResult.invalid(
        'Le nom de l\'entreprise ne doit pas dépasser 100 caractères',
      );
    }

    return ValidationResult.valid();
  }

  // Notes validation
  static ValidationResult validateNotes(String notes) {
    if (notes.isEmpty) {
      return ValidationResult.valid(); // Optional field
    }

    if (notes.length > 1000) {
      return ValidationResult.invalid(
        'Les notes ne doivent pas dépasser 1000 caractères',
      );
    }

    return ValidationResult.valid();
  }

  // Validate all fields for registration
  static ValidationResult validateRegistration({
    required String nom,
    required String prenom,
    required String email,
    required String username,
    required String password,
  }) {
    var result = validateName(nom, 'Le nom');
    if (!result.isValid) return result;

    result = validateName(prenom, 'Le prénom');
    if (!result.isValid) return result;

    result = validateEmail(email);
    if (!result.isValid) return result;

    result = validateUsername(username);
    if (!result.isValid) return result;

    result = validatePassword(password);
    if (!result.isValid) return result;

    return ValidationResult.valid();
  }

  // Validate all fields for prospect
  static ValidationResult validateProspect({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String entreprise,
  }) {
    var result = validateName(nom, 'Le nom');
    if (!result.isValid) return result;

    result = validateName(prenom, 'Le prénom');
    if (!result.isValid) return result;

    result = validateEmail(email);
    if (!result.isValid) return result;

    result = validatePhone(telephone);
    if (!result.isValid) return result;

    result = validateCompanyName(entreprise);
    if (!result.isValid) return result;

    return ValidationResult.valid();
  }
}
