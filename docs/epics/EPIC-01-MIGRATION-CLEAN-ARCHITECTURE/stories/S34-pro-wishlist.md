# Story S34: Pro - Wishlist Page

## Description

En tant que developpeur, je veux migrer la page Wishlist Pro vers Clean Architecture afin d'afficher les brides qui ont sauvegarde ce professionnel.

## Criteres d'Acceptance (Gherkin)

- [ ] Given `WishlistProWidget` When je la migre Then elle utilise Clean Architecture

- [ ] Given la liste des brides When je l'affiche Then elle est chargee correctement

- [ ] Given une bride When je clique Then je peux la contacter ou voir son profil

## Fichiers Concernes

### Pages Legacy a Migrer
- `lib/pages/pro/wishlist_pro/wishlist_pro_widget.dart`
- `lib/pages/pro/wishlist_pro/wishlist_pro_model.dart`

### Actions Custom Code
- `lib/custom_code/actions/get_wishlisted_by_brides_action.dart`

### A Creer
- `lib/features/wishlist/presentation/pages/wishlist_pro_page.dart`

## Notes Techniques

### Wishlist Pro Page
```dart
class WishlistProPage extends StatefulWidget {
  const WishlistProPage({super.key});

  static const routeName = 'WishlistPro';
  static const routePath = '/wishlistPro';

  @override
  State<WishlistProPage> createState() => _WishlistProPageState();
}

class _WishlistProPageState extends State<WishlistProPage> {
  List<WishlistBride>? _brides;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client
          .rpc('get_wishlisted_by_brides');

      final brides = (response as List)
          .map((e) => WishlistBride.fromJson(e))
          .toList();

      setState(() {
        _brides = brides;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Who Saved Me'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _brides?.isEmpty == true
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadWishlist,
                  child: ListView.builder(
                    itemCount: _brides!.length,
                    itemBuilder: (context, index) {
                      final bride = _brides![index];
                      return _WishlistBrideTile(
                        bride: bride,
                        onTap: () => _openBrideProfile(bride),
                        onContact: () => _contactBride(bride),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No brides have saved you yet',
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Keep sharing your work to get noticed!',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  void _openBrideProfile(WishlistBride bride) {
    // Open bride profile if viewable
  }

  Future<void> _contactBride(WishlistBride bride) async {
    final contactRepo = getIt<ContactRepository>();
    final result = await contactRepo.prepareContactContext(bride.profileId);

    if (!mounted) return;

    result.when(
      success: (context) {
        if (context?.requiresContactRequest == true) {
          ContactRequestSheet.show(
            this.context,
            targetProfileId: bride.profileId,
            targetName: bride.displayName,
            source: ContactRequestSource.fromWishlist,
          );
        } else if (context?.canNavigateToChat == true) {
          this.context.pushNamed(
            ChatDetailsPage.routeName,
            pathParameters: {'roomId': context!.roomId!},
          );
        }
      },
      failure: (error) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
    );
  }
}

class WishlistBride {
  final String profileId;
  final String displayName;
  final String? avatarUrl;
  final DateTime savedAt;
  final String? weddingDate;
  final String? weddingLocation;

  const WishlistBride({
    required this.profileId,
    required this.displayName,
    this.avatarUrl,
    required this.savedAt,
    this.weddingDate,
    this.weddingLocation,
  });

  factory WishlistBride.fromJson(Map<String, dynamic> json) {
    return WishlistBride(
      profileId: json['profile_id'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      savedAt: DateTime.parse(json['saved_at'] as String),
      weddingDate: json['wedding_date'] as String?,
      weddingLocation: json['wedding_location'] as String?,
    );
  }
}

class _WishlistBrideTile extends StatelessWidget {
  final WishlistBride bride;
  final VoidCallback onTap;
  final VoidCallback onContact;

  const _WishlistBrideTile({
    required this.bride,
    required this.onTap,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: bride.avatarUrl != null
            ? NetworkImage(bride.avatarUrl!)
            : null,
        child: bride.avatarUrl == null
            ? Text(bride.displayName[0].toUpperCase())
            : null,
      ),
      title: Text(bride.displayName),
      subtitle: bride.weddingDate != null || bride.weddingLocation != null
          ? Text(
              [bride.weddingDate, bride.weddingLocation]
                  .whereType<String>()
                  .join(' - '),
            )
          : Text('Saved ${_formatDate(bride.savedAt)}'),
      trailing: IconButton(
        icon: const Icon(Icons.message_outlined),
        onPressed: onContact,
      ),
      onTap: onTap,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat('MMM d').format(date);
  }
}
```

## Definition of Done

- [ ] WishlistProPage migree
- [ ] Liste des brides affichee
- [ ] Contact bride fonctionnel
- [ ] Empty state
- [ ] Tests
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 3
**Complexite** : Faible
**Risque** : Faible

## Dependances

- S03 : Design system
- S07 : Chat (pour contact)

## Stories Dependantes

- Aucune
