# Story S08: Implementer tracking statut guest (pending/invited/joined)

## Description
En tant que mariee, je veux voir clairement le statut de chaque invite et pouvoir filtrer par statut, afin de suivre facilement qui a recu l'invitation et qui a rejoint le mariage.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the wedding has 5 guests "pending", 3 guests "invited", 2 guests "joined" When viewing the guests list Then a summary "10 invites - 3 invitations envoyees - 2 ont rejoint" should be displayed
- [ ] Given the guests list with mixed statuses When the bride taps the filter icon Then filter options "Tous", "En attente", "Invites", "Ont rejoint" should appear
- [ ] Given the bride selects "Ont rejoint" filter When the filter is applied Then only guests with status='joined' should be displayed
- [ ] Given a guest with status "pending" When an invitation is sent successfully Then the status should change to "invited" And the invited_at timestamp should be set
- [ ] Given a guest with status "invited" When the guest creates an account and joins Then the status should change to "joined" And the joined_at timestamp should be set And the user_id should be linked
- [ ] Given the guests list Then status "pending" should display gray badge And status "invited" should display yellow badge with envelope icon And status "joined" should display green badge with checkmark icon

## Fichiers Concernes

### A Creer
- `lib/features/my_wedding/presentation/widgets/guest_status_filter.dart`
- `lib/features/my_wedding/presentation/widgets/guest_list_summary.dart`
- `lib/features/my_wedding/presentation/providers/guest_filter_provider.dart`

### A Modifier
- `lib/features/my_wedding/presentation/pages/wedding_guests_page.dart`
- `lib/features/my_wedding/presentation/widgets/guest_status_badge.dart` (si pas deja cree dans S07)

## Notes Techniques

### Filter Provider

```dart
// lib/features/my_wedding/presentation/providers/guest_filter_provider.dart
enum GuestStatusFilter { all, pending, invited, joined }

final guestStatusFilterProvider = StateProvider<GuestStatusFilter>(
  (ref) => GuestStatusFilter.all,
);

final filteredGuestsProvider = Provider<List<WeddingGuest>>((ref) {
  final guests = ref.watch(weddingGuestsProvider).valueOrNull ?? [];
  final filter = ref.watch(guestStatusFilterProvider);

  if (filter == GuestStatusFilter.all) return guests;

  return guests.where((g) {
    return switch (filter) {
      GuestStatusFilter.pending => g.status == 'pending',
      GuestStatusFilter.invited => g.status == 'invited',
      GuestStatusFilter.joined => g.status == 'joined',
      GuestStatusFilter.all => true,
    };
  }).toList();
});
```

### Guest List Summary Widget

```dart
// lib/features/my_wedding/presentation/widgets/guest_list_summary.dart
class GuestListSummary extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guests = ref.watch(weddingGuestsProvider).valueOrNull ?? [];

    final total = guests.length;
    final invited = guests.where((g) => g.status == 'invited').length;
    final joined = guests.where((g) => g.status == 'joined').length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            count: total,
            label: 'invites',
            color: Colors.grey,
          ),
          _SummaryItem(
            count: invited,
            label: 'invitations\nenvoyees',
            color: Colors.amber,
          ),
          _SummaryItem(
            count: joined,
            label: 'ont\nrejoint',
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
```

### Guest Status Filter Widget

```dart
// lib/features/my_wedding/presentation/widgets/guest_status_filter.dart
class GuestStatusFilter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(guestStatusFilterProvider);

    return PopupMenuButton<GuestStatusFilter>(
      icon: Badge(
        isLabelVisible: currentFilter != GuestStatusFilter.all,
        child: const Icon(Icons.filter_list),
      ),
      onSelected: (filter) {
        ref.read(guestStatusFilterProvider.notifier).state = filter;
      },
      itemBuilder: (context) => [
        _buildMenuItem(context, GuestStatusFilter.all, 'Tous', currentFilter),
        _buildMenuItem(context, GuestStatusFilter.pending, 'En attente', currentFilter),
        _buildMenuItem(context, GuestStatusFilter.invited, 'Invites', currentFilter),
        _buildMenuItem(context, GuestStatusFilter.joined, 'Ont rejoint', currentFilter),
      ],
    );
  }

  PopupMenuItem<GuestStatusFilter> _buildMenuItem(
    BuildContext context,
    GuestStatusFilter filter,
    String label,
    GuestStatusFilter current,
  ) {
    final isSelected = filter == current;
    return PopupMenuItem(
      value: filter,
      child: Row(
        children: [
          if (isSelected)
            Icon(Icons.check, size: 18, color: Theme.of(context).primaryColor)
          else
            const SizedBox(width: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
```

### Updated Wedding Guests Page

```dart
// Dans wedding_guests_page.dart
class WeddingGuestsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredGuests = ref.watch(filteredGuestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes invites'),
        actions: [
          const GuestStatusFilter(),
        ],
      ),
      body: Column(
        children: [
          // Summary at top
          const Padding(
            padding: EdgeInsets.all(16),
            child: GuestListSummary(),
          ),

          // Filter indicator
          Consumer(builder: (context, ref, _) {
            final filter = ref.watch(guestStatusFilterProvider);
            if (filter == GuestStatusFilter.all) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Chip(
                label: Text(_filterLabel(filter)),
                onDeleted: () {
                  ref.read(guestStatusFilterProvider.notifier).state =
                      GuestStatusFilter.all;
                },
              ),
            );
          }),

          // Guest list
          Expanded(
            child: ListView.builder(
              itemCount: filteredGuests.length,
              itemBuilder: (context, index) {
                return GuestTile(guest: filteredGuests[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _filterLabel(GuestStatusFilter filter) {
    return switch (filter) {
      GuestStatusFilter.pending => 'En attente',
      GuestStatusFilter.invited => 'Invites',
      GuestStatusFilter.joined => 'Ont rejoint',
      GuestStatusFilter.all => 'Tous',
    };
  }
}
```

### Badge Colors Reference

| Status | Color | Icon | Label FR |
|--------|-------|------|----------|
| pending | Grey (#9E9E9E) | none | - |
| invited | Amber (#FFC107) | mail_outline | Invite |
| joined | Green (#4CAF50) | check_circle | Rejoint |

## Definition of Done

- [ ] Criteres valides
- [ ] Tests unitaires (filteredGuestsProvider)
- [ ] Tests widget (GuestListSummary, GuestStatusFilter)
- [ ] Tests integration (filter flow)
- [ ] `flutter analyze --fatal-infos` passe
- [ ] Compteurs mis a jour en temps reel
- [ ] Filter persiste pendant la session

## Estimation

**Points** : 3
**Complexite** : Faible
**Risque** : Faible

## Dependances

- S07 (UI envoi invitation - partage les badges)
- S04 (guest account creation - transitions de statut)

## Stories Dependantes

- Aucune (fonctionnalite finale de tracking)
