/// Contact status enum for wishlist feature
///
/// Represents the contact status between a professional and a bride
/// who has added them to their wishlist.
library;

/// Contact status between professional and bride
enum ContactStatus {
  /// No contact request sent yet
  none,

  /// Contact request is pending
  pending,

  /// Contact request was accepted
  accepted,

  /// Contact request was declined
  declined;

  /// Parse from string value (case insensitive)
  static ContactStatus fromString(String? value) {
    if (value == null || value.isEmpty) return ContactStatus.none;

    final normalized = value.toLowerCase();
    return ContactStatus.values.firstWhere(
      (status) => status.name == normalized,
      orElse: () => ContactStatus.none,
    );
  }

  /// Convert to string value
  String get toValue => name;

  /// Whether status is none
  bool get isNone => this == ContactStatus.none;

  /// Whether status is pending
  bool get isPending => this == ContactStatus.pending;

  /// Whether status is accepted
  bool get isAccepted => this == ContactStatus.accepted;

  /// Whether status is declined
  bool get isDeclined => this == ContactStatus.declined;

  /// Whether the professional can contact this bride
  /// Only possible if no request exists yet (none) or request was accepted
  bool get canContact => this == ContactStatus.none || this == ContactStatus.accepted;
}
