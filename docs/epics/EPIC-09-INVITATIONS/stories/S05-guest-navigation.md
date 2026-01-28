# Story S05: Implementer navigation Guest-specific (3 tabs)

## Description
En tant que guest, je veux avoir une interface dediee avec 3 onglets (Album, Chat, Profil), afin d'acceder uniquement aux fonctionnalites pertinentes pour moi.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the user is logged in with role='guest' And the user belongs to wedding of "Marie" When the guest home page loads Then a bottom navigation bar should be visible And it should have exactly 3 tabs: Album, Chat, Profil And the Album tab should be selected by default
- [ ] Given the user is on the Guest home page When the user taps the Album tab Then the guest's album page should load And it should show "Mes photos et videos" header And a button to add photos/videos should be visible
- [ ] Given the user is on the Guest home page When the user taps the Chat tab Then the wedding team chat should load And the chat room name should be "Groupe du mariage" And the user should see messages from other guests and bride
- [ ] Given the user is on the Guest home page When the user taps the Profil tab Then the guest profile page should load And the user's name and email should be displayed And a "Passer en compte Mariee" button should be visible
- [ ] Given the user is logged in as guest When the user tries to navigate to "/map" directly Then the user should be redirected to the Guest home page And a message "Cette fonctionnalite n'est pas disponible pour les invites" should appear
- [ ] Given the user is logged in as guest When the user tries to navigate to "/feed" directly Then the user should be redirected to the Guest home page
- [ ] Given the user is logged in as guest When the user tries to navigate to "/wishlist" directly Then the user should be redirected to the Guest home page
- [ ] Given the user is on any Guest tab Then the app bar should display "Mariage de Marie"

## Fichiers Concernes

### A Creer
- `lib/features/guest/presentation/pages/guest_home_page.dart`
- `lib/features/guest/presentation/pages/guest_album_page.dart`
- `lib/features/guest/presentation/pages/guest_chat_page.dart`
- `lib/features/guest/presentation/pages/guest_profile_page.dart`
- `lib/features/guest/presentation/widgets/guest_nav_bar.dart`
- `lib/features/guest/domain/entities/guest_state.dart`
- `lib/features/guest/presentation/providers/guest_home_provider.dart`

### A Modifier
- `lib/core/navigation/app_router.dart` (routes guest + guards)
- `lib/core/navigation/route_guards.dart` (GuestGuard)

## Notes Techniques

### Guest Home Page avec IndexedStack

```dart
// lib/features/guest/presentation/pages/guest_home_page.dart
class GuestHomePage extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(guestNavIndexProvider);
    final weddingInfo = ref.watch(guestWeddingInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Mariage de ${weddingInfo.brideName}'),
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: currentIndex,
        children: const [
          GuestAlbumPage(),
          GuestChatPage(),
          GuestProfilePage(),
        ],
      ),
      bottomNavigationBar: GuestNavBar(
        currentIndex: currentIndex,
        onTap: (index) => ref.read(guestNavIndexProvider.notifier).state = index,
      ),
    );
  }
}
```

### Guest Nav Bar

```dart
// lib/features/guest/presentation/widgets/guest_nav_bar.dart
class GuestNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.photo_library_outlined),
          activeIcon: Icon(Icons.photo_library),
          label: 'Album',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          activeIcon: Icon(Icons.chat_bubble),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}
```

### Route Guard pour Guest

```dart
// lib/core/navigation/route_guards.dart
class GuestRouteGuard extends RouteGuard {
  @override
  Future<String?> canAccess(BuildContext context, GoRouterState state) async {
    final user = ref.read(currentUserProvider);

    if (user?.role != 'guest') {
      // Not a guest, redirect to normal home
      return '/home';
    }

    // Block forbidden routes for guests
    final forbiddenRoutes = ['/map', '/feed', '/wishlist', '/dashboard'];
    if (forbiddenRoutes.any((r) => state.matchedLocation.startsWith(r))) {
      // Show message and redirect
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cette fonctionnalite n\'est pas disponible pour les invites'),
        ),
      );
      return '/guest-home';
    }

    return null; // Allow access
  }
}
```

### Router Configuration

```dart
// Dans app_router.dart
GoRoute(
  path: '/guest-home',
  builder: (context, state) => const GuestHomePage(),
  redirect: (context, state) {
    final user = ref.read(currentUserProvider);
    if (user?.role != 'guest') return '/home';
    return null;
  },
),
```

### Placeholder Album Page (implementation complete dans EPIC-10)

```dart
// lib/features/guest/presentation/pages/guest_album_page.dart
class GuestAlbumPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('Mes photos et videos'),
          SizedBox(height: 8),
          Text(
            'Ajoutez vos photos du mariage !',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: null, // TODO: EPIC-10
            icon: Icon(Icons.add_photo_alternate),
            label: Text('Ajouter photo/video'),
          ),
        ],
      ),
    );
  }
}
```

## Definition of Done

- [ ] Criteres valides
- [ ] Tests unitaires (GuestRouteGuard)
- [ ] Tests widget (GuestHomePage, GuestNavBar)
- [ ] Tests integration (navigation entre tabs)
- [ ] Tests integration (blocage routes interdites)
- [ ] `flutter analyze --fatal-infos` passe
- [ ] Navigation fluide entre les 3 tabs
- [ ] Album page en placeholder (EPIC-10 pour implementation)

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Faible

## Dependances

- S04 (guest account creation - l'utilisateur doit etre cree)

## Stories Dependantes

- S09 (guest → bride upgrade - dans le profil)
- S11 (chat integration - tab Chat)
- EPIC-10 (photos/videos - tab Album complet)
