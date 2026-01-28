# Story S28: Bride - Home Page

## Description

En tant que developpeur, je veux migrer la Home Page Bride vers Clean Architecture afin d'avoir une page d'accueil coherente et maintenable.

## Criteres d'Acceptance (Gherkin)

- [ ] Given `HomeBridesWidget` When je la migre Then elle utilise les modules Clean Architecture

- [ ] Given la home page When j'affiche Then les sections sont chargees (wedding, feed, map preview)

- [ ] Given la navigation bottom When je clique Then je navigue vers les bonnes pages

## Fichiers Concernes

### Pages Legacy a Migrer
- `lib/pages/bride/home_brides/home_brides_widget.dart`
- `lib/pages/bride/home_brides/home_brides_model.dart`

### A Creer
- `lib/features/home/home.dart` - Barrel
- `lib/features/home/presentation/pages/home_brides_page.dart`
- `lib/features/home/presentation/widgets/wedding_summary_card.dart`
- `lib/features/home/presentation/widgets/quick_actions_row.dart`

## Notes Techniques

### Home Brides Page
```dart
class HomeBridesPage extends StatelessWidget {
  const HomeBridesPage({super.key});

  static const routeName = 'HomeBrides';
  static const routePath = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refresh(context),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Header with greeting
                _buildHeader(context),
                // Wedding summary card
                const WeddingSummaryCard(),
                const SizedBox(height: 24),
                // Quick actions
                const QuickActionsRow(),
                const SizedBox(height: 24),
                // Feed preview
                _buildFeedPreview(context),
                const SizedBox(height: 24),
                // Map preview
                _buildMapPreview(context),
                const SizedBox(height: 80), // Bottom nav space
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BrideBottomNav(currentIndex: 0),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final name = state is Authenticated
            ? state.profile?.displayName ?? 'there'
            : 'there';

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $name',
                      style: context.textTheme.headlineSmall,
                    ),
                    Text(
                      _getGreetingSubtitle(),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              // Notification bell
              BlocBuilder<NotificationsCubit, NotificationsState>(
                builder: (context, state) {
                  return NotificationBadge(
                    count: state.unreadCount,
                    child: IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () => context.pushNamed(NotificationsPage.routeName),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeedPreview(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Discover Professionals',
                style: context.textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () => context.pushNamed(FeedBridesPage.routeName),
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: _FeedPreviewList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreview(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nearby Professionals',
                style: context.textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () => context.pushNamed(MapPage.routeName),
                child: const Text('Open Map'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: const LynewedMiniMap(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    // Refresh wedding data, feed, etc.
  }

  String _getGreetingSubtitle() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning!';
    if (hour < 17) return 'Good afternoon!';
    return 'Good evening!';
  }
}
```

### Wedding Summary Card
```dart
class WeddingSummaryCard extends StatelessWidget {
  const WeddingSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyWeddingCubit, MyWeddingState>(
      builder: (context, state) {
        final wedding = state.wedding;

        if (wedding == null) {
          return _buildNoWeddingCard(context);
        }

        return Card(
          margin: const EdgeInsets.all(16),
          child: InkWell(
            onTap: () => context.pushNamed(MyWeddingPage.routeName),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (wedding.coverImageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            wedding.coverImageUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: context.colors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.cake),
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Wedding',
                              style: context.textTheme.titleMedium,
                            ),
                            if (wedding.eventDate != null)
                              Text(
                                _formatCountdown(wedding.eventDate!),
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  if (wedding.venueLabel != null) ...[
                    const Divider(),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            wedding.venueLabel!,
                            style: context.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoWeddingCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.cake_outlined, size: 48),
            const SizedBox(height: 8),
            Text(
              'Plan your wedding',
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Set up your wedding details to get personalized recommendations.',
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            LynewedButton(
              text: 'Get Started',
              onPressed: () => context.pushNamed(WeddingOnboardingPage.routeName),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCountdown(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.isNegative) return 'Wedding day passed';
    if (difference.inDays == 0) return 'Today is the day!';
    if (difference.inDays == 1) return '1 day to go';
    if (difference.inDays < 30) return '${difference.inDays} days to go';
    if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} to go';
    }
    return DateFormat('MMMM d, yyyy').format(date);
  }
}
```

### Quick Actions Row
```dart
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _QuickActionItem(
            icon: Icons.search,
            label: 'Find Pros',
            onTap: () => context.pushNamed(FeedBridesPage.routeName),
          ),
          _QuickActionItem(
            icon: Icons.favorite,
            label: 'Favorites',
            onTap: () => context.pushNamed(FavProListPage.routeName),
          ),
          _QuickActionItem(
            icon: Icons.message,
            label: 'Messages',
            onTap: () => context.pushNamed(MessagesPage.routeName),
          ),
          _QuickActionItem(
            icon: Icons.photo_album,
            label: 'Inspirations',
            onTap: () => context.pushNamed(InspirationsPage.routeName),
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: context.colors.primary),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: context.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
```

## Definition of Done

- [ ] HomeBridesPage migree
- [ ] WeddingSummaryCard implemente
- [ ] QuickActionsRow implemente
- [ ] Feed preview section
- [ ] Map preview section
- [ ] Bottom navigation
- [ ] Tests
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Faible

## Dependances

- S03 : Design system
- S04 : Navigation
- S17-S18 : My Wedding

## Stories Dependantes

- Aucune
