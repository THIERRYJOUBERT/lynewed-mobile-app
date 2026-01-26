# ADR-004: Design System Unifié

**Date:** 2025-01
**Statut:** Accepté
**Décideurs:** Équipe fondatrice Lynewed

---

## Contexte

L'interface utilisateur de Lynewed présentait des problèmes de cohérence:

- **Styles dispersés**: Couleurs et typographies définies partout
- **Duplication**: Même bouton codé différemment selon les écrans
- **Inconsistance**: Espacements et rayons de bordure variables
- **Maintenance difficile**: Changement de style = modifications multiples
- **Legacy FlutterFlow**: Mélange de styles FlutterFlow et custom

---

## Décision

Nous avons décidé de créer un **Design System unifié** dans `lib/core/design/`:

**Structure:**
```
lib/core/design/
├── design.dart              # Export principal
├── lynewed_colors.dart      # Palette de couleurs
├── lynewed_text_styles.dart # Typographie
├── lynewed_spacing.dart     # Espacements
├── lynewed_borders.dart     # Rayons de bordure
├── lynewed_component_styles.dart
├── lynewed_app_theme.dart   # Theme Material
└── widgets/                 # Composants réutilisables
```

**Principes:**
- Import unique: `import '/core/design/design.dart';`
- Tokens nommés sémantiquement (ex: `LynewedColors.textPrimary`)
- Composants prêts à l'emploi (ex: `LynewedButton`, `LynewedSheet`)
- Font weight max w500 (jamais w600+)

---

## Conséquences

### Positives

- **Cohérence**: UI uniforme sur tous les écrans
- **Rapidité**: Développement plus rapide avec composants prêts
- **Maintenabilité**: Un seul endroit pour les modifications
- **Onboarding**: Nouveaux devs comprennent vite les conventions
- **Accessibilité**: Contrôle centralisé des contrastes

### Négatives

- **Effort initial**: Création et documentation du système
- **Discipline**: L'équipe doit utiliser le système
- **Rigidité**: Certaines customisations plus compliquées

### Risques

- **Non-adoption**: L'équipe continue d'utiliser des styles ad-hoc
  - Mitigation: Review PR, règles lint, documentation

---

## Alternatives Considérées

### Alternative 1: Material Design Par Défaut

- **Description:** Utiliser uniquement les widgets Material Flutter
- **Avantages:** Pas d'effort, large documentation
- **Inconvénients:** Look générique, pas de branding Lynewed
- **Raison du rejet:** Besoin d'une identité visuelle distinctive

### Alternative 2: Package Design System Externe

- **Description:** Utiliser un package comme `shadcn_ui` ou `getwidget`
- **Avantages:** Prêt à l'emploi, communauté
- **Inconvénients:** Customisation limitée, dépendance externe
- **Raison du rejet:** Contrôle total sur l'identité visuelle requis

### Alternative 3: Design System Custom (Choisie)

- **Description:** Créer un système sur mesure pour Lynewed
- **Avantages:** 100% adapté aux besoins, évolutif
- **Inconvénients:** Effort de création et maintenance
- **Raison du rejet:** N/A - Alternative choisie

---

## Références

- [docs/App/DESIGN_SYSTEM.md](../App/DESIGN_SYSTEM.md) - Documentation complète (1041 lignes)
- [lib/core/design/](../../lib/core/design/) - Implémentation
