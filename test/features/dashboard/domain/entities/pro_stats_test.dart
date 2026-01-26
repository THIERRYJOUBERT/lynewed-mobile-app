/// ProStats entity tests
///
/// Tests for professional dashboard statistics entity.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/dashboard/domain/entities/pro_stats.dart';

void main() {
  group('ProStats', () {
    test('should create with required fields', () {
      const stats = ProStats(
        profileViews: 100,
        savedCount: 25,
        messageCount: 15,
        alertCount: 3,
      );

      expect(stats.profileViews, 100);
      expect(stats.savedCount, 25);
      expect(stats.messageCount, 15);
      expect(stats.alertCount, 3);
    });

    test('should have default values of zero', () {
      const stats = ProStats.empty();

      expect(stats.profileViews, 0);
      expect(stats.savedCount, 0);
      expect(stats.messageCount, 0);
      expect(stats.alertCount, 0);
    });

    test('should support equality', () {
      const stats1 = ProStats(
        profileViews: 100,
        savedCount: 25,
        messageCount: 15,
        alertCount: 3,
      );
      const stats2 = ProStats(
        profileViews: 100,
        savedCount: 25,
        messageCount: 15,
        alertCount: 3,
      );
      const stats3 = ProStats(
        profileViews: 50,
        savedCount: 25,
        messageCount: 15,
        alertCount: 3,
      );

      expect(stats1, stats2);
      expect(stats1, isNot(stats3));
    });

    test('should support copyWith', () {
      const stats = ProStats(
        profileViews: 100,
        savedCount: 25,
        messageCount: 15,
        alertCount: 3,
      );

      final updated = stats.copyWith(profileViews: 200);

      expect(updated.profileViews, 200);
      expect(updated.savedCount, 25);
      expect(updated.messageCount, 15);
      expect(updated.alertCount, 3);
    });

    test('should calculate total engagement', () {
      const stats = ProStats(
        profileViews: 100,
        savedCount: 25,
        messageCount: 15,
        alertCount: 3,
      );

      // Total engagement = views + saves + messages
      expect(stats.totalEngagement, 140);
    });

    test('should have optional responseRate field', () {
      const stats = ProStats(
        profileViews: 100,
        savedCount: 25,
        messageCount: 15,
        alertCount: 3,
        responseRate: 0.85,
      );

      expect(stats.responseRate, 0.85);
    });

    test('should have optional lastUpdated field', () {
      final now = DateTime(2024, 1, 15, 10, 30);
      final stats = ProStats(
        profileViews: 100,
        savedCount: 25,
        messageCount: 15,
        alertCount: 3,
        lastUpdated: now,
      );

      expect(stats.lastUpdated, now);
    });
  });
}
