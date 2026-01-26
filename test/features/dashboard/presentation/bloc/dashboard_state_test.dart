/// Dashboard state tests
///
/// Tests for dashboard cubit state classes.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:lynewed_beta/features/dashboard/domain/entities/pro_stats.dart';
import 'package:lynewed_beta/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:lynewed_beta/features/map/domain/entities/alert_details.dart';
import 'package:lynewed_beta/features/map/domain/entities/professional_alert.dart';

void main() {
  group('DashboardState', () {
    group('DashboardInitial', () {
      test('should be a DashboardState', () {
        const state = DashboardInitial();
        expect(state, isA<DashboardState>());
      });
    });

    group('DashboardLoading', () {
      test('should be a DashboardState', () {
        const state = DashboardLoading();
        expect(state, isA<DashboardState>());
      });
    });

    group('DashboardLoaded', () {
      final testStats = const ProStats(
        profileViews: 100,
        savedCount: 25,
        messageCount: 15,
        alertCount: 3,
      );

      final testAlerts = [
        ProfessionalAlert(
          id: 'alert-1',
          professionalId: 'pro-1',
          type: AlertType.backupNeeded,
          position: const gmaps.LatLng(48.8566, 2.3522),
          eventDate: DateTime(2024, 1, 15),
        ),
      ];

      test('should be a DashboardState', () {
        final state = DashboardLoaded(
          stats: testStats,
          alerts: testAlerts,
        );
        expect(state, isA<DashboardState>());
      });

      test('should store stats and alerts', () {
        final state = DashboardLoaded(
          stats: testStats,
          alerts: testAlerts,
        );
        expect(state.stats, testStats);
        expect(state.alerts, testAlerts);
        expect(state.isRefreshing, false);
      });

      test('should have isRefreshing flag defaulting to false', () {
        final state = DashboardLoaded(
          stats: testStats,
          alerts: testAlerts,
        );
        expect(state.isRefreshing, false);
      });

      test('should support copyWith', () {
        final state = DashboardLoaded(
          stats: testStats,
          alerts: testAlerts,
        );

        final newStats = testStats.copyWith(profileViews: 200);
        final updated = state.copyWith(stats: newStats, isRefreshing: true);

        expect(updated.stats.profileViews, 200);
        expect(updated.alerts, testAlerts);
        expect(updated.isRefreshing, true);
      });

      test('should have hasActiveAlerts getter', () {
        final stateWithAlerts = DashboardLoaded(
          stats: testStats,
          alerts: testAlerts,
        );
        final stateWithoutAlerts = DashboardLoaded(
          stats: testStats,
          alerts: const [],
        );

        expect(stateWithAlerts.hasActiveAlerts, true);
        expect(stateWithoutAlerts.hasActiveAlerts, false);
      });
    });

    group('DashboardError', () {
      test('should be a DashboardState', () {
        const state = DashboardError('Error message');
        expect(state, isA<DashboardState>());
      });

      test('should store error message', () {
        const state = DashboardError('Something went wrong');
        expect(state.message, 'Something went wrong');
      });
    });
  });
}
