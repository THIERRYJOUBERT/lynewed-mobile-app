/// Tests for GetGuestAlbumsUseCase.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/guest_album.dart';
import 'package:lynewed_beta/features/my_wedding/domain/repositories/my_wedding_repository.dart';
import 'package:lynewed_beta/features/my_wedding/domain/usecases/get_guest_albums_use_case.dart';

/// Mock implementation of MyWeddingRepository for testing.
class MockMyWeddingRepository implements MyWeddingRepository {
  MockMyWeddingRepository({
    this.mockAlbums = const [],
    this.mockError,
  });

  final List<GuestAlbum> mockAlbums;
  final String? mockError;

  String? lastWeddingId;

  @override
  Future<RepositoryResult<List<GuestAlbum>>> getGuestAlbums({
    required String weddingId,
  }) async {
    lastWeddingId = weddingId;

    if (mockError != null) {
      return RepositoryResult.failure(mockError!);
    }

    return RepositoryResult.success(mockAlbums);
  }

  // Implement required methods from interface with minimal stubs
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('GetGuestAlbumsUseCase', () {
    final testDate = DateTime(2026, 6, 15);

    GuestAlbum createTestAlbum({
      String id = 'album-1',
      String weddingId = 'wedding-456',
      String guestName = 'Alice',
      int photoCount = 5,
      int videoCount = 2,
    }) {
      return GuestAlbum(
        id: id,
        weddingId: weddingId,
        guestUserId: 'guest-$id',
        guestName: guestName,
        photoCount: photoCount,
        videoCount: videoCount,
        createdAt: testDate,
      );
    }

    test('should call repository with correct wedding ID', () async {
      final repository = MockMyWeddingRepository();
      final useCase = GetGuestAlbumsUseCase(repository);

      await useCase(weddingId: 'wedding-456');

      expect(repository.lastWeddingId, 'wedding-456');
    });

    test('should return list of albums on success', () async {
      final albums = [
        createTestAlbum(id: 'album-1', guestName: 'Alice'),
        createTestAlbum(id: 'album-2', guestName: 'Bob'),
      ];
      final repository = MockMyWeddingRepository(mockAlbums: albums);
      final useCase = GetGuestAlbumsUseCase(repository);

      final result = await useCase(weddingId: 'wedding-456');

      expect(result.isSuccess, isTrue);
      expect(result.data, hasLength(2));
      expect(result.data![0].guestName, 'Alice');
      expect(result.data![1].guestName, 'Bob');
    });

    test('should return empty list when no albums exist', () async {
      final repository = MockMyWeddingRepository(mockAlbums: []);
      final useCase = GetGuestAlbumsUseCase(repository);

      final result = await useCase(weddingId: 'wedding-456');

      expect(result.isSuccess, isTrue);
      expect(result.data, isEmpty);
    });

    test('should return failure on error', () async {
      final repository = MockMyWeddingRepository(
        mockError: 'Failed to load guest albums',
      );
      final useCase = GetGuestAlbumsUseCase(repository);

      final result = await useCase(weddingId: 'wedding-456');

      expect(result.isFailure, isTrue);
      expect(result.error, 'Failed to load guest albums');
    });
  });
}
