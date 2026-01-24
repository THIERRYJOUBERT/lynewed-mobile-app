# Story STORY-04: Tests My Wedding Module - Data Layer

## Description

En tant que developpeur, je veux avoir des tests unitaires pour le repository My Wedding afin de garantir la fiabilite des operations CRUD sur les weddings, events, expenses, guests et albums.

## Points : 5

## Priorite : Haute

## Fichiers source a tester

### Data Layer

| Fichier | Composant | Methodes |
|---------|-----------|----------|
| `lib/features/my_wedding/data/repositories/my_wedding_repository_impl.dart` | MyWeddingRepositoryImpl | ~30 methodes |

## Criteres d'Acceptance

### AC1: Tests Wedding Operations
- [ ] Test `getMyWedding()` success et failure
- [ ] Test `createWedding()` success et failure
- [ ] Test `updateWedding()` success et failure
- [ ] Test `updateWeddingStatus()` success et failure
- [ ] Test `updateOnboardingData()` success et failure
- [ ] Test `completeOnboarding()` success et failure

### AC2: Tests Wedding Team Operations
- [ ] Test `getWeddingTeam()` success et failure
- [ ] Test `getActiveWeddingTeam()` success et failure
- [ ] Test `getContactedPros()` success et failure
- [ ] Test `inviteProToWedding()` success et failure
- [ ] Test `excludeProFromWedding()` success et failure
- [ ] Test `getWeddingTeamChat()` success et failure

### AC3: Tests Inspiration Albums Operations
- [ ] Test `getInspirationAlbums()` success et failure
- [ ] Test `createInspirationAlbum()` success et failure
- [ ] Test `updateInspirationAlbum()` success et failure
- [ ] Test `deleteInspirationAlbum()` success et failure
- [ ] Test `getAlbumImages()` success et failure
- [ ] Test `uploadAlbumImage()` success et failure
- [ ] Test `deleteAlbumImage()` success et failure

### AC4: Tests Saved Posts Operations
- [ ] Test `getSavedPosts()` success et failure
- [ ] Test `saveImageToAlbum()` success et failure
- [ ] Test `removeSavedPost()` success et failure
- [ ] Test `removeSavedPostByImageUrl()` success et failure
- [ ] Test `isImageSavedInWedding()` success et failure

### AC5: Tests Wedding Events (Agenda) Operations
- [ ] Test `getWeddingEvents()` success et failure
- [ ] Test `createWeddingEvent()` success et failure
- [ ] Test `updateWeddingEvent()` success et failure
- [ ] Test `deleteWeddingEvent()` success et failure
- [ ] Test `toggleEventStatus()` success et failure

### AC6: Tests Wedding Expenses (Budget) Operations
- [ ] Test `getWeddingExpenses()` success et failure
- [ ] Test `createWeddingExpense()` success et failure
- [ ] Test `updateWeddingExpense()` success et failure
- [ ] Test `deleteWeddingExpense()` success et failure

### AC7: Tests Wedding Guests Operations
- [ ] Test `getWeddingGuests()` success et failure
- [ ] Test `createWeddingGuest()` success et failure
- [ ] Test `updateWeddingGuest()` success et failure
- [ ] Test `deleteWeddingGuest()` success et failure

### AC8: Qualite des tests
- [ ] Coverage > 60% sur data/repositories/
- [ ] Tous les tests passent
- [ ] Temps d'execution < 10s

## Fichiers de Test a Creer

```
test/features/my_wedding/
└── data/
    └── repositories/
        └── my_wedding_repository_impl_test.dart
```

## Notes Techniques

### Mock necessaire

```dart
import 'package:mocktail/mocktail.dart';

class MockSupabaseMyWeddingDatasource extends Mock
    implements SupabaseMyWeddingDatasource {}
```

### Pattern de test groupé par fonctionnalite

```dart
void main() {
  late MockSupabaseMyWeddingDatasource mockDatasource;
  late MyWeddingRepositoryImpl repository;

  setUp(() {
    mockDatasource = MockSupabaseMyWeddingDatasource();
    repository = MyWeddingRepositoryImpl(datasource: mockDatasource);
  });

  group('Wedding Operations', () {
    group('getMyWedding', () {
      test('should return success when datasource returns wedding', () async {
        when(() => mockDatasource.getMyWedding())
            .thenAnswer((_) async => testWeddingOverview);

        final result = await repository.getMyWedding();

        expect(result.isSuccess, true);
        expect(result.data, testWeddingOverview);
      });

      test('should return failure when datasource throws', () async {
        when(() => mockDatasource.getMyWedding())
            .thenThrow(Exception('Network error'));

        final result = await repository.getMyWedding();

        expect(result.isSuccess, false);
        expect(result.error, contains('Failed to get wedding'));
      });
    });

    group('createWedding', () {
      test('should return wedding ID on success', () async {
        when(() => mockDatasource.createWedding(
          eventDate: any(named: 'eventDate'),
          lat: any(named: 'lat'),
          lng: any(named: 'lng'),
          venueName: any(named: 'venueName'),
          venueAddress: any(named: 'venueAddress'),
          countryCode: any(named: 'countryCode'),
        )).thenAnswer((_) async => 'new-wedding-id');

        final result = await repository.createWedding(
          eventDate: DateTime(2025, 9, 15),
          lat: 48.8566,
          lng: 2.3522,
        );

        expect(result.isSuccess, true);
        expect(result.data, 'new-wedding-id');
      });
    });
  });

  group('Wedding Events (Agenda)', () {
    group('getWeddingEvents', () {
      test('should return list of events on success', () async {
        when(() => mockDatasource.getWeddingEvents(weddingId: 'wed-123'))
            .thenAnswer((_) async => [testWeddingEvent]);

        final result = await repository.getWeddingEvents(weddingId: 'wed-123');

        expect(result.isSuccess, true);
        expect(result.data?.length, 1);
      });
    });

    group('toggleEventStatus', () {
      test('should toggle from pending to done', () async {
        when(() => mockDatasource.toggleEventStatus(
          eventId: 'event-1',
          currentStatus: 'pending',
        )).thenAnswer((_) async {});

        final result = await repository.toggleEventStatus(
          eventId: 'event-1',
          currentStatus: 'pending',
        );

        expect(result.isSuccess, true);
        verify(() => mockDatasource.toggleEventStatus(
          eventId: 'event-1',
          currentStatus: 'pending',
        )).called(1);
      });
    });
  });

  group('Wedding Expenses (Budget)', () {
    group('createWeddingExpense', () {
      test('should return created expense on success', () async {
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

        final result = await repository.createWeddingExpense(
          weddingId: 'wed-123',
          category: 'photographer',
          amount: 3000,
          currencyCode: 'EUR',
        );

        expect(result.isSuccess, true);
        expect(result.data?.category, 'photographer');
      });
    });
  });
}
```

### Fixtures de test

```dart
// test/features/my_wedding/fixtures/my_wedding_fixtures.dart

final testWeddingOverview = WeddingOverview(
  id: 'wed-123',
  eventDate: DateTime(2025, 9, 15),
  lat: 48.8566,
  lng: 2.3522,
  // ... autres champs
);

final testWeddingEvent = WeddingEvent(
  id: 'event-123',
  weddingId: 'wed-123',
  title: 'Ceremonie',
  eventDate: DateTime(2025, 9, 15, 14, 0),
);

final testWeddingExpense = WeddingExpense(
  id: 'expense-123',
  weddingId: 'wed-123',
  category: 'photographer',
  amount: 3000,
  currencyCode: 'EUR',
);

final testWeddingGuest = WeddingGuest(
  id: 'guest-123',
  weddingId: 'wed-123',
  name: 'Marie Dupont',
);
```

## Definition of Done

- [ ] Fichier de test cree avec tous les groupes
- [ ] Tous les tests passent (`flutter test test/features/my_wedding/data/`)
- [ ] Aucun warning (`flutter analyze`)
- [ ] Coverage > 60% sur data/repositories/
- [ ] TRACKING.md mis a jour

## Estimation

- Wedding Operations : ~1h
- Team Operations : ~1h
- Albums + Saved Posts : ~1h
- Events + Expenses + Guests : ~1.5h
- Review : ~30min

**Total** : ~5h (1 jour)
