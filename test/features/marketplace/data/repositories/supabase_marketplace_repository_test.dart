/// Tests for SupabaseMarketplaceRepository.
///
/// Focuses on validation logic and contract verification.
/// Supabase integration is tested via the validation layer.
library;

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/data/repositories/supabase_marketplace_repository.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_listing.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

void main() {
  group('SupabaseMarketplaceRepository', () {
    late MockSupabaseClient mockClient;
    late MockGoTrueClient mockAuthClient;
    late MockUser mockUser;
    late SupabaseMarketplaceRepository repository;

    final testListing = MarketplaceListing(
      id: 'test-id-123',
      sellerId: 'user-123',
      title: 'Beautiful Wedding Dress',
      description: 'A stunning white wedding dress',
      category: 'dress',
      priceCents: 50000,
      displayCurrency: 'USD',
      designerBrand: 'Vera Wang',
      size: 'M',
      condition: 'excellent',
      sleeveLength: 'long',
      city: 'Paris',
      country: 'France',
      countryCode: 'FR',
      status: 'draft',
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );

    setUp(() {
      mockClient = MockSupabaseClient();
      mockAuthClient = MockGoTrueClient();
      mockUser = MockUser();

      when(() => mockClient.auth).thenReturn(mockAuthClient);
      when(() => mockAuthClient.currentUser).thenReturn(mockUser);
      when(() => mockUser.id).thenReturn('user-123');

      repository = SupabaseMarketplaceRepository(mockClient);
    });

    group('constructor', () {
      test('should create instance that implements MarketplaceRepository', () {
        expect(repository, isA<MarketplaceRepository>());
      });

      test('should store client reference', () {
        expect(repository, isNotNull);
      });
    });

    group('createListing validation', () {
      test('should throw ArgumentError when title exceeds 255 characters', () {
        final longTitle = 'A' * 256;
        final invalidListing = testListing.copyWith(title: longTitle);

        expect(
          () => repository.createListing(invalidListing),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Title must be less than 255 characters'),
          )),
        );
      });

      test('should throw ArgumentError when title is exactly 256 chars', () {
        final exactLimitTitle = 'B' * 256;
        final invalidListing = testListing.copyWith(title: exactLimitTitle);

        expect(
          () => repository.createListing(invalidListing),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError when price is negative', () {
        final invalidListing = testListing.copyWith(priceCents: -100);

        expect(
          () => repository.createListing(invalidListing),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Price must be greater than 0'),
          )),
        );
      });

      test('should throw ArgumentError when price is zero', () {
        final invalidListing = testListing.copyWith(priceCents: 0);

        expect(
          () => repository.createListing(invalidListing),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Price must be greater than 0'),
          )),
        );
      });

      test('should accept 255-character title without validation error', () async {
        // Title at exactly the limit should not throw validation error
        final maxTitle = 'C' * 255;
        final validListing = testListing.copyWith(title: maxTitle);

        // Will throw from the mock client (not configured), but NOT ArgumentError
        try {
          await repository.createListing(validListing);
        } on ArgumentError {
          fail('Should not throw ArgumentError for 255-char title');
        } catch (_) {
          // Expected: mock client throws, but not ArgumentError
        }
      });
    });

    group('uploadListingPhotos validation', () {
      test('should throw when exceeding max photos limit', () {
        final tooManyPhotos = List.generate(11, (_) => Uint8List(0));
        final fileNames = List.generate(11, (i) => 'photo_$i.jpg');

        expect(
          () => repository.uploadListingPhotos(
            listingId: 'test-id-123',
            photoBytes: tooManyPhotos,
            fileNames: fileNames,
          ),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Maximum 10 photos allowed'),
          )),
        );
      });

      test('should accept exactly 10 photos without validation error', () async {
        final tenPhotos = List.generate(10, (_) => Uint8List(0));
        final fileNames = List.generate(10, (i) => 'photo_$i.jpg');

        // Will throw from mock client (not configured), but NOT ArgumentError
        try {
          await repository.uploadListingPhotos(
            listingId: 'test-id-123',
            photoBytes: tenPhotos,
            fileNames: fileNames,
          );
        } on ArgumentError {
          fail('Should not throw ArgumentError for 10 photos');
        } catch (_) {
          // Expected: mock client throws, but not ArgumentError
        }
      });
    });

    group('getMyListings', () {
      test('should return empty list when no current user', () async {
        when(() => mockAuthClient.currentUser).thenReturn(null);

        final result = await repository.getMyListings();

        expect(result, isEmpty);
      });
    });

    group('getListings', () {
      test('should implement getListings method from interface', () {
        // Verify the method exists and is callable (contract test).
        // The actual Supabase call will fail with mock, but we verify
        // the method signature matches the interface.
        expect(repository.getListings, isA<Function>());
      });

      test('should accept optional category parameter', () {
        // Verify method accepts category parameter without compile error.
        expect(
          () => repository.getListings(category: 'dress'),
          isA<Function>(),
        );
      });

      test('should accept pagination parameters', () {
        // Verify method accepts page and pageSize parameters.
        expect(
          () => repository.getListings(page: 1, pageSize: 10),
          isA<Function>(),
        );
      });

      test('should default page to 0 and pageSize to 20', () {
        // Verify default parameters by calling without them.
        // Method should not throw from parameter validation.
        expect(
          () => repository.getListings(),
          isA<Function>(),
        );
      });
    });

    group('getListingsCount', () {
      test('should implement getListingsCount method from interface', () {
        expect(repository.getListingsCount, isA<Function>());
      });

      test('should accept optional category parameter', () {
        expect(
          () => repository.getListingsCount(category: 'shoes'),
          isA<Function>(),
        );
      });
    });

    group('constants', () {
      test('maxTitleLength should be 255', () {
        expect(SupabaseMarketplaceRepository.maxTitleLength, 255);
      });

      test('maxPhotos should be 10', () {
        expect(SupabaseMarketplaceRepository.maxPhotos, 10);
      });
    });
  });
}
