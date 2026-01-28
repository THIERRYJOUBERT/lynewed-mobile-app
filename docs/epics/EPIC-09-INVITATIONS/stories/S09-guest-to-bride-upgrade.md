# Story S09: Creer flow Guest -> Bride upgrade avec warning

## Description
En tant que guest, je veux pouvoir passer en compte Mariee si j'organise mon propre mariage, afin de beneficier de toutes les fonctionnalites sans recreer un compte.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the user is logged in as a guest When viewing the guest profile page Then a section "Vous organisez votre propre mariage ?" should be visible And a button "Passer en compte Mariee" should be displayed And a warning text "Cette action est irreversible" should appear
- [ ] Given the user taps "Passer en compte Mariee" When the confirmation dialog appears Then it should contain: Title "Passer en compte Mariee", Warning "Attention : cette action est irreversible. Vous ne pourrez plus revenir en compte invite.", Info "Vous conserverez vos photos et votre compte.", Cancel button "Annuler", Confirm button "Je confirme"
- [ ] Given the confirmation dialog is displayed When the user taps "Annuler" Then the dialog should close And the user should remain on the guest profile page And the user role should still be 'guest'
- [ ] Given the confirmation dialog is displayed When the user taps "Je confirme" Then a loading indicator should appear And the profile.role should be updated to 'bride' And the user should be navigated to the Bride home page And a success message "Bienvenue ! Vous pouvez maintenant creer votre mariage." should appear
- [ ] Given the user has just upgraded to bride When viewing the Bride home page Then a button "Creer mon mariage" should be visible And tapping it should open the wedding creation flow
- [ ] Given the guest has uploaded 5 photos When the user upgrades to bride Then the photos should still be accessible And the account email and profile info should be unchanged
- [ ] Given a network error occurs during upgrade When the user confirms the upgrade Then an error message "Une erreur est survenue. Reessayez." should appear And the user should remain as guest And the user can retry the upgrade

## Fichiers Concernes

### A Creer
- `lib/features/guest/presentation/widgets/upgrade_to_bride_section.dart`
- `lib/features/guest/presentation/widgets/upgrade_confirmation_dialog.dart`
- `lib/features/auth/domain/usecases/upgrade_to_bride.dart`

### A Modifier
- `lib/features/guest/presentation/pages/guest_profile_page.dart`
- `lib/features/auth/data/datasources/auth_remote_datasource.dart` (methode upgrade)

## Notes Techniques

### Backend RPC Function

```sql
-- Migration: create_upgrade_guest_to_bride_function
-- Function: upgrade_guest_to_bride
CREATE OR REPLACE FUNCTION upgrade_guest_to_bride(p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  -- Verify current role is guest
  IF NOT EXISTS (
    SELECT 1 FROM profiles WHERE id = p_user_id AND role = 'guest'
  ) THEN
    RAISE EXCEPTION 'User is not a guest';
  END IF;

  -- Update role
  UPDATE profiles
  SET role = 'bride', updated_at = NOW()
  WHERE id = p_user_id;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### UpgradeToBride UseCase

```dart
// lib/features/auth/domain/usecases/upgrade_to_bride.dart
class UpgradeToBride {
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  Future<Either<Failure, void>> call(String userId) async {
    try {
      // Call RPC function
      final result = await _profileRepository.upgradeToBride(userId);

      // Update local auth state
      await _authRepository.refreshSession();

      return result;
    } catch (e) {
      return Left(UpgradeFailure(message: 'Une erreur est survenue. Reessayez.'));
    }
  }
}
```

### Upgrade Section Widget

```dart
// lib/features/guest/presentation/widgets/upgrade_to_bride_section.dart
class UpgradeToBrideSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pink.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.pink.shade300),
              const SizedBox(width: 8),
              Text(
                'Vous organisez votre propre mariage ?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.pink.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Passez en compte Mariee pour acceder a toutes les fonctionnalites : recherche de prestataires, organisation, planning...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showUpgradeDialog(context, ref),
              icon: const Icon(Icons.upgrade),
              label: const Text('Passer en compte Mariee'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.pink.shade600,
                side: BorderSide(color: Colors.pink.shade300),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cette action est irreversible',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange.shade700,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => UpgradeConfirmationDialog(
        onConfirm: () async {
          Navigator.of(context).pop();
          await _performUpgrade(context, ref);
        },
      ),
    );
  }

  Future<void> _performUpgrade(BuildContext context, WidgetRef ref) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) {
      Navigator.of(context).pop();
      return;
    }

    final result = await ref.read(upgradeToBrideProvider).call(userId);

    Navigator.of(context).pop(); // Remove loading

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
            content: Text('Bienvenue ! Vous pouvez maintenant creer votre mariage.'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to bride home
        context.go('/home');
      },
    );
  }
}
```

### Confirmation Dialog

```dart
// lib/features/guest/presentation/widgets/upgrade_confirmation_dialog.dart
class UpgradeConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const UpgradeConfirmationDialog({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          const Text('Passer en compte Mariee'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Attention : cette action est irreversible. Vous ne pourrez plus revenir en compte invite.',
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Vous conserverez vos photos et votre compte.',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
          ),
          child: const Text('Je confirme'),
        ),
      ],
    );
  }
}
```

## Definition of Done

- [ ] Criteres valides
- [ ] Tests unitaires (UpgradeToBride usecase)
- [ ] Tests widget (UpgradeToBrideSection, UpgradeConfirmationDialog)
- [ ] Tests integration (flow complet upgrade)
- [ ] Migration Supabase deployee (upgrade_guest_to_bride)
- [ ] `flutter analyze --fatal-infos` passe
- [ ] Navigation vers home bride fonctionne
- [ ] Donnees conservees apres upgrade (photos, profil)

## Estimation

**Points** : 3
**Complexite** : Faible
**Risque** : Faible (operation simple avec confirmation)

## Dependances

- S05 (guest navigation - page profil guest existe)

## Stories Dependantes

- Aucune (fonctionnalite finale d'upgrade)
