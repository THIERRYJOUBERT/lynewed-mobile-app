/// Tests for MediaActionsDataSourceImpl
///
/// Tests the Supabase datasource for photo favorites and media status.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/data/datasources/media_actions_datasource_impl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<PostgrestMap?> {}

void main() {
  late MediaActionsDataSourceImpl dataSource;
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();

    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('user-123');

    dataSource = MediaActionsDataSourceImpl(client: mockClient);
  });

  group('MediaActionsDataSourceImpl', () {
    group('constructor', () {
      test('should create instance with default client', () {
        // This test just verifies the class can be instantiated
        // The actual Supabase client won't be available in tests
        expect(dataSource, isNotNull);
      });

      test('should create instance with provided client', () {
        final customClient = MockSupabaseClient();
        when(() => customClient.auth).thenReturn(mockAuth);

        final ds = MediaActionsDataSourceImpl(client: customClient);
        expect(ds, isNotNull);
      });
    });

    group('addToFavorites', () {
      test('should return AuthFailure when user is not authenticated', () async {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(null);

        // Act
        final result = await dataSource.addToFavorites(
          mediaId: 'media-123',
          mediaType: 'photo',
        );

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull()?.message, 'Not authenticated');
      });
    });

    group('removeFromFavorites', () {
      test('should return AuthFailure when user is not authenticated', () async {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(null);

        // Act
        final result = await dataSource.removeFromFavorites(
          mediaId: 'media-123',
        );

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull()?.message, 'Not authenticated');
      });
    });

    group('updateMediaStatus', () {
      test('should return AuthFailure when user is not authenticated', () async {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(null);

        // Act
        final result = await dataSource.updateMediaStatus(
          mediaId: 'media-123',
          status: 'hidden_by_bride',
        );

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull()?.message, 'Not authenticated');
      });

      test('should return ValidationFailure for invalid status', () async {
        // Act
        final result = await dataSource.updateMediaStatus(
          mediaId: 'media-123',
          status: 'invalid_status',
        );

        // Assert
        expect(result.isFailure, true);
        expect(
          result.failureOrNull()?.message,
          contains('Invalid status'),
        );
      });
    });

    group('isFavorited', () {
      test('should return AuthFailure when user is not authenticated', () async {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(null);

        // Act
        final result = await dataSource.isFavorited(mediaId: 'media-123');

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull()?.message, 'Not authenticated');
      });
    });

    group('getFavoritedMediaIds', () {
      test('should return AuthFailure when user is not authenticated', () async {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(null);

        // Act
        final result = await dataSource.getFavoritedMediaIds();

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull()?.message, 'Not authenticated');
      });
    });
  });
}
