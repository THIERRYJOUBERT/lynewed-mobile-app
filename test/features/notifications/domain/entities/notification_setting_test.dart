import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/notifications/domain/entities/notification_setting.dart';

void main() {
  // ==============================================================
  // TEST FIXTURES
  // ==============================================================

  const testNotificationSettingMap = {
    'id': 'setting-123',
    'profile_id': 'user-456',
    'notification_type': 'chat_message',
    'in_app_enabled': true,
    'push_enabled': false,
    'created_at': '2025-01-24T10:00:00Z',
    'updated_at': '2025-01-24T12:00:00Z',
  };

  const testNotificationSettingMapPartial = {
    'id': 'setting-123',
    'profile_id': 'user-456',
    'notification_type': 'new_contact',
    // No in_app_enabled or push_enabled -> defaults
  };

  // ==============================================================
  // AC1: CREATION TESTS
  // ==============================================================

  group('NotificationSetting', () {
    group('creation', () {
      test('should create NotificationSetting with required fields', () {
        final now = DateTime.now();
        final setting = NotificationSetting(
          id: 'setting-123',
          profileId: 'user-456',
          notificationType: 'chat_message',
          inAppEnabled: true,
          pushEnabled: false,
          createdAt: now,
          updatedAt: now,
        );

        expect(setting.id, 'setting-123');
        expect(setting.profileId, 'user-456');
        expect(setting.notificationType, 'chat_message');
        expect(setting.inAppEnabled, true);
        expect(setting.pushEnabled, false);
        expect(setting.createdAt, now);
        expect(setting.updatedAt, now);
      });

      test('should create NotificationSetting with null optional fields', () {
        const setting = NotificationSetting(
          id: 'setting-123',
          profileId: 'user-456',
          notificationType: 'chat_message',
          inAppEnabled: true,
          pushEnabled: true,
        );

        expect(setting.createdAt, isNull);
        expect(setting.updatedAt, isNull);
      });
    });

    // ==============================================================
    // AC1: FROMJSON TESTS
    // ==============================================================

    group('fromJson', () {
      test('should parse from JSON with all fields', () {
        final setting = NotificationSetting.fromJson(testNotificationSettingMap);

        expect(setting.id, 'setting-123');
        expect(setting.profileId, 'user-456');
        expect(setting.notificationType, 'chat_message');
        expect(setting.inAppEnabled, true);
        expect(setting.pushEnabled, false);
        expect(setting.createdAt, isA<DateTime>());
        expect(setting.createdAt!.year, 2025);
        expect(setting.createdAt!.month, 1);
        expect(setting.createdAt!.day, 24);
        expect(setting.updatedAt, isA<DateTime>());
      });

      test('should use default values when fields are missing', () {
        final setting =
            NotificationSetting.fromJson(testNotificationSettingMapPartial);

        expect(setting.id, 'setting-123');
        expect(setting.profileId, 'user-456');
        expect(setting.notificationType, 'new_contact');
        // Default values for missing fields
        expect(setting.inAppEnabled, true);
        expect(setting.pushEnabled, true);
        expect(setting.createdAt, isNull);
        expect(setting.updatedAt, isNull);
      });

      test('should handle null id gracefully', () {
        final map = <String, dynamic>{
          'id': null,
          'profile_id': 'user-456',
          'notification_type': 'chat_message',
        };

        final setting = NotificationSetting.fromJson(map);

        expect(setting.id, '');
      });

      test('should handle null profile_id gracefully', () {
        final map = <String, dynamic>{
          'id': 'setting-123',
          'profile_id': null,
          'notification_type': 'chat_message',
        };

        final setting = NotificationSetting.fromJson(map);

        expect(setting.profileId, '');
      });

      test('should handle null notification_type gracefully', () {
        final map = <String, dynamic>{
          'id': 'setting-123',
          'profile_id': 'user-456',
          'notification_type': null,
        };

        final setting = NotificationSetting.fromJson(map);

        expect(setting.notificationType, '');
      });

      test('should handle malformed date strings gracefully', () {
        final map = <String, dynamic>{
          'id': 'setting-123',
          'profile_id': 'user-456',
          'notification_type': 'chat_message',
          'created_at': 'invalid-date',
          'updated_at': 'also-invalid',
        };

        final setting = NotificationSetting.fromJson(map);

        expect(setting.createdAt, isNull);
        expect(setting.updatedAt, isNull);
      });

      test('should handle empty map gracefully', () {
        final setting = NotificationSetting.fromJson(<String, dynamic>{});

        // All fields should use defaults
        expect(setting.id, '');
        expect(setting.profileId, '');
        expect(setting.notificationType, '');
        expect(setting.inAppEnabled, true);
        expect(setting.pushEnabled, true);
        expect(setting.createdAt, isNull);
        expect(setting.updatedAt, isNull);
      });
    });

    // ==============================================================
    // AC1: TOJSON TESTS
    // ==============================================================

    group('toJson', () {
      test('should serialize to JSON with all fields', () {
        final createdAt = DateTime.utc(2025, 1, 24, 10, 0, 0);
        final updatedAt = DateTime.utc(2025, 1, 24, 12, 0, 0);
        final setting = NotificationSetting(
          id: 'setting-123',
          profileId: 'user-456',
          notificationType: 'chat_message',
          inAppEnabled: true,
          pushEnabled: false,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final json = setting.toJson();

        expect(json['id'], 'setting-123');
        expect(json['profile_id'], 'user-456');
        expect(json['notification_type'], 'chat_message');
        expect(json['in_app_enabled'], true);
        expect(json['push_enabled'], false);
        expect(json['created_at'], '2025-01-24T10:00:00.000Z');
        expect(json['updated_at'], '2025-01-24T12:00:00.000Z');
      });

      test('should not include null createdAt/updatedAt in JSON', () {
        const setting = NotificationSetting(
          id: 'setting-123',
          profileId: 'user-456',
          notificationType: 'chat_message',
          inAppEnabled: true,
          pushEnabled: true,
        );

        final json = setting.toJson();

        expect(json.containsKey('created_at'), false);
        expect(json.containsKey('updated_at'), false);
      });

      test('should be reversible with fromJson', () {
        final createdAt = DateTime.utc(2025, 1, 24, 10, 0, 0);
        final original = NotificationSetting(
          id: 'setting-123',
          profileId: 'user-456',
          notificationType: 'chat_message',
          inAppEnabled: true,
          pushEnabled: false,
          createdAt: createdAt,
        );

        final json = original.toJson();
        final restored = NotificationSetting.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.profileId, original.profileId);
        expect(restored.notificationType, original.notificationType);
        expect(restored.inAppEnabled, original.inAppEnabled);
        expect(restored.pushEnabled, original.pushEnabled);
        expect(restored.createdAt, original.createdAt);
      });
    });

    // ==============================================================
    // AC1: COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should preserve unchanged fields', () {
        final setting = NotificationSetting.fromJson(testNotificationSettingMap);

        final updated = setting.copyWith(pushEnabled: true);

        expect(updated.id, setting.id);
        expect(updated.profileId, setting.profileId);
        expect(updated.notificationType, setting.notificationType);
        expect(updated.inAppEnabled, setting.inAppEnabled);
        expect(updated.createdAt, setting.createdAt);
        expect(updated.updatedAt, setting.updatedAt);
        // Only pushEnabled changed
        expect(updated.pushEnabled, true);
      });

      test('should update multiple fields at once', () {
        final setting = NotificationSetting.fromJson(testNotificationSettingMap);

        final updated = setting.copyWith(
          inAppEnabled: false,
          pushEnabled: true,
        );

        expect(updated.inAppEnabled, false);
        expect(updated.pushEnabled, true);
      });

      test('should not modify original instance', () {
        final original =
            NotificationSetting.fromJson(testNotificationSettingMap);

        original.copyWith(pushEnabled: true);

        expect(original.pushEnabled, false);
      });

      test('should update id when specified', () {
        final setting = NotificationSetting.fromJson(testNotificationSettingMap);

        final updated = setting.copyWith(id: 'new-id');

        expect(updated.id, 'new-id');
      });

      test('should update profileId when specified', () {
        final setting = NotificationSetting.fromJson(testNotificationSettingMap);

        final updated = setting.copyWith(profileId: 'new-user');

        expect(updated.profileId, 'new-user');
      });

      test('should update notificationType when specified', () {
        final setting = NotificationSetting.fromJson(testNotificationSettingMap);

        final updated = setting.copyWith(notificationType: 'video_call');

        expect(updated.notificationType, 'video_call');
      });

      test('should update timestamps when specified', () {
        final setting = NotificationSetting.fromJson(testNotificationSettingMap);
        final newDate = DateTime.utc(2025, 2, 1);

        final updated = setting.copyWith(
          createdAt: newDate,
          updatedAt: newDate,
        );

        expect(updated.createdAt, newDate);
        expect(updated.updatedAt, newDate);
      });
    });

    // ==============================================================
    // AC1: TOSTRING TESTS
    // ==============================================================

    group('toString', () {
      test('should return formatted string with notification type', () {
        final setting = NotificationSetting.fromJson(testNotificationSettingMap);

        final result = setting.toString();

        expect(result, contains('chat_message'));
        expect(result, contains('inApp=true'));
        expect(result, contains('push=false'));
      });

      test('should include NotificationSetting prefix', () {
        const setting = NotificationSetting(
          id: 'setting-123',
          profileId: 'user-456',
          notificationType: 'video_call',
          inAppEnabled: false,
          pushEnabled: true,
        );

        final result = setting.toString();

        expect(result, startsWith('NotificationSetting('));
        expect(result, endsWith(')'));
        expect(result, contains('video_call'));
        expect(result, contains('inApp=false'));
        expect(result, contains('push=true'));
      });
    });
  });
}
