# Story STORY-02: Tests Notifications Module

## Description

En tant que developpeur, je veux avoir des tests unitaires pour le module Notifications afin de garantir la qualite des entites de configuration de notifications.

## Points : 2

## Priorite : Haute

## Fichiers source a tester

### Domain Layer

| Fichier | Entites/Composants |
|---------|-------------------|
| `lib/features/notifications/domain/entities/notification_setting.dart` | NotificationSetting |
| `lib/features/notifications/domain/entities/notification_type_config.dart` | NotificationTypeConfig |

## Criteres d'Acceptance

### AC1: Tests NotificationSetting
- [ ] Test creation avec champs requis
- [ ] Test `fromJson()` avec donnees completes
- [ ] Test `fromJson()` avec donnees partielles (defaults)
- [ ] Test `toJson()` serialise correctement
- [ ] Test `copyWith()` preserve les champs non modifies
- [ ] Test `toString()` format attendu

### AC2: Tests NotificationTypeConfig
- [ ] Test creation avec champs requis
- [ ] Test parsing depuis JSON
- [ ] Test valeurs par defaut

### AC3: Qualite des tests
- [ ] Coverage > 80% sur domain/entities/
- [ ] Tous les tests passent
- [ ] Temps d'execution < 2s

## Fichiers de Test a Creer

```
test/features/notifications/
└── domain/
    └── entities/
        ├── notification_setting_test.dart
        └── notification_type_config_test.dart
```

## Notes Techniques

### Fixtures de test

```dart
// test/features/notifications/fixtures/notification_fixtures.dart

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
  // Pas de in_app_enabled ni push_enabled -> defaults
};
```

### Exemple de test

```dart
void main() {
  group('NotificationSetting', () {
    test('should create from JSON with all fields', () {
      // Arrange & Act
      final setting = NotificationSetting.fromJson(testNotificationSettingMap);

      // Assert
      expect(setting.id, 'setting-123');
      expect(setting.profileId, 'user-456');
      expect(setting.notificationType, 'chat_message');
      expect(setting.inAppEnabled, true);
      expect(setting.pushEnabled, false);
      expect(setting.createdAt, isA<DateTime>());
    });

    test('should use default values when fields are missing', () {
      // Arrange & Act
      final setting = NotificationSetting.fromJson(testNotificationSettingMapPartial);

      // Assert
      expect(setting.inAppEnabled, true);  // default
      expect(setting.pushEnabled, true);   // default
    });

    test('copyWith should preserve unchanged fields', () {
      // Arrange
      final original = NotificationSetting.fromJson(testNotificationSettingMap);

      // Act
      final updated = original.copyWith(pushEnabled: true);

      // Assert
      expect(updated.id, original.id);
      expect(updated.profileId, original.profileId);
      expect(updated.inAppEnabled, original.inAppEnabled);
      expect(updated.pushEnabled, true);  // changed
    });
  });
}
```

## Definition of Done

- [ ] Tous les fichiers de test crees
- [ ] Tous les tests passent (`flutter test test/features/notifications/`)
- [ ] Aucun warning (`flutter analyze`)
- [ ] Coverage mesure et documente
- [ ] TRACKING.md mis a jour

## Estimation

- NotificationSetting tests : ~45min
- NotificationTypeConfig tests : ~30min
- Review : ~15min

**Total** : ~1.5h
