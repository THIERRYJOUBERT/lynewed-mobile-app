# Story S01: Modifier login page avec bouton Guest discret

## Description
En tant que guest potentiel, je veux voir un bouton discret sur la page de login pour rejoindre un mariage, afin de pouvoir acceder facilement au processus d'invitation.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the user is on the login page When the page loads completely Then a discrete button "Rejoindre en tant qu'invite" should be visible And it should be positioned below the Bride/Pro selection And it should have a person_add icon
- [ ] Given the user is on the login page When the user taps "Rejoindre en tant qu'invite" Then the app should navigate to the JoinWedding page And the JoinWedding page should display the code input field
- [ ] Given the user is on the login page When the user selects "Bride" and proceeds to login Then the normal bride login flow should work unchanged
- [ ] Given the user is on the login page When viewing on small screen (iPhone SE) Then the guest button should remain visible and tappable without scrolling conflicts

## Fichiers Concernes

### A Creer
- `lib/features/auth/presentation/widgets/guest_join_button.dart`

### A Modifier
- `lib/features/auth/presentation/pages/login_page.dart`
- `lib/core/navigation/app_router.dart` (ajouter route /join-wedding)

## Notes Techniques

Le bouton doit etre discret mais visible. Style recommande:

```dart
// Guest join button - discrete style
TextButton.icon(
  onPressed: () => context.push('/join-wedding'),
  icon: const Icon(Icons.person_add_outlined, size: 18),
  label: const Text(
    'Rejoindre en tant qu\'invite',
    style: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.grey,
    ),
  ),
)
```

Placement: En dessous des options Bride/Pro, avec un Divider optionnel et un peu d'espace vertical.

## Definition of Done

- [ ] Criteres valides
- [ ] Tests unitaires (widget test pour le bouton)
- [ ] Tests integration (navigation vers JoinWedding)
- [ ] `flutter analyze --fatal-infos` passe
- [ ] Design coherent avec le reste de la page login

## Estimation

**Points** : 2
**Complexite** : Faible
**Risque** : Faible

## Dependances

- EPIC-06 complete (prerequis pour tout l'Epic)

## Stories Dependantes

- S02 (Join wedding page - destination de la navigation)
