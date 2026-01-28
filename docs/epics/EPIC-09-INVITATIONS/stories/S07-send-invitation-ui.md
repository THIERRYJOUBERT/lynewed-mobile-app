# Story S07: Ajouter UI envoi invitation pour bride

## Description
En tant que mariee, je veux pouvoir envoyer des invitations a mes guests depuis l'application, afin de les inviter facilement a rejoindre mon mariage.

## Criteres d'Acceptance (Gherkin)

- [ ] Given a guest "Pierre" has email "pierre@example.com" When viewing the guest details Then a "Envoyer l'invitation" button should be visible
- [ ] Given a guest "Marie" has no email When viewing the guest details Then the "Envoyer l'invitation" button should NOT be visible And a message "Ajoutez un email pour envoyer une invitation" should appear
- [ ] Given a guest with valid email When the bride taps "Envoyer l'invitation" Then the button should show a loading spinner And the button should be disabled during loading
- [ ] Given the invitation email was sent successfully When the loading completes Then a success toast "Invitation envoyee !" should appear And the guest status should change to "Invite" And a green checkmark badge should appear next to the guest
- [ ] Given the email service fails When the loading completes Then an error toast "Echec de l'envoi. Verifiez l'email." should appear And the guest status should remain unchanged
- [ ] Given a guest already has status "Invite" When viewing the guest details Then a "Renvoyer l'invitation" button should be visible And tapping it should send another email
- [ ] Given the guests list Then guests with status "pending" should show no badge And guests with status "invited" should show "Invite" badge (yellow) And guests with status "joined" should show "Rejoint" badge (green)

## Fichiers Concernes

### A Creer
- `lib/features/my_wedding/domain/usecases/send_guest_invitation.dart`
- `lib/features/my_wedding/presentation/widgets/send_invitation_button.dart`

### A Modifier
- `lib/features/my_wedding/presentation/pages/wedding_guests_page.dart`
- `lib/features/my_wedding/presentation/widgets/guest_tile.dart`
- `lib/features/my_wedding/data/datasources/wedding_remote_datasource.dart`

## Notes Techniques

### UseCase SendGuestInvitation

```dart
// lib/features/my_wedding/domain/usecases/send_guest_invitation.dart
class SendGuestInvitation {
  final SupabaseClient _supabase;

  Future<Either<Failure, void>> call(SendInvitationParams params) async {
    try {
      final response = await _supabase.functions.invoke(
        'send-wedding-invitation',
        body: {
          'guest_id': params.guestId,
          'wedding_id': params.weddingId,
        },
      );

      if (response.status != 200) {
        final error = response.data['error'] as String?;
        return Left(InvitationFailure(
          message: _mapErrorToMessage(error),
          code: error,
        ));
      }

      return const Right(null);
    } catch (e) {
      return Left(InvitationFailure(message: 'Erreur lors de l\'envoi'));
    }
  }

  String _mapErrorToMessage(String? error) {
    switch (error) {
      case 'invalid_email':
        return 'Adresse email invalide';
      case 'guest_not_found':
        return 'Invite introuvable';
      case 'rate_limited':
        return 'Trop de requetes, reessayez plus tard';
      default:
        return 'Echec de l\'envoi';
    }
  }
}
```

### SendInvitationButton Widget

```dart
// lib/features/my_wedding/presentation/widgets/send_invitation_button.dart
class SendInvitationButton extends ConsumerWidget {
  final String guestId;
  final String weddingId;
  final String? guestEmail;
  final String guestStatus;
  final VoidCallback? onSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(sendInvitationLoadingProvider(guestId));

    // No email - show hint
    if (guestEmail == null || guestEmail!.isEmpty) {
      return Text(
        'Ajoutez un email pour envoyer une invitation',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final buttonText = guestStatus == 'invited'
        ? 'Renvoyer l\'invitation'
        : 'Envoyer l\'invitation';

    return ElevatedButton.icon(
      onPressed: isLoading
          ? null
          : () => _sendInvitation(context, ref),
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.send, size: 18),
      label: Text(buttonText),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _sendInvitation(BuildContext context, WidgetRef ref) async {
    ref.read(sendInvitationLoadingProvider(guestId).notifier).state = true;

    final result = await ref.read(sendGuestInvitationProvider).call(
      SendInvitationParams(guestId: guestId, weddingId: weddingId),
    );

    ref.read(sendInvitationLoadingProvider(guestId).notifier).state = false;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Colors.red,
          ),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitation envoyee !'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh guest list
        ref.invalidate(weddingGuestsProvider);
        onSuccess?.call();
      },
    );
  }
}
```

### Guest Tile Modification

```dart
// Dans guest_tile.dart - ajouter le bouton et badge
class GuestTile extends StatelessWidget {
  final WeddingGuest guest;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(guest.name[0].toUpperCase()),
      ),
      title: Row(
        children: [
          Expanded(child: Text(guest.name)),
          if (guest.status != 'pending')
            GuestStatusBadge(status: guest.status),
        ],
      ),
      subtitle: Text(guest.email ?? 'Pas d\'email'),
      trailing: SendInvitationButton(
        guestId: guest.id,
        weddingId: guest.weddingId,
        guestEmail: guest.email,
        guestStatus: guest.status,
      ),
    );
  }
}
```

### Status Badge Widget

```dart
// lib/features/my_wedding/presentation/widgets/guest_status_badge.dart
class GuestStatusBadge extends StatelessWidget {
  final String status;

  @override
  Widget build(BuildContext context) {
    final (color, text, icon) = switch (status) {
      'invited' => (Colors.amber, 'Invite', Icons.mail_outline),
      'joined' => (Colors.green, 'Rejoint', Icons.check_circle_outline),
      _ => (Colors.grey, '', null),
    };

    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
```

## Definition of Done

- [ ] Criteres valides
- [ ] Tests unitaires (SendGuestInvitation usecase)
- [ ] Tests widget (SendInvitationButton, GuestStatusBadge)
- [ ] Tests integration (envoi invitation et mise a jour status)
- [ ] `flutter analyze --fatal-infos` passe
- [ ] UI responsive (bouton adapte aux petits ecrans)
- [ ] Feedback utilisateur clair (loading, success, error)

## Estimation

**Points** : 3
**Complexite** : Faible
**Risque** : Faible

## Dependances

- S06 (Edge Function send-wedding-invitation - backend)

## Stories Dependantes

- S08 (status tracking - utilise les memes badges)
