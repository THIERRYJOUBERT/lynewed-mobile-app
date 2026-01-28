# Story S09: Verifier que guests n'ont pas acces map

## Description
En tant que developpeur, je veux verifier et tester que les utilisateurs avec le role "guest" ne peuvent pas acceder a la carte, afin de respecter la decision D-13 du PRD.

## Criteres d'Acceptance (Gherkin)
- [ ] Given a user with role = 'guest' When the user attempts to navigate to the map page Then the navigation should be blocked And an appropriate message should be shown
- [ ] Given a user with role = 'bride' When the user navigates to the map page Then the map should be displayed normally
- [ ] Given a user with role = 'professional' When the user navigates to the map page Then the map should be displayed normally
- [ ] Given a user with role = 'guest' When viewing the navigation bar Then the map icon should NOT be visible Or the map tab should be disabled

## Fichiers Concernes
### A Creer
- `test/features/map/presentation/pages/map_page_access_test.dart`

### A Modifier
- `lib/features/map/presentation/pages/map_page.dart` (add role check if missing)
- `lib/core/navigation/app_navigation.dart` (verify guest navbar)
- Potentiellement le widget de navigation bar

## Notes Techniques

### Role check in MapPage
```dart
// lib/features/map/presentation/pages/map_page.dart

class MapPage extends ConsumerWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    // D-13: Guests cannot access map
    if (user?.role == 'guest') {
      return _buildAccessDenied(context);
    }

    return Scaffold(
      // ... normal map content
    );
  }

  Widget _buildAccessDenied(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: LynewedColors.gray400),
            const SizedBox(height: 16),
            Text(
              'Map not available',
              style: LynewedTextStyles.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'As a guest, you don\'t have access to the map feature.',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go back home'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Helper function for access check
```dart
// lib/core/auth/role_utils.dart

/// Check if a role can access the map feature (D-13)
bool canAccessMap({required String? role}) {
  if (role == null) return false;
  return role == 'bride' || role == 'professional';
}

/// Roles that are allowed to see map in navigation
const Set<String> mapAllowedRoles = {'bride', 'professional'};
```

### Navigation bar configuration
```dart
// In navigation/bottom_nav_bar.dart or similar

List<BottomNavigationBarItem> _buildNavItems(String? userRole) {
  final items = <BottomNavigationBarItem>[];

  // Home - always visible
  items.add(const BottomNavigationBarItem(
    icon: Icon(Icons.home),
    label: 'Home',
  ));

  // Map - only for bride and professional (D-13)
  if (canAccessMap(role: userRole)) {
    items.add(const BottomNavigationBarItem(
      icon: Icon(Icons.map),
      label: 'Map',
    ));
  }

  // ... other items

  return items;
}
```

### Test file
```dart
// test/features/map/presentation/pages/map_page_access_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed/core/auth/role_utils.dart';

void main() {
  group('Map Page Access Control (D-13)', () {
    group('canAccessMap function', () {
      test('should return false for guest role', () {
        expect(canAccessMap(role: 'guest'), isFalse);
      });

      test('should return true for bride role', () {
        expect(canAccessMap(role: 'bride'), isTrue);
      });

      test('should return true for professional role', () {
        expect(canAccessMap(role: 'professional'), isTrue);
      });

      test('should return false for null role', () {
        expect(canAccessMap(role: null), isFalse);
      });

      test('should return false for unknown role', () {
        expect(canAccessMap(role: 'unknown'), isFalse);
      });
    });

    group('mapAllowedRoles constant', () {
      test('should contain bride', () {
        expect(mapAllowedRoles.contains('bride'), isTrue);
      });

      test('should contain professional', () {
        expect(mapAllowedRoles.contains('professional'), isTrue);
      });

      test('should not contain guest', () {
        expect(mapAllowedRoles.contains('guest'), isFalse);
      });

      test('should have exactly 2 roles', () {
        expect(mapAllowedRoles.length, 2);
      });
    });
  });

  group('MapPage widget access', () {
    testWidgets('shows access denied for guest user', (tester) async {
      // Mock user provider with guest role
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(
              User(id: '1', role: 'guest'),
            ),
          ],
          child: const MaterialApp(home: MapPage()),
        ),
      );

      expect(find.text('Map not available'), findsOneWidget);
      expect(find.text('As a guest, you don\'t have access to the map feature.'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('shows map content for bride user', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(
              User(id: '1', role: 'bride'),
            ),
          ],
          child: const MaterialApp(home: MapPage()),
        ),
      );

      // Should not show access denied
      expect(find.text('Map not available'), findsNothing);
      // Should show map (or map-related widget)
      // Adjust based on actual MapPage implementation
    });

    testWidgets('shows map content for professional user', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(
              User(id: '1', role: 'professional'),
            ),
          ],
          child: const MaterialApp(home: MapPage()),
        ),
      );

      expect(find.text('Map not available'), findsNothing);
    });
  });

  group('Navigation bar visibility', () {
    testWidgets('map icon not shown for guest', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(
              User(id: '1', role: 'guest'),
            ),
          ],
          child: const MaterialApp(home: MainShell()),
        ),
      );

      // Map icon should not be in bottom nav for guest
      expect(find.byIcon(Icons.map), findsNothing);
    });

    testWidgets('map icon shown for bride', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(
              User(id: '1', role: 'bride'),
            ),
          ],
          child: const MaterialApp(home: MainShell()),
        ),
      );

      // Map icon should be in bottom nav for bride
      expect(find.byIcon(Icons.map), findsOneWidget);
    });
  });
}
```

### Verification SQL (existante)
```sql
-- Verify current profiles roles
SELECT role, COUNT(*) as count
FROM profiles
GROUP BY role;

-- Expected: bride, professional, guest (if any)
```

## Definition of Done
- [ ] Criteres valides
- [ ] Helper function canAccessMap creee et testee
- [ ] MapPage verifie le role et bloque les guests
- [ ] Message d'acces refuse affiche pour guests
- [ ] Navigation bar ne montre pas map aux guests
- [ ] Tests unitaires pour canAccessMap
- [ ] Tests widget pour MapPage access control
- [ ] Tests widget pour navigation bar
- [ ] `flutter analyze --fatal-infos` passe
- [ ] Decision D-13 documentee respectee

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Faible

## Dependances
- Aucune

## Stories Dependantes
- Aucune

## Reference PRD
Decision D-13 : "Les Guests n'ont PAS acces a la map"
