# Story S35: Pro - Public Profile View

## Description

En tant que developpeur, je veux migrer la page Public Pro Profile vers Clean Architecture afin d'avoir une vue du profil public coherente.

## Criteres d'Acceptance (Gherkin)

- [ ] Given `PublicProProfileViewWidget` When je la migre Then elle utilise Clean Architecture

- [ ] Given le profil public When je l'affiche Then toutes les infos sont visibles

- [ ] Given les actions When je les utilise Then contact/save fonctionnent

## Fichiers Concernes

### Pages Legacy a Migrer
- `lib/pages/pro/public_pro_profile_view/public_pro_profile_view_widget.dart`
- `lib/pages/pro/public_pro_profile_view/public_pro_profile_view_model.dart`

### A Creer
- `lib/features/profile/presentation/pages/public_pro_profile_page.dart`

## Notes Techniques

Cette page est similaire a ProDetailsPage (S23) mais pour les pros qui voient leur propre profil public.

```dart
class PublicProProfilePage extends StatelessWidget {
  const PublicProProfilePage({super.key});

  static const routeName = 'PublicProProfile';
  static const routePath = '/publicProProfile';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated || state.profile == null) {
          return const Scaffold(
            body: Center(child: Text('Not authenticated')),
          );
        }

        final profile = state.profile!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Public Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.pushNamed(EditProfileProPage.routeName),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Cover image
                if (profile.coverImageUrl != null)
                  Image.network(
                    profile.coverImageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                // Profile info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: profile.avatarUrl != null
                            ? NetworkImage(profile.avatarUrl!)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.displayName ?? 'Professional',
                        style: context.textTheme.headlineSmall,
                      ),
                      if (profile.profession != null)
                        Text(
                          profile.profession!,
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: context.colors.primary,
                          ),
                        ),
                      if (profile.companyName != null)
                        Text(
                          profile.companyName!,
                          style: context.textTheme.bodyMedium,
                        ),
                      if (profile.bio != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          profile.bio!,
                          style: context.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                // Portfolio preview
                _buildPortfolioSection(context),
                // Hint
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    color: context.colors.primary.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: context.colors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This is how brides see your profile. Keep it updated!',
                              style: context.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPortfolioSection(BuildContext context) {
    // Load and display portfolio items
    return FutureBuilder(
      future: _loadPortfolio(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data as List<PortfolioItem>? ?? [];

        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.photo_library_outlined, size: 48),
                const SizedBox(height: 8),
                const Text('No portfolio items yet'),
                const SizedBox(height: 8),
                LynewedButton(
                  text: 'Add Photos',
                  type: LynewedButtonType.outline,
                  onPressed: () {
                    // Navigate to portfolio editor
                  },
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Portfolio',
                    style: context.textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to portfolio editor
                    },
                    child: const Text('Edit'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    items[index].thumbnailUrl ?? items[index].imageUrl,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<PortfolioItem>> _loadPortfolio() async {
    // Load portfolio from repository
    return [];
  }
}
```

## Definition of Done

- [ ] PublicProProfilePage migree
- [ ] Affichage du profil complet
- [ ] Portfolio preview
- [ ] Link vers edit profile
- [ ] Tests
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 3
**Complexite** : Faible
**Risque** : Faible

## Dependances

- S03 : Design system
- S13 : Auth - Presentation

## Stories Dependantes

- Aucune
