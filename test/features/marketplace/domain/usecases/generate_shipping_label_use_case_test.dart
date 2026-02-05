/// Tests for GenerateShippingLabelUseCase.
///
/// Verifies the use case delegates to the repository for label generation.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_label.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/fedex_repository.dart';
import 'package:lynewed_beta/features/marketplace/domain/usecases/generate_shipping_label_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockFedExRepository extends Mock implements FedExRepository {}

void main() {
  group('GenerateShippingLabelUseCase', () {
    late MockFedExRepository mockRepository;
    late GenerateShippingLabelUseCase useCase;

    setUp(() {
      mockRepository = MockFedExRepository();
      useCase = GenerateShippingLabelUseCase(mockRepository);
    });

    test('should call repository with correct parameters', () async {
      const expectedLabel = ShippingLabel(
        trackingNumber: '123456789',
        labelUrl: 'https://example.com/label.pdf',
        serviceType: 'FEDEX_GROUND',
      );

      when(
        () => mockRepository.createShipment(
          transactionId: any(named: 'transactionId'),
          serviceType: any(named: 'serviceType'),
        ),
      ).thenAnswer((_) async => expectedLabel);

      final result = await useCase(
        transactionId: 'txn-abc-123',
        serviceType: 'FEDEX_GROUND',
      );

      verify(
        () => mockRepository.createShipment(
          transactionId: 'txn-abc-123',
          serviceType: 'FEDEX_GROUND',
        ),
      ).called(1);

      expect(result, expectedLabel);
      expect(result.trackingNumber, '123456789');
    });

    test('should propagate repository exceptions', () async {
      when(
        () => mockRepository.createShipment(
          transactionId: any(named: 'transactionId'),
          serviceType: any(named: 'serviceType'),
        ),
      ).thenThrow(Exception('FedEx API error'));

      expect(
        () => useCase(
          transactionId: 'txn-abc-123',
          serviceType: 'FEDEX_GROUND',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
