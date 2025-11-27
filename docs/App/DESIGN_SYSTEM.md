# Lynewed Design System - Guide Unifié

**Version:** 1.0  
**Date:** 2025-11-27  
**Objectif:** Documenter et unifier l'identité visuelle existante du MVP approuvée par Thierry  
**Philosophie:** "Documenter & Unifier" PAS "Redéfinir"

---

## 🎯 Principes Fondamentaux

### Design Philosophy
- **Minimalisme Élégant**: Noir et blanc dominants avec touches de gris
- **Clarté Hiérarchique**: Typographie forte avec contrastes nets
- **Design Carré**: Bordures droites (0.0) pour les boutons, arrondies (24.0) pour les sheets
- **Professionnel Luxe**: Esthétique haut de gamme pour l'industrie du mariage

### Font Family Unifiée
```
Haas Grot Text Trial - TOUTE la typographie
```

---

## 📝 Typographie Sémantique

### Échelle Complète (basée sur l'usage réel MVP)

| Token | Taille | Weight | Usage Context | Exemples MVP |
|-------|--------|--------|---------------|-------------|
| **displayLarge** | 64.0 | w600 | Titres hero | Pages d'accueil |
| **displayMedium** | 44.0 | w600 | Gros titres | ONBOARDING |
| **displaySmall** | 36.0 | w600 | Sous-titres hero | - |
| **headlineLarge** | 32.0 | w600 | Titres sections | AuthWelcome, Onboarding |
| **headlineMedium** | 28.0 | w600 | Titres secondaires | - |
| **headlineSmall** | 24.0 | w600 | Sous-titres | - |
| **titleLarge** | 22.0 | w600 | Titres cards | Onboarding |
| **titleMedium** | 20.0 | w600 | Titres modules | FlutterFlowTheme |
| **titleSmall** | 18.0 | w600 | Titres petits | Onboarding, Home |
| **bodyLarge** | 16.0 | normal | Texte principal | Messages, Profile |
| **bodyMedium** | 14.0 | normal | Texte secondaire | Boutons, descriptions |
| **bodySmall** | 13.0 | normal | Petits textes | Onboarding |
| **labelLarge** | 12.0 | normal | Labels, métadonnées | Edit Profile |
| **labelMedium** | 11.0 | normal | Très petit texte | Home, Feed |
| **labelSmall** | 10.0 | normal | Mini textes | Messages |
| **caption** | 9.0 | normal | Légendes, timestamps | Messages |

### Couleurs de Texte

| Token | Couleur | Usage |
|-------|---------|-------|
| **textPrimary** | 0xFF141414 | Texte principal sur fond blanc |
| **textSecondary** | 0xFF545454 | Texte secondaire, désactivé |
| **textOnDark** | Colors.white | Texte sur fond sombre/image |
| **textOnPrimary** | Colors.white | Texte sur fond noir |

---

## 🎨 Palette de Couleurs

### Couleurs Primaires (validées Thierry)

| Token | Hex | Usage |
|-------|-----|-------|
| **primary** | 0xFF000000 | Noir principal - boutons, textes, icônes |
| **background** | 0xFFFFFFFF | Blanc fond principal |
| **surface** | 0xFFF5F5F5 | Fonds secondaires, cards |
| **border** | 0xFFEBEBEB | Bordures, séparateurs |
| **textPrimary** | 0xFF141414 | Texte principal |
| **textSecondary** | 0xFF545454 | Texte secondaire |

### Couleurs Fonctionnelles

| Token | Hex | Usage |
|-------|-----|-------|
| **success** | 0xFF249689 | États succès, validation |
| **warning** | 0xFFF9CF58 | Alertes, attention |
| **error** | 0xFFFF5963 | Erreurs, danger |
| **info** | 0xFFFFFFFF | Information, neutre |

### Couleurs Neutres

| Token | Hex | Usage |
|-------|-----|-------|
| **gray100** | 0xFF727272 | Texte désactivé, placeholders |
| **gray200** | 0xFFD9D9D9 | Bordures légères |
| **gray300** | 0xFFBFBFBF | Icônes désactivées |
| **transparent** | Colors.transparent | Interactions, overlays |

---

## 📐 Système d'Espacement

### Espacements Standards (baseline 4px)

| Token | Valeur | Usage Context |
|-------|--------|---------------|
| **xs** | 4.0 | Espacements minimaux |
| **sm** | 8.0 | Petits espacements |
| **md** | 12.0 | Espacements moyens |
| **lg** | 16.0 | Espacements standards |
| **xl** | 20.0 | Padding sections, cards |
| **xxl** | 24.0 | Grands espacements |
| **xxxl** | 32.0 | Très grands espacements |

### Espacements Safe Area (pour mobile)

| Token | Valeur | Usage |
|-------|--------|-------|
| **safeTop** | 70.0 | Top padding avec safe area |
| **safeTopLarge** | 84.0 | Top padding avec navigation |
| **safeTopXL** | 110.0 | Top padding pages principales |
| **safeTopXXL** | 130.0 | Top padding pages profil |

### Patterns EdgeInsets

```dart
// Standards MVP
EdgeInsetsDirectional.fromSTEB(20.0, 70.0, 20.0, 0.0)  // Page content
EdgeInsetsDirectional.fromSTEB(32.0, 70.0, 32.0, 40.0)  // Form sections
EdgeInsets.zero  // Reset padding
```

---

## 🔘 Système de Bordures

### Border Radius

| Token | Valeur | Usage |
|-------|--------|-------|
| **none** | 0.0 | Boutons, cards (design carré) |
| **sm** | 2.0 | Champs de formulaire |
| **md** | 8.0 | Avatars, petites icônes |
| **lg** | 12.0 | Images, cards secondaires |
| **xl** | 24.0 | Bottom sheets, modales |

### Patterns Observés

- **Boutons**: `BorderRadius.circular(0.0)` (carrés)
- **Sheets**: `BorderRadius.circular(24.0)` (arrondis en haut)
- **Inputs**: `BorderRadius.circular(2.0)` (légèrement arrondis)

---

## 🎯 Composants Clés

### Boutons

| Type | Style | État |
|------|-------|------|
| **Primary** | Fond noir, texte blanc | Default/Pressed/Disabled |
| **Secondary** | Fond blanc, bordure noir, texte noir | Default/Pressed/Disabled |
| **Text** | Texte noir seulement | Default/Pressed/Disabled |
| **Icon** | Icône noir/blanc selon contexte | Default/Pressed/Disabled |

**Hauteur standard**: 48.0px

### Champs de Formulaire

| Élément | Style |
|---------|-------|
| **TextField** | Bordure fine, coins légèrement arrondis (2.0) |
| **Label** | `labelMedium` (12.0) couleur secondaire |
| **Hint** | `labelSmall` (11.0) couleur secondaire |
| **Error** | Couleur `error` (0xFFFF5963) |

### Containers & Cards

| Type | Style |
|------|-------|
| **Card** | Fond blanc, bordure fine, coins carrés |
| **Sheet** | Fond blanc, coins arrondis 24.0 en haut |
| **AppBar** | Fond blanc, hauteur standard |
| **Avatar** | Cercle, bordure fine si nécessaire |

---

## 📱 Implémentation Technique

### Structure des Fichiers

```
lib/core/design/
├── design.dart                    # Barrel export (import principal)
├── lynewed_colors.dart           # Tokens de couleurs
├── lynewed_text_styles.dart      # Tokens de typographie
├── lynewed_spacing.dart          # Tokens d'espacement
├── lynewed_borders.dart          # Tokens de bordures
├── lynewed_component_styles.dart # Styles de composants
├── lynewed_design_system.dart    # API principale (mirroir FlutterFlowTheme)
├── lynewed_app_theme.dart        # ThemeData complet
└── test_design_system_widget.dart # Widget de test/validation
```

### Import Principal

```dart
// Un seul import pour tout le design system
import '/core/design/design.dart';
```

### Usage de Base

```dart
// Remplacement direct de FlutterFlowTheme
LynewedTheme.of(context).primaryBackground
LynewedTheme.of(context).bodyMedium
LynewedTheme.of(context).primary

// Accès direct aux tokens
LynewedColors.primary
LynewedTextStyles.headlineLarge
LynewedSpacing.xl
LynewedBorders.borderRadiusNone
```

### Composants Pré-définis

```dart
// Boutons
ElevatedButton(
  style: LynewedComponentStyles.primaryButton(),
  child: Text('Primary'),
  onPressed: () {},
)

// Inputs
TextField(
  decoration: LynewedComponentStyles.inputDecoration(
    labelText: 'Email',
  ),
)

// Cards
Container(
  decoration: LynewedComponentStyles.cardDecoration(),
  child: Text('Card content'),
)
```

---

## 🔄 Guide de Migration

### Étape 1: Mise à jour des Imports
```dart
// Avant
import '/flutter_flow/flutter_flow_theme.dart';

// Après  
import '/core/design/design.dart';
```

### Étape 2: Remplacement des Appels Theme
```dart
// Avant
FlutterFlowTheme.of(context).primaryBackground
FlutterFlowTheme.of(context).bodyMedium
FlutterFlowTheme.of(context).primary

// Après
LynewedTheme.of(context).primaryBackground
LynewedTheme.of(context).bodyMedium
LynewedTheme.of(context).primary
```

### Exemples de Migration Complète

#### Text Styling
```dart
// AVANT (FlutterFlow)
Text(
  'Welcome',
  style: FlutterFlowTheme.of(context).headlineLarge.override(
    fontFamily: 'Haas Grot Text Trial',
    color: Colors.white,
    fontSize: 32.0,
    fontWeight: FontWeight.w600,
  ),
)

// APRÈS (Lynewed)
Text(
  'Welcome',
  style: LynewedTextStyles.textOnDark(
    LynewedTheme.of(context).headlineLarge,
  ),
)
```

#### Button Styling
```dart
// AVANT (FlutterFlow)
FFButtonWidget(
  text: 'Get Started',
  options: FFButtonOptions(
    color: Color(0xFF000000),
    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
      fontFamily: 'Haas Grot Text Trial',
      color: Colors.white,
    ),
    borderRadius: BorderRadius.circular(0.0),
  ),
)

// APRÈS (Lynewed)
ElevatedButton(
  style: LynewedComponentStyles.primaryButton(),
  child: Text('Get Started'),
  onPressed: () {},
)
```

---

## 📋 Règles d'Usage

### Quand utiliser quel token

1. **Titres**: Utiliser l'échelle `display*` → `headline*` → `title*`
2. **Textes**: `bodyLarge` pour contenu principal, `bodyMedium` pour secondaire
3. **Espacements**: Baseline 4px, utiliser `safeTop*` pour les pages
4. **Bordures**: `none` pour design carré, `xl` pour sheets

### Exceptions Documentées

| Exception | Contexte | Raison |
|-----------|----------|--------|
| `Colors.white` | Texte sur fond sombre | Visibilité |
| `fontSize: 9.0` | Timestamps messages | Espace limité |
| `padding: 130.0` | Pages profil | Safe area + header |

---

## 🚨 Accessibilité

### Contrastes

- **Texte sur fond**: Ratio 4.5:1 minimum
- **Texte grand sur fond**: Ratio 3:1 minimum
- **Composants interactifs**: Ratio 3:1 minimum

### Tailles Minimales

- **Texte**: 12px minimum
- **Cibles tactiles**: 44px minimum
- **Espacements**: 8px minimum entre éléments

---

## ✅ Processus de Validation

### Checklist de Migration

#### Pré-Migration
- [ ] Backup du code actuel
- [ ] Installation des fichiers design system dans `/lib/core/design/`
- [ ] Test du design system avec composant d'exemple

#### Migration par Page
1. [ ] Mise à jour des imports: `import '/core/design/design.dart';`
2. [ ] Remplacement `FlutterFlowTheme.of(context)` → `LynewedTheme.of(context)`
3. [ ] Remplacement couleurs hardcodées avec tokens de couleur
4. [ ] Remplacement espacements hardcodés avec tokens d'espacement
5. [ ] Remplacement FFButtonWidget → ElevatedButton/OutlinedButton
6. [ ] Remplacement border radius hardcodés avec tokens de bordure
7. [ ] Test visuel d'apparence identique

#### Validation Post-Migration
- [ ] Toutes les pages rendent identiquement à avant
- [ ] Aucune erreur console
- [ ] Performance maintenue ou améliorée
- [ ] Code plus lisible et maintenable

---

## 📊 Méthodologie d'Audit

### Processus d'Extraction Systématique

#### Phase 1: Analyse du Thème Existant
1. **Analyse FlutterFlowTheme**: Extraction des couleurs et styles de base
2. **Identification Patterns**: Recherche des overrides et personnalisations
3. **Documentation Exceptions**: Capture des cas spéciaux avec contexte métier

#### Phase 2: Extraction des Patterns d'Usage
1. **Scan Automatisé**: Utilisation de grep pour extraire:
   - Couleurs: `grep -r "Color(0x" lib/pages/`
   - Tailles: `grep -r "fontSize:" lib/pages/`
   - Espacements: `grep -r "EdgeInsets" lib/pages/`
   - Bordures: `grep -r "borderRadius:" lib/pages/`

2. **Classification Sémantique**: Mapping des valeurs brutes vers tokens sémantiques
3. **Validation Croisée**: Comparaison avec usage réel dans 38 pages analysées

#### Phase 3: Création des Tokens
1. **Tokens de Couleurs**: Mapping hex → tokens sémantiques
2. **Tokens de Typographie**: Tailles → styles sémantiques (display, headline, title, body, label)
3. **Tokens d'Espacement**: Valeurs → échelle baseline 4px
4. **Tokens de Bordures**: Valeurs → usage sémantique (none, sm, md, lg, xl)

#### Phase 4: Documentation et Validation
1. **Documentation Complète**: Création du guide de référence
2. **Widget de Test**: Validation visuelle de tous les tokens
3. **Guide de Migration**: Exemples avant/après pour développeurs

### Patterns Extraits (Données Brutes)

#### Couleurs Identifiées
- **Colors.white**: Usage intensif pour texte sur fond sombre
- **Colors.transparent**: Interactions boutons, overlays
- **Color(0xFF000000)**: Noir principal (validé Thierry)
- **Color(0xFFFFFFFF)**: Blanc fond principal
- **Color(0xFFEBEBEB)**: Bordures, séparateurs
- **Color(0xFF141414)**: Texte principal
- **Color(0xFF545454)**: Texte secondaire

#### Tailles de Police (fréquence d'usage)
- **32.0**: Titres sections (high frequency)
- **22.0**: Titres cards (medium frequency)
- **18.0**: Sous-titres (high frequency)
- **16.0**: Texte principal (very high frequency)
- **14.0**: Texte secondaire (very high frequency)
- **13.0**: Petits textes (medium frequency)
- **12.0**: Labels (high frequency)
- **11.0**: Métadonnées (medium frequency)
- **10.0**: Mini textes (low frequency)
- **9.0**: Timestamps (low frequency)

#### Espacements (patterns observés)
- **70.0**: Top padding avec safe area
- **84.0**: Top padding avec navigation
- **110.0**: Top padding pages principales
- **130.0**: Top padding pages profil
- **20.0**: Padding horizontal standard
- **32.0**: Padding horizontal large

#### Bordures (patterns observés)
- **0.0**: Boutons, cards (design carré)
- **2.0**: Champs de formulaire
- **24.0**: Bottom sheets, modales

---

## 🧪 Widget de Test

### Validation Complète

Un widget de test complet (`test_design_system_widget.dart`) est disponible pour valider:

- **Typographie**: Tous les styles de display à caption
- **Couleurs**: Toutes les couleurs primaires et fonctionnelles
- **Boutons**: Primary, secondary, text buttons
- **Inputs**: Champs avec états normal, erreur, focus
- **Cards**: Styles standard et surface
- **Espacements**: Patterns standards et safe area

### Utilisation du Widget de Test

```dart
// Ajouter ce widget dans votre app pour validation
MaterialApp(
  theme: LynewedAppTheme.lightTheme,
  home: const DesignSystemTestWidget(),
)
```

---

## 📚 Références et Sources

### Patterns Extraits
- **38 pages** analysées dans `/lib/pages/`
- **100+** variations de fontSize documentées
- **50+** valeurs d'espacement identifiées
- **Couleurs**: Noir/blanc dominants confirmés

### Fichiers Source
- `lib/flutter_flow/flutter_flow_theme.dart` - Thème de base
- Pages représentatives: Auth, Bride, Pro, Shared
- Composants finaux: `lib/compo_finaux/`

### Documentation Complémentaire
- `docs/App/APP_SOURCE_OF_TRUTH.md` - Architecture et flux applicatifs
- `docs/App/ENUMS.md` - Énumérations et valeurs valides

---

## 🚀 Prochaines Étapes

### Application au Module Map

Avec ce design system unifié, nous pouvons maintenant:

1. **Corriger les problèmes UI/UX** du module map identifiés lors des tests
2. **Appliquer les styles cohérents** à tous les composants map
3. **Assurer la conformité** avec l'esthétique MVP approuvée
4. **Créer une base solide** pour la refactorisation des modules restants

### Modules Cibles pour Migration

1. **Map Module** (Phase 1-7) - Corrections UI/UX immédiates
2. **Auth Module** - Refactorisation complète
3. **Chat Module** - Refactorisation complète
4. **Other Modules** - Migration progressive

---

**Design System créé:** 2025-11-27  
**Basé sur:** MVP FlutterFlow existant (38 pages analysées)  
**Validé par:** Analyse complète des patterns réels  
**Prêt pour:** Refactorisation des modules restants  
**Référence principale:** `/docs/App/DESIGN_SYSTEM.md`
