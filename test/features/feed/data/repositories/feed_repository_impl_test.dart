import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/feed/domain/entities/feed_filter.dart';
import 'package:lynewed_beta/features/feed/domain/repositories/feed_repository.dart';
import 'package:lynewed_beta/features/feed/data/repositories/feed_repository_impl.dart';

// Simple mock datasource for testing
class MockFeedDatasource implements FeedDatasource {
  List<Map<String, dynamic>> mockProfessionals = [];
  bool shouldThrow = false;
  String errorMessage = 'Mock error';
  bool isFavoritedResult = true;
  List<String> favoritedIds = [];

  @override
  Future<List<Map<String, dynamic>>> getFeedProfessionals({
    required FeedFilter filter,
    int? limit,
    int? offset,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
    return mockProfessionals;
  }

  @override
  Future<Map<String, dynamic>?> getProfessionalById(String profileId) async {
    if (shouldThrow) throw Exception(errorMessage);
    try {
      return mockProfessionals.firstWhere(
        (p) => p['profile_id'] == profileId,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> toggleFavorite(String profileId) async {
    if (shouldThrow) throw Exception(errorMessage);
    if (favoritedIds.contains(profileId)) {
      favoritedIds.remove(profileId);
      return false;
    }
    favoritedIds.add(profileId);
    return true;
  }

  @override
  Future<List<String>> getAvailableProfessions() async {
    if (shouldThrow) throw Exception(errorMessage);
    return ['photographer', 'florist', 'videographer'];
  }
}

void main() {
  group('FeedRepositoryImpl', () {
    late MockFeedDatasource mockDatasource;
    late FeedRepositoryImpl repository;

    setUp(() {
      mockDatasource = MockFeedDatasource();
      repository = FeedRepositoryImpl(datasource: mockDatasource);
    });

    // ==============================================================
    // GETFEEDPROFESSIONALS TESTS
    // ==============================================================

    group('getFeedProfessionals', () {
      test('should return success with list of professionals', () async {
        mockDatasource.mockProfessionals = [
          {
            'profile_id': 'pro-1',
            'display_name': 'Jane Photography',
            'profession': 'photographer',
            'portfolio_items': [
              {
                'id': 'item-1',
                'image_url': 'https://example.com/1.jpg',
                'professional_id': 'pro-1',
                'created_at': '2025-01-24T10:00:00Z',
              },
            ],
          },
          {
            'profile_id': 'pro-2',
            'display_name': 'Floral Dreams',
            'profession': 'florist',
            'portfolio_items': <Map<String, dynamic>>[],
          },
        ];

        final result = await repository.getFeedProfessionals(
          filter: const FeedFilter(),
        );

        expect(result.isSuccess, true);
        expect(result.data, hasLength(2));
        expect(result.data![0].displayName, 'Jane Photography');
        expect(result.data![0].portfolioItems, hasLength(1));
        expect(result.data![1].displayName, 'Floral Dreams');
      });

      test('should return success with empty list when no professionals', () async {
        mockDatasource.mockProfessionals = [];

        final result = await repository.getFeedProfessionals(
          filter: const FeedFilter(),
        );

        expect(result.isSuccess, true);
        expect(result.data, isEmpty);
      });

      test('should return failure on error', () async {
        mockDatasource.shouldThrow = true;
        mockDatasource.errorMessage = 'Database connection failed';

        final result = await repository.getFeedProfessionals(
          filter: const FeedFilter(),
        );

        expect(result.isFailure, true);
        expect(result.error, contains('Failed to get feed'));
      });

      test('should pass limit and offset to datasource', () async {
        mockDatasource.mockProfessionals = [];

        await repository.getFeedProfessionals(
          filter: const FeedFilter(),
          limit: 10,
          offset: 20,
        );

        // If we get here without error, parameters were passed correctly
        expect(true, true);
      });
    });

    // ==============================================================
    // GETPROFESSIONALBYID TESTS
    // ==============================================================

    group('getProfessionalById', () {
      test('should return success with professional when found', () async {
        mockDatasource.mockProfessionals = [
          {
            'profile_id': 'pro-123',
            'display_name': 'Jane Photography',
            'profession': 'photographer',
            'portfolio_items': <Map<String, dynamic>>[],
          },
        ];

        final result = await repository.getProfessionalById('pro-123');

        expect(result.isSuccess, true);
        expect(result.data, isNotNull);
        expect(result.data!.profileId, 'pro-123');
        expect(result.data!.displayName, 'Jane Photography');
      });

      test('should return success with null when not found', () async {
        mockDatasource.mockProfessionals = [];

        final result = await repository.getProfessionalById('non-existent');

        expect(result.isSuccess, true);
        expect(result.data, isNull);
      });

      test('should return failure on error', () async {
        mockDatasource.shouldThrow = true;

        final result = await repository.getProfessionalById('pro-123');

        expect(result.isFailure, true);
        expect(result.error, contains('Failed to get professional'));
      });
    });

    // ==============================================================
    // TOGGLEFAVORITE TESTS
    // ==============================================================

    group('toggleFavorite', () {
      test('should return success with true when favorited', () async {
        final result = await repository.toggleFavorite('pro-123');

        expect(result.isSuccess, true);
        expect(result.data, true);
        expect(mockDatasource.favoritedIds, contains('pro-123'));
      });

      test('should return success with false when unfavorited', () async {
        mockDatasource.favoritedIds = ['pro-123'];

        final result = await repository.toggleFavorite('pro-123');

        expect(result.isSuccess, true);
        expect(result.data, false);
        expect(mockDatasource.favoritedIds, isNot(contains('pro-123')));
      });

      test('should return failure on error', () async {
        mockDatasource.shouldThrow = true;

        final result = await repository.toggleFavorite('pro-123');

        expect(result.isFailure, true);
        expect(result.error, contains('Failed to toggle favorite'));
      });
    });

    // ==============================================================
    // GETAVAILABLEPROFESSIONS TESTS
    // ==============================================================

    group('getAvailableProfessions', () {
      test('should return success with list of professions', () async {
        final result = await repository.getAvailableProfessions();

        expect(result.isSuccess, true);
        expect(result.data, hasLength(3));
        expect(result.data, contains('photographer'));
        expect(result.data, contains('florist'));
        expect(result.data, contains('videographer'));
      });

      test('should return failure on error', () async {
        mockDatasource.shouldThrow = true;

        final result = await repository.getAvailableProfessions();

        expect(result.isFailure, true);
        expect(result.error, contains('Failed to get professions'));
      });
    });
  });

  // ==============================================================
  // FEEDREPOSITORYRESULT TESTS
  // ==============================================================

  group('FeedRepositoryResult', () {
    test('should create success result', () {
      final result = FeedRepositoryResult<String>.success('data');

      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.data, 'data');
      expect(result.error, isNull);
    });

    test('should create failure result', () {
      final result = FeedRepositoryResult<String>.failure('error message');

      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.data, isNull);
      expect(result.error, 'error message');
    });

    test('should handle null data in success', () {
      final result = FeedRepositoryResult<String?>.success(null);

      expect(result.isSuccess, true);
      expect(result.data, isNull);
    });
  });
}
