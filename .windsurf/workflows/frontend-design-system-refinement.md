---
description: Design System Refinement & UI/UX Unification for Sheets and Map Components
---

# Frontend Design System Refinement Workflow

## 🎯 Objectif Principal

Créer un Design System unifié, élégant et pixel-parfait pour tous les sheets et composants de la map, en s'inspirant de la page profil/settings qui sert de référence pour l'élégance visuelle.

---

## 📋 Contexte du Projet

### État Actuel
- **Module Map**: 100% fonctionnel mais UI/UX incohérente
- **Problème**: Sheets avec paddings, typographie, poids et styles différents
- **Design System**: `/lib/core/design/` existe mais mal appliqué
- **Référence**: Page profil/settings (modèle d'élégance à copier)

### Philosophie de Design
- **Palette**: Noir/blanc avec nuances de gris
- **Couleurs d'état**: Vert (succès/vérifié), Rouge (erreur/non autorisé)
- **Formes**: Arrondis minimaux (4px max pour chips/boutons)
- **Typographie**: Textes fins, hiérarchie visuelle subtile
- **Pas de**: Couleurs vives, arrondis prononcés, gras excessif

---

## 🔄 Workflow en 4 Phases

### Phase 1: Audit & Analyse (2-3h)

#### 1.1 Localiser et Analyser la Page de Référence
**Action**: Trouver la page profil/settings et extraire les spécifications exactes

```bash
# Rechercher la page profil/settings
find /Users/leoberthet/Desktop/lynewed_v1/lib -name "*.dart" -type f | xargs grep -l "PROFIL\|profile\|settings" | head -5
```

**À extraire**:
- Tailles de texte exactes (px)
- Poids de police (font weight)
- Valeurs de padding (vertical/horizontal)
- Espacements entre sections
- Hiérarchie typographique

#### 1.2 Audit des Sheets Actuels
**Fichiers à analyser**:
```
lib/features/map/presentation/sheets/
├── alert_create_sheet.dart      (~650 lignes)
├── wedding_create_sheet.dart    (~800 lignes)
├── professional_details_sheet.dart
├── alert_details_sheet.dart
└── wedding_details_sheet.dart
```

**Grille d'audit**:
| Composant | Taille | Poids | Padding | Couleur | Arrondi |
|-----------|--------|-------|---------|---------|---------|
| Titres principaux | ? | ? | ? | ? | ? |
| Sous-titres | ? | ? | ? | ? | ? |
| Corps de texte | ? | ? | ? | ? | ? |
| Chips | ? | ? | ? | ? | ? |
| TextFields | ? | ? | ? | ? | ? |
| Boutons | ? | ? | ? | ? | ? |

#### 1.3 Documentation des Incohérences
Créer un rapport détaillé des différences trouvées avec captures d'écran si possible.

### Phase 2: Refonte des Tokens Design System (1-2h)

#### 2.1 Mise à Jour des Tokens de Typographie
**Fichier**: `/lib/core/design/lynewed_text_styles.dart`

```dart
// Basé sur l'analyse de la page profil
class LynewedTextStyles {
  // Titres principaux (style "PROFIL")
  static const titleLarge = TextStyle(
    fontSize: 18.0,  // À ajuster selon analyse
    fontWeight: FontWeight.w600,  // Moins gras
    height: 1.2,
  );
  
  // Titres de sections
  static const bodyLarge = TextStyle(
    fontSize: 16.0,  // À ajuster
    fontWeight: FontWeight.w500,  // Plus fin
    height: 1.3,
  );
  
  // Corps de texte
  static const bodyMedium = TextStyle(
    fontSize: 14.0,  // À ajuster
    fontWeight: FontWeight.w400,  // Fin
    height: 1.4,
  );
}
```

#### 2.2 Standardisation des Espacements
**Fichier**: `/lib/core/design/lynewed_spacing.dart`

```dart
class LynewedSpacing {
  // Basé sur l'analyse profil/settings
  static const sheetPadding = EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0);
  static const sectionSpacing = 16.0;
  static const itemSpacing = 12.0;
  // etc...
}
```

#### 2.3 Refonte des Styles de Composants
**Fichier**: `/lib/core/design/lynewed_component_styles.dart`

```dart
class LynewedComponentStyles {
  // Chips élégants (4px radius, texte fin)
  static final chipTheme = ChipThemeData(
    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
    labelStyle: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
  );
  
  // TextFields épurés
  static final inputDecoration = InputDecoration(
    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
  );
}
```

#### 2.4 Mise à Jour Documentation
**Fichier**: `/docs/App/DESIGN_SYSTEM.md`
- Ajouter section "Typography Hierarchy"
- Ajouter section "Component Standards v2.0"
- Inclure exemples visuels

### Phase 3: Application Systématique (3-4h)

#### 3.1 Ordre de Priorité d'Application
1. **alert_create_sheet.dart** (Plus complexe, ~650 lignes)
2. **wedding_create_sheet.dart** (Plus complexe, ~800 lignes)
3. **professional_details_sheet.dart**
4. **alert_details_sheet.dart**
5. **wedding_details_sheet.dart**

#### 3.2 Processus par Fichier

**Pour chaque sheet**:

1. **Remplacer les styles locaux**:
```dart
// AVANT
TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)

// APRÈS
LynewedTextStyles.bodyLarge.copyWith(color: LynewedColors.textPrimary)
```

2. **Standardiser les paddings**:
```dart
// AVANT
padding: EdgeInsets.all(16)

// APRÈS
padding: LynewedSpacing.sheetPadding
```

3. **Appliquer les thèmes de composants**:
```dart
// AVANT
FilterChip(
  labelStyle: TextStyle(...),
  padding: EdgeInsets(...),
  shape: RoundedRectangleBorder(...),
)

// APRÈS
FilterChip(
  labelStyle: LynewedComponentStyles.chipTheme.labelStyle,
  padding: LynewedComponentStyles.chipTheme.padding,
  shape: LynewedComponentStyles.chipTheme.shape,
)
```

#### 3.3 Validation par Fichier
Après chaque fichier modifié:
- Vérifier la compilation
- Vérifier l'apparence en simulateur
- Prendre screenshot pour comparaison

### Phase 4: Validation & Itération (1-2h)

#### 4.1 Check-list de Validation
- [ ] Tous les sheets utilisent les mêmes tokens
- [ ] Typographie cohérente (tailles, poids, couleurs)
- [ ] Paddings uniformes
- [ ] Arrondis de 4px maximum
- [ ] Textes fins avec hiérarchie claire
- [ ] Couleurs minimalistes (noir/blanc/gris + états)

#### 4.2 Processus d'Itération
1. **Présenter les changements** avec screenshots avant/après
2. **Feedback utilisateur** sur éléments spécifiques
3. **Ajustements ciblés** des tokens concernés
4. **Re-application** si nécessaire
5. **Validation finale** pixel-parfait

---

## 🎯 Fichiers Clés à Modifier

### Tokens Design System
```
lib/core/design/
├── lynewed_text_styles.dart      # Typographie hiérarchique
├── lynewed_spacing.dart          # Espacements standardisés
├── lynewed_component_styles.dart # Styles composants
└── design.dart                   # Barrel export
```

### Sheets à Refactoriser
```
lib/features/map/presentation/sheets/
├── alert_create_sheet.dart       # Priorité 1
├── wedding_create_sheet.dart     # Priorité 2
├── professional_details_sheet.dart
├── alert_details_sheet.dart
└── wedding_details_sheet.dart
```

### Documentation
```
docs/App/
└── DESIGN_SYSTEM.md              # Mise à jour v2.0
```

---

## ⚠️ Pièges à Éviter

### Erreurs Communes
- **Ne pas analyser la page profil** → Copier des valeurs incorrectes
- **Modifier les sheets avant les tokens** → Duplication de code
- **Utiliser des valeurs "à l'œil"** → Manque de précision
- **Oublier un composant** → Incohérence visuelle
- **Ne pas documenter** → Perte du savoir-faire

### Bonnes Pratiques
- **Toujours mesurer** les valeurs exactes sur la page de référence
- **Créer des tokens** avant de modifier les composants
- **Appliquer systématiquement** les mêmes tokens
- **Valider étape par étape** avec screenshots
- **Documenter** chaque décision de design

---

## 🔍 Validation Finale

### Critères de Succès
1. **Unification visuelle**: Tous les sheets identiques en style
2. **Élégance**: Typographie fine et hiérarchique
3. **Lisibilité**: Textes plus petits mais toujours clairs
4. **Cohérence**: Paddings et espacements uniformes
5. **Minimalisme**: Noir/blanc/gris avec touches de couleur

### Processus de Validation
1. **Screenshot comparatif** avant/après pour chaque sheet
2. **Test utilisateur** sur simulateur
3. **Check-list finale** de tous les critères
4. **Documentation mise à jour**
5. **Go/No-Go** pour déploiement

---

## 📚 Références

- **Design System actuel**: `/lib/core/design/`
- **Documentation**: `/docs/App/DESIGN_SYSTEM.md`
- **Code Map**: `/lib/features/map/`
- **Projet**: `/docs/PROJECT.md`

---

**Note**: Ce workflow doit être suivi rigoureusement. La qualité du Design System final déterminera la qualité de toute l'application future.
