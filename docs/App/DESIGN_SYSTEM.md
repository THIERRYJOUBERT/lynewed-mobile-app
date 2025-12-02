# Lynewed Design System - Source de Vérité

**Version:** 3.0  
**Date:** 2025-12-02  
**Statut:** ✅ VALIDÉ - Source de vérité pour tout le design  
**Philosophie:** "Élégance Minimale" - Typographie légère, design épuré

---

## 🎯 RÈGLES FONDAMENTALES

### ⚠️ Règles Critiques (À TOUJOURS RESPECTER)

| Règle | Valeur | Contexte |
|-------|--------|----------|
| **Font Weight Max** | w500 | Tous les textes (sauf exceptions documentées) |
| **Border Radius Items** | 4px | Chips, cards, list items, inputs |
| **Border Radius Sheets** | 24px | Top corners des bottom sheets uniquement |
| **Divider Color** | `gray200` | Tous les dividers (0xFFD9D9D9) |
| **Cibles Tactiles** | 44px min | Boutons, icônes interactives |
| **Spacing Sections** | 30px | Entre sections dans sheets/pages |
| **Spacing Label→Content** | 10px | Entre titre de section et contenu |

### Font Family Unifiée
```
Haas Grot Text Trial - TOUTE la typographie
```

---

## 📱 ÉCRANS VALIDÉS (Références)

Ces écrans sont les références pour tout nouveau développement:

| Écran | Fichier | Statut |
|-------|---------|--------|
| **MessagesPage** | `lib/features/chat/presentation/pages/messages_page.dart` | ✅ Validé |
| **BlockedUsersSheet** | `lib/features/chat/presentation/sheets/blocked_users_sheet.dart` | ✅ Validé |
| **AlertCreateSheet** | `lib/features/map/presentation/sheets/alert_create_sheet.dart` | ✅ Validé |
| **WeddingCreateSheet** | `lib/features/map/presentation/sheets/wedding_create_sheet.dart` | ✅ Validé |
| **ProfessionalDetailsSheet** | `lib/features/map/presentation/sheets/professional_details_sheet.dart` | ✅ Validé |

---

## 📐 STRUCTURE DES PAGES

### Header de Page (Style MessagesPage)

```dart
Widget _buildHeader() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
    child: Row(
      children: [
        // Back button
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(
            Icons.chevron_left,
            size: 28,
            color: LynewedColors.textPrimary,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Title - sheetTitle style + fontSize 20
        Expanded(
          child: Text(
            'Page Title',
            style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
          ),
        ),
        
        // Action button (optional) - cercle 44px
        GestureDetector(
          onTap: _onAction,
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: LynewedColors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.archive_outlined,
              size: 22,
              color: LynewedColors.textSecondary,
            ),
          ),
        ),
      ],
    ),
  );
}
```

### Divider Standard
```dart
const Divider(height: 1, color: LynewedColors.gray200)
```

### Section Title
```dart
Padding(
  padding: const EdgeInsets.fromLTRB(20, 30, 20, 10), // 30px top, 10px bottom
  child: Text(
    'Section Title',
    style: LynewedTextStyles.sectionTitle, // 16px, w500
  ),
),
```

---

## 📄 STRUCTURE DES SHEETS

### LynewedSheet (Widget Standard)

```dart
LynewedSheet(
  title: 'Sheet Title',           // sheetTitle + fontSize 20
  onClose: () => Navigator.pop(), // Close icon à droite
  bottomAction: LynewedButton(...),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Sections avec 30px entre elles
    ],
  ),
)
```

### Anatomie d'un Sheet

| Élément | Spécification |
|---------|---------------|
| **Handle bar** | 40x4px, `gray200`, radius 2px, margin top 12px |
| **Header padding** | `EdgeInsets.fromLTRB(20, 20, 20, 12)` |
| **Title** | `sheetTitle.copyWith(fontSize: 20)` |
| **Close icon** | 24px, `gray300`, à droite |
| **Divider** | 1px, `gray200` |
| **Content padding** | `EdgeInsets.symmetric(horizontal: 20, vertical: 16)` |
| **Max height** | 80% de l'écran |
| **Border radius** | 24px top corners |

### Section dans un Sheet

```dart
// Section Title - 30px avant, 10px après
_buildSectionTitle('Section Name'),

// Contenu de la section
Widget content,

const SizedBox(height: 30), // Avant la section suivante
```

---

## 🎨 PALETTE DE COULEURS

### Couleurs Primaires

| Token | Hex | Usage |
|-------|-----|-------|
| **primary** | `0xFF000000` | Boutons, textes principaux, icônes |
| **background** | `0xFFFFFFFF` | Fond principal des pages |
| **surface** | `0xFFF5F5F5` | Fond des cards, list items, boutons secondaires |
| **border** | `0xFFEBEBEB` | Bordures des inputs |
| **textPrimary** | `0xFF141414` | Texte principal |
| **textSecondary** | `0xFF545454` | Texte secondaire, hints |

### Couleurs Neutres (Grays)

| Token | Hex | Usage |
|-------|-----|-------|
| **gray100** | `0xFF727272` | Texte désactivé |
| **gray200** | `0xFFD9D9D9` | **Dividers**, bordures légères, handle bar |
| **gray300** | `0xFFBFBFBF` | Icônes désactivées, close icon |

### Couleurs Fonctionnelles

| Token | Hex | Usage |
|-------|-----|-------|
| **success** | `0xFF249689` | États succès |
| **warning** | `0xFFF9CF58` | Alertes |
| **error** | `0xFFFF5963` | Erreurs, badges |

---

## 📝 TYPOGRAPHIE

### Styles Sémantiques (À UTILISER)

| Token | Taille | Weight | Usage |
|-------|--------|--------|-------|
| **sheetTitle** | 18px | w500 | Titres de sheets (+ fontSize 20 pour pages) |
| **sectionTitle** | 16px | w500 | Titres de sections |
| **bodyLarge** | 16px | w400 | Texte principal |
| **bodyMedium** | 14px | w400 | Texte standard, list items |
| **bodySmall** | 13px | w400 | Texte secondaire |
| **labelSmall** | 10px | w400 | Captions, timestamps |

### Règles de Weight

| Contexte | Weight Max |
|----------|------------|
| **Titres de page** | w500 |
| **Titres de section** | w500 |
| **Texte courant** | w400 |
| **Boutons** | w400 |
| **Chips** | w300 |
| **Labels/hints** | w300 |

### ❌ NE JAMAIS UTILISER
- `FontWeight.w600` ou plus (sauf exceptions documentées)
- `FontWeight.bold`

---

## 🔘 COMPOSANTS

### List Item / Conversation Tile

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  decoration: BoxDecoration(
    color: LynewedColors.surface, // Gris clair
    borderRadius: BorderRadius.circular(4), // 4px radius
  ),
  child: Row(...),
)
```

### Bouton Icône Circulaire (44px)

```dart
GestureDetector(
  onTap: _onTap,
  child: Container(
    width: 44,
    height: 44,
    decoration: const BoxDecoration(
      color: LynewedColors.surface,
      shape: BoxShape.circle,
    ),
    child: Icon(
      Icons.icon_name,
      size: 22,
      color: LynewedColors.textSecondary,
    ),
  ),
)
```

### Chip (Sélectionnable)

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  decoration: BoxDecoration(
    color: selected ? LynewedColors.primary : const Color(0xFFF2F2F2),
    borderRadius: BorderRadius.circular(4), // 4px radius
  ),
  child: Text(
    label,
    style: LynewedTextStyles.chipText.copyWith(
      color: selected ? LynewedColors.textOnPrimary : LynewedColors.textPrimary,
      fontWeight: FontWeight.w300,
    ),
  ),
)
```

### Bouton Primary (Full Width)

```dart
LynewedButton(
  text: 'Action',
  onPressed: _onPressed,
  width: double.infinity,
  type: LynewedButtonType.primary,
)
```

**Spécifications:**
- Hauteur: 48px
- Background: `primary` (noir)
- Text: blanc, 15px, w400
- Border radius: 0px (carré)

---

## 📐 ESPACEMENTS

### Valeurs Standards

| Token | Valeur | Usage |
|-------|--------|-------|
| **xs** | 4px | Espacements minimaux |
| **sm** | 8px | Petits espacements, chips spacing |
| **md** | 12px | Espacements moyens |
| **lg** | 16px | Espacements standards |
| **xl** | 20px | Padding horizontal pages/sheets |
| **xxl** | 24px | Grands espacements |
| **xxxl** | 32px | Très grands espacements |

### Patterns Validés

| Contexte | Valeur |
|----------|--------|
| **Header padding** | `EdgeInsets.fromLTRB(20, 20, 20, 12)` |
| **Section title padding** | `EdgeInsets.fromLTRB(20, 30, 20, 10)` |
| **Content horizontal** | 20px |
| **Entre sections** | 30px |
| **Label → contenu** | 10px |
| **Entre chips** | 8px (spacing & runSpacing) |
| **Entre boutons** | 12px |

---

## 🔲 BORDER RADIUS

| Contexte | Valeur |
|----------|--------|
| **Boutons** | 0px (carrés) |
| **Inputs** | 2px |
| **Chips** | 4px |
| **List items / Cards** | 4px |
| **Sheets (top)** | 24px |

---

## 📁 STRUCTURE DES FICHIERS

```
lib/core/design/
├── design.dart                    # Barrel export (IMPORT PRINCIPAL)
├── lynewed_colors.dart           # Tokens couleurs
├── lynewed_text_styles.dart      # Tokens typographie
├── lynewed_spacing.dart          # Tokens espacement
├── lynewed_borders.dart          # Tokens bordures
├── lynewed_component_styles.dart # Styles composants
├── lynewed_design_system.dart    # API principale
├── lynewed_app_theme.dart        # ThemeData
└── widgets/
    ├── widgets.dart              # Barrel export widgets
    ├── lynewed_sheet.dart        # Sheet wrapper
    ├── lynewed_button.dart       # Boutons
    ├── lynewed_chip.dart         # Chips
    ├── lynewed_text_field.dart   # Text fields
    ├── lynewed_slider.dart       # Sliders
    └── ...
```

### Import Principal

```dart
import '/core/design/design.dart';
import '/core/design/widgets/widgets.dart'; // Pour les widgets
```

---

## ✅ CHECKLIST VALIDATION

### Avant de valider un écran

- [ ] **Header**: Back button + titre (sheetTitle + 20px) + action optionnelle (cercle 44px)
- [ ] **Divider**: `gray200` sous le header
- [ ] **Section titles**: `sectionTitle` (16px, w500)
- [ ] **Spacing sections**: 30px entre sections
- [ ] **Spacing label→content**: 10px
- [ ] **List items**: fond `surface`, radius 4px
- [ ] **Chips**: radius 4px, w300
- [ ] **Boutons**: hauteur 48px, radius 0px
- [ ] **Font weights**: max w500 (sauf exceptions)
- [ ] **Cibles tactiles**: min 44px

---

## 📚 WIDGETS DISPONIBLES

| Widget | Usage |
|--------|-------|
| `LynewedSheet` | Wrapper bottom sheet standard |
| `LynewedButton` | Boutons (primary, secondary, ghost, destructive) |
| `LynewedTextField` | Champs texte avec label |
| `LynewedChip` | Chips sélectionnables |
| `LynewedSlider` | Slider single value |
| `LynewedRangeSlider` | Slider range |
| `LynewedSectionTitle` | Titre de section |
| `LynewedHeaderActions` | Actions header (favorite, menu) |
| `LynewedDetailsSheet` | Sheet détails avec avatar |

---

## 🔄 HISTORIQUE DES VALIDATIONS

| Date | Écran | Corrections |
|------|-------|-------------|
| 2025-12-02 | MessagesPage | Header, divider gray200, section titles w500, list items surface+4px |
| 2025-12-02 | BlockedUsersSheet | Header (title left, close right), divider gray200 |
| 2025-12-01 | AlertCreateSheet | Structure LynewedSheet, spacing 30px/10px |
| 2025-12-01 | WeddingCreateSheet | Structure LynewedSheet, chips 4px |
| 2025-11-30 | ProfessionalDetailsSheet | LynewedDetailsSheet, header actions |

---

**Créé:** 2025-11-27  
**Dernière mise à jour:** 2025-12-02  
**Validé par:** Corrections UI/UX itératives  
**Source de vérité:** Ce document + écrans validés listés ci-dessus
