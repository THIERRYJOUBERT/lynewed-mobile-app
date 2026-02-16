/// Tests for CalculateShippingRateUseCase.
///
/// Verifies the use case delegates to the repository for rate calculation.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_address.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_rate.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/fedex_repository.dart';
import 'package:lynewed_beta/features/marketplace/domain/usecases/calculate_shipping_rate_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockFedExRepository extends Mock implements FedExRepository {}

class FakeShippingAddress extends Fake implements ShippingAddress {}

void main() {
  group('CalculateShippingRateUseCase', () {
    late MockFedExRepository mockRepository;
    late CalculateShippingRateUseCase useCase;

    setUpAll(() {
      registerFallbackValue(FakeShippingAddress());
    });

    setUp(() {
      mockRepository = MockFedExRepository();
      useCase = CalculateShippingRateUseCase(mockRepository);
    });

    const fromAddress = ShippingAddress(
      streetLines: ['123 Main St'],
      city: 'New York',
      postalCode: '10001',
      countryCode: 'US',
    );

    const toAddress = ShippingAddress(
      streetLines: ['456 Elm Ave'],
      city: 'Los Angeles',
      postalCode: '90001',
      countryCode: 'US',
    );

    test('should call repository with correct parameters', () async {
      when(
        () => mockRepository.calculateRates(
          fromAddress: any(named: 'fromAddress'),
          toAddress: any(named: 'toAddress'),
          category: any(named: 'category'),
          weightKg: any(named: 'weightKg'),
        ),
      ).thenAnswer(
        (_) async => [
          const ShippingRate(
            serviceType: 'FEDEX_GROUND',
            serviceName: 'FedEx Ground',
            rateCents: 1250,
            currency: 'USD',
          ),
        ],
      );

      final result = await useCase(
        fromAddress: fromAddress,
        toAddress: toAddress,
        category: 'dress',
      );

      verify(
        () => mockRepository.calculateRates(
          fromAddress: fromAddress,
          toAddress: toAddress,
          category: 'dress',
        ),
      ).called(1);

      expect(result.length, 1);
      expect(result[0].serviceType, 'FEDEX_GROUND');
    });

    test('should pass weightKg to repository when provided', () async {
      when(
        () => mockRepository.calculateRates(
          fromAddress: any(named: 'fromAddress'),
          toAddress: any(named: 'toAddress'),
          category: any(named: 'category'),
          weightKg: any(named: 'weightKg'),
        ),
      ).thenAnswer(
        (_) async => [
          const ShippingRate(
            serviceType: 'FEDEX_GROUND',
            serviceName: 'FedEx Ground',
            rateCents: 1500,
            currency: 'USD',
          ),
        ],
      );

      final result = await useCase(
        fromAddress: fromAddress,
        toAddress: toAddress,
        category: 'dress',
        weightKg: 4.5,
      );

      verify(
        () => mockRepository.calculateRates(
          fromAddress: fromAddress,
          toAddress: toAddress,
          category: 'dress',
          weightKg: 4.5,
        ),
      ).called(1);

      expect(result.length, 1);
      expect(result[0].rateCents, 1500);
    });

    test('should propagate repository exceptions', () async {
      when(
        () => mockRepository.calculateRates(
          fromAddress: any(named: 'fromAddress'),
          toAddress: any(named: 'toAddress'),
          category: any(named: 'category'),
          weightKg: any(named: 'weightKg'),
        ),
      ).thenThrow(Exception('FedEx API error'));

      expect(
        () => useCase(
          fromAddress: fromAddress,
          toAddress: toAddress,
          category: 'dress',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
