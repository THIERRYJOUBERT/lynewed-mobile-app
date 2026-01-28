# Story S20: My Wedding - Team Management

## Description

En tant que developpeur, je veux migrer la gestion de l'equipe mariage vers Clean Architecture afin d'avoir une gestion propre des professionnels invites.

## Criteres d'Acceptance (Gherkin)

- [ ] Given la page My Wedding When j'affiche l'equipe Then la liste des pros est chargee

- [ ] Given le sheet d'invitation When j'invite un pro Then il est ajoute a l'equipe

- [ ] Given un pro de l'equipe When je l'exclue Then il est retire avec une raison

- [ ] Given l'equipe When je clique sur le chat Then je navigue vers le wedding team chat

- [ ] Given les widgets existants When je les migre Then ils utilisent le Cubit

## Fichiers Concernes

### Existants (a migrer)
- `lib/features/my_wedding/presentation/sheets/invite_pro_sheet.dart`
- `lib/features/my_wedding/presentation/sheets/note_for_pros_sheet.dart`

### Module Weddings Hub Pro (pour reference)
- `lib/features/weddings_hub_pro/presentation/sheets/leave_wedding_sheet.dart`
- `lib/features/weddings_hub_pro/presentation/sheets/wedding_actions_sheet.dart`

### A Creer
- `lib/features/my_wedding/presentation/bloc/wedding_team_cubit.dart`
- `lib/features/my_wedding/presentation/bloc/wedding_team_state.dart`
- `lib/features/my_wedding/presentation/widgets/wedding_team_list.dart`
- `lib/features/my_wedding/presentation/widgets/wedding_team_member_tile.dart`
- `lib/features/my_wedding/presentation/sheets/exclude_pro_sheet.dart`

## Notes Techniques

### Wedding Team State
```dart
class WeddingTeamState {
  final List<WeddingTeamMember> members;
  final List<ContactedPro> availablePros;
  final WeddingTeamChatInfo? teamChat;
  final bool isLoading;
  final String? error;

  const WeddingTeamState({
    this.members = const [],
    this.availablePros = const [],
    this.teamChat,
    this.isLoading = false,
    this.error,
  });

  List<WeddingTeamMember> get activeMembers =>
      members.where((m) => m.isActive).toList();

  List<WeddingTeamMember> get leftMembers =>
      members.where((m) => m.hasLeft || m.isExcluded).toList();

  WeddingTeamState copyWith({...});
}
```

### Wedding Team Cubit
```dart
class WeddingTeamCubit extends Cubit<WeddingTeamState> {
  final MyWeddingRepository _repository;
  final String weddingId;

  WeddingTeamCubit({
    required MyWeddingRepository repository,
    required this.weddingId,
  }) : _repository = repository,
       super(const WeddingTeamState()) {
    loadTeam();
  }

  Future<void> loadTeam() async {
    emit(state.copyWith(isLoading: true));

    final results = await Future.wait([
      _repository.getWeddingTeam(weddingId: weddingId),
      _repository.getContactedPros(),
      _repository.getWeddingTeamChat(weddingId: weddingId),
    ]);

    final teamResult = results[0] as RepositoryResult<List<WeddingTeamMember>>;
    final prosResult = results[1] as RepositoryResult<List<ContactedPro>>;
    final chatResult = results[2] as RepositoryResult<WeddingTeamChatInfo?>;

    emit(state.copyWith(
      isLoading: false,
      members: teamResult.data ?? [],
      availablePros: prosResult.data ?? [],
      teamChat: chatResult.data,
    ));
  }

  Future<void> invitePro(String proProfileId) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.inviteProToWedding(
      weddingId: weddingId,
      proProfileId: proProfileId,
    );

    result.when(
      success: (_) => loadTeam(),
      failure: (error) => emit(state.copyWith(isLoading: false, error: error)),
    );
  }

  Future<void> excludePro(String proProfileId, {String? reason}) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.excludeProFromWedding(
      weddingId: weddingId,
      proProfileId: proProfileId,
      reason: reason,
    );

    result.when(
      success: (_) => loadTeam(),
      failure: (error) => emit(state.copyWith(isLoading: false, error: error)),
    );
  }
}
```

### Team Member Tile
```dart
class WeddingTeamMemberTile extends StatelessWidget {
  final WeddingTeamMember member;
  final VoidCallback? onTap;
  final VoidCallback? onExclude;

  const WeddingTeamMemberTile({
    required this.member,
    this.onTap,
    this.onExclude,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: member.avatarUrl != null
            ? NetworkImage(member.avatarUrl!)
            : null,
        child: member.avatarUrl == null
            ? Text(member.displayName[0].toUpperCase())
            : null,
      ),
      title: Text(member.displayName),
      subtitle: Text(member.profession ?? 'Professional'),
      trailing: member.isActive
          ? PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'exclude') onExclude?.call();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'exclude',
                  child: Text('Remove from team'),
                ),
              ],
            )
          : _buildStatusBadge(),
      onTap: onTap,
    );
  }

  Widget _buildStatusBadge() {
    if (member.hasLeft) {
      return const Chip(label: Text('Left'));
    }
    if (member.isExcluded) {
      return const Chip(label: Text('Removed'));
    }
    return const SizedBox.shrink();
  }
}
```

### Invite Pro Sheet
```dart
class InviteProSheet extends StatelessWidget {
  final String weddingId;

  const InviteProSheet({required this.weddingId, super.key});

  static Future<void> show(BuildContext context, String weddingId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => InviteProSheet(weddingId: weddingId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeddingTeamCubit, WeddingTeamState>(
      builder: (context, state) {
        // Filter out already invited pros
        final invitedIds = state.members.map((m) => m.profileId).toSet();
        final availablePros = state.availablePros
            .where((p) => !invitedIds.contains(p.profileId))
            .toList();

        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invite Professionals',
                    style: context.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select professionals you have contacted to join your wedding team.',
                    style: context.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: availablePros.isEmpty
                        ? const Center(
                            child: Text('No professionals to invite'),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: availablePros.length,
                            itemBuilder: (context, index) {
                              final pro = availablePros[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: pro.avatarUrl != null
                                      ? NetworkImage(pro.avatarUrl!)
                                      : null,
                                ),
                                title: Text(pro.displayName),
                                subtitle: Text(pro.profession ?? ''),
                                trailing: LynewedButton(
                                  text: 'Invite',
                                  type: LynewedButtonType.outline,
                                  onPressed: () {
                                    context
                                        .read<WeddingTeamCubit>()
                                        .invitePro(pro.profileId);
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
```

## Definition of Done

- [ ] WeddingTeamCubit implemente
- [ ] Liste des membres affichee
- [ ] Invite pro sheet fonctionnel
- [ ] Exclude pro sheet fonctionnel
- [ ] Navigation vers team chat
- [ ] Tests
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Faible

## Dependances

- S03 : Design system
- S17 : My Wedding - Domain
- S18 : My Wedding - Data
- S07 : Chat (pour navigation)

## Stories Dependantes

- Aucune
