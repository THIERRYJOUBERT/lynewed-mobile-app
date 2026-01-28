# Story STORY-03: Tests My Wedding Module - Domain Layer

## Description

En tant que developpeur, je veux avoir des tests unitaires pour les entites du module My Wedding afin de garantir la qualite et la stabilite de ce module central de l'application.

## Points : 5

## Priorite : Haute

## Fichiers source a tester

### Domain Layer - Entities

| Fichier | Entite | Complexite |
|---------|--------|------------|
| `lib/features/my_wedding/domain/entities/wedding_overview.dart` | WeddingOverview | Haute |
| `lib/features/my_wedding/domain/entities/wedding_guest.dart` | WeddingGuest, GuestRole | Moyenne |
| `lib/features/my_wedding/domain/entities/wedding_event.dart` | WeddingEvent | Moyenne |
| `lib/features/my_wedding/domain/entities/wedding_expense.dart` | WeddingExpense, ExpenseStatus | Moyenne |
| `lib/features/my_wedding/domain/entities/inspiration_album.dart` | InspirationAlbum | Moyenne |
| `lib/features/my_wedding/domain/entities/album_image.dart` | AlbumImage | Basse |
| `lib/features/my_wedding/domain/entities/saved_post.dart` | SavedPost | Basse |
| `lib/features/my_wedding/domain/entities/wedding_team_chat_info.dart` | WeddingTeamChatInfo | Basse |

## Criteres d'Acceptance

### AC1: Tests WeddingGuest
- [ ] Test creation avec champs requis
- [ ] Test `fromJson()` avec tous les roles (guest, bridesmaid, bestMan, family, witness, other)
- [ ] Test `_parseRole()` avec valeurs invalides -> default guest
- [ ] Test `toJson()` serialise correctement
- [ ] Test `copyWith()` preserve les champs non modifies
- [ ] Test egalite (basee sur ID)

### AC2: Tests WeddingExpense
- [ ] Test creation avec champs requis
- [ ] Test `fromJson()` avec tous les statuts (pending, partial, paid)
- [ ] Test `_parseStatus()` avec valeurs invalides -> default pending
- [ ] Test getters derives (`remainingAmount`, `paymentProgress`, `isFullyPaid`)
- [ ] Test `toJson()` serialise correctement
- [ ] Test `copyWith()`
- [ ] Test edge cases (amount = 0, paidAmount > amount)

### AC3: Tests WeddingEvent
- [ ] Test creation avec champs requis
- [ ] Test `fromJson()` avec donnees completes
- [ ] Test `fromJson()` avec donnees optionnelles manquantes
- [ ] Test `toJson()` serialise correctement
- [ ] Test `copyWith()`

### AC4: Tests InspirationAlbum
- [ ] Test creation avec champs requis
- [ ] Test `fromJson()` avec donnees completes
- [ ] Test champs optionnels (coverImageUrl, category)
- [ ] Test `toJson()` serialise correctement

### AC5: Tests AlbumImage et SavedPost
- [ ] Test creation et parsing JSON
- [ ] Test serialisation
- [ ] Test egalite

### AC6: Qualite des tests
- [ ] Coverage > 80% sur domain/entities/
- [ ] Tous les tests passent
- [ ] Temps d'execution < 5s

## Fichiers de Test a Creer

```
test/features/my_wedding/
└── domain/
    └── entities/
        ├── wedding_guest_test.dart
        ├── wedding_expense_test.dart
        ├── wedding_event_test.dart
        ├── inspiration_album_test.dart
        ├── album_image_test.dart
        ├── saved_post_test.dart
        └── wedding_team_chat_info_test.dart
```

## Notes Techniques

### Fixtures de test

```dart
// test/features/my_wedding/fixtures/wedding_fixtures.dart

const testWeddingGuestMap = {
  'id': 'guest-123',
  'wedding_id': 'wedding-456',
  'name': 'Marie Dupont',
  'email': 'marie@example.com',
  'phone': '+33612345678',
  'role': 'bridesmaid',
  'notes': 'Temoin de la mariee',
  'created_at': '2025-01-24T10:00:00Z',
};

const testWeddingExpenseMap = {
  'id': 'expense-123',
  'wedding_id': 'wedding-456',
  'category': 'photographer',
  'description': 'Photographe principal',
  'amount': 3000.0,
  'currency_code': 'EUR',
  'status': 'partial',
  'paid_amount': 1500.0,
  'due_date': '2025-06-15T00:00:00Z',
  'linked_pro_id': 'pro-789',
  'linked_pro_name': 'Studio Photo',
  'created_at': '2025-01-24T10:00:00Z',
};

const testWeddingEventMap = {
  'id': 'event-123',
  'wedding_id': 'wedding-456',
  'title': 'Ceremonie',
  'description': 'Ceremonie civile a la mairie',
  'event_date': '2025-09-15T14:00:00Z',
  'event_end_date': '2025-09-15T15:00:00Z',
  'location': 'Mairie de Paris',
  'linked_pro_id': null,
  'is_public': true,
  'status': 'pending',
  'created_at': '2025-01-24T10:00:00Z',
};
```

### Exemple de test pour WeddingExpense

```dart
void main() {
  group('WeddingExpense', () {
    group('computed properties', () {
      test('remainingAmount should calculate correctly', () {
        const expense = WeddingExpense(
          id: 'exp-1',
          weddingId: 'wed-1',
          category: 'venue',
          amount: 5000,
          currencyCode: 'EUR',
          paidAmount: 2000,
        );

        expect(expense.remainingAmount, 3000);
      });

      test('paymentProgress should return 0.0 when amount is 0', () {
        const expense = WeddingExpense(
          id: 'exp-1',
          weddingId: 'wed-1',
          category: 'venue',
          amount: 0,
          currencyCode: 'EUR',
        );

        expect(expense.paymentProgress, 0.0);
      });

      test('isFullyPaid should be true when status is paid', () {
        const expense = WeddingExpense(
          id: 'exp-1',
          weddingId: 'wed-1',
          category: 'venue',
          amount: 5000,
          currencyCode: 'EUR',
          status: ExpenseStatus.paid,
        );

        expect(expense.isFullyPaid, true);
      });

      test('isFullyPaid should be true when paidAmount >= amount', () {
        const expense = WeddingExpense(
          id: 'exp-1',
          weddingId: 'wed-1',
          category: 'venue',
          amount: 5000,
          currencyCode: 'EUR',
          paidAmount: 5000,
        );

        expect(expense.isFullyPaid, true);
      });
    });

    group('parsing', () {
      test('should parse all expense statuses correctly', () {
        expect(
          WeddingExpense.fromJson({...testExpenseMap, 'status': 'pending'}).status,
          ExpenseStatus.pending,
        );
        expect(
          WeddingExpense.fromJson({...testExpenseMap, 'status': 'partial'}).status,
          ExpenseStatus.partial,
        );
        expect(
          WeddingExpense.fromJson({...testExpenseMap, 'status': 'paid'}).status,
          ExpenseStatus.paid,
        );
      });

      test('should default to pending for invalid status', () {
        final expense = WeddingExpense.fromJson({
          ...testExpenseMap,
          'status': 'invalid_status',
        });

        expect(expense.status, ExpenseStatus.pending);
      });
    });
  });
}
```

## Definition of Done

- [ ] Tous les fichiers de test crees
- [ ] Tous les tests passent (`flutter test test/features/my_wedding/domain/`)
- [ ] Aucun warning (`flutter analyze`)
- [ ] Coverage > 80% sur domain/entities/
- [ ] TRACKING.md mis a jour

## Estimation

- WeddingGuest + WeddingExpense : ~1.5h
- WeddingEvent + InspirationAlbum : ~1h
- AlbumImage + SavedPost + autres : ~1h
- Review et polish : ~30min

**Total** : ~4h (1 jour)
