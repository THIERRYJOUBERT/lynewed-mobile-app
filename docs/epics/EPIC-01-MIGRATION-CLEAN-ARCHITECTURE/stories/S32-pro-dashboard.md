# Story S32: Pro - Dashboard Page

## Description

En tant que developpeur, je veux migrer la page Dashboard Pro vers Clean Architecture afin d'avoir un tableau de bord professionnel coherent.

## Criteres d'Acceptance (Gherkin)

- [ ] Given `DashboardProWidget` When je la migre Then elle utilise Clean Architecture

- [ ] Given les statistiques When je les affiche Then elles sont chargees correctement

- [ ] Given les alertes actives When je les affiche Then elles sont listees

- [ ] Given les actions rapides When je les utilise Then la navigation fonctionne

## Fichiers Concernes

### Pages Legacy a Migrer
- `lib/pages/pro/dashboard_pro/dashboard_pro_widget.dart`
- `lib/pages/pro/dashboard_pro/dashboard_pro_model.dart`

### Widgets Custom Code
- `lib/features/dashboard/presentation/widgets/alert_item_widget.dart` (existe deja)

### Actions Custom Code
- `lib/custom_code/actions/get_active_alerts_action.dart`

### A Creer
- `lib/features/dashboard/dashboard.dart` - Barrel
- `lib/features/dashboard/domain/entities/pro_stats.dart`
- `lib/features/dashboard/domain/repositories/dashboard_repository.dart`
- `lib/features/dashboard/presentation/pages/dashboard_pro_page.dart`
- `lib/features/dashboard/presentation/bloc/dashboard_cubit.dart`

## Notes Techniques

### Pro Stats Entity
```dart
class ProStats {
  final int profileViews;
  final int savedCount; // Brides who saved this pro
  final int messageCount;
  final int activeAlerts;
  final int weddingsCount;
  final double? averageRating;
  final int reviewCount;

  const ProStats({
    this.profileViews = 0,
    this.savedCount = 0,
    this.messageCount = 0,
    this.activeAlerts = 0,
    this.weddingsCount = 0,
    this.averageRating,
    this.reviewCount = 0,
  });
}
```

### Dashboard Cubit
```dart
class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _repository;
  final MapRepository _mapRepository;

  DashboardCubit({
    required DashboardRepository repository,
    required MapRepository mapRepository,
  }) : _repository = repository,
       _mapRepository = mapRepository,
       super(const DashboardState()) {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    emit(state.copyWith(isLoading: true));

    final results = await Future.wait([
      _repository.getProStats(),
      _mapRepository.getActiveAlerts(),
    ]);

    final statsResult = results[0] as Result<ProStats>;
    final alertsResult = results[1] as Result<List<ProfessionalAlert>>;

    emit(state.copyWith(
      isLoading: false,
      stats: statsResult.data,
      activeAlerts: alertsResult.data ?? [],
    ));
  }
}

class DashboardState {
  final ProStats? stats;
  final List<ProfessionalAlert> activeAlerts;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.stats,
    this.activeAlerts = const [],
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({...});
}
```

### Dashboard Pro Page
```dart
class DashboardProPage extends StatelessWidget {
  const DashboardProPage({super.key});

  static const routeName = 'DashboardPro';
  static const routePath = '/dashboardPro';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardCubit(
        repository: getIt<DashboardRepository>(),
        mapRepository: getIt<MapRepository>(),
      ),
      child: const _DashboardProView(),
    );
  }
}

class _DashboardProView extends StatelessWidget {
  const _DashboardProView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.pushNamed(NotificationsPage.routeName),
          ),
        ],
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => context.read<DashboardCubit>().loadDashboard(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Grid
                  _buildStatsGrid(context, state.stats),
                  const SizedBox(height: 24),
                  // Quick Actions
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  // Active Alerts
                  if (state.activeAlerts.isNotEmpty)
                    _buildAlertsSection(context, state.activeAlerts),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const ProBottomNav(currentIndex: 0),
    );
  }

  Widget _buildStatsGrid(BuildContext context, ProStats? stats) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Statistics',
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.visibility,
                  value: '${stats?.profileViews ?? 0}',
                  label: 'Profile Views',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.favorite,
                  value: '${stats?.savedCount ?? 0}',
                  label: 'Saved By',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.message,
                  value: '${stats?.messageCount ?? 0}',
                  label: 'Messages',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.event,
                  value: '${stats?.weddingsCount ?? 0}',
                  label: 'Weddings',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QuickAction(
                icon: Icons.add_alert,
                label: 'Create Alert',
                onTap: () => _createAlert(context),
              ),
              _QuickAction(
                icon: Icons.map,
                label: 'Open Map',
                onTap: () => context.pushNamed(MapPage.routeName),
              ),
              _QuickAction(
                icon: Icons.message,
                label: 'Messages',
                onTap: () => context.pushNamed(MessagesProWrapper.routeName),
              ),
              _QuickAction(
                icon: Icons.calendar_today,
                label: 'Weddings',
                onTap: () => context.pushNamed(WeddingsHubProPage.routeName),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection(BuildContext context, List<ProfessionalAlert> alerts) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Alerts',
                style: context.textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () => context.pushNamed(MapPage.routeName),
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...alerts.take(3).map((alert) => AlertItemWidget(
            alert: alert,
            onTap: () => _openAlertDetails(context, alert),
          )),
        ],
      ),
    );
  }

  void _createAlert(BuildContext context) {
    AlertCreateSheet.show(context);
  }

  void _openAlertDetails(BuildContext context, ProfessionalAlert alert) {
    AlertDetailsSheet.show(context, alertId: alert.id);
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 24, color: context.colors.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: context.textTheme.headlineSmall,
            ),
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Definition of Done

- [ ] Module dashboard cree
- [ ] DashboardCubit implemente
- [ ] Stats affichees
- [ ] Alertes actives listees
- [ ] Quick actions fonctionnelles
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
- Map module (pour alertes)

## Stories Dependantes

- Aucune
