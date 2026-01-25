import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/chat/domain/entities/chat_enums.dart';

void main() {
  // ==============================================================
  // CHATENTRY STATUS
  // ==============================================================

  group('ChatEntryStatus', () {
    group('fromString', () {
      test('should parse all valid values', () {
        expect(ChatEntryStatus.fromString('roomReady'), ChatEntryStatus.roomReady);
        expect(ChatEntryStatus.fromString('requestPending'), ChatEntryStatus.requestPending);
        expect(ChatEntryStatus.fromString('requiresRequest'), ChatEntryStatus.requiresRequest);
        expect(ChatEntryStatus.fromString('notAllowed'), ChatEntryStatus.notAllowed);
        expect(ChatEntryStatus.fromString('blocked'), ChatEntryStatus.blocked);
        expect(ChatEntryStatus.fromString('error'), ChatEntryStatus.error);
      });

      test('should return null for invalid values', () {
        expect(ChatEntryStatus.fromString('invalid'), isNull);
        expect(ChatEntryStatus.fromString('ROOM_READY'), isNull);
        expect(ChatEntryStatus.fromString(''), isNull);
      });

      test('should return null for null input', () {
        expect(ChatEntryStatus.fromString(null), isNull);
      });
    });
  });

  // ==============================================================
  // CONVERSATION STATUS
  // ==============================================================

  group('ConversationStatus', () {
    group('fromString', () {
      test('should parse all valid values', () {
        expect(ConversationStatus.fromString('pending'), ConversationStatus.pending);
        expect(ConversationStatus.fromString('active'), ConversationStatus.active);
        expect(ConversationStatus.fromString('declined'), ConversationStatus.declined);
        expect(ConversationStatus.fromString('blocked'), ConversationStatus.blocked);
        expect(ConversationStatus.fromString('reportedPending'), ConversationStatus.reportedPending);
        expect(ConversationStatus.fromString('archived'), ConversationStatus.archived);
      });

      test('should return null for invalid values', () {
        expect(ConversationStatus.fromString('invalid'), isNull);
        expect(ConversationStatus.fromString('ACTIVE'), isNull);
      });

      test('should return null for null input', () {
        expect(ConversationStatus.fromString(null), isNull);
      });
    });
  });

  // ==============================================================
  // CONNECTION REQUEST STATUS
  // ==============================================================

  group('ConnectionRequestStatus', () {
    group('fromString', () {
      test('should parse all valid values', () {
        expect(ConnectionRequestStatus.fromString('pending'), ConnectionRequestStatus.pending);
        expect(ConnectionRequestStatus.fromString('accepted'), ConnectionRequestStatus.accepted);
        expect(ConnectionRequestStatus.fromString('declined'), ConnectionRequestStatus.declined);
      });

      test('should return null for invalid values', () {
        expect(ConnectionRequestStatus.fromString('invalid'), isNull);
        expect(ConnectionRequestStatus.fromString('PENDING'), isNull);
      });

      test('should return null for null input', () {
        expect(ConnectionRequestStatus.fromString(null), isNull);
      });
    });
  });

  // ==============================================================
  // CONTACT REQUEST SOURCE
  // ==============================================================

  group('ContactRequestSource', () {
    group('fromString', () {
      test('should parse all valid values', () {
        expect(ContactRequestSource.fromString('fromWishlist'), ContactRequestSource.fromWishlist);
        expect(ContactRequestSource.fromString('fromWedding'), ContactRequestSource.fromWedding);
        expect(ContactRequestSource.fromString('fromAlert'), ContactRequestSource.fromAlert);
        expect(ContactRequestSource.fromString('fromProfile'), ContactRequestSource.fromProfile);
      });

      test('should return null for invalid values', () {
        expect(ContactRequestSource.fromString('invalid'), isNull);
        expect(ContactRequestSource.fromString('FROM_WISHLIST'), isNull);
      });

      test('should return null for null input', () {
        expect(ContactRequestSource.fromString(null), isNull);
      });
    });

    group('displayLabel', () {
      test('should return correct labels for all values', () {
        expect(ContactRequestSource.fromWishlist.displayLabel, 'From wishlist');
        expect(ContactRequestSource.fromWedding.displayLabel, 'From wedding');
        expect(ContactRequestSource.fromAlert.displayLabel, 'From alert');
        expect(ContactRequestSource.fromProfile.displayLabel, 'From profile');
      });
    });
  });

  // ==============================================================
  // MESSAGE TYPE
  // ==============================================================

  group('MessageType', () {
    group('fromString', () {
      test('should parse all valid values', () {
        expect(MessageType.fromString('text'), MessageType.text);
        expect(MessageType.fromString('image'), MessageType.image);
        expect(MessageType.fromString('audio'), MessageType.audio);
        expect(MessageType.fromString('document'), MessageType.document);
      });

      test('should return null for invalid values', () {
        expect(MessageType.fromString('invalid'), isNull);
        expect(MessageType.fromString('TEXT'), isNull);
        expect(MessageType.fromString('video'), isNull);
      });

      test('should return null for null input', () {
        expect(MessageType.fromString(null), isNull);
      });
    });
  });

  // ==============================================================
  // ROOM TYPE
  // ==============================================================

  group('RoomType', () {
    group('fromString', () {
      test('should parse all valid values', () {
        expect(RoomType.fromString('private'), RoomType.private);
        expect(RoomType.fromString('public'), RoomType.public);
        expect(RoomType.fromString('weddingTeam'), RoomType.weddingTeam);
      });

      test('should parse snake_case wedding_team', () {
        expect(RoomType.fromString('wedding_team'), RoomType.weddingTeam);
      });

      test('should return null for invalid values', () {
        expect(RoomType.fromString('invalid'), isNull);
        expect(RoomType.fromString('PRIVATE'), isNull);
      });

      test('should return null for null input', () {
        expect(RoomType.fromString(null), isNull);
      });
    });
  });

  // ==============================================================
  // USER ROLE
  // ==============================================================

  group('UserRole', () {
    group('fromString', () {
      test('should parse all valid values', () {
        expect(UserRole.fromString('bride'), UserRole.bride);
        expect(UserRole.fromString('professional'), UserRole.professional);
      });

      test('should return null for invalid values', () {
        expect(UserRole.fromString('invalid'), isNull);
        expect(UserRole.fromString('BRIDE'), isNull);
        expect(UserRole.fromString('pro'), isNull);
      });

      test('should return null for null input', () {
        expect(UserRole.fromString(null), isNull);
      });
    });
  });

  // ==============================================================
  // REPORT REASON
  // ==============================================================

  group('ReportReason', () {
    group('fromString', () {
      test('should parse all valid values', () {
        expect(ReportReason.fromString('spam'), ReportReason.spam);
        expect(ReportReason.fromString('harassment'), ReportReason.harassment);
        expect(ReportReason.fromString('inappropriate_content'), ReportReason.inappropriateContent);
        expect(ReportReason.fromString('other'), ReportReason.other);
      });

      test('should return null for invalid values', () {
        expect(ReportReason.fromString('invalid'), isNull);
        expect(ReportReason.fromString('SPAM'), isNull);
        expect(ReportReason.fromString('inappropriateContent'), isNull); // expects snake_case
      });

      test('should return null for null input', () {
        expect(ReportReason.fromString(null), isNull);
      });
    });

    group('toBackendValue', () {
      test('should convert to snake_case for backend', () {
        expect(ReportReason.spam.toBackendValue(), 'spam');
        expect(ReportReason.harassment.toBackendValue(), 'harassment');
        expect(ReportReason.inappropriateContent.toBackendValue(), 'inappropriate_content');
        expect(ReportReason.other.toBackendValue(), 'other');
      });

      test('should round-trip correctly', () {
        for (final reason in ReportReason.values) {
          final backendValue = reason.toBackendValue();
          final parsed = ReportReason.fromString(backendValue);
          expect(parsed, reason, reason: 'Failed for $reason');
        }
      });
    });

    group('displayLabel', () {
      test('should return correct labels for all values', () {
        expect(ReportReason.spam.displayLabel, 'Spam');
        expect(ReportReason.harassment.displayLabel, 'Harassment');
        expect(ReportReason.inappropriateContent.displayLabel, 'Inappropriate content');
        expect(ReportReason.other.displayLabel, 'Other');
      });
    });
  });
}
