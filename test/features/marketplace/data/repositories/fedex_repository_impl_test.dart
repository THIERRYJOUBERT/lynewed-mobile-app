/// Tests for FedExRepositoryImpl.
///
/// Verifies the repository correctly delegates to the datasource.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/data/datasources/fedex_remote_datasource.dart';
import 'package:lynewed_beta/features/marketplace/data/repositories/fedex_repository_impl.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_address.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_label.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_rate.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/tracking_event.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/fedex_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockFedExRemoteDatasource extends Mock
    implements FedExRemoteDatasource {}

class FakeShippingAddress extends Fake implements ShippingAddress {}

void main() {
  group('FedExRepositoryImpl', () {
    late MockFedExRemoteDatasource mockDatasource;
    late FedExRepositoryImpl repository;

    setUpAll(() {
      registerFallbackValue(FakeShippingAddress());
    });

    setUp(() {
      mockDatasource = MockFedExRemoteDatasource();
      repository = FedExRepositoryImpl(mockDatasource);
    });

    test('should implement FedExRepository', () {
      expect(repository, isA<FedExRepository>());
    });

    group('calculateRates', () {
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

      test('should delegate to datasource', () async {
        final expectedRates = [
          const ShippingRate(
            serviceType: 'FEDEX_GROUND',
            serviceName: 'FedEx Ground',
            rateCents: 1250,
            currency: 'USD',
          ),
        ];

        when(
          () => mockDatasource.calculateRates(
            fromAddress: any(named: 'fromAddress'),
            toAddress: any(named: 'toAddress'),
            category: any(named: 'category'),
          ),
        ).thenAnswer((_) async => expectedRates);

        final result = await repository.calculateRates(
          fromAddress: fromAddress,
          toAddress: toAddress,
          category: 'dress',
        );

        verify(
          () => mockDatasource.calculateRates(
            fromAddress: fromAddress,
            toAddress: toAddress,
            category: 'dress',
          ),
        ).called(1);

        expect(result, expectedRates);
      });
    });

    group('createShipment', () {
      test('should delegate to datasource', () async {
        const expectedLabel = ShippingLabel(
          trackingNumber: '123456789',
          labelUrl: 'https://example.com/label.pdf',
          serviceType: 'FEDEX_GROUND',
        );

        when(
          () => mockDatasource.createShipment(
            transactionId: any(named: 'transactionId'),
            serviceType: any(named: 'serviceType'),
          ),
        ).thenAnswer((_) async => expectedLabel);

        final result = await repository.createShipment(
          transactionId: 'txn-abc-123',
          serviceType: 'FEDEX_GROUND',
        );

        verify(
          () => mockDatasource.createShipment(
            transactionId: 'txn-abc-123',
            serviceType: 'FEDEX_GROUND',
          ),
        ).called(1);

        expect(result, expectedLabel);
      });
    });

    group('getTrackingEvents', () {
      test('should delegate to datasource', () async {
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
          () => mockDatasource.getTrackingEvents(any()),
        ).thenAnswer((_) async => expectedEvents);

        final result = await repository.getTrackingEvents('txn-abc-123');

        verify(
          () => mockDatasource.getTrackingEvents('txn-abc-123'),
        ).called(1);

        expect(result, expectedEvents);
      });
    });
  });
}
