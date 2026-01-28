# Story S02: Creer page "Rejoindre un mariage" (code + QR)

## Description
En tant que guest, je veux pouvoir saisir le code du mariage ou scanner un QR code, afin de rejoindre le mariage de mes proches.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the user is on the JoinWedding page When the user types "abc12345" Then the input should display "ABC12345" (uppercase) And the Continue button should be enabled
- [ ] Given the user is on the JoinWedding page When the user types "abc" (less than 8 chars) Then the Continue button should be disabled And a helper text "8 caracteres requis" should be displayed
- [ ] Given the user is on the JoinWedding page When the user taps "Scanner QR Code" Then the camera should open with QR scanner overlay And the scanner should detect QR codes
- [ ] Given the QR scanner is open When a QR code containing "https://lynewed.app/join/ABCD1234" is scanned Then the code "ABCD1234" should be extracted And the input field should be populated with "ABCD1234" And the scanner should close automatically
- [ ] Given the user has entered code "ABCD1234" When the user taps "Continuer" Then the app should call the validate_invite_code API And show a loading indicator during validation
- [ ] Given the user has entered an invalid code When the validation returns "invalid" Then an error message "Code invalide ou expire" should be displayed And the user should remain on the JoinWedding page
- [ ] Given the user has made 5 failed attempts in 15 minutes When the user tries again Then an error message "Trop de tentatives. Reessayez dans quelques minutes." should be displayed And the Continue button should be disabled temporarily
- [ ] Given the user opens the app via deep link "lynewed.app/join/WXYZ5678" When the JoinWedding page loads Then the code input should be pre-filled with "WXYZ5678" And validation should start automatically

## Fichiers Concernes

### A Creer
- `lib/features/auth/presentation/pages/join_wedding_page.dart`
- `lib/features/auth/presentation/widgets/invite_code_input.dart`
- `lib/features/auth/presentation/widgets/qr_scanner_widget.dart`
- `lib/features/auth/domain/usecases/validate_invite_code.dart`
- `lib/features/auth/data/repositories/invite_code_repository.dart`

### A Modifier
- `lib/core/navigation/app_router.dart` (route /join-wedding avec parametre optionnel code)
- `pubspec.yaml` (ajouter mobile_scanner: ^5.0.0)

## Notes Techniques

### Input code style (8 caracteres espaces)

```dart
// Invite code input with formatting
class InviteCodeInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: 8,
      textCapitalization: TextCapitalization.characters,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
        UpperCaseTextFormatter(),
      ],
      style: const TextStyle(
        fontSize: 24,
        letterSpacing: 4,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: '_ _ _ _ _ _ _ _',
        counterText: '',
        helperText: controller.text.length < 8 ? '8 caracteres requis' : null,
      ),
    );
  }
}
```

### QR Scanner avec mobile_scanner

```dart
// QR Scanner using mobile_scanner package
MobileScanner(
  onDetect: (capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue?.contains('lynewed.app/join/') ?? false) {
        final code = extractCodeFromUrl(barcode.rawValue!);
        if (code != null && code.length == 8) {
          Navigator.of(context).pop(code);
        }
      }
    }
  },
)
```

### Rate limiting local

```dart
// Simple rate limiting tracker
class RateLimiter {
  static const int maxAttempts = 5;
  static const Duration window = Duration(minutes: 15);

  final List<DateTime> _attempts = [];

  bool canAttempt() {
    _cleanup();
    return _attempts.length < maxAttempts;
  }

  void recordAttempt() {
    _attempts.add(DateTime.now());
  }

  void _cleanup() {
    final cutoff = DateTime.now().subtract(window);
    _attempts.removeWhere((a) => a.isBefore(cutoff));
  }
}
```

## Definition of Done

- [ ] Criteres valides
- [ ] Tests unitaires (InviteCodeInput, QR parsing, RateLimiter)
- [ ] Tests widget (JoinWeddingPage)
- [ ] Tests integration (validation flow)
- [ ] `flutter analyze --fatal-infos` passe
- [ ] Permission camera demandee correctement (iOS et Android)
- [ ] UI responsive (small screens, tablets)

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (camera permissions peuvent poser probleme sur certains devices)

## Dependances

- S01 (bouton guest sur login page pour la navigation)
- EPIC-06 complete (colonnes invite_code)

## Stories Dependantes

- S03 (deep links - pre-remplissage du code)
- S04 (guest account creation - etape suivante apres validation)
