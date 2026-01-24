# Story S18: My Wedding - Data Layer Completion

## Description

En tant que developpeur, je veux completer la couche data du module My Wedding afin d'avoir toutes les implementations pour les operations de mariage.

## Criteres d'Acceptance (Gherkin)

- [ ] Given `MyWeddingRepositoryImpl` existant When je l'analyse Then je liste les methodes manquantes

- [ ] Given le datasource When je verifie Then toutes les operations Supabase sont encapsulees

- [ ] Given les implementations When je les complete Then le repository est 100% implemente

- [ ] Given les tests When je les execute Then ils passent avec des mocks

## Fichiers Concernes

### Existants (a verifier/completer)
- `lib/features/my_wedding/data/repositories/my_wedding_repository_impl.dart`
- `lib/features/my_wedding/data/datasources/supabase_my_wedding_datasource.dart`

### A Creer si Manquants
- `lib/features/my_wedding/data/models/` - DTOs si necessaire

### Tests
- `test/features/my_wedding/data/repositories/my_wedding_repository_impl_test.dart`

## Notes Techniques

### Datasource Verification
Verifier que le datasource couvre toutes les tables :
- `wedding_pins` - Mariages
- `wedding_events` - Agenda
- `wedding_expenses` - Budget
- `wedding_guests` - Invites (si table existe)
- `inspiration_albums` - Albums
- `album_images` - Images
- `saved_posts` - Posts sauvegardes
- `wedding_team_participants` - Equipe

### Exemple Implementation
```dart
class SupabaseMyWeddingDatasource {
  final SupabaseClient _supabase;

  SupabaseMyWeddingDatasource(this._supabase);

  // Wedding Core
  Future<Map<String, dynamic>?> getMyWedding() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw NotAuthenticatedException();

    // Get bride profile ID first
    final profile = await _supabase
        .from('profiles')
        .select('id')
        .eq('auth_user_id', userId)
        .single();

    final response = await _supabase
        .from('wedding_pins')
        .select('''
          *,
          wedding_team:chat_room_participants(
            professional_profile_id,
            status,
            joined_at,
            profiles:professional_profile_id(
              id,
              display_name,
              avatar_url,
              profession
            )
          )
        ''')
        .eq('bride_profile_id', profile['id'])
        .maybeSingle();

    return response;
  }

  // Events
  Future<List<Map<String, dynamic>>> getWeddingEvents(String weddingId) async {
    final response = await _supabase
        .from('wedding_events')
        .select()
        .eq('wedding_id', weddingId)
        .order('event_date', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createWeddingEvent({
    required String weddingId,
    required String title,
    required DateTime eventDate,
    String? description,
    DateTime? eventEndDate,
    String? location,
    String? linkedProId,
    bool isPublic = false,
  }) async {
    final response = await _supabase
        .from('wedding_events')
        .insert({
          'wedding_id': weddingId,
          'title': title,
          'event_date': eventDate.toIso8601String(),
          'description': description,
          'event_end_date': eventEndDate?.toIso8601String(),
          'location': location,
          'linked_pro_id': linkedProId,
          'is_public': isPublic,
        })
        .select()
        .single();

    return response;
  }

  // Expenses
  Future<List<Map<String, dynamic>>> getWeddingExpenses(String weddingId) async {
    final response = await _supabase
        .from('wedding_expenses')
        .select()
        .eq('wedding_id', weddingId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Albums
  Future<List<Map<String, dynamic>>> getInspirationAlbums(String weddingId) async {
    final response = await _supabase
        .from('inspiration_albums')
        .select('''
          *,
          images:album_images(count),
          saved_posts:saved_posts(count)
        ''')
        .eq('wedding_id', weddingId)
        .order('sort_order', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createInspirationAlbum({
    required String weddingId,
    required String name,
    String? category,
    bool isPrivate = false,
  }) async {
    final response = await _supabase
        .from('inspiration_albums')
        .insert({
          'wedding_id': weddingId,
          'name': name,
          'category': category,
          'is_private': isPrivate,
        })
        .select()
        .single();

    return response;
  }

  // Team
  Future<List<Map<String, dynamic>>> getWeddingTeam(String weddingId) async {
    // Get team chat room
    final room = await _supabase
        .from('chat_rooms')
        .select('id')
        .eq('wedding_id', weddingId)
        .eq('room_type', 'wedding_team')
        .maybeSingle();

    if (room == null) return [];

    final response = await _supabase
        .from('chat_room_participants')
        .select('''
          *,
          profile:professional_profile_id(
            id,
            display_name,
            avatar_url,
            profession
          )
        ''')
        .eq('room_id', room['id'])
        .neq('role', 'bride');

    return List<Map<String, dynamic>>.from(response);
  }
}
```

### Repository Error Handling
```dart
class MyWeddingRepositoryImpl implements MyWeddingRepository {
  final SupabaseMyWeddingDatasource _datasource;

  MyWeddingRepositoryImpl(this._datasource);

  @override
  Future<RepositoryResult<WeddingOverview?>> getMyWedding() async {
    try {
      final data = await _datasource.getMyWedding();
      if (data == null) return const RepositoryResult.success(null);

      final wedding = WeddingOverview.fromJson(data);
      return RepositoryResult.success(wedding);
    } on NotAuthenticatedException {
      return const RepositoryResult.failure('Not authenticated');
    } on PostgrestException catch (e) {
      return RepositoryResult.failure(e.message);
    } catch (e) {
      return RepositoryResult.failure(e.toString());
    }
  }

  @override
  Future<RepositoryResult<List<WeddingEvent>>> getWeddingEvents({
    required String weddingId,
  }) async {
    try {
      final data = await _datasource.getWeddingEvents(weddingId);
      final events = data.map((e) => WeddingEvent.fromJson(e)).toList();
      return RepositoryResult.success(events);
    } on PostgrestException catch (e) {
      return RepositoryResult.failure(e.message);
    } catch (e) {
      return RepositoryResult.failure(e.toString());
    }
  }
  // ... autres methodes
}
```

## Definition of Done

- [ ] Datasource complet
- [ ] Repository 100% implemente
- [ ] DTOs/Models si necessaire
- [ ] Tests avec mocks
- [ ] Error handling coherent
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 8
**Complexite** : Elevee
**Risque** : Moyen

## Dependances

- S01 : Setup infrastructure
- S17 : My Wedding - Domain

## Stories Dependantes

- S19-S22 : Presentation stories
