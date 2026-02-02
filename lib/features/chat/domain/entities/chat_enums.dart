/// Chat module enums - Clean Architecture
/// 
/// Defines all enums used in the chat module.
/// These replace FlutterFlow's verbose enum definitions.
library;

/// Status returned by open_or_prepare_contact_context RPC
enum ChatEntryStatus {
  /// Room is ready, can navigate to chat
  roomReady,
  
  /// A contact request is pending (Pro→Bride)
  requestPending,
  
  /// Pro→Bride: Must show ContactRequestSheet first (new flow)
  requiresRequest,
  
  /// Contact not allowed (tier, role, etc.)
  notAllowed,
  
  /// User is blocked
  blocked,
  
  /// Error occurred
  error;

  /// Parse from string (Supabase RPC response)
  static ChatEntryStatus? fromString(String? value) {
    if (value == null) return null;
    return ChatEntryStatus.values.cast<ChatEntryStatus?>().firstWhere(
      (e) => e?.name == value,
      orElse: () => null,
    );
  }
}

/// Conversation status in chat_room_participants
enum ConversationStatus {
  pending,
  active,
  declined,
  blocked,
  reportedPending,
  archived;

  static ConversationStatus? fromString(String? value) {
    if (value == null) return null;
    return ConversationStatus.values.cast<ConversationStatus?>().firstWhere(
      (e) => e?.name == value,
      orElse: () => null,
    );
  }
}

/// Connection request status
enum ConnectionRequestStatus {
  pending,
  accepted,
  declined;

  static ConnectionRequestStatus? fromString(String? value) {
    if (value == null) return null;
    return ConnectionRequestStatus.values.cast<ConnectionRequestStatus?>().firstWhere(
      (e) => e?.name == value,
      orElse: () => null,
    );
  }
}

/// Source of contact request (renamed in Phase 1)
enum ContactRequestSource {
  fromWishlist,
  fromWedding,
  fromAlert,
  fromProfile;

  static ContactRequestSource? fromString(String? value) {
    if (value == null) return null;
    return ContactRequestSource.values.cast<ContactRequestSource?>().firstWhere(
      (e) => e?.name == value,
      orElse: () => null,
    );
  }
  
  /// Display label for UI
  String get displayLabel {
    switch (this) {
      case ContactRequestSource.fromWishlist:
        return 'From wishlist';
      case ContactRequestSource.fromWedding:
        return 'From wedding';
      case ContactRequestSource.fromAlert:
        return 'From alert';
      case ContactRequestSource.fromProfile:
        return 'From profile';
    }
  }
}

/// Message type
enum MessageType {
  text,
  image,
  audio,
  document;

  static MessageType? fromString(String? value) {
    if (value == null) return null;
    return MessageType.values.cast<MessageType?>().firstWhere(
      (e) => e?.name == value,
      orElse: () => null,
    );
  }
}

/// Room type
enum RoomType {
  private,
  public,
  weddingTeam,
  weddingGroupPublic,
  weddingGroupPrivate;

  static RoomType? fromString(String? value) {
    if (value == null) return null;
    // Handle snake_case from database
    switch (value) {
      case 'wedding_team':
        return RoomType.weddingTeam;
      case 'wedding_group_public':
        return RoomType.weddingGroupPublic;
      case 'wedding_group_private':
        return RoomType.weddingGroupPrivate;
      default:
        return RoomType.values.cast<RoomType?>().firstWhere(
          (e) => e?.name == value,
          orElse: () => null,
        );
    }
  }

  /// Convert to snake_case for database
  String toBackendValue() {
    switch (this) {
      case RoomType.weddingTeam:
        return 'wedding_team';
      case RoomType.weddingGroupPublic:
        return 'wedding_group_public';
      case RoomType.weddingGroupPrivate:
        return 'wedding_group_private';
      default:
        return name;
    }
  }

  /// Whether this is a wedding-related group (team or custom)
  bool get isWeddingGroup =>
      this == RoomType.weddingTeam ||
      this == RoomType.weddingGroupPublic ||
      this == RoomType.weddingGroupPrivate;
}

/// User role (shared with other modules)
enum UserRole {
  bride,
  professional;

  static UserRole? fromString(String? value) {
    if (value == null) return null;
    return UserRole.values.cast<UserRole?>().firstWhere(
      (e) => e?.name == value,
      orElse: () => null,
    );
  }
}

/// Report reason for message moderation
enum ReportReason {
  spam,
  harassment,
  inappropriateContent,
  other;

  static ReportReason? fromString(String? value) {
    if (value == null) return null;
    // Handle snake_case from backend
    switch (value) {
      case 'spam':
        return ReportReason.spam;
      case 'harassment':
        return ReportReason.harassment;
      case 'inappropriate_content':
        return ReportReason.inappropriateContent;
      case 'other':
        return ReportReason.other;
      default:
        return null;
    }
  }

  /// Convert to snake_case for backend
  String toBackendValue() {
    switch (this) {
      case ReportReason.spam:
        return 'spam';
      case ReportReason.harassment:
        return 'harassment';
      case ReportReason.inappropriateContent:
        return 'inappropriate_content';
      case ReportReason.other:
        return 'other';
    }
  }

  /// Display label for UI
  String get displayLabel {
    switch (this) {
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.harassment:
        return 'Harassment';
      case ReportReason.inappropriateContent:
        return 'Inappropriate content';
      case ReportReason.other:
        return 'Other';
    }
  }
}
