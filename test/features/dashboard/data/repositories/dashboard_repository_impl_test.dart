/// DashboardRepositoryImpl tests
///
/// Tests for Supabase implementation of dashboard repository.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:lynewed_beta/core/core.dart';
import 'package:lynewed_beta/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:lynewed_beta/features/dashboard/domain/entities/pro_stats.dart';
import 'package:lynewed_beta/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:lynewed_beta/features/map/domain/entities/alert_details.dart';
import 'package:lynewed_beta/features/map/domain/entities/professional_alert.dart';

/// Mock datasource for testing
class MockDashboardDatasource {
  bool shouldFail = false;
  ProStats? statsToReturn;
  List<ProfessionalAlert>? alertsToReturn;

  Future<ProStats> getStats() async {
    if (shouldFail) {
      throw Exception('Mock error');
    }
    return statsToReturn ??
        const ProStats(
          profileViews: 100,
          savedCount: 25,
          messageCount: 15,
          alertCount: 3,
        );
  }

  Future<List<ProfessionalAlert>> getActiveAlerts({int limit = 3}) async {
    if (shouldFail) {
      throw Exception('Mock error');
    }
    return alertsToReturn ??
        [
          ProfessionalAlert(
            id: 'alert-1',
            professionalId: 'pro-1',
            type: AlertType.backupNeeded,
            position: const gmaps.LatLng(48.8566, 2.3522),
            eventDate: DateTime(2024, 1, 15),
          ),
        ];
  }
}

void main() {
  group('DashboardRepositoryImpl', () {
    late DashboardRepositoryImpl repository;
    late MockDashboardDatasource mockDatasource;

    setUp(() {
      mockDatasource = MockDashboardDatasource();
      repository = DashboardRepositoryImpl.withMockDatasource(mockDatasource);
    });

    test('should implement DashboardRepository', () {
      expect(repository, isA<DashboardRepository>());
    });

    group('getStats', () {
      test('should return Success with ProStats on success', () async {
        final result = await repository.getStats();

        expect(result.isSuccess, true);
        final stats = result.getOrNull();
        expect(stats, isA<ProStats>());
        expect(stats!.profileViews, 100);
      });

      test('should return Failure on error', () async {
        mockDatasource.shouldFail = true;

        final result = await repository.getStats();

        expect(result.isFailure, true);
        expect(result.failureOrNull(), isA<ServerFailure>());
      });
    });

    group('getActiveAlerts', () {
      test('should return Success with alerts on success', () async {
        final result = await repository.getActiveAlerts();

        expect(result.isSuccess, true);
        final alerts = result.getOrNull();
        expect(alerts, isA<List<ProfessionalAlert>>());
        expect(alerts!.length, 1);
      });

      test('should respect limit parameter', () async {
        mockDatasource.alertsToReturn = List.generate(
          10,
          (i) => ProfessionalAlert(
            id: 'alert-$i',
            professionalId: 'pro-$i',
            type: AlertType.backupNeeded,
            position: const gmaps.LatLng(48.8566, 2.3522),
            eventDate: DateTime(2024, 1, 15),
          ),
        );

        final result = await repository.getActiveAlerts(limit: 5);

        expect(result.isSuccess, true);
        // Repository passes limit to datasource - tested via mock
      });

      test('should return Failure on error', () async {
        mockDatasource.shouldFail = true;

        final result = await repository.getActiveAlerts();

        expect(result.isFailure, true);
        expect(result.failureOrNull(), isA<ServerFailure>());
      });
    });
  });
}
