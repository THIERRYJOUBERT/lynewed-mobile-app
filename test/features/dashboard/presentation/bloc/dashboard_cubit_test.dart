/// DashboardCubit tests
///
/// Tests for professional dashboard cubit/notifier.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:lynewed_beta/core/core.dart';
import 'package:lynewed_beta/features/dashboard/domain/entities/pro_stats.dart';
import 'package:lynewed_beta/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:lynewed_beta/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:lynewed_beta/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:lynewed_beta/features/map/domain/entities/alert_details.dart';
import 'package:lynewed_beta/features/map/domain/entities/professional_alert.dart';

/// Mock repository for testing
class MockDashboardRepository implements DashboardRepository {
  bool shouldFail = false;
  ProStats statsToReturn = const ProStats(
    profileViews: 100,
    savedCount: 25,
    messageCount: 15,
    alertCount: 3,
  );
  List<ProfessionalAlert> alertsToReturn = [];

  @override
  Future<Result<ProStats>> getStats() async {
    if (shouldFail) {
      return const Failure(ServerFailure('Mock error'));
    }
    return Success(statsToReturn);
  }

  @override
  Future<Result<List<ProfessionalAlert>>> getActiveAlerts({int limit = 3}) async {
    if (shouldFail) {
      return const Failure(ServerFailure('Mock error'));
    }
    return Success(alertsToReturn.take(limit).toList());
  }
}

void main() {
  group('DashboardCubit', () {
    late DashboardCubit cubit;
    late MockDashboardRepository mockRepository;

    setUp(() {
      mockRepository = MockDashboardRepository();
      mockRepository.alertsToReturn = [
        ProfessionalAlert(
          id: 'alert-1',
          professionalId: 'pro-1',
          type: AlertType.backupNeeded,
          position: const gmaps.LatLng(48.8566, 2.3522),
          eventDate: DateTime(2024, 1, 15),
        ),
        ProfessionalAlert(
          id: 'alert-2',
          professionalId: 'pro-2',
          type: AlertType.gearEmergency,
          position: const gmaps.LatLng(48.8566, 2.3522),
          eventDate: DateTime(2024, 1, 16),
        ),
      ];
      cubit = DashboardCubit(repository: mockRepository);
    });

    tearDown(() {
      cubit.dispose();
    });

    test('should have initial state as DashboardInitial', () {
      expect(cubit.state, isA<DashboardInitial>());
    });

    group('loadDashboard', () {
      test('should emit Loading then Loaded on success', () async {
        final states = <DashboardState>[];
        cubit.addListener(() => states.add(cubit.state));

        await cubit.loadDashboard();

        expect(states.length, greaterThanOrEqualTo(2));
        expect(states[0], isA<DashboardLoading>());
        expect(states.last, isA<DashboardLoaded>());

        final loadedState = states.last as DashboardLoaded;
        expect(loadedState.stats.profileViews, 100);
        expect(loadedState.alerts.length, 2);
      });

      test('should emit Loading then Error on failure', () async {
        mockRepository.shouldFail = true;

        final states = <DashboardState>[];
        cubit.addListener(() => states.add(cubit.state));

        await cubit.loadDashboard();

        expect(states.length, greaterThanOrEqualTo(2));
        expect(states[0], isA<DashboardLoading>());
        expect(states.last, isA<DashboardError>());
      });

      test('should load stats and alerts in parallel', () async {
        await cubit.loadDashboard();

        final state = cubit.state as DashboardLoaded;
        expect(state.stats, isNotNull);
        expect(state.alerts, isNotNull);
      });
    });

    group('refresh', () {
      test('should set isRefreshing to true during refresh', () async {
        // First load
        await cubit.loadDashboard();
        expect(cubit.state, isA<DashboardLoaded>());

        final states = <DashboardState>[];
        cubit.addListener(() => states.add(cubit.state));

        // Refresh
        await cubit.refresh();

        // Should have had a state with isRefreshing = true
        final refreshingStates = states.whereType<DashboardLoaded>();
        expect(refreshingStates.any((s) => s.isRefreshing), true);

        // Final state should not be refreshing
        final finalState = cubit.state as DashboardLoaded;
        expect(finalState.isRefreshing, false);
      });

      test('should load dashboard if not already loaded', () async {
        expect(cubit.state, isA<DashboardInitial>());

        await cubit.refresh();

        expect(cubit.state, isA<DashboardLoaded>());
      });
    });

    group('convenience getters', () {
      test('stats should return null when not loaded', () {
        expect(cubit.stats, isNull);
      });

      test('stats should return stats when loaded', () async {
        await cubit.loadDashboard();

        expect(cubit.stats, isNotNull);
        expect(cubit.stats!.profileViews, 100);
      });

      test('alerts should return empty list when not loaded', () {
        expect(cubit.alerts, isEmpty);
      });

      test('alerts should return alerts when loaded', () async {
        await cubit.loadDashboard();

        expect(cubit.alerts.length, 2);
      });

      test('hasActiveAlerts should return false when not loaded', () {
        expect(cubit.hasActiveAlerts, false);
      });

      test('hasActiveAlerts should return true when loaded with alerts', () async {
        await cubit.loadDashboard();

        expect(cubit.hasActiveAlerts, true);
      });
    });
  });
}
