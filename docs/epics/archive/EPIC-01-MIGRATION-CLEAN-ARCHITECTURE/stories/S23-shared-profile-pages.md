# Story S23: Shared - Profile Pages

## Description

En tant que developpeur, je veux migrer les pages de profil partagees vers Clean Architecture afin d'avoir une gestion de profil coherente pour Brides et Pros.

## Criteres d'Acceptance (Gherkin)

- [ ] Given `ProfileBridesAndProWidget` When je la migre Then elle utilise AuthCubit et le design system

- [ ] Given le profil utilisateur When je l'affiche Then toutes les informations sont correctement presentees

- [ ] Given les actions profil When je les execute Then elles fonctionnent (edit, logout, delete)

- [ ] Given la page Pro Details When je la migre Then elle affiche les details du professionnel

## Fichiers Concernes

### Pages Legacy a Migrer
- `lib/pages/shared/profile_brides_and_pro/profile_brides_and_pro_widget.dart`
- `lib/pages/shared/profile_brides_and_pro/profile_brides_and_pro_model.dart`
- `lib/pages/shared/pro_details/pro_details_widget.dart`
- `lib/pages/shared/pro_details/pro_details_model.dart`

### A Creer
- `lib/features/profile/profile.dart` - Barrel export (nouveau module)
- `lib/features/profile/presentation/pages/profile_page.dart`
- `lib/features/profile/presentation/pages/pro_details_page.dart`
- `lib/features/profile/presentation/widgets/profile_header.dart`
- `lib/features/profile/presentation/widgets/profile_menu_item.dart`

## Notes Techniques

### Structure Module Profile
```
lib/features/profile/
├── profile.dart                   # Barrel
├── domain/
│   └── entities/
│       └── profile_menu_item.dart
└── presentation/
    ├── pages/
    │   ├── profile_page.dart      # Mon profil (bride/pro)
    │   └── pro_details_page.dart  # Voir profil pro
    └── widgets/
        ├── profile_header.dart
        ├── profile_menu_item.dart
        └── profile_stats.dart
```

### Profile Page
```dart
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const routeName = 'ProfilePage';
  static const routePath = '/profile';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return const Center(child: Text('Not authenticated'));
        }

        final profile = state.profile;
        if (profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => context.pushNamed(SettingsPage.routeName),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                ProfileHeader(profile: profile),
                const Divider(),
                _buildMenuSection(context, profile),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuSection(BuildContext context, UserProfile profile) {
    final items = profile.isBride
        ? _brideMenuItems(context)
        : _proMenuItems(context);

    return Column(
      children: items.map((item) => ProfileMenuItem(item: item)).toList(),
    );
  }

  List<ProfileMenuItemData> _brideMenuItems(BuildContext context) {
    return [
      ProfileMenuItemData(
        icon: Icons.favorite,
        title: 'My Favorites',
        onTap: () => context.pushNamed(FavProListPage.routeName),
      ),
      ProfileMenuItemData(
        icon: Icons.cake,
        title: 'My Wedding',
        onTap: () => context.pushNamed(MyWeddingPage.routeName),
      ),
      ProfileMenuItemData(
        icon: Icons.edit,
        title: 'Edit Profile',
        onTap: () => context.pushNamed(EditProfileBridesPage.routeName),
      ),
      ProfileMenuItemData(
        icon: Icons.help,
        title: 'Help & Support',
        onTap: () => context.pushNamed(SupportPage.routeName),
      ),
    ];
  }

  List<ProfileMenuItemData> _proMenuItems(BuildContext context) {
    return [
      ProfileMenuItemData(
        icon: Icons.dashboard,
        title: 'Dashboard',
        onTap: () => context.pushNamed(DashboardProPage.routeName),
      ),
      ProfileMenuItemData(
        icon: Icons.people,
        title: 'Who Saved Me',
        onTap: () => context.pushNamed(WishlistProPage.routeName),
      ),
      ProfileMenuItemData(
        icon: Icons.edit,
        title: 'Edit Profile',
        onTap: () => context.pushNamed(EditProfileProPage.routeName),
      ),
      ProfileMenuItemData(
        icon: Icons.help,
        title: 'Help & Support',
        onTap: () => context.pushNamed(SupportPage.routeName),
      ),
    ];
  }
}
```

### Profile Header Widget
```dart
class ProfileHeader extends StatelessWidget {
  final UserProfile profile;

  const ProfileHeader({required this.profile, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: profile.avatarUrl != null
                ? NetworkImage(profile.avatarUrl!)
                : null,
            child: profile.avatarUrl == null
                ? Text(
                    (profile.displayName ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(fontSize: 32),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            profile.displayName ?? 'User',
            style: context.textTheme.headlineSmall,
          ),
          if (profile.isProfessional && profile.profession != null)
            Text(
              profile.profession!,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.secondaryText,
              ),
            ),
          if (profile.bio != null) ...[
            const SizedBox(height: 8),
            Text(
              profile.bio!,
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
```

### Pro Details Page
```dart
class ProDetailsPage extends StatefulWidget {
  final String profileId;

  const ProDetailsPage({required this.profileId, super.key});

  static const routeName = 'ProDetailsPage';
  static const routePath = '/proDetails/:profileId';

  @override
  State<ProDetailsPage> createState() => _ProDetailsPageState();
}

class _ProDetailsPageState extends State<ProDetailsPage> {
  Map<String, dynamic>? _proDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProDetails();
  }

  Future<void> _loadProDetails() async {
    // Load from Supabase
    final details = await _fetchProDetails(widget.profileId);
    if (mounted) {
      setState(() {
        _proDetails = details;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_proDetails == null) {
      return const Scaffold(
        body: Center(child: Text('Professional not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Cover image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _proDetails!['cover_image_url'] != null
                  ? Image.network(
                      _proDetails!['cover_image_url'],
                      fit: BoxFit.cover,
                    )
                  : Container(color: context.colors.primary),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Profile info
                _buildProfileInfo(),
                // Portfolio
                _buildPortfolioSection(),
                // Contact button
                _buildContactButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LynewedButton(
        text: 'Contact',
        onPressed: () async {
          // Use chat module to open contact
          final chatRepo = getIt<ContactRepository>();
          final result = await chatRepo.prepareContactContext(widget.profileId);
          // Handle navigation based on result
        },
        width: double.infinity,
      ),
    );
  }
}
```

## Definition of Done

- [ ] ProfilePage migree et fonctionnelle
- [ ] ProDetailsPage migree et fonctionnelle
- [ ] Widgets partages (header, menu item)
- [ ] Integration avec AuthCubit
- [ ] Navigation vers edit/settings
- [ ] Tests widgets
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Faible

## Dependances

- S03 : Design system
- S04 : Navigation
- S13 : Auth - Presentation

## Stories Dependantes

- S31 : Bride - Edit profile
