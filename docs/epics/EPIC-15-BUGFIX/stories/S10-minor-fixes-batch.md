# S10 - Fixes mineurs batch

> **Epic** : EPIC-15-BUGFIX
> **Domaine** : MULTI (UI + DATA)
> **Complexite** : M (Medium - 6 points)
> **Dependances** : Aucune
> **Source bugs** : BUG-08 (onglet marketplace messagerie pro), BUG-11 (chat prenom + border radius)
> **Status** : Draft

---

## Contexte

Trois corrections mineures groupees dans une seule story car elles sont chacune trop petites pour justifier une story individuelle, mais necessaires pour la coherence de l'app avant push sur les stores.

1. **Onglet Marketplace visible cote pro dans la messagerie** : Les professionnels n'ont pas acces au marketplace (reserve aux brides). L'onglet "Marketplace" dans `messages_page.dart` ne devrait pas apparaitre pour eux.

2. **Chat prenom "Unknown" dans les conversations marketplace** : Le repository marketplace chat fait un JOIN sur `profiles.full_name` (ligne 294 de `supabase_marketplace_chat_repository.dart`), mais certains profils peuvent avoir `full_name = NULL` en base, ce qui affiche "Unknown" au lieu du vrai prenom. Le fallback doit aller chercher `first_name` ou le role comme dernier recours.

3. **Border radius excessif sur les images produits marketplace** : Les cards listing (`listing_card.dart`) et la page detail listing (`listing_detail_page.dart`) utilisent des `BorderRadius.circular(12)` et `BorderRadius.circular(16)` sur les conteneurs d'images. Les images produits doivent avoir un border radius de 4px maximum pour rester coherentes avec le style editorial du marketplace.

---

## Scope

### In scope
- Cacher le chip "Marketplace" dans `messages_page.dart` si l'utilisateur est un professionnel
- Ameliorer l'affichage du nom dans les conversations marketplace
- Reduire le border radius des images produits dans listing card et listing detail page

### Out of scope
- Refonte de la page messagerie
- Changement de la logique de chat marketplace
- Redesign global du marketplace

---

## Fichiers concernes

| Fichier | Modification |
|---------|-------------|
| `lib/core/design/lynewed_borders.dart` | **CREER** `borderRadiusXs` constant |
| `lib/features/chat/presentation/pages/messages_page.dart` | Conditionner l'affichage du chip "Marketplace" sur `!isProfessional` via BlocBuilder |
| `lib/features/marketplace/data/repositories/supabase_marketplace_chat_repository.dart` | Ameliorer le fallback du nom (`full_name` -> `first_name` -> role) |
| `lib/features/marketplace/presentation/widgets/listing_card.dart` | Reduire `borderRadius` du conteneur card de 12 a 4 |
| `lib/features/marketplace/presentation/pages/listing_detail_page.dart` | Reduire `borderRadius` du conteneur image de 16 a 4 |
| `lib/features/marketplace/presentation/pages/seller_dashboard_page.dart` | Reduire `borderRadius` des images produit de 12 a 4 (ligne 670) |
| `test/features/chat/presentation/pages/messages_page_test.dart` | **CREER** fichier + tests chip Marketplace cache pour pro |
| `test/features/marketplace/data/repositories/supabase_marketplace_chat_repository_test.dart` | **CREER** fichier + tests fallback nom |
| `test/features/marketplace/presentation/widgets/listing_card_test.dart` | Test : border radius coherent |

---

## Criteres d'acceptation

### AC-0 : Design System et fichiers de tests prepares

```gherkin
Given the Design System file lynewed_borders.dart
When developers need a borderRadius for xs size (4px)
Then a constant borderRadiusXs is available
And it is defined as BorderRadius.all(Radius.circular(xs))

Given the test suite for chat feature
When testing messages_page conditional rendering
Then a test file messages_page_test.dart exists with proper setup
And it includes mocks for AuthCubit and ConversationsNotifier

Given the test suite for marketplace feature
When testing chat repository name fallback
Then a test file supabase_marketplace_chat_repository_test.dart exists
And it includes mocks for Supabase client
```

**Implementation** :

**1. Creer `borderRadiusXs` dans `lib/core/design/lynewed_borders.dart`** :

Ajouter apres ligne 22 :
```dart
static const BorderRadius borderRadiusXs = BorderRadius.all(Radius.circular(xs));
```

**2. Creer `test/features/chat/presentation/pages/messages_page_test.dart`** :

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed/features/auth/domain/entities/profile.dart';
import 'package:lynewed/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:lynewed/features/auth/presentation/bloc/auth_state.dart';
import 'package:lynewed/features/chat/presentation/pages/messages_page.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  group('MessagesPage - Tab Visibility', () {
    late MockAuthCubit mockAuthCubit;

    setUp(() {
      mockAuthCubit = MockAuthCubit();
    });

    Widget buildTestWidget(AuthState authState) {
      when(() => mockAuthCubit.state).thenReturn(authState);
      return MaterialApp(
        home: BlocProvider<AuthCubit>.value(
          value: mockAuthCubit,
          child: const MessagesPage(),
        ),
      );
    }

    testWidgets('should hide Marketplace chip for professional user', (tester) async {
      final professionalProfile = Profile(
        id: 'pro-123',
        role: 'professional',
        fullName: 'John Doe',
      );

      await tester.pumpWidget(buildTestWidget(Authenticated(profile: professionalProfile)));
      await tester.pumpAndSettle();

      expect(find.text('Marketplace'), findsNothing);
      expect(find.text('Messages'), findsOneWidget);
      expect(find.text('Wedding'), findsOneWidget);
    });

    testWidgets('should show Marketplace chip for bride user', (tester) async {
      final brideProfile = Profile(
        id: 'bride-123',
        role: 'bride',
        fullName: 'Jane Doe',
      );

      await tester.pumpWidget(buildTestWidget(Authenticated(profile: brideProfile)));
      await tester.pumpAndSettle();

      expect(find.text('Marketplace'), findsOneWidget);
      expect(find.text('Messages'), findsOneWidget);
      expect(find.text('Wedding'), findsOneWidget);
    });
  });
}
```

**3. Creer `test/features/marketplace/data/repositories/supabase_marketplace_chat_repository_test.dart`** :

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed/features/marketplace/data/repositories/supabase_marketplace_chat_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder {}
class MockPostgrestBuilder extends Mock implements PostgrestBuilder {}

void main() {
  group('SupabaseMarketplaceChatRepository - Name Fallback', () {
    late SupabaseMarketplaceChatRepository repository;
    late MockSupabaseClient mockSupabaseClient;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      repository = SupabaseMarketplaceChatRepository(mockSupabaseClient);
    });

    test('should display full_name when available', () async {
      // Mock response avec full_name
      final mockResponse = {
        'id': 'conv-1',
        'other_user_id': 'user-1',
        'profiles': {'full_name': 'Sarah Johnson', 'first_name': 'Sarah', 'role': 'bride'},
      };

      // Test parsing
      final result = repository.parseConversation(mockResponse);
      expect(result.otherUserName, 'Sarah Johnson');
    });

    test('should fallback to first_name when full_name is null', () async {
      final mockResponse = {
        'id': 'conv-1',
        'other_user_id': 'user-1',
        'profiles': {'full_name': null, 'first_name': 'Sarah', 'role': 'bride'},
      };

      final result = repository.parseConversation(mockResponse);
      expect(result.otherUserName, 'Sarah');
    });

    test('should fallback to "User" when both names are null', () async {
      final mockResponse = {
        'id': 'conv-1',
        'other_user_id': 'user-1',
        'profiles': {'full_name': null, 'first_name': null, 'role': 'bride'},
      };

      final result = repository.parseConversation(mockResponse);
      expect(result.otherUserName, 'User');
    });
  });
}
```

---

### AC-1 : Onglet Marketplace cache dans la messagerie cote pro

```gherkin
Given a professional user viewing the messages page
When the tab selector is rendered
Then the "Marketplace" chip is NOT visible
And only "Messages" and "Wedding" chips are displayed

Given a bride user viewing the messages page
When the tab selector is rendered
Then all three chips "Messages", "Wedding", "Marketplace" are visible
And the Marketplace chip shows the unread count if applicable
```

**Implementation** :

**PROBLEME DE L'APPROCHE INITIALE** :
- ❌ Requête Supabase directe dans `initState` : contourne Clean Architecture
- ❌ Non testable : nécessite mock Supabase au lieu de mock AuthCubit
- ❌ Ignore AuthCubit : le profil est **DÉJÀ DISPONIBLE** via `AuthState.profile`
- ❌ setState inutile : un BlocBuilder réactif suffit

**APPROCHE CORRECTE (Pattern Clean Architecture du projet)** :

Le profil utilisateur (incluant le `role`) est **déjà disponible** via `AuthCubit`. Pattern observé dans `lib/features/profile/presentation/pages/profile_page.dart` :

```dart
BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    return switch (state) {
      Authenticated(:final profile) when profile != null => // ...
    };
  },
)
```

**Implementation dans `messages_page.dart`** :

Modifier la méthode `_buildTabSelector` pour recevoir le `role` en paramètre :

```dart
// 1. Modifier signature de _buildTabSelector
Widget _buildTabSelector(ConversationsLoaded state, String? userRole) {
  final isProfessional = userRole == 'professional';

  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
    child: Row(
      children: [
        LynewedChip(
          label: 'Messages',
          selected: _selectedTab == 0,
          onSelected: (_) => setState(() => _selectedTab = 0),
          count: state.privateUnreadCount > 0 ? state.privateUnreadCount : null,
        ),
        const SizedBox(width: 8),
        LynewedChip(
          label: 'Wedding',
          selected: _selectedTab == 1,
          onSelected: (_) => setState(() => _selectedTab = 1),
          count: state.weddingUnreadCount > 0 ? state.weddingUnreadCount : null,
        ),
        // ⚠️ Marketplace chip visible UNIQUEMENT pour les brides
        if (!isProfessional) ...[
          const SizedBox(width: 8),
          LynewedChip(
            label: 'Marketplace',
            selected: _selectedTab == 2,
            onSelected: (_) => setState(() => _selectedTab = 2),
            count: _marketplaceUnreadCount > 0 ? _marketplaceUnreadCount : null,
          ),
        ],
      ],
    ),
  );
}

// 2. Dans build(), wrapper le body avec BlocBuilder pour obtenir le role
@override
Widget build(BuildContext context) {
  return BlocBuilder<AuthCubit, AuthState>(
    builder: (context, authState) {
      final userRole = authState is Authenticated ? authState.profile?.role : null;

      return Scaffold(
        appBar: AppBar(title: const Text('Messages')),
        body: BlocBuilder<ConversationsNotifier, ConversationsState>(
          bloc: _notifier,
          builder: (context, conversationsState) {
            return switch (conversationsState) {
              ConversationsLoaded(:final state) => Column(
                children: [
                  _buildTabSelector(state, userRole), // <-- Passer userRole
                  Expanded(child: _buildContent(state)),
                ],
              ),
              ConversationsLoading() => const Center(child: CircularProgressIndicator()),
              ConversationsError(:final message) => Center(child: Text(message)),
            };
          },
        ),
      );
    },
  );
}
```

**Justification** :
- ✅ **Clean Architecture** : Utilise AuthCubit (couche présentation) au lieu de requête DB directe
- ✅ **Testable** : Mock `AuthCubit.state` trivial vs mock Supabase complexe
- ✅ **Réactif** : Si le profil change (edge case), le UI se met à jour automatiquement
- ✅ **Pattern projet** : Identique à `profile_page.dart`, `home_brides_page.dart`, etc.

---

### AC-2 : Prenom reel affiche dans les conversations marketplace

```gherkin
Given a marketplace conversation where the other user has full_name set in their profile
When the conversation list is displayed
Then the other user's full_name is shown (e.g. "Sarah Johnson")

Given a marketplace conversation where the other user has full_name = NULL
When the conversation list is displayed
Then a meaningful fallback is shown instead of "Unknown"
And the fallback uses first_name from the profile if available
```

**Implementation** :
- Dans `supabase_marketplace_chat_repository.dart`, methode `getConversations` (ligne 292-295)
- Modifier la requete `profiles` pour inclure plus de champs :
  ```dart
  .select('id, full_name, first_name, avatar_url, role')
  ```
- Modifier le fallback ligne 311 :
  ```dart
  otherUserName: profile?['full_name'] as String?
      ?? profile?['first_name'] as String?
      ?? 'User',
  ```
- Cela garantit qu'on affiche toujours un nom lisible

**Note** : Le header de la page chat marketplace (`marketplace_chat_page.dart:610`) utilise `widget.otherUserName` qui est passe depuis la conversation tile. Le fix dans le repository corrige donc l'affichage partout.

---

### AC-3 : Border radius coherent sur les images produits marketplace

```gherkin
Given the marketplace feed page with listing cards
When listing cards are rendered with product images
Then the card container has a borderRadius of 4px maximum
And the product image inside has no additional border radius (clipped by container)

Given the listing detail page with a product photo gallery
When the photo indicator badge is displayed
Then the badge overlay keeps its own borderRadius (not affected)
And the main image container has a borderRadius of 4px maximum
```

**Justification Design System** :

D'apres `lib/core/design/lynewed_borders.dart` :
- `xs = 4.0` : Utilise pour items, chips, cards (commentaire ligne 12 : "DS v3: items, chips, cards")
- `lg = 12.0` : Utilise pour les border radius generaux

**Decision** : Les images produits doivent utiliser `LynewedBorders.borderRadiusXs` (4px) au lieu de `lg` (12px) pour respecter le design system v3 et obtenir un style editorial plus sobre, coherent avec les specifications de BUG-11. Les badges, pills et boutons conservent leurs `borderRadius` propres (12px pour les badges pills est correct).

**⚠️ PREREQUIS** : AC-0 doit avoir créé `LynewedBorders.borderRadiusXs` dans le Design System.

**Implementation** :

**`listing_card.dart`** :
- Ligne 57 : `BorderRadius.circular(12)` -> `LynewedBorders.borderRadiusXs` (conteneur principal de la card)
- Ligne 176 : Conserver `BorderRadius.circular(12)` (badge condition - c'est un badge pill, pas une image)

**`listing_detail_page.dart`** :
- Ligne 521 : Ce borderRadius est sur le badge indicateur de page ("1 / 5"), PAS sur l'image. Conserver le radius actuel.
- Verifier que le conteneur parent des images n'a pas de borderRadius excessif. Si l'image est plein ecran dans un PageView, aucun border radius n'est necessaire.

**`seller_dashboard_page.dart`** :
- Ligne 510 : `BorderRadius.circular(12)` -> `LynewedBorders.borderRadiusXs` (conteneur card listing)
- Ligne 670 : `BorderRadius.circular(8)` -> `LynewedBorders.borderRadiusXs` (thumbnail image)
- Lignes 564, 595, 628 : `BorderRadius.circular(12)` -> Conserver (badges pills "pending offers", "generate label", "messages")
- Ligne 369 : `BorderRadius.circular(12)` -> Conserver (earnings section - conteneur stats, pas une image)
- Ligne 706 : `BorderRadius.circular(4)` -> OK deja conforme (status badge)

**Regle** : Seules les IMAGES PRODUITS et les CONTENEURS DE CARDS sont concernees (passage a `LynewedBorders.borderRadiusXs`). Les badges, boutons, et conteneurs de stats conservent leurs border radius actuels.

---

## Tests requis

### Unit tests - `supabase_marketplace_chat_repository_test.dart`

| Test | Description |
|------|-------------|
| `should display full_name when available` | Profile avec full_name -> nom affiche |
| `should fallback to first_name when full_name is null` | Profile avec full_name=null, first_name="Sarah" -> "Sarah" |
| `should fallback to "User" when both names are null` | Profile sans nom -> "User" |

### Widget tests - `messages_page_test.dart`

| Test | Description |
|------|-------------|
| `should hide Marketplace chip for professional user` | Mock auth pro -> pas de chip Marketplace |
| `should show Marketplace chip for bride user` | Mock auth bride -> chip Marketplace visible |
| `should show all 3 chips for bride user` | Verifier "Messages", "Wedding", "Marketplace" presents |

### Widget tests - `listing_card_test.dart`

| Test | Description |
|------|-------------|
| `should have borderRadius of 4 on card container` | Verifier decoration du Container principal |
| `should clip product image with card borderRadius` | Verifier `Clip.antiAlias` |

---

## Plan d'implementation

**ORDRE CRITIQUE** : AC-0 en PREMIER (dépendances pour tests et code)

1. **AC-0 SETUP** (PREREQUIS) :
   - Créer `LynewedBorders.borderRadiusXs` dans Design System
   - Créer `test/features/chat/presentation/pages/messages_page_test.dart` avec setup mocks
   - Créer `test/features/marketplace/data/repositories/supabase_marketplace_chat_repository_test.dart` avec setup mocks

2. **RED** : Ecrire les tests pour AC-1, AC-2, AC-3 (fichiers créés en AC-0)

3. **GREEN** :
   - AC-1 : `messages_page.dart` : Wrapper build avec `BlocBuilder<AuthCubit>`, modifier `_buildTabSelector` pour recevoir `userRole`, condition sur chip Marketplace
   - AC-2 : `supabase_marketplace_chat_repository.dart` : Enrichir la requete profils et le fallback nom
   - AC-3 : Reduire borderRadius images produits (utiliser `LynewedBorders.borderRadiusXs` créé en AC-0) :
     - `listing_card.dart` ligne 57 : 12 -> borderRadiusXs
     - `seller_dashboard_page.dart` ligne 510 : 12 -> borderRadiusXs
     - `seller_dashboard_page.dart` ligne 670 : 8 -> borderRadiusXs

4. **REFACTOR** : Nettoyer, verifier coherence, uniformiser import Design System

---

## Estimation

| Element | Effort |
|---------|--------|
| AC-0 : Créer borderRadiusXs dans Design System | 5 min |
| AC-0 : Créer fichier test messages_page_test.dart (setup mocks) | 25 min |
| AC-0 : Créer fichier test supabase_marketplace_chat_repository_test.dart (setup mocks) | 20 min |
| Tests AC-1 (chip conditionnel) | 15 min |
| Tests AC-2 (fallback nom) | 15 min |
| Tests AC-3 (border radius) | 10 min |
| Implementation AC-1 (BlocBuilder + userRole param) | 30 min |
| Implementation AC-2 (fallback nom) | 15 min |
| Implementation AC-3 (border radius - 3 fichiers) | 20 min |
| Review adversariale + polish | 20 min |
| **Total** | **~2h55** |

**Justification passage de 3 SP à 6 SP** :
- Création de 2 fichiers de tests from scratch (non mentionné dans version initiale)
- Ajout constant Design System (non existante)
- Pattern AuthCubit plus complexe que setState simple (mais correct architecturalement)

---

## Risques

| Risque | Probabilite | Mitigation |
|--------|-------------|------------|
| `LynewedBorders.borderRadiusXs` n'existe pas dans Design System actuel | ✅ RESOLU | AC-0 crée cette constante AVANT les autres AC |
| Fichiers de tests n'existent pas | ✅ RESOLU | AC-0 crée les fichiers avec setup AVANT RED phase |
| Pattern AuthCubit plus complexe que setState simple | Faible | Exemples existants dans `profile_page.dart`, `home_brides_page.dart` - pattern standard du projet |
| Certains profils n'ont ni `full_name` ni `first_name` en base | Moyen | Le fallback "User" est explicite et non-ambigu |
| Reduire le borderRadius casse l'harmonie visuelle des cards | Faible | 4px est le standard demande par Thierry, coherent avec le design system |

---

## Definition of Done

- [ ] AC-0 : `LynewedBorders.borderRadiusXs` créé dans Design System
- [ ] AC-0 : `messages_page_test.dart` créé avec setup mocks AuthCubit
- [ ] AC-0 : `supabase_marketplace_chat_repository_test.dart` créé avec setup mocks
- [ ] AC-1 : Chip Marketplace invisible pour les pros, visible pour les brides (via BlocBuilder AuthCubit)
- [ ] AC-2 : Prenom reel affiche, fallback "User" si aucun nom
- [ ] AC-3 : Images produits avec `LynewedBorders.borderRadiusXs` (4px)
- [ ] `flutter test --no-pub test/features/chat/presentation/pages/messages_page_test.dart` : 0 echecs
- [ ] `flutter test --no-pub test/features/marketplace/data/repositories/supabase_marketplace_chat_repository_test.dart` : 0 echecs
- [ ] `flutter test --no-pub test/features/marketplace/` : 0 echecs
- [ ] `flutter analyze --fatal-infos` : 0 warnings sur les fichiers modifies
- [ ] Pas de regression sur les tests existants
- [ ] Code review adversariale effectuee
