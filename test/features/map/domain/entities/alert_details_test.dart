import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/map/domain/entities/entities.dart';

void main() {
  group('AlertDetails', () {
    test('should create from JSON correctly', () {
      final json = {
        'alertId': 'test-alert-id',
        'alertType': 'backup_needed',
        'motifCode': 'backup_needed',
        'motifLabel': 'Backup Photographer Needed',
        'message': 'Looking for a backup for wedding on Dec 15',
        'locationLabel': 'Paris, France',
        'startAt': '2024-12-15T10:00:00Z',
        'endAt': '2024-12-16T10:00:00Z',
        'authorProfileId': 'author-id',
        'authorAvatarUrl': 'https://example.com/avatar.jpg',
        'authorFullName': 'Jane Doe',
        'authorProfession': 'photographer',
        'isOwn': false,
        'isContactable': true,
      };

      final details = AlertDetails.fromJson(json);

      expect(details.id, 'test-alert-id');
      expect(details.alertType, AlertType.backupNeeded);
      expect(details.motifLabel, 'Backup Photographer Needed');
      expect(details.message, 'Looking for a backup for wedding on Dec 15');
      expect(details.authorId, 'author-id');
      expect(details.authorFullName, 'Jane Doe');
      expect(details.authorProfession, Profession.photographer);
      expect(details.isContactable, true);
    });

    test('displayTitle should return motifLabel if available', () {
      const details = AlertDetails(
        id: 'test',
        alertType: AlertType.backupNeeded,
        motifLabel: 'Custom Label',
        authorId: 'author',
      );

      expect(details.displayTitle, 'Custom Label');
    });

    test('displayTitle should return alertType displayName if no motifLabel', () {
      const details = AlertDetails(
        id: 'test',
        alertType: AlertType.gearEmergency,
        authorId: 'author',
      );

      expect(details.displayTitle, 'Gear Emergency');
    });

    test('isActive should return true for future endAt', () {
      final details = AlertDetails(
        id: 'test',
        alertType: AlertType.backupNeeded,
        authorId: 'author',
        endAt: DateTime.now().add(const Duration(days: 1)),
      );

      expect(details.isActive, true);
      expect(details.isExpired, false);
    });

    test('isActive should return false for past endAt', () {
      final details = AlertDetails(
        id: 'test',
        alertType: AlertType.backupNeeded,
        authorId: 'author',
        endAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(details.isActive, false);
      expect(details.isExpired, true);
    });

    test('timeRemaining should format correctly', () {
      final details = AlertDetails(
        id: 'test',
        alertType: AlertType.backupNeeded,
        authorId: 'author',
        endAt: DateTime.now().add(const Duration(days: 2)),
      );

      // Allow for timing variance (1-2 days)
      expect(details.timeRemaining, anyOf('2d remaining', '1d remaining'));
    });
  });

  group('AlertType', () {
    test('should have correct values', () {
      expect(AlertType.values.length, 5);
      expect(AlertType.values, contains(AlertType.backupNeeded));
      expect(AlertType.values, contains(AlertType.gearEmergency));
      expect(AlertType.values, contains(AlertType.teamMember));
      expect(AlertType.values, contains(AlertType.emergencyHelp));
      expect(AlertType.values, contains(AlertType.other));
    });

    test('fromString should parse correctly', () {
      expect(AlertType.fromString('backup_needed'), AlertType.backupNeeded);
      expect(AlertType.fromString('backupneeded'), AlertType.backupNeeded);
      expect(AlertType.fromString('gear_emergency'), AlertType.gearEmergency);
      expect(AlertType.fromString('team_member'), AlertType.teamMember);
      expect(AlertType.fromString('emergency_help'), AlertType.emergencyHelp);
      expect(AlertType.fromString('unknown'), AlertType.other);
      expect(AlertType.fromString(null), AlertType.other);
    });

    test('displayName should return correct labels', () {
      expect(AlertType.backupNeeded.displayName, 'Backup Needed');
      expect(AlertType.gearEmergency.displayName, 'Gear Emergency');
      expect(AlertType.teamMember.displayName, 'Team Member');
      expect(AlertType.emergencyHelp.displayName, 'Emergency Help');
      expect(AlertType.other.displayName, 'Other');
    });

    test('description should return correct descriptions', () {
      expect(AlertType.backupNeeded.description, 'Looking for a replacement for a date');
      expect(AlertType.gearEmergency.description, 'Need to rent equipment');
      expect(AlertType.teamMember.description, 'Looking for a second shooter or assistant');
    });
  });
}
