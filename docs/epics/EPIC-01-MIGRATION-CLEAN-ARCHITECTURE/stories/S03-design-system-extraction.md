# Story S03: Core Design System Extraction

## Description

En tant que developpeur, je veux extraire le design system de FlutterFlow vers un module `lib/core/design/` independant afin de garantir une UI coherente sans dependance FlutterFlow.

## Criteres d'Acceptance (Gherkin)

- [ ] Given `lib/flutter_flow/flutter_flow_theme.dart` When j'extrais le theme Then `lib/core/design/theme/` contient un AppTheme equivalent

- [ ] Given `lib/flutter_flow/flutter_flow_widgets.dart` When j'extrais les widgets Then `lib/core/design/widgets/` contient les widgets de base (boutons, inputs, etc.)

- [ ] Given `lib/flutter_flow/flutter_flow_icon_button.dart` When je migre vers le design system Then le composant est disponible dans `lib/core/design/`

- [ ] Given le design system extrait When je remplace les imports FlutterFlow Then toutes les pages utilisent le nouveau design system

- [ ] Given le nouveau theme When je lance l'app Then l'apparence est identique a l'original

## Fichiers Concernes

### A Migrer
- `lib/flutter_flow/flutter_flow_theme.dart` - Theme complet
- `lib/flutter_flow/flutter_flow_widgets.dart` - Widgets de base
- `lib/flutter_flow/flutter_flow_icon_button.dart` - Icon button custom

### A Verifier
- `lib/core/design/` - Existe-t-il deja ? Si oui, enrichir

### A Creer/Enrichir
- `lib/core/design/design.dart` - Barrel export
- `lib/core/design/theme/app_theme.dart` - Theme principal
- `lib/core/design/theme/app_colors.dart` - Palette de couleurs
- `lib/core/design/theme/app_typography.dart` - Typographie
- `lib/core/design/theme/app_spacing.dart` - Espacements standards
- `lib/core/design/widgets/lynewed_button.dart` - Bouton principal
- `lib/core/design/widgets/lynewed_text_field.dart` - Champ texte
- `lib/core/design/widgets/lynewed_icon_button.dart` - Icon button

## Notes Techniques

### Structure Design System
```
lib/core/design/
├── design.dart                    # Barrel export
├── theme/
│   ├── app_theme.dart             # ThemeData configuration
│   ├── app_colors.dart            # Color palette
│   ├── app_typography.dart        # TextStyles
│   └── app_spacing.dart           # Spacing constants
└── widgets/
    ├── widgets.dart               # Barrel
    ├── lynewed_button.dart
    ├── lynewed_text_field.dart
    ├── lynewed_icon_button.dart
    └── lynewed_avatar.dart
```

### Migration du Theme
```dart
// Avant (FlutterFlow)
FlutterFlowTheme.of(context).primaryText

// Apres (Clean)
context.colors.primaryText  // via extension
// ou
AppTheme.of(context).primaryText
```

### Widget Button
```dart
class LynewedButton extends StatelessWidget {
  const LynewedButton({
    required this.text,
    required this.onPressed,
    this.type = LynewedButtonType.primary,
    this.isLoading = false,
    this.width,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;
  final LynewedButtonType type;
  final bool isLoading;
  final double? width;

  @override
  Widget build(BuildContext context) { ... }
}

enum LynewedButtonType { primary, secondary, outline, text }
```

## Definition of Done

- [ ] Theme complet extrait et fonctionnel
- [ ] Widgets de base migres
- [ ] Extensions de contexte pour acces facile
- [ ] Documentation des tokens de design
- [ ] Tests widgets (golden tests optionnels)
- [ ] Apparence identique a l'original
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (impact visuel)

## Dependances

- S01 : Setup infrastructure
- S02 : FlutterFlow utilities (pour extensions)

## Stories Dependantes

- Toutes les stories de migration de pages
