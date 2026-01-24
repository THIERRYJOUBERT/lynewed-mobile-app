/// Input Validators - Centralized input validation for security and data integrity.
///
/// Provides validation for common input types:
/// - Email addresses
/// - Passwords
/// - Names
/// - Bio/descriptions
/// - Chat messages
/// - Search queries
///
/// Also provides sanitization for display to prevent XSS attacks.
library;

/// Centralized input validation utility class.
///
/// Usage:
/// ```dart
/// // In a form validator
/// TextFormField(
///   validator: InputValidators.validateEmail,
/// )
///
/// // For display sanitization
/// Text(InputValidators.sanitizeForDisplay(userInput))
/// ```
class InputValidators {
  InputValidators._(); // Private constructor - utility class

  // ============== LENGTH CONSTANTS ==============

  /// Maximum email length per RFC 5321
  static const int maxEmailLength = 254;

  /// Minimum password length for security
  static const int minPasswordLength = 8;

  /// Maximum password length to prevent DoS
  static const int maxPasswordLength = 128;

  /// Maximum name length
  static const int maxNameLength = 100;

  /// Maximum bio/description length
  static const int maxBioLength = 500;

  /// Maximum chat message length
  static const int maxMessageLength = 2000;

  /// Maximum search query length
  static const int maxSearchLength = 200;

  /// Maximum phone number length
  static const int maxPhoneLength = 20;

  // ============== EMAIL VALIDATION ==============

  /// Validates email address.
  ///
  /// Checks:
  /// - Not null or empty
  /// - Valid email format
  /// - Length <= 254 characters (RFC 5321)
  ///
  /// Returns null if valid, error message if invalid.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final trimmed = value.trim();

    // Check length first to prevent DoS
    if (trimmed.length > maxEmailLength) {
      return 'Email is too long (max $maxEmailLength characters)';
    }

    // Standard email regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // ============== PASSWORD VALIDATION ==============

  /// Validates password.
  ///
  /// Checks:
  /// - Not null or empty
  /// - At least 8 characters
  /// - At most 128 characters
  /// - Contains at least one uppercase letter
  /// - Contains at least one lowercase letter
  /// - Contains at least one digit
  ///
  /// Returns null if valid, error message if invalid.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    // Check length first to prevent DoS
    if (value.length > maxPasswordLength) {
      return 'Password is too long (max $maxPasswordLength characters)';
    }

    if (value.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one digit';
    }

    return null;
  }

  // ============== NAME VALIDATION ==============

  /// Validates a person's name.
  ///
  /// Checks:
  /// - Not null or empty
  /// - Length <= 100 characters
  /// - Only contains letters, spaces, hyphens, apostrophes
  /// - No HTML tags or SQL injection patterns
  /// - No malicious unicode
  ///
  /// Returns null if valid, error message if invalid.
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    final trimmed = value.trim();

    // Check length first to prevent DoS
    if (trimmed.length > maxNameLength) {
      return 'Name is too long (max $maxNameLength characters)';
    }

    // Check for malicious unicode
    if (containsMaliciousUnicode(trimmed)) {
      return 'Name contains invalid characters';
    }

    // Check for HTML tags (XSS prevention)
    if (containsHtmlTags(trimmed)) {
      return 'Name contains invalid characters';
    }

    // Check for SQL injection patterns
    if (containsSqlInjectionPattern(trimmed)) {
      return 'Name contains invalid characters';
    }

    // Allow letters (including accented), spaces, hyphens, apostrophes
    // This regex allows unicode letters
    final nameRegex = RegExp(r"^[\p{L}\s\-']+$", unicode: true);

    if (!nameRegex.hasMatch(trimmed)) {
      return 'Name contains invalid characters';
    }

    return null;
  }

  // ============== BIO/DESCRIPTION VALIDATION ==============

  /// Validates bio/description text.
  ///
  /// Checks:
  /// - Length <= 500 characters (if provided)
  /// - No HTML tags (XSS prevention)
  ///
  /// Note: This is an optional field, so null/empty returns null.
  ///
  /// Returns null if valid, error message if invalid.
  static String? validateBio(String? value) {
    // Bio is optional
    if (value == null || value.isEmpty) {
      return null;
    }

    // Check length first to prevent DoS
    if (value.length > maxBioLength) {
      return 'Bio is too long (max $maxBioLength characters)';
    }

    // Check for HTML tags (XSS prevention)
    if (containsHtmlTags(value)) {
      return 'Bio contains invalid content';
    }

    return null;
  }

  // ============== MESSAGE VALIDATION ==============

  /// Validates a chat message.
  ///
  /// Checks:
  /// - Not null or empty (trimmed)
  /// - Length <= maxLength (default 2000)
  ///
  /// Returns null if valid, error message if invalid.
  static String? validateMessage(String? value, {int maxLength = maxMessageLength}) {
    if (value == null || value.trim().isEmpty) {
      return 'Message cannot be empty';
    }

    // Check length first to prevent DoS
    if (value.length > maxLength) {
      return 'Message is too long (max $maxLength characters)';
    }

    return null;
  }

  // ============== PHONE VALIDATION ==============

  /// Validates a phone number.
  ///
  /// Checks:
  /// - Length <= 20 characters (if provided)
  /// - Only contains valid phone characters: digits, +, -, (), spaces
  ///
  /// Note: This is an optional field, so null/empty returns null.
  ///
  /// Returns null if valid, error message if invalid.
  static String? validatePhone(String? value) {
    // Phone is optional
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final trimmed = value.trim();

    // Check length first to prevent DoS
    if (trimmed.length > maxPhoneLength) {
      return 'Phone number is too long (max $maxPhoneLength characters)';
    }

    // Allow digits, +, -, (), spaces
    final phoneRegex = RegExp(r'^[0-9+\-\(\)\s]+$');
    if (!phoneRegex.hasMatch(trimmed)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // ============== SEARCH QUERY VALIDATION ==============

  /// Validates a search query.
  ///
  /// Checks:
  /// - Length <= 200 characters (if provided)
  ///
  /// Note: This is an optional field, so null/empty returns null.
  ///
  /// Returns null if valid, error message if invalid.
  static String? validateSearchQuery(String? value) {
    // Search is optional
    if (value == null || value.isEmpty) {
      return null;
    }

    // Check length first to prevent DoS
    if (value.length > maxSearchLength) {
      return 'Search query is too long (max $maxSearchLength characters)';
    }

    return null;
  }

  // ============== SANITIZATION ==============

  /// Sanitizes a string for safe display by escaping HTML special characters.
  ///
  /// Use this when displaying user-generated content to prevent XSS attacks.
  ///
  /// Escapes: & < > " '
  static String sanitizeForDisplay(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }

  // ============== SECURITY CHECKS ==============

  /// Checks if a string contains HTML tags (potential XSS).
  ///
  /// Detects patterns like: <script>, <img, <div, <a, <iframe, etc.
  static bool containsHtmlTags(String input) {
    if (input.isEmpty) return false;

    // Matches HTML-like tags: <tagname or </tagname
    // More precise: looks for < followed by optional / and then letter(s)
    final htmlTagRegex = RegExp(r'<\/?[a-zA-Z][^>]*>', caseSensitive: false);
    return htmlTagRegex.hasMatch(input);
  }

  /// Checks if a string contains common SQL injection patterns.
  ///
  /// Detects patterns like: ' OR ', UNION SELECT, DROP TABLE, etc.
  static bool containsSqlInjectionPattern(String input) {
    if (input.isEmpty) return false;

    final lowerInput = input.toLowerCase();

    // Common SQL injection patterns
    final patterns = [
      r"'\s*(or|and)\s*'", // ' OR ' or ' AND '
      r"'\s*(or|and)\s+\d", // ' OR 1, ' AND 1
      r'union\s+select', // UNION SELECT
      r'drop\s+table', // DROP TABLE
      r'delete\s+from', // DELETE FROM
      r'insert\s+into', // INSERT INTO
      r'update\s+\w+\s+set', // UPDATE x SET
      r'--\s*$', // SQL comment at end
      r';\s*--', // ; followed by comment
      r"'\s*;\s*", // ' followed by ;
      r'"\s*--', // " followed by --
    ];

    for (final pattern in patterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(lowerInput)) {
        return true;
      }
    }

    return false;
  }

  /// Checks if a string contains malicious unicode characters.
  ///
  /// Detects invisible characters that could be used for spoofing:
  /// - Zero-width space (U+200B)
  /// - Zero-width non-joiner (U+200C)
  /// - Zero-width joiner (U+200D)
  /// - Right-to-left override (U+202E)
  /// - Left-to-right override (U+202D)
  /// - Other formatting characters
  static bool containsMaliciousUnicode(String input) {
    if (input.isEmpty) return false;

    // Dangerous invisible/formatting unicode characters
    // Note: U+200D (zero-width joiner) is NOT included because it's needed for
    // emoji sequences (family emojis, skin tone modifiers, etc.)
    final maliciousChars = [
      '\u200B', // Zero-width space
      '\u200C', // Zero-width non-joiner
      // '\u200D' - Zero-width joiner (NOT blocked - needed for emoji sequences)
      '\u200E', // Left-to-right mark
      '\u200F', // Right-to-left mark
      '\u202A', // Left-to-right embedding
      '\u202B', // Right-to-left embedding
      '\u202C', // Pop directional formatting
      '\u202D', // Left-to-right override
      '\u202E', // Right-to-left override
      '\u2060', // Word joiner
      '\u2061', // Function application
      '\u2062', // Invisible times
      '\u2063', // Invisible separator
      '\u2064', // Invisible plus
      '\uFEFF', // Byte order mark
    ];

    for (final char in maliciousChars) {
      if (input.contains(char)) {
        return true;
      }
    }

    return false;
  }
}
