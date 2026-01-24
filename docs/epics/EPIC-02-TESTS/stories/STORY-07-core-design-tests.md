# Story STORY-07: Tests Core Design System Widgets

## Description

En tant que developpeur, je veux avoir des widget tests pour les composants du design system Lynewed afin de garantir leur bon fonctionnement et prevenir les regressions visuelles.

## Points : 3

## Priorite : Basse

## Fichiers source a tester

### Design System - Theme/Constants

| Fichier | Composant | Responsabilite |
|---------|-----------|----------------|
| `lib/core/design/lynewed_colors.dart` | LynewedColors | Palette de couleurs |
| `lib/core/design/lynewed_spacing.dart` | LynewedSpacing | Espacements |
| `lib/core/design/lynewed_borders.dart` | LynewedBorders | Border radius, styles |
| `lib/core/design/lynewed_text_styles.dart` | LynewedTextStyles | Typographie |

### Design System - Widgets

| Fichier | Widget | Priorite test |
|---------|--------|---------------|
| `lib/core/design/widgets/lynewed_button.dart` | LynewedButton | Haute |
| `lib/core/design/widgets/lynewed_text_field.dart` | LynewedTextField | Haute |
| `lib/core/design/widgets/lynewed_chip.dart` | LynewedChip | Moyenne |
| `lib/core/design/widgets/lynewed_sheet.dart` | LynewedSheet | Moyenne |
| `lib/core/design/widgets/lynewed_slider.dart` | LynewedSlider | Moyenne |
| `lib/core/design/widgets/lynewed_section_title.dart` | LynewedSectionTitle | Basse |
| `lib/core/design/widgets/lynewed_info_row.dart` | LynewedInfoRow | Basse |

## Criteres d'Acceptance

### AC1: Tests Design Tokens
- [ ] Test LynewedColors contient toutes les couleurs requises
- [ ] Test LynewedSpacing contient les espacements standards
- [ ] Test LynewedBorders contient les radius standards
- [ ] Test consistance des valeurs (ex: spacing.sm < spacing.md < spacing.lg)

### AC2: Tests LynewedButton Widget
- [ ] Test render avec label
- [ ] Test render avec icon
- [ ] Test onPressed callback est appele
- [ ] Test disabled state
- [ ] Test variants (primary, secondary, outlined)
- [ ] Test loading state

### AC3: Tests LynewedTextField Widget
- [ ] Test render avec label
- [ ] Test render avec hint
- [ ] Test onChanged callback
- [ ] Test validation error display
- [ ] Test enabled/disabled states
- [ ] Test obscureText pour passwords

### AC4: Tests LynewedChip Widget
- [ ] Test render avec label
- [ ] Test selected state
- [ ] Test onTap callback
- [ ] Test custom colors

### AC5: Tests autres widgets (si temps)
- [ ] Test LynewedSheet s'affiche correctement
- [ ] Test LynewedSlider value change
- [ ] Test LynewedSectionTitle render

### AC6: Qualite des tests
- [ ] Coverage > 50% sur core/design/widgets/
- [ ] Tous les tests passent
- [ ] Temps d'execution < 10s

## Fichiers de Test a Creer

```
test/core/design/
├── lynewed_colors_test.dart
├── lynewed_spacing_test.dart
└── widgets/
    ├── lynewed_button_test.dart
    ├── lynewed_text_field_test.dart
    └── lynewed_chip_test.dart
```

## Notes Techniques

### Widget Test Setup

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/design/widgets/lynewed_button.dart';

void main() {
  group('LynewedButton', () {
    testWidgets('should render with label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LynewedButton(
              label: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LynewedButton(
              label: 'Test Button',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(LynewedButton));
      await tester.pump();

      expect(pressed, true);
    });

    testWidgets('should not call onPressed when disabled', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LynewedButton(
              label: 'Test Button',
              onPressed: null, // Disabled
            ),
          ),
        ),
      );

      await tester.tap(find.byType(LynewedButton));
      await tester.pump();

      expect(pressed, false);
    });
  });
}
```

### Test des Design Tokens

```dart
void main() {
  group('LynewedColors', () {
    test('should have primary color defined', () {
      expect(LynewedColors.primary, isA<Color>());
    });

    test('should have consistent color palette', () {
      // Verify colors are not null
      expect(LynewedColors.primary, isNotNull);
      expect(LynewedColors.secondary, isNotNull);
      expect(LynewedColors.background, isNotNull);
      expect(LynewedColors.error, isNotNull);
    });
  });

  group('LynewedSpacing', () {
    test('spacing values should be in ascending order', () {
      expect(LynewedSpacing.xs, lessThan(LynewedSpacing.sm));
      expect(LynewedSpacing.sm, lessThan(LynewedSpacing.md));
      expect(LynewedSpacing.md, lessThan(LynewedSpacing.lg));
      expect(LynewedSpacing.lg, lessThan(LynewedSpacing.xl));
    });
  });
}
```

### Pattern pour TextField

```dart
testWidgets('should show error when validation fails', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: LynewedTextField(
          label: 'Email',
          errorText: 'Invalid email',
        ),
      ),
    ),
  );

  expect(find.text('Invalid email'), findsOneWidget);
});

testWidgets('should call onChanged when text changes', (tester) async {
  String? changedValue;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: LynewedTextField(
          label: 'Name',
          onChanged: (value) => changedValue = value,
        ),
      ),
    ),
  );

  await tester.enterText(find.byType(TextField), 'Test Name');
  await tester.pump();

  expect(changedValue, 'Test Name');
});
```

## Priorites

Concentrer les efforts sur :

1. **LynewedButton** - Widget le plus utilise
2. **LynewedTextField** - Widget critique pour formulaires
3. **Design tokens** - Foundation du design system

Les autres widgets peuvent etre testes si le temps le permet.

## Definition of Done

- [ ] Tests des design tokens crees
- [ ] Tests LynewedButton complets
- [ ] Tests LynewedTextField complets
- [ ] Tous les tests passent (`flutter test test/core/design/`)
- [ ] Aucun warning (`flutter analyze`)
- [ ] TRACKING.md mis a jour

## Estimation

- Design tokens : ~30min
- LynewedButton tests : ~1h
- LynewedTextField tests : ~1h
- Autres widgets (optionnel) : ~30min

**Total** : ~3h
