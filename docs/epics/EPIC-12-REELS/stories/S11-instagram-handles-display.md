# Story S11: Display Pro Instagram Handles (Bride Only)

## Description
En tant que **bride**, je veux **voir les @ Instagram des professionnels de mon mariage**, afin de **les taguer facilement quand je partage mon reel sur les reseaux sociaux**.

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Display pro Instagram handles for bride

  Scenario: Section visible only for bride
    Given a bride viewing her reel detail page
    Then "Taguer les professionnels" section should be visible
    And it should be positioned below the preview player

    Given a guest viewing their reel detail page
    Then "Taguer les professionnels" section should NOT be visible

  Scenario: Display all pro handles from wedding
    Given a wedding with 3 professionals:
      | Professional   | Instagram Handle |
      | Photographe    | photo_pro        |
      | Fleuriste      | flower_artist    |
      | DJ             | dj_beats         |
    When bride views the section
    Then she should see:
      | displayed        |
      | @photo_pro       |
      | @flower_artist   |
      | @dj_beats        |
    And each handle should be displayed in a chip/pill style

  Scenario: Handle pros without Instagram
    Given a wedding with 3 professionals
    And only 2 have Instagram handles set
    When bride views the section
    Then only the 2 pros with Instagram should be listed
    And the pro without Instagram should not appear

  Scenario: Copy single handle
    Given the list of Instagram handles
    When bride taps on "@photo_pro"
    Then "@photo_pro" should be copied to clipboard
    And a brief toast "Copie !" should appear

  Scenario: Copy all handles
    Given 3 Instagram handles displayed
    When bride taps "Copier tout"
    Then all handles should be copied as "@photo_pro @flower_artist @dj_beats"
    And toast "3 comptes copies !" should appear

  Scenario: Empty state - no pros
    Given a wedding with no professionals assigned
    When bride views the reel detail page
    Then the Instagram section should show "Aucun professionnel assigne"
    And "Copier tout" button should be disabled/hidden

  Scenario: Empty state - no Instagram handles
    Given a wedding with 2 professionals
    And none have Instagram handles
    When bride views the section
    Then message "Aucun compte Instagram disponible" should appear
    And suggestion "Demandez a vos pros d'ajouter leur Instagram" could appear

  Scenario: Pro type displayed
    Given a pro with Instagram "@photo_pro" and type "photographer"
    When displayed
    Then it should show "@photo_pro" with label "Photographe" or icon
    And this helps bride identify which pro is which
```

## Fichiers Concernes

### A Creer
- `lib/features/reels/presentation/widgets/pro_instagram_section.dart`
- `lib/features/reels/domain/usecases/get_wedding_pro_instagrams.dart`
- `lib/features/reels/data/datasources/pro_instagram_datasource.dart`
- `test/features/reels/presentation/widgets/pro_instagram_section_test.dart`
- `test/features/reels/domain/usecases/get_wedding_pro_instagrams_test.dart`

### A Modifier
- `lib/features/reels/presentation/pages/reel_detail_page.dart` - Add Instagram section

## Notes Techniques

### Pro Instagram Entity
```dart
// lib/features/reels/domain/entities/pro_instagram.dart

class ProInstagram {
  final String professionalId;
  final String instagramHandle;
  final String? proType; // photographer, florist, dj, etc.
  final String? businessName;

  const ProInstagram({
    required this.professionalId,
    required this.instagramHandle,
    this.proType,
    this.businessName,
  });

  String get formattedHandle => '@$instagramHandle';
}
```

### Use Case Implementation
```dart
// lib/features/reels/domain/usecases/get_wedding_pro_instagrams.dart

class GetWeddingProInstagramsUseCase {
  final ProInstagramDatasource _datasource;

  GetWeddingProInstagramsUseCase(this._datasource);

  Future<List<ProInstagram>> execute(String weddingId) async {
    return _datasource.getProInstagramsForWedding(weddingId);
  }
}
```

### Datasource Implementation
```dart
// lib/features/reels/data/datasources/pro_instagram_datasource.dart

class ProInstagramDatasource {
  final SupabaseClient _client;

  ProInstagramDatasource(this._client);

  Future<List<ProInstagram>> getProInstagramsForWedding(String weddingId) async {
    // Query wedding_participants + professional_details
    final response = await _client
      .from('wedding_participants')
      .select('''
        professional_id,
        professional_details!inner(
          id,
          instagram_handle,
          professional_type,
          business_name
        )
      ''')
      .eq('wedding_id', weddingId)
      .not('professional_details.instagram_handle', 'is', null);

    return (response as List)
      .map((row) => ProInstagram(
        professionalId: row['professional_id'],
        instagramHandle: row['professional_details']['instagram_handle'],
        proType: row['professional_details']['professional_type'],
        businessName: row['professional_details']['business_name'],
      ))
      .toList();
  }
}
```

### Instagram Section Widget
```dart
// lib/features/reels/presentation/widgets/pro_instagram_section.dart

class ProInstagramSection extends ConsumerWidget {
  final String weddingId;

  const ProInstagramSection({required this.weddingId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prosAsync = ref.watch(weddingProInstagramsProvider(weddingId));

    return prosAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (pros) {
        if (pros.isEmpty) {
          return _buildEmptyState(context);
        }
        return _buildHandlesList(context, pros);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Taguer les professionnels',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Aucun compte Instagram disponible',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandlesList(BuildContext context, List<ProInstagram> pros) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Taguer les professionnels',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton.icon(
                onPressed: () => _copyAll(context, pros),
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copier tout'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Taguez ces pros quand vous partagez votre reel',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pros.map((pro) => _buildHandleChip(context, pro)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHandleChip(BuildContext context, ProInstagram pro) {
    return ActionChip(
      avatar: pro.proType != null
        ? Icon(_getProTypeIcon(pro.proType!), size: 16)
        : null,
      label: Text(pro.formattedHandle),
      onPressed: () => _copySingle(context, pro),
    );
  }

  IconData _getProTypeIcon(String proType) {
    switch (proType.toLowerCase()) {
      case 'photographer':
        return Icons.camera_alt;
      case 'florist':
        return Icons.local_florist;
      case 'dj':
        return Icons.music_note;
      case 'caterer':
        return Icons.restaurant;
      case 'videographer':
        return Icons.videocam;
      default:
        return Icons.person;
    }
  }

  void _copySingle(BuildContext context, ProInstagram pro) {
    Clipboard.setData(ClipboardData(text: pro.formattedHandle));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copie !'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _copyAll(BuildContext context, List<ProInstagram> pros) {
    final allHandles = pros.map((p) => p.formattedHandle).join(' ');
    Clipboard.setData(ClipboardData(text: allHandles));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${pros.length} comptes copies !'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
```

### Integration in ReelDetailPage
```dart
// In lib/features/reels/presentation/pages/reel_detail_page.dart

@override
Widget build(BuildContext context, WidgetRef ref) {
  final user = ref.watch(currentUserProvider);
  final isBride = user.value?.role == UserRole.bride;

  return Scaffold(
    // ...
    body: Column(
      children: [
        // Preview player
        ReelPreviewPlayer(previewUrl: previewUrl),

        // Download button
        ReelDownloadButton(reelId: reelId, outputPath: outputPath),

        // Instagram section - BRIDE ONLY
        if (isBride)
          ProInstagramSection(weddingId: reel.weddingId),
      ],
    ),
  );
}
```

### Provider
```dart
// lib/features/reels/presentation/providers/pro_instagram_provider.dart

@riverpod
Future<List<ProInstagram>> weddingProInstagrams(
  WeddingProInstagramsRef ref,
  String weddingId,
) async {
  final useCase = ref.watch(getWeddingProInstagramsUseCaseProvider);
  return useCase.execute(weddingId);
}
```

## Definition of Done
- [ ] Criteres d'acceptance valides
- [ ] Tests unitaires GetWeddingProInstagramsUseCase
- [ ] Tests widget ProInstagramSection
- [ ] Section visible only for bride
- [ ] All pro handles displayed correctly
- [ ] "Copy all" copies all handles with space separator
- [ ] Individual handle tap copies single handle
- [ ] Empty state handled gracefully
- [ ] Pro type icons displayed
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Faible

## Dependances
- None (independent, uses existing wedding_participants data)

## Stories Dependantes
- None (enhancement feature)
