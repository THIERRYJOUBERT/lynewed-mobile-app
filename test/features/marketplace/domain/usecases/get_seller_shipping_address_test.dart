/// Tests for GetSellerShippingAddress use case.
///
/// Verifies seller profile retrieval and address validation.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:lynewed_beta/features/auth/data/models/user_profile_model.dart';
import 'package:lynewed_beta/features/auth/domain/entities/user_role.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_address.dart';
import 'package:lynewed_beta/features/marketplace/domain/usecases/get_seller_shipping_address.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDatasource extends Mock implements AuthRemoteDatasource {}

void main() {
  group('GetSellerShippingAddress', () {
    late MockAuthRemoteDatasource mockDatasource;
    late GetSellerShippingAddress useCase;

    setUp(() {
      mockDatasource = MockAuthRemoteDatasource();
      useCase = GetSellerShippingAddress(mockDatasource);
    });

    const validAddress = ShippingAddress(
      streetLines: ['123 Main St'],
      city: 'New York',
      postalCode: '10001',
      countryCode: 'US',
    );

    UserProfileModel createProfile({ShippingAddress? address}) {
      return UserProfileModel(
        id: 'seller-123',
        authUserId: 'auth-seller-123',
        displayName: 'Test Seller',
        role: UserRole.professional,
        createdAt: DateTime(2026, 1, 1),
        shippingAddress: address,
      );
    }

    test('should return shipping address when profile has valid address',
        () async {
      when(() => mockDatasource.getProfile('seller-123'))
          .thenAnswer((_) async => createProfile(address: validAddress));

      final result = await useCase('seller-123');

      expect(result.countryCode, 'US');
      expect(result.city, 'New York');
      expect(result.postalCode, '10001');
      verify(() => mockDatasource.getProfile('seller-123')).called(1);
    });

    test('should throw when seller profile not found', () async {
      when(() => mockDatasource.getProfile('unknown'))
          .thenAnswer((_) async => null);

      expect(
        () => useCase('unknown'),
        throwsA(isA<SellerAddressException>().having(
          (e) => e.message,
          'message',
          contains('profile not found'),
        )),
      );
    });

    test('should throw when shipping address is null', () async {
      when(() => mockDatasource.getProfile('seller-123'))
          .thenAnswer((_) async => createProfile(address: null));

      expect(
        () => useCase('seller-123'),
        throwsA(isA<SellerAddressException>().having(
          (e) => e.message,
          'message',
          contains('not configured'),
        )),
      );
    });

    test('should throw when countryCode is empty', () async {
      const badAddress = ShippingAddress(
        streetLines: ['123 Main St'],
        city: 'New York',
        postalCode: '10001',
        countryCode: '',
      );
      when(() => mockDatasource.getProfile('seller-123'))
          .thenAnswer((_) async => createProfile(address: badAddress));

      expect(
        () => useCase('seller-123'),
        throwsA(isA<SellerAddressException>().having(
          (e) => e.message,
          'message',
          contains('country code'),
        )),
      );
    });

    test('should throw when city is empty', () async {
      const badAddress = ShippingAddress(
        streetLines: ['123 Main St'],
        city: '',
        postalCode: '10001',
        countryCode: 'US',
      );
      when(() => mockDatasource.getProfile('seller-123'))
          .thenAnswer((_) async => createProfile(address: badAddress));

      expect(
        () => useCase('seller-123'),
        throwsA(isA<SellerAddressException>().having(
          (e) => e.message,
          'message',
          contains('city'),
        )),
      );
    });

    test('should throw when postalCode is empty', () async {
      const badAddress = ShippingAddress(
        streetLines: ['123 Main St'],
        city: 'New York',
        postalCode: '',
        countryCode: 'US',
      );
      when(() => mockDatasource.getProfile('seller-123'))
          .thenAnswer((_) async => createProfile(address: badAddress));

      expect(
        () => useCase('seller-123'),
        throwsA(isA<SellerAddressException>().having(
          (e) => e.message,
          'message',
          contains('postal code'),
        )),
      );
    });

    test('should throw when streetLines is empty', () async {
      const badAddress = ShippingAddress(
        streetLines: [],
        city: 'New York',
        postalCode: '10001',
        countryCode: 'US',
      );
      when(() => mockDatasource.getProfile('seller-123'))
          .thenAnswer((_) async => createProfile(address: badAddress));

      expect(
        () => useCase('seller-123'),
        throwsA(isA<SellerAddressException>().having(
          (e) => e.message,
          'message',
          contains('street address'),
        )),
      );
    });

    test('should throw when streetLines contains only blank strings', () async {
      const badAddress = ShippingAddress(
        streetLines: ['  ', ''],
        city: 'New York',
        postalCode: '10001',
        countryCode: 'US',
      );
      when(() => mockDatasource.getProfile('seller-123'))
          .thenAnswer((_) async => createProfile(address: badAddress));

      expect(
        () => useCase('seller-123'),
        throwsA(isA<SellerAddressException>().having(
          (e) => e.message,
          'message',
          contains('street address'),
        )),
      );
    });
  });
}
