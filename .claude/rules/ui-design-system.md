# Regles UI/UX - Design System Lynewed

> **OBLIGATOIRE** : Toute creation d'ecran ou widget doit suivre ces regles pour garantir la coherence visuelle.

---

## Composants Reutilisables (lib/core/design/)

### Widgets de Base (lib/core/design/widgets/)

| Widget | Fichier | Usage |
|--------|---------|-------|
| `LynewedButton` | `lynewed_button.dart` | Boutons (primary, secondary, text) |
| `LynewedTextField` | `lynewed_text_field.dart` | Champs de saisie |
| `LynewedChip` | `lynewed_chip.dart` | Chips selectionnables |
| `LynewedSlider` | `lynewed_slider.dart` | Sliders simples |
| `LynewedRangeSlider` | `lynewed_range_slider.dart` | Sliders double |
| `LynewedIconButton` | `lynewed_icon_button.dart` | Boutons icone |
| `LynewedSheet` | `lynewed_sheet.dart` | Base pour bottom sheets |
| `LynewedSectionTitle` | `lynewed_section_title.dart` | Titres de sections |
| `LynewedDetailsSheet` | `lynewed_details_sheet.dart` | Sheet de details |
| `LynewedInfoRow` | `lynewed_info_row.dart` | Lignes info icone + texte |
| `LynewedMoreMenu` | `lynewed_more_menu.dart` | Menu contextuel |

### Styles (lib/core/design/)

| Fichier | Contenu |
|---------|---------|
| `lynewed_colors.dart` | Palette couleurs |
| `lynewed_text_styles.dart` | Styles typographiques |
| `lynewed_spacing.dart` | Espacements standardises |
| `lynewed_borders.dart` | Bordures et radius |
| `lynewed_component_styles.dart` | Decorations reusables |

### Import Standard

```dart
import '/core/design/design.dart';
```

---

## Ecrans de Reference

### Bottom Sheets

| Fichier | Pattern | Usage |
|---------|---------|-------|
| `report_user_sheet.dart` | Formulaire + radio options | Sheets avec selection + input |
| `create_album_sheet.dart` | Formulaire + chips + toggle | Sheets de creation |
| `conversation_actions_sheet.dart` | Actions simples | Sheets d'actions rapides |

**Structure type d'une sheet :**
```dart
LynewedSheet(
  title: 'Titre',
  onClose: () => Navigator.pop(context),
  bottomAction: LynewedButton(...),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Section 1
      LynewedSectionTitle('Label'),
      const SizedBox(height: 10),
      // Contenu section
      const SizedBox(height: 30), // Inter-section spacing
      // Section 2
      ...
    ],
  ),
)
```

### Pages

| Fichier | Pattern | Usage |
|---------|---------|-------|
| `messages_page.dart` | Liste conversations | Pages liste avec header |
| `notifications_page.dart` | Centre notifications | Pages notifications |
| `my_wedding_page.dart` | Page complexe sections | Pages multi-sections |
| `album_detail_page.dart` | Grille medias | Pages galerie |
| `guest_home_page.dart` | Navigation tabs | Pages avec bottom nav |

---

## Regles d'Espacement

| Context | Valeur |
|---------|--------|
| Inter-section | `30px` |
| Label → Contenu | `10px` |
| Items dans liste | `8-12px` |
| Padding horizontal page | `20px` |
| Padding sheet | `20px` |

---

## Pattern Header Standard

```dart
Widget _buildHeader() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
    child: Row(
      children: [
        LynewedComponentStyles.backButton(context),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            'Titre',
            style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
          ),
        ),
        // Actions optionnelles
      ],
    ),
  );
}
```

---

## Pattern Grille Media

```dart
GridView.builder(
  padding: const EdgeInsets.all(12),
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    crossAxisSpacing: 4,
    mainAxisSpacing: 4,
  ),
  itemCount: items.length,
  itemBuilder: (context, index) => _buildMediaTile(items[index]),
)
```

---

## Pattern Empty State

```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.photo_library_outlined,
        size: 64,
        color: LynewedColors.gray300,
      ),
      SizedBox(height: LynewedSpacing.lg),
      Text(
        'Titre',
        style: LynewedTextStyles.titleSmall.copyWith(
          color: LynewedColors.textPrimary,
        ),
      ),
      SizedBox(height: LynewedSpacing.sm),
      Text(
        'Description',
        style: LynewedTextStyles.bodySmall.copyWith(
          color: LynewedColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  ),
)
```

---

## Regles Obligatoires

1. **TOUJOURS** utiliser les widgets `Lynewed*` au lieu de widgets Material bruts
2. **TOUJOURS** importer via `design.dart` (barrel export)
3. **TOUJOURS** respecter les espacements standardises
4. **JAMAIS** hardcoder des couleurs - utiliser `LynewedColors`
5. **JAMAIS** hardcoder des styles texte - utiliser `LynewedTextStyles`
6. **TOUJOURS** s'inspirer des ecrans de reference pour la structure
7. **TOUJOURS** utiliser `LynewedSheet` pour les bottom sheets
