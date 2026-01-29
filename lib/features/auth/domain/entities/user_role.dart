/// User role enumeration for the application.
///
/// Defines the different roles a user can have in the system.
library;

/// The role of a user in the application.
enum UserRole {
  /// Regular user looking for wedding professionals.
  bride,

  /// Wedding professional offering services.
  professional,

  /// System administrator.
  admin,

  /// Guest invited to a wedding.
  guest,
}

/// Extension methods for [UserRole].
extension UserRoleX on UserRole {
  /// Returns the string value for database storage.
  String get value {
    switch (this) {
      case UserRole.bride:
        return 'bride';
      case UserRole.professional:
        return 'professional';
      case UserRole.admin:
        return 'admin';
      case UserRole.guest:
        return 'guest';
    }
  }

  /// Parses a string to [UserRole].
  ///
  /// Returns [UserRole.bride] for unknown values.
  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'bride':
        return UserRole.bride;
      case 'professional':
        return UserRole.professional;
      case 'admin':
        return UserRole.admin;
      case 'guest':
        return UserRole.guest;
      default:
        return UserRole.bride;
    }
  }
}
