/// MyWeddingRepositoryImpl Unit Tests
///
/// Tests for the My Wedding data layer repository implementation.
/// Covers all CRUD operations for weddings, events, expenses, guests, and albums.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lynewed_beta/features/my_wedding/data/datasources/supabase_my_wedding_datasource.dart';
import 'package:lynewed_beta/features/my_wedding/data/repositories/my_wedding_repository_impl.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/entities.dart';
import 'package:lynewed_beta/features/my_wedding/domain/repositories/my_wedding_repository.dart';

// ==============================================================
// MOCKS
// ==============================================================

class MockSupabaseMyWeddingDatasource extends Mock
    implements SupabaseMyWeddingDatasource {}

// ==============================================================
// TEST FIXTURES
// ==============================================================

final testWeddingOverview = WeddingOverview(
  id: 'wed-123',
  brideId: 'bride-456',
  name: 'Sophie & Thomas Wedding',
  eventDate: DateTime(2025, 9, 15),
  searchRadiusKm: 50,
);

final testWeddingTeamMember = WeddingTeamMember(
  profileId: 'pro-123',
  displayName: 'John Photographer',
  profession: 'photographer',
  status: 'active',
  joinedAt: DateTime(2025, 1, 15),
);

final testWeddingTeamMember2 = WeddingTeamMember(
  profileId: 'pro-456',
  displayName: 'Jane Florist',
  profession: 'florist',
  status: 'active',
  joinedAt: DateTime(2025, 1, 20),
);

final testContactedPro = ContactedPro(
  profileId: 'pro-789',
  displayName: 'Mike DJ',
  profession: 'dj',
);

final testInspirationAlbum = InspirationAlbum(
  id: 'album-123',
  weddingId: 'wed-123',
  brideProfileId: 'bride-456',
  name: 'Decoration Ideas',
  category: AlbumCategory.decor,
);

final testAlbumImage = AlbumImage(
  id: 'image-123',
  albumId: 'album-123',
  imageUrl: 'https://example.com/image.jpg',
  thumbnailUrl: 'https://example.com/thumb.jpg',
  uploadedAt: DateTime(2025, 1, 10),
);

final testSavedPost = SavedPost(
  id: 'saved-123',
  albumId: 'album-123',
  imageUrl: 'https://example.com/saved.jpg',
  sourceProfileId: 'pro-111',
  savedAt: DateTime(2025, 1, 12),
);

final testWeddingEvent = WeddingEvent(
  id: 'event-123',
  weddingId: 'wed-123',
  title: 'Ceremony',
  eventDate: DateTime(2025, 9, 15, 14, 0),
  description: 'Main ceremony',
  status: EventStatus.pending,
);

final testWeddingExpense = WeddingExpense(
  id: 'expense-123',
  weddingId: 'wed-123',
  category: 'photographer',
  amount: 3000,
  currencyCode: 'EUR',
  status: ExpenseStatus.pending,
);

final testWeddingGuest = WeddingGuest(
  id: 'guest-123',
  weddingId: 'wed-123',
  name: 'Marie Dupont',
  email: 'marie@example.com',
  role: GuestRole.guest,
);

final testWeddingTeamChatInfo = WeddingTeamChatInfo(
  roomId: 'room-123',
  weddingId: 'wed-123',
  participantsCount: 5,
  unreadCount: 3,
  participantAvatars: ['https://example.com/avatar1.jpg'],
);

final testOnboardingData = OnboardingData(
  guestCount: 100,
  budgetMin: 10000,
  budgetMax: 30000,
  onboardingStep: 5,
);

void main() {
  late MockSupabaseMyWeddingDatasource mockDatasource;
  late MyWeddingRepositoryImpl repository;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(testOnboardingData);
  });

  setUp(() {
    mockDatasource = MockSupabaseMyWeddingDatasource();
    repository = MyWeddingRepositoryImpl(datasource: mockDatasource);
  });

  // ==============================================================
  // AC1: WEDDING OPERATIONS TESTS
  // ==============================================================

  group('Wedding Operations', () {
    group('getMyWedding', () {
      test('should return success when datasource returns wedding', () async {
        // Arrange
        when(() => mockDatasource.getMyWedding())
            .thenAnswer((_) async => testWeddingOverview);

        // Act
        final result = await repository.getMyWedding();

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, testWeddingOverview);
        expect(result.data?.id, 'wed-123');
        verify(() => mockDatasource.getMyWedding()).called(1);
      });

      test('should return success with null when no wedding exists', () async {
        // Arrange
        when(() => mockDatasource.getMyWedding()).thenAnswer((_) async => null);

        // Act
        final result = await repository.getMyWedding();

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, isNull);
      });

      test('should return failure when datasource throws', () async {
        // Arrange
        when(() => mockDatasource.getMyWedding())
            .thenThrow(Exception('Network error'));

        // Act
        final result = await repository.getMyWedding();

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to get wedding'));
      });
    });

    group('createWedding', () {
      test('should return wedding ID on success', () async {
        // Arrange
        when(() => mockDatasource.createWedding(
              eventDate: any(named: 'eventDate'),
              lat: any(named: 'lat'),
              lng: any(named: 'lng'),
              venueName: any(named: 'venueName'),
              venueAddress: any(named: 'venueAddress'),
              countryCode: any(named: 'countryCode'),
            )).thenAnswer((_) async => 'new-wedding-id');

        // Act
        final result = await repository.createWedding(
          eventDate: DateTime(2025, 9, 15),
          lat: 48.8566,
          lng: 2.3522,
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, 'new-wedding-id');
      });

      test('should pass all parameters correctly', () async {
        // Arrange
        when(() => mockDatasource.createWedding(
              eventDate: any(named: 'eventDate'),
              lat: any(named: 'lat'),
              lng: any(named: 'lng'),
              venueName: any(named: 'venueName'),
              venueAddress: any(named: 'venueAddress'),
              countryCode: any(named: 'countryCode'),
            )).thenAnswer((_) async => 'wed-789');

        // Act
        await repository.createWedding(
          eventDate: DateTime(2025, 9, 15),
          lat: 48.8566,
          lng: 2.3522,
          venueName: 'Chateau de Paris',
          venueAddress: '123 Paris Street',
          countryCode: 'FR',
        );

        // Assert
        verify(() => mockDatasource.createWedding(
              eventDate: DateTime(2025, 9, 15),
              lat: 48.8566,
              lng: 2.3522,
              venueName: 'Chateau de Paris',
              venueAddress: '123 Paris Street',
              countryCode: 'FR',
            )).called(1);
      });

      test('should return failure when datasource throws', () async {
        // Arrange
        when(() => mockDatasource.createWedding(
              eventDate: any(named: 'eventDate'),
              lat: any(named: 'lat'),
              lng: any(named: 'lng'),
              venueName: any(named: 'venueName'),
              venueAddress: any(named: 'venueAddress'),
              countryCode: any(named: 'countryCode'),
            )).thenThrow(Exception('Database error'));

        // Act
        final result = await repository.createWedding(
          eventDate: DateTime(2025, 9, 15),
          lat: 48.8566,
          lng: 2.3522,
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to create wedding'));
      });
    });

    group('updateWedding', () {
      test('should return success when update succeeds', () async {
        // Arrange
        when(() => mockDatasource.updateWedding(
              weddingId: any(named: 'weddingId'),
              name: any(named: 'name'),
              eventDate: any(named: 'eventDate'),
              lat: any(named: 'lat'),
              lng: any(named: 'lng'),
              venueAddress: any(named: 'venueAddress'),
              countryCode: any(named: 'countryCode'),
              guestCount: any(named: 'guestCount'),
              budgetMin: any(named: 'budgetMin'),
              budgetMax: any(named: 'budgetMax'),
              currency: any(named: 'currency'),
              visibility: any(named: 'visibility'),
              searchRadiusKm: any(named: 'searchRadiusKm'),
              coverImageUrl: any(named: 'coverImageUrl'),
              noteForPros: any(named: 'noteForPros'),
            )).thenAnswer((_) async {});

        // Act
        final result = await repository.updateWedding(
          weddingId: 'wed-123',
          name: 'Updated Wedding',
          guestCount: 150,
        );

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDatasource.updateWedding(
              weddingId: 'wed-123',
              name: 'Updated Wedding',
              eventDate: null,
              lat: null,
              lng: null,
              venueAddress: null,
              countryCode: null,
              guestCount: 150,
              budgetMin: null,
              budgetMax: null,
              currency: null,
              visibility: null,
              searchRadiusKm: null,
              coverImageUrl: null,
              noteForPros: null,
            )).called(1);
      });

      test('should return failure when update throws', () async {
        // Arrange
        when(() => mockDatasource.updateWedding(
              weddingId: any(named: 'weddingId'),
              name: any(named: 'name'),
              eventDate: any(named: 'eventDate'),
              lat: any(named: 'lat'),
              lng: any(named: 'lng'),
              venueAddress: any(named: 'venueAddress'),
              countryCode: any(named: 'countryCode'),
              guestCount: any(named: 'guestCount'),
              budgetMin: any(named: 'budgetMin'),
              budgetMax: any(named: 'budgetMax'),
              currency: any(named: 'currency'),
              visibility: any(named: 'visibility'),
              searchRadiusKm: any(named: 'searchRadiusKm'),
              coverImageUrl: any(named: 'coverImageUrl'),
              noteForPros: any(named: 'noteForPros'),
            )).thenThrow(Exception('Update failed'));

        // Act
        final result = await repository.updateWedding(weddingId: 'wed-123');

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to update wedding'));
      });
    });

    group('updateWeddingStatus', () {
      test('should return success when status update succeeds', () async {
        // Arrange
        when(() => mockDatasource.updateWeddingStatus(
              weddingId: any(named: 'weddingId'),
              status: any(named: 'status'),
            )).thenAnswer((_) async {});

        // Act
        final result = await repository.updateWeddingStatus(
          weddingId: 'wed-123',
          status: 'cancelled',
        );

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDatasource.updateWeddingStatus(
              weddingId: 'wed-123',
              status: 'cancelled',
            )).called(1);
      });

      test('should return failure when status update throws', () async {
        // Arrange
        when(() => mockDatasource.updateWeddingStatus(
              weddingId: any(named: 'weddingId'),
              status: any(named: 'status'),
            )).thenThrow(Exception('Status update failed'));

        // Act
        final result = await repository.updateWeddingStatus(
          weddingId: 'wed-123',
          status: 'cancelled',
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to update wedding status'));
      });
    });

    group('updateOnboardingData', () {
      test('should return success when onboarding update succeeds', () async {
        // Arrange
        when(() => mockDatasource.updateOnboardingData(
              weddingId: any(named: 'weddingId'),
              data: any(named: 'data'),
            )).thenAnswer((_) async {});

        // Act
        final result = await repository.updateOnboardingData(
          weddingId: 'wed-123',
          data: testOnboardingData,
        );

        // Assert
        expect(result.isSuccess, true);
      });

      test('should return failure when onboarding update throws', () async {
        // Arrange
        when(() => mockDatasource.updateOnboardingData(
              weddingId: any(named: 'weddingId'),
              data: any(named: 'data'),
            )).thenThrow(Exception('Onboarding update failed'));

        // Act
        final result = await repository.updateOnboardingData(
          weddingId: 'wed-123',
          data: testOnboardingData,
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to update onboarding data'));
      });
    });

    group('completeOnboarding', () {
      test('should return success when onboarding completion succeeds',
          () async {
        // Arrange
        when(() => mockDatasource.completeOnboarding(
              weddingId: any(named: 'weddingId'),
            )).thenAnswer((_) async {});

        // Act
        final result = await repository.completeOnboarding(weddingId: 'wed-123');

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDatasource.completeOnboarding(weddingId: 'wed-123'))
            .called(1);
      });

      test('should return failure when onboarding completion throws', () async {
        // Arrange
        when(() => mockDatasource.completeOnboarding(
              weddingId: any(named: 'weddingId'),
            )).thenThrow(Exception('Completion failed'));

        // Act
        final result = await repository.completeOnboarding(weddingId: 'wed-123');

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to complete onboarding'));
      });
    });
  });

  // ==============================================================
  // AC2: WEDDING TEAM OPERATIONS TESTS
  // ==============================================================

  group('Wedding Team Operations', () {
    group('getWeddingTeam', () {
      test('should return success with team members', () async {
        // Arrange
        when(() => mockDatasource.getWeddingTeam(
              weddingId: any(named: 'weddingId'),
            )).thenAnswer((_) async => [testWeddingTeamMember, testWeddingTeamMember2]);

        // Act
        final result = await repository.getWeddingTeam(weddingId: 'wed-123');

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.length, 2);
        expect(result.data?[0].profileId, 'pro-123');
        expect(result.data?[1].profession, 'florist');
      });

      test('should return empty list when no team members', () async {
        // Arrange
        when(() => mockDatasource.getWeddingTeam(
              weddingId: any(named: 'weddingId'),
            )).thenAnswer((_) async => []);

        // Act
        final result = await repository.getWeddingTeam(weddingId: 'wed-123');

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, isEmpty);
      });

      test('should return failure when datasource throws', () async {
        // Arrange
        when(() => mockDatasource.getWeddingTeam(
              weddingId: any(named: 'weddingId'),
            )).thenThrow(Exception('Database error'));

        // Act
        final result = await repository.getWeddingTeam(weddingId: 'wed-123');

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to get wedding team'));
      });
    });

    group('getActiveWeddingTeam', () {
      test('should return success with active team members', () async {
        // Arrange
        when(() => mockDatasource.getActiveWeddingTeam(
              weddingId: any(named: 'weddingId'),
            )).thenAnswer((_) async => [testWeddingTeamMember]);

        // Act
        final result =
            await repository.getActiveWeddingTeam(weddingId: 'wed-123');

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.length, 1);
        expect(result.data?[0].status, 'active');
      });

      test('should return failure when datasource throws', () async {
        // Arrange
        when(() => mockDatasource.getActiveWeddingTeam(
              weddingId: any(named: 'weddingId'),
            )).thenThrow(Exception('Database error'));

        // Act
        final result =
            await repository.getActiveWeddingTeam(weddingId: 'wed-123');

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to get active wedding team'));
      });
    });

    group('getContactedPros', () {
      test('should return success with contacted pros', () async {
        // Arrange
        when(() => mockDatasource.getContactedPros())
            .thenAnswer((_) async => [testContactedPro]);

        // Act
        final result = await repository.getContactedPros();

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.length, 1);
        expect(result.data?[0].profileId, 'pro-789');
      });

      test('should return empty list when no contacted pros', () async {
        // Arrange
        when(() => mockDatasource.getContactedPros())
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getContactedPros();

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, isEmpty);
      });

      test('should return failure when datasource throws', () async {
        // Arrange
        when(() => mockDatasource.getContactedPros())
            .thenThrow(Exception('Database error'));

        // Act
        final result = await repository.getContactedPros();

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to get contacted pros'));
      });
    });

    group('inviteProToWedding', () {
      test('should return success when invite succeeds', () async {
        // Arrange
        when(() => mockDatasource.inviteProToWedding(
              weddingId: any(named: 'weddingId'),
              proProfileId: any(named: 'proProfileId'),
            )).thenAnswer((_) async {});

        // Act
        final result = await repository.inviteProToWedding(
          weddingId: 'wed-123',
          proProfileId: 'pro-456',
        );

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDatasource.inviteProToWedding(
              weddingId: 'wed-123',
              proProfileId: 'pro-456',
            )).called(1);
      });

      test('should return failure when invite throws', () async {
        // Arrange
        when(() => mockDatasource.inviteProToWedding(
              weddingId: any(named: 'weddingId'),
              proProfileId: any(named: 'proProfileId'),
            )).thenThrow(Exception('Invite failed'));

        // Act
        final result = await repository.inviteProToWedding(
          weddingId: 'wed-123',
          proProfileId: 'pro-456',
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to invite pro'));
      });
    });

    group('excludeProFromWedding', () {
      test('should return success when exclude succeeds', () async {
        // Arrange
        when(() => mockDatasource.excludeProFromWedding(
              weddingId: any(named: 'weddingId'),
              proProfileId: any(named: 'proProfileId'),
              reason: any(named: 'reason'),
            )).thenAnswer((_) async {});

        // Act
        final result = await repository.excludeProFromWedding(
          weddingId: 'wed-123',
          proProfileId: 'pro-456',
          reason: 'No longer needed',
        );

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDatasource.excludeProFromWedding(
              weddingId: 'wed-123',
              proProfileId: 'pro-456',
              reason: 'No longer needed',
            )).called(1);
      });

      test('should return failure when exclude throws', () async {
        // Arrange
        when(() => mockDatasource.excludeProFromWedding(
              weddingId: any(named: 'weddingId'),
              proProfileId: any(named: 'proProfileId'),
              reason: any(named: 'reason'),
            )).thenThrow(Exception('Exclude failed'));

        // Act
        final result = await repository.excludeProFromWedding(
          weddingId: 'wed-123',
          proProfileId: 'pro-456',
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to exclude pro'));
      });
    });

    group('getWeddingTeamChat', () {
      test('should return success with chat info', () async {
        // Arrange
        when(() => mockDatasource.getWeddingTeamChat(
              weddingId: any(named: 'weddingId'),
            )).thenAnswer((_) async => testWeddingTeamChatInfo);

        // Act
        final result =
            await repository.getWeddingTeamChat(weddingId: 'wed-123');

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.roomId, 'room-123');
        expect(result.data?.participantsCount, 5);
        expect(result.data?.unreadCount, 3);
      });

      test('should return success with null when no chat exists', () async {
        // Arrange
        when(() => mockDatasource.getWeddingTeamChat(
              weddingId: any(named: 'weddingId'),
            )).thenAnswer((_) async => null);

        // Act
        final result =
            await repository.getWeddingTeamChat(weddingId: 'wed-123');

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, isNull);
      });

      test('should return failure when datasource throws', () async {
        // Arrange
        when(() => mockDatasource.getWeddingTeamChat(
              weddingId: any(named: 'weddingId'),
            )).thenThrow(Exception('Database error'));

        // Act
        final result =
            await repository.getWeddingTeamChat(weddingId: 'wed-123');

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to get wedding team chat'));
      });
    });
  });

  // ==============================================================
  // AC3: INSPIRATION ALBUMS OPERATIONS TESTS
  // ==============================================================

  group('Inspiration Albums Operations', () {
    group('getInspirationAlbums', () {
      test('should return success with albums', () async {
        // Arrange
        when(() => mockDatasource.getInspirationAlbums(
              weddingId: any(named: 'weddingId'),
            )).thenAnswer((_) async => [testInspirationAlbum]);

        // Act
        final result =
            await repository.getInspirationAlbums(weddingId: 'wed-123');

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.length, 1);
        expect(result.data?[0].name, 'Decoration Ideas');
      });

      test('should return empty list when no albums', () async {
        // Arrange
        when(() => mockDatasource.getInspirationAlbums(
              weddingId: any(named: 'weddingId'),
            )).thenAnswer((_) async => []);

        // Act
        final result =
            await repository.getInspirationAlbums(weddingId: 'wed-123');

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, isEmpty);
      });

      test('should return failure when datasource throws', () async {
        // Arrange
        when(() => mockDatasource.getInspirationAlbums(
              weddingId: any(named: 'weddingId'),
            )).thenThrow(Exception('Database error'));

        // Act
        final result =
            await repository.getInspirationAlbums(weddingId: 'wed-123');

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to get albums'));
      });
    });

    group('createInspirationAlbum', () {
      test('should return success with created album', () async {
        // Arrange
        when(() => mockDatasource.createInspirationAlbum(
              weddingId: any(named: 'weddingId'),
              name: any(named: 'name'),
              category: any(named: 'category'),
              isPrivate: any(named: 'isPrivate'),
            )).thenAnswer((_) async => testInspirationAlbum);

        // Act
        final result = await repository.createInspirationAlbum(
          weddingId: 'wed-123',
          name: 'Decoration Ideas',
          category: 'decor',
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.name, 'Decoration Ideas');
      });

      test('should return failure when datasource throws', () async {
        // Arrange
        when(() => mockDatasource.createInspirationAlbum(
              weddingId: any(named: 'weddingId'),
              name: any(named: 'name'),
              category: any(named: 'category'),
              isPrivate: any(named: 'isPrivate'),
            )).thenThrow(Exception('Creation failed'));

        // Act
        final result = await repository.createInspirationAlbum(
          weddingId: 'wed-123',
          name: 'Decoration Ideas',
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to create album'));
      });
    });

    group('updateInspirationAlbum', () {
      test('should return success when update succeeds', () async {
        // Arrange
        when(() => mockDatasource.updateInspirationAlbum(
              albumId: any(named: 'albumId'),
              name: any(named: 'name'),
              category: any(named: 'category'),
              isPrivate: any(named: 'isPrivate'),
              coverImageUrl: any(named: 'coverImageUrl'),
              sortOrder: any(named: 'sortOrder'),
            )).thenAnswer((_) async {});

        // Act
        final result = await repository.updateInspirationAlbum(
          albumId: 'album-123',
          name: 'Updated Album',
        );

        // Assert
        expect(result.isSuccess, true);
      });

      test('should return failure when update throws', () async {
        // Arrange
        when(() => mockDatasource.updateInspirationAlbum(
              albumId: any(named: 'albumId'),
              name: any(named: 'name'),
              category: any(named: 'category'),
              isPrivate: any(named: 'isPrivate'),
              coverImageUrl: any(named: 'coverImageUrl'),
              sortOrder: any(named: 'sortOrder'),
            )).thenThrow(Exception('Update failed'));

        // Act
        final result = await repository.updateInspirationAlbum(
          albumId: 'album-123',
          name: 'Updated Album',
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to update album'));
      });
    });

    group('deleteInspirationAlbum', () {
      test('should return success when delete succeeds', () async {
        // Arrange
        when(() => mockDatasource.deleteInspirationAlbum(
              albumId: any(named: 'albumId'),
            )).thenAnswer((_) async {});

        // Act
        final result =
            await repository.deleteInspirationAlbum(albumId: 'album-123');

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDatasource.deleteInspirationAlbum(albumId: 'album-123'))
            .called(1);
      });

      test('should return failure when delete throws', () async {
        // Arrange
        when(() => mockDatasource.deleteInspirationAlbum(
              albumId: any(named: 'albumId'),
            )).thenThrow(Exception('Delete failed'));

        // Act
        final result =
            await repository.deleteInspirationAlbum(albumId: 'album-123');

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to delete album'));
      });
    });

    group('getAlbumImages', () {
      test('should return success with images', () async {
        // Arrange
        when(() => mockDatasource.getAlbumImages(
              albumId: any(named: 'albumId'),
            )).thenAnswer((_) async => [testAlbumImage]);

        // Act
        final result = await repository.getAlbumImages(albumId: 'album-123');

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.length, 1);
        expect(result.data?[0].imageUrl, 'https://example.com/image.jpg');
      });

      test('should return failure when datasource throws', () async {
        // Arrange
        when(() => mockDatasource.getAlbumImages(
              albumId: any(named: 'albumId'),
            )).thenThrow(Exception('Database error'));

        // Act
        final result = await repository.getAlbumImages(albumId: 'album-123');

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to get album images'));
      });
    });

    group('uploadAlbumImage', () {
      test('should return success with uploaded image', () async {
        // Arrange
        when(() => mockDatasource.uploadAlbumImage(
              albumId: any(named: 'albumId'),
              imageUrl: any(named: 'imageUrl'),
              thumbnailUrl: any(named: 'thumbnailUrl'),
            )).thenAnswer((_) async => testAlbumImage);

        // Act
        final result = await repository.uploadAlbumImage(
          albumId: 'album-123',
          imageUrl: 'https://example.com/image.jpg',
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.imageUrl, 'https://example.com/image.jpg');
      });

      test('should return failure when upload throws', () async {
        // Arrange
        when(() => mockDatasource.uploadAlbumImage(
              albumId: any(named: 'albumId'),
              imageUrl: any(named: 'imageUrl'),
              thumbnailUrl: any(named: 'thumbnailUrl'),
            )).thenThrow(Exception('Upload failed'));

        // Act
        final result = await repository.uploadAlbumImage(
          albumId: 'album-123',
          imageUrl: 'https://example.com/image.jpg',
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to upload image'));
      });
    });

    group('deleteAlbumImage', () {
      test('should return success when delete succeeds', () async {
        // Arrange
        when(() => mockDatasource.deleteAlbumImage(
              imageId: any(named: 'imageId'),
            )).thenAnswer((_) async {});

        // Act
        final result = await repository.deleteAlbumImage(imageId: 'image-123');

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDatasource.deleteAlbumImage(imageId: 'image-123'))
            .called(1);
      });

      test('should return failure when delete throws', () async {
        // Arrange
        when(() => mockDatasource.deleteAlbumImage(
              imageId: any(named: 'imageId'),
            )).thenThrow(Exception('Delete failed'));

        // Act
        final result = await repository.deleteAlbumImage(imageId: 'image-123');

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to delete image'));
      });
    });
  });

  // ==============================================================
  // AC4: SAVED POSTS OPERATIONS TESTS
  // ==============================================================

  group('Saved Posts Operations', () {
    group('getSavedPosts', () {
      test('should return success with saved posts', () async {
        // Arrange
        when(() => mockDatasource.getSavedPosts(
              albumId: any(named: 'albumId'),
            )).thenAnswer((_) async => [testSavedPost]);

        // Act
        final result = await repository.getSavedPosts(albumId: 'album-123');

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.length, 1);
        expect(result.data?[0].imageUrl, 'https://example.com/saved.jpg');
      });

      test('should return failure when datasource throws', () async {
        // Arrange
        when(() => mockDatasource.getSavedPosts(
              albumId: any(named: 'albumId'),
            )).thenThrow(Exception('Database error'));

        // Act
        final result = await repository.getSavedPosts(albumId: 'album-123');

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to get saved posts'));
      });
    });

    group('saveImageToAlbum', () {
      test('should return success with saved post', () async {
        // Arrange
        when(() => mockDatasource.saveImageToAlbum(
              albumId: any(named: 'albumId'),
              imageUrl: any(named: 'imageUrl'),
              sourceProfileId: any(named: 'sourceProfileId'),
            )).thenAnswer((_) async => testSavedPost);

        // Act
        final result = await repository.saveImageToAlbum(
          albumId: 'album-123',
          imageUrl: 'https://example.com/saved.jpg',
          sourceProfileId: 'pro-111',
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.imageUrl, 'https://example.com/saved.jpg');
      });

      test('should return failure when save throws', () async {
        // Arrange
        when(() => mockDatasource.saveImageToAlbum(
              albumId: any(named: 'albumId'),
              imageUrl: any(named: 'imageUrl'),
              sourceProfileId: any(named: 'sourceProfileId'),
            )).thenThrow(Exception('Save failed'));

        // Act
        final result = await repository.saveImageToAlbum(
          albumId: 'album-123',
          imageUrl: 'https://example.com/saved.jpg',
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to save image'));
      });
    });

    group('removeSavedPost', () {
      test('should return success when remove succeeds', () async {
        // Arrange
        when(() => mockDatasource.removeSavedPost(
              savedPostId: any(named: 'savedPostId'),
            )).thenAnswer((_) async {});

        // Act
        final result =
            await repository.removeSavedPost(savedPostId: 'saved-123');

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDatasource.removeSavedPost(savedPostId: 'saved-123'))
            .called(1);
      });

      test('should return failure when remove throws', () async {
        // Arrange
        when(() => mockDatasource.removeSavedPost(
              savedPostId: any(named: 'savedPostId'),
            )).thenThrow(Exception('Remove failed'));

        // Act
        final result =
            await repository.removeSavedPost(savedPostId: 'saved-123');

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to remove saved post'));
      });
    });

    group('removeSavedPostByImageUrl', () {
      test('should return success with true when deleted', () async {
        // Arrange
        when(() => mockDatasource.removeSavedPostByImageUrl(
              weddingId: any(named: 'weddingId'),
              imageUrl: any(named: 'imageUrl'),
            )).thenAnswer((_) async => true);

        // Act
        final result = await repository.removeSavedPostByImageUrl(
          weddingId: 'wed-123',
          imageUrl: 'https://example.com/image.jpg',
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, true);
      });

      test('should return success with false when not found', () async {
        // Arrange
        when(() => mockDatasource.removeSavedPostByImageUrl(
              weddingId: any(named: 'weddingId'),
              imageUrl: any(named: 'imageUrl'),
            )).thenAnswer((_) async => false);

        // Act
        final result = await repository.removeSavedPostByImageUrl(
          weddingId: 'wed-123',
          imageUrl: 'https://example.com/not-found.jpg',
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, false);
      });

      test('should return failure when remove throws', () async {
        // Arrange
        when(() => mockDatasource.removeSavedPostByImageUrl(
              weddingId: any(named: 'weddingId'),
              imageUrl: any(named: 'imageUrl'),
            )).thenThrow(Exception('Remove failed'));

        // Act
        final result = await repository.removeSavedPostByImageUrl(
          weddingId: 'wed-123',
          imageUrl: 'https://example.com/image.jpg',
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to remove saved post'));
      });
    });

    group('isImageSavedInWedding', () {
      test('should return success with true when image is saved', () async {
        // Arrange
        when(() => mockDatasource.isImageSavedInWedding(
              weddingId: any(named: 'weddingId'),
              imageUrl: any(named: 'imageUrl'),
            )).thenAnswer((_) async => true);

        // Act
        final result = await repository.isImageSavedInWedding(
          weddingId: 'wed-123',
          imageUrl: 'https://example.com/image.jpg',
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, true);
      });

      test('should return success with false when image is not saved',
          () async {
        // Arrange
        when(() => mockDatasource.isImageSavedInWedding(
              weddingId: any(named: 'weddingId'),
              imageUrl: any(named: 'imageUrl'),
            )).thenAnswer((_) async => false);

        // Act
        final result = await repository.isImageSavedInWedding(
          weddingId: 'wed-123',
          imageUrl: 'https://example.com/not-saved.jpg',
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, false);
      });

      test('should return failure when check throws', () async {
        // Arrange
        when(() => mockDatasource.isImageSavedInWedding(
              weddingId: any(named: 'weddingId'),
              imageUrl: any(named: 'imageUrl'),
            )).thenThrow(Exception('Check failed'));

        // Act
        final result = await repository.isImageSavedInWedding(
          weddingId: 'wed-123',
          imageUrl: 'https://example.com/image.jpg',
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to check if image is saved'));
      });
    });
  });

  // ==============================================================
  // AC5: WEDDING EVENTS (AGENDA) OPERATIONS TESTS
  // ==============================================================

  group('Wedding Events (Agenda) Operations', () {
    group('getWeddingEvents', () {
      test('should return success with events', () async {
        // Arrange
        when(() => mockDatasource.getWeddingEvents(
              weddingId: any(named: 'weddingId'),
            )).thenAnswer((_) async => [testWeddingEvent]);

        // Act
        final result = await repository.getWeddingEvents(weddingId: 'wed-123');

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.length, 1);
        expect(result.data?[0].title, 'Ceremony');
      });

      test('should return empty list when no events', () async {
        // Arrange
        when(() => mockDatasource.getWeddingEvents(
              weddingId: any(named: 'weddingId'),
            )).thenAnswer((_) async => []);

        // Act
        final result = await repository.getWeddingEvents(weddingId: 'wed-123');

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, isEmpty);
      });

      test('should return failure when datasource throws', () async {
        // Arrange
        when(() => mockDatasource.getWeddingEvents(
              weddingId: any(named: 'weddingId'),
            )).thenThrow(Exception('Database error'));

        // Act
        final result = await repository.getWeddingEvents(weddingId: 'wed-123');

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to get events'));
      });
    });

    group('createWeddingEvent', () {
      test('should return success with created event', () async {
        // Arrange
        when(() => mockDatasource.createWeddingEvent(
              weddingId: any(named: 'weddingId'),
              title: any(named: 'title'),
              eventDate: any(named: 'eventDate'),
              description: any(named: 'description'),
              eventEndDate: any(named: 'eventEndDate'),
              location: any(named: 'location'),
              linkedProId: any(named: 'linkedProId'),
              isPublic: any(named: 'isPublic'),
            )).thenAnswer((_) async => testWeddingEvent);

        // Act
        final result = await repository.createWeddingEvent(
          weddingId: 'wed-123',
          title: 'Ceremony',
          eventDate: DateTime(2025, 9, 15, 14, 0),
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.title, 'Ceremony');
      });

      test('should return failure when create throws', () async {
        // Arrange
        when(() => mockDatasource.createWeddingEvent(
              weddingId: any(named: 'weddingId'),
              title: any(named: 'title'),
              eventDate: any(named: 'eventDate'),
              description: any(named: 'description'),
              eventEndDate: any(named: 'eventEndDate'),
              location: any(named: 'location'),
              linkedProId: any(named: 'linkedProId'),
              isPublic: any(named: 'isPublic'),
            )).thenThrow(Exception('Creation failed'));

        // Act
        final result = await repository.createWeddingEvent(
          weddingId: 'wed-123',
          title: 'Ceremony',
          eventDate: DateTime(2025, 9, 15, 14, 0),
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to create event'));
      });
    });

    group('updateWeddingEvent', () {
      test('should return success when update succeeds', () async {
        // Arrange
        when(() => mockDatasource.updateWeddingEvent(
              eventId: any(named: 'eventId'),
              title: any(named: 'title'),
              description: any(named: 'description'),
              eventDate: any(named: 'eventDate'),
              eventEndDate: any(named: 'eventEndDate'),
              location: any(named: 'location'),
              linkedProId: any(named: 'linkedProId'),
              isPublic: any(named: 'isPublic'),
              status: any(named: 'status'),
            )).thenAnswer((_) async {});

        // Act
        final result = await repository.updateWeddingEvent(
          eventId: 'event-123',
          title: 'Updated Ceremony',
        );

        // Assert
        expect(result.isSuccess, true);
      });

      test('should return failure when update throws', () async {
        // Arrange
        when(() => mockDatasource.updateWeddingEvent(
              eventId: any(named: 'eventId'),
              title: any(named: 'title'),
              description: any(named: 'description'),
              eventDate: any(named: 'eventDate'),
              eventEndDate: any(named: 'eventEndDate'),
              location: any(named: 'location'),
              linkedProId: any(named: 'linkedProId'),
              isPublic: any(named: 'isPublic'),
              status: any(named: 'status'),
            )).thenThrow(Exception('Update failed'));

        // Act
        final result = await repository.updateWeddingEvent(
          eventId: 'event-123',
          title: 'Updated Ceremony',
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to update event'));
      });
    });

    group('deleteWeddingEvent', () {
      test('should return success when delete succeeds', () async {
        // Arrange
        when(() => mockDatasource.deleteWeddingEvent(
              eventId: any(named: 'eventId'),
            )).thenAnswer((_) async {});

        // Act
        final result =
            await repository.deleteWeddingEvent(eventId: 'event-123');

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDatasource.deleteWeddingEvent(eventId: 'event-123'))
            .called(1);
      });

      test('should return failure when delete throws', () async {
        // Arrange
        when(() => mockDatasource.deleteWeddingEvent(
              eventId: any(named: 'eventId'),
            )).thenThrow(Exception('Delete failed'));

        // Act
        final result =
            await repository.deleteWeddingEvent(eventId: 'event-123');

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to delete event'));
      });
    });

    group('toggleEventStatus', () {
      test('should return success when toggle from pending to done', () async {
        // Arrange
        when(() => mockDatasource.toggleEventStatus(
              eventId: any(named: 'eventId'),
              currentStatus: any(named: 'currentStatus'),
            )).thenAnswer((_) async {});

        // Act
        final result = await repository.toggleEventStatus(
          eventId: 'event-123',
          currentStatus: 'pending',
        );

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDatasource.toggleEventStatus(
              eventId: 'event-123',
              currentStatus: 'pending',
            )).called(1);
      });

      test('should return success when toggle from done to pending', () async {
        // Arrange
        when(() => mockDatasource.toggleEventStatus(
              eventId: any(named: 'eventId'),
              currentStatus: any(named: 'currentStatus'),
            )).thenAnswer((_) async {});

        // Act
        final result = await repository.toggleEventStatus(
          eventId: 'event-123',
          currentStatus: 'done',
        );

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDatasource.toggleEventStatus(
              eventId: 'event-123',
              currentStatus: 'done',
            )).called(1);
      });

      test('should return failure when toggle throws', () async {
        // Arrange
        when(() => mockDatasource.toggleEventStatus(
              eventId: any(named: 'eventId'),
              currentStatus: any(named: 'currentStatus'),
            )).thenThrow(Exception('Toggle failed'));

        // Act
        final result = await repository.toggleEventStatus(
          eventId: 'event-123',
          currentStatus: 'pending',
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to toggle event status'));
      });
    });
  });

  // ==============================================================
  // AC6: WEDDING EXPENSES (BUDGET) OPERATIONS TESTS
  // ==============================================================

  group('Wedding Expenses (Budget) Operations', () {
    group('getWeddingExpenses', () {
      test('should return success with expenses', () async {
        // Arrange
        when(() => mockDatasource.getWeddingExpenses(
              weddingId: any(named: 'weddingId'),
            )).thenAnswer((_) async => [testWeddingExpense]);

        // Act
        final result =
            await repository.getWeddingExpenses(weddingId: 'wed-123');

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.length, 1);
        expect(result.data?[0].category, 'photographer');
        expect(result.data?[0].amount, 3000);
      });

      test('should return empty list when no expenses', () async {
        // Arrange
        when(() => mockDatasource.getWeddingExpenses(
              weddingId: any(named: 'weddingId'),
            )).thenAnswer((_) async => []);

        // Act
        final result =
            await repository.getWeddingExpenses(weddingId: 'wed-123');

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, isEmpty);
      });

      test('should return failure when datasource throws', () async {
        // Arrange
        when(() => mockDatasource.getWeddingExpenses(
              weddingId: any(named: 'weddingId'),
            )).thenThrow(Exception('Database error'));

        // Act
        final result =
            await repository.getWeddingExpenses(weddingId: 'wed-123');

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to get expenses'));
      });
    });

    group('createWeddingExpense', () {
      test('should return success with created expense', () async {
        // Arrange
        when(() => mockDatasource.createWeddingExpense(
              weddingId: any(named: 'weddingId'),
              category: any(named: 'category'),
              amount: any(named: 'amount'),
              currencyCode: any(named: 'currencyCode'),
              description: any(named: 'description'),
              status: any(named: 'status'),
              paidAmount: any(named: 'paidAmount'),
              dueDate: any(named: 'dueDate'),
              linkedProId: any(named: 'linkedProId'),
            )).thenAnswer((_) async => testWeddingExpense);

        // Act
        final result = await repository.createWeddingExpense(
          weddingId: 'wed-123',
          category: 'photographer',
          amount: 3000,
          currencyCode: 'EUR',
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.category, 'photographer');
        expect(result.data?.amount, 3000);
      });

      test('should return failure when create throws', () async {
        // Arrange
        when(() => mockDatasource.createWeddingExpense(
              weddingId: any(named: 'weddingId'),
              category: any(named: 'category'),
              amount: any(named: 'amount'),
              currencyCode: any(named: 'currencyCode'),
              description: any(named: 'description'),
              status: any(named: 'status'),
              paidAmount: any(named: 'paidAmount'),
              dueDate: any(named: 'dueDate'),
              linkedProId: any(named: 'linkedProId'),
            )).thenThrow(Exception('Creation failed'));

        // Act
        final result = await repository.createWeddingExpense(
          weddingId: 'wed-123',
          category: 'photographer',
          amount: 3000,
          currencyCode: 'EUR',
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to create expense'));
      });
    });

    group('updateWeddingExpense', () {
      test('should return success when update succeeds', () async {
        // Arrange
        when(() => mockDatasource.updateWeddingExpense(
              expenseId: any(named: 'expenseId'),
              category: any(named: 'category'),
              description: any(named: 'description'),
              amount: any(named: 'amount'),
              currencyCode: any(named: 'currencyCode'),
              status: any(named: 'status'),
              paidAmount: any(named: 'paidAmount'),
              dueDate: any(named: 'dueDate'),
              linkedProId: any(named: 'linkedProId'),
            )).thenAnswer((_) async {});

        // Act
        final result = await repository.updateWeddingExpense(
          expenseId: 'expense-123',
          paidAmount: 1500,
          status: 'partial',
        );

        // Assert
        expect(result.isSuccess, true);
      });

      test('should return failure when update throws', () async {
        // Arrange
        when(() => mockDatasource.updateWeddingExpense(
              expenseId: any(named: 'expenseId'),
              category: any(named: 'category'),
              description: any(named: 'description'),
              amount: any(named: 'amount'),
              currencyCode: any(named: 'currencyCode'),
              status: any(named: 'status'),
              paidAmount: any(named: 'paidAmount'),
              dueDate: any(named: 'dueDate'),
              linkedProId: any(named: 'linkedProId'),
            )).thenThrow(Exception('Update failed'));

        // Act
        final result = await repository.updateWeddingExpense(
          expenseId: 'expense-123',
          paidAmount: 1500,
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to update expense'));
      });
    });

    group('deleteWeddingExpense', () {
      test('should return success when delete succeeds', () async {
        // Arrange
        when(() => mockDatasource.deleteWeddingExpense(
              expenseId: any(named: 'expenseId'),
            )).thenAnswer((_) async {});

        // Act
        final result =
            await repository.deleteWeddingExpense(expenseId: 'expense-123');

        // Assert
        expect(result.isSuccess, true);
        verify(() =>
                mockDatasource.deleteWeddingExpense(expenseId: 'expense-123'))
            .called(1);
      });

      test('should return failure when delete throws', () async {
        // Arrange
        when(() => mockDatasource.deleteWeddingExpense(
              expenseId: any(named: 'expenseId'),
            )).thenThrow(Exception('Delete failed'));

        // Act
        final result =
            await repository.deleteWeddingExpense(expenseId: 'expense-123');

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to delete expense'));
      });
    });
  });

  // ==============================================================
  // AC7: WEDDING GUESTS OPERATIONS TESTS
  // ==============================================================

  group('Wedding Guests Operations', () {
    group('getWeddingGuests', () {
      test('should return success with guests', () async {
        // Arrange
        when(() => mockDatasource.getWeddingGuests(
              weddingId: any(named: 'weddingId'),
            )).thenAnswer((_) async => [testWeddingGuest]);

        // Act
        final result = await repository.getWeddingGuests(weddingId: 'wed-123');

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.length, 1);
        expect(result.data?[0].name, 'Marie Dupont');
      });

      test('should return empty list when no guests', () async {
        // Arrange
        when(() => mockDatasource.getWeddingGuests(
              weddingId: any(named: 'weddingId'),
            )).thenAnswer((_) async => []);

        // Act
        final result = await repository.getWeddingGuests(weddingId: 'wed-123');

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, isEmpty);
      });

      test('should return failure when datasource throws', () async {
        // Arrange
        when(() => mockDatasource.getWeddingGuests(
              weddingId: any(named: 'weddingId'),
            )).thenThrow(Exception('Database error'));

        // Act
        final result = await repository.getWeddingGuests(weddingId: 'wed-123');

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to get guests'));
      });
    });

    group('createWeddingGuest', () {
      test('should return success with created guest', () async {
        // Arrange
        when(() => mockDatasource.createWeddingGuest(
              weddingId: any(named: 'weddingId'),
              name: any(named: 'name'),
              email: any(named: 'email'),
              phone: any(named: 'phone'),
              role: any(named: 'role'),
              notes: any(named: 'notes'),
            )).thenAnswer((_) async => testWeddingGuest);

        // Act
        final result = await repository.createWeddingGuest(
          weddingId: 'wed-123',
          name: 'Marie Dupont',
          email: 'marie@example.com',
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.name, 'Marie Dupont');
      });

      test('should return failure when create throws', () async {
        // Arrange
        when(() => mockDatasource.createWeddingGuest(
              weddingId: any(named: 'weddingId'),
              name: any(named: 'name'),
              email: any(named: 'email'),
              phone: any(named: 'phone'),
              role: any(named: 'role'),
              notes: any(named: 'notes'),
            )).thenThrow(Exception('Creation failed'));

        // Act
        final result = await repository.createWeddingGuest(
          weddingId: 'wed-123',
          name: 'Marie Dupont',
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to create guest'));
      });
    });

    group('updateWeddingGuest', () {
      test('should return success when update succeeds', () async {
        // Arrange
        when(() => mockDatasource.updateWeddingGuest(
              guestId: any(named: 'guestId'),
              name: any(named: 'name'),
              email: any(named: 'email'),
              phone: any(named: 'phone'),
              role: any(named: 'role'),
              notes: any(named: 'notes'),
            )).thenAnswer((_) async {});

        // Act
        final result = await repository.updateWeddingGuest(
          guestId: 'guest-123',
          name: 'Marie Updated',
          role: 'bridesmaid',
        );

        // Assert
        expect(result.isSuccess, true);
      });

      test('should return failure when update throws', () async {
        // Arrange
        when(() => mockDatasource.updateWeddingGuest(
              guestId: any(named: 'guestId'),
              name: any(named: 'name'),
              email: any(named: 'email'),
              phone: any(named: 'phone'),
              role: any(named: 'role'),
              notes: any(named: 'notes'),
            )).thenThrow(Exception('Update failed'));

        // Act
        final result = await repository.updateWeddingGuest(
          guestId: 'guest-123',
          name: 'Marie Updated',
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to update guest'));
      });
    });

    group('deleteWeddingGuest', () {
      test('should return success when delete succeeds', () async {
        // Arrange
        when(() => mockDatasource.deleteWeddingGuest(
              guestId: any(named: 'guestId'),
            )).thenAnswer((_) async {});

        // Act
        final result =
            await repository.deleteWeddingGuest(guestId: 'guest-123');

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDatasource.deleteWeddingGuest(guestId: 'guest-123'))
            .called(1);
      });

      test('should return failure when delete throws', () async {
        // Arrange
        when(() => mockDatasource.deleteWeddingGuest(
              guestId: any(named: 'guestId'),
            )).thenThrow(Exception('Delete failed'));

        // Act
        final result =
            await repository.deleteWeddingGuest(guestId: 'guest-123');

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to delete guest'));
      });
    });
  });

  // ==============================================================
  // AC8: REPOSITORYRESULT WRAPPER TESTS
  // ==============================================================

  group('RepositoryResult', () {
    test('success should have data and no error', () {
      const result = RepositoryResult.success('test data');

      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.data, 'test data');
      expect(result.error, isNull);
    });

    test('failure should have error and no data', () {
      const result = RepositoryResult<String>.failure('error message');

      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.data, isNull);
      expect(result.error, 'error message');
    });

    test('success with void should work', () {
      const result = RepositoryResult<void>.success(null);

      expect(result.isSuccess, true);
      expect(result.error, isNull);
    });

    test('success with list should work', () {
      const result = RepositoryResult<List<String>>.success(['a', 'b', 'c']);

      expect(result.isSuccess, true);
      expect(result.data, ['a', 'b', 'c']);
    });
  });
}
