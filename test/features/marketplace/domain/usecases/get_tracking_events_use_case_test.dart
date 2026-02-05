/// Tests for GetTrackingEventsUseCase.
///
/// Verifies the use case delegates to the repository for tracking event retrieval.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/tracking_event.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/fedex_repository.dart';
import 'package:lynewed_beta/features/marketplace/domain/usecases/get_tracking_events_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockFedExRepository extends Mock implements FedExRepository {}

void main() {
  group('GetTrackingEventsUseCase', () {
    late MockFedExRepository mockRepository;
    late GetTrackingEventsUseCase useCase;

    setUp(() {
      mockRepository = MockFedExRepository();
      useCase = GetTrackingEventsUseCase(mockRepository);
    });

    test('should call repository with correct transaction ID', () async {
      final expectedEvents = [
        TrackingEvent(
          eventType: 'picked_up',
          description: 'Package picked up',
          timestamp: DateTime(2026, 2, 3),
        ),
        TrackingEvent(
          eventType: 'in_transit',
          description: 'In transit',
          timestamp: DateTime(2026, 2, 4),
        ),
      ];

      when(
        () => mockRepository.getTrackingEvents(any()),
      ).thenAnswer((_) async => expectedEvents);

      final result = await useCase('txn-abc-123');

      verify(
        () => mockRepository.getTrackingEvents('txn-abc-123'),
      ).called(1);

      expect(result.length, 2);
      expect(result[0].eventType, 'picked_up');
      expect(result[1].eventType, 'in_transit');
    });

    test('should return empty list when no events', () async {
      when(
        () => mockRepository.getTrackingEvents(any()),
      ).thenAnswer((_) async => []);

      final result = await useCase('txn-no-events');

      expect(result, isEmpty);
    });

    test('should propagate repository exceptions', () async {
      when(
        () => mockRepository.getTrackingEvents(any()),
      ).thenThrow(Exception('Database error'));

      expect(
        () => useCase('txn-abc-123'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
