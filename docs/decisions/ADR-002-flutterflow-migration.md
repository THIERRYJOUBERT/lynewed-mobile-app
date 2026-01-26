# ADR-002: Migration FlutterFlow vers Code Natif

**Date:** 2025-01
**Statut:** Accepté
**Décideurs:** Équipe fondatrice Lynewed

---

## Contexte

Lynewed a été initialement prototypé avec FlutterFlow pour valider rapidement le concept. FlutterFlow est un outil no-code/low-code qui génère du code Flutter.

Problèmes rencontrés:
- **Limitations de customisation**: Impossible d'implémenter certaines features (carte complexe, chat avancé)
- **Code généré**: Difficile à lire, maintenir et débugger
- **Vendor lock-in**: Dépendance forte à FlutterFlow pour les modifications
- **Performance**: Code non optimisé, widgets inutilisés inclus
- **Tests**: Impossible d'écrire des tests automatisés

---

## Décision

Nous avons décidé de migrer progressivement vers du code Flutter natif tout en conservant certains utilitaires FlutterFlow compatibles:

1. **Migration par modules**: Chaque feature est migrée indépendamment vers Clean Architecture
2. **Conservation temporaire**: `lib/flutter_flow/` et `lib/pages/` gardés pour compatibilité
3. **Remplacement progressif**: Les pages legacy sont remplacées au fur et à mesure

**Résultat de la migration (EPIC-01):**
- 40,588 lignes de code legacy supprimées
- 15 modules Clean Architecture créés
- 3,069 tests ajoutés
- 0 warnings

---

## Conséquences

### Positives

- **Contrôle total**: Possibilité d'implémenter n'importe quelle feature
- **Performance**: Code optimisé, tree-shaking efficace
- **Testabilité**: 3,069 tests unitaires et widget
- **Maintenabilité**: Code structuré et documenté
- **Indépendance**: Plus de dépendance à FlutterFlow

### Négatives

- **Temps de migration**: EPIC-01 a nécessité 42 stories
- **Legacy à maintenir**: `lib/flutter_flow/` et `lib/pages/` encore présents
- **Effort continu**: Chaque nouvelle feature en code natif

### Risques

- **Régressions**: Risque de bugs lors de la migration
  - Mitigation: Migration module par module avec tests

---

## Alternatives Considérées

### Alternative 1: Rester sur FlutterFlow

- **Description:** Continuer à utiliser FlutterFlow pour tout
- **Avantages:** Développement rapide pour features simples
- **Inconvénients:** Limitations bloquantes pour features avancées
- **Raison du rejet:** Carte interactive et chat impossible à implémenter correctement

### Alternative 2: Réécriture Complète

- **Description:** Tout réécrire from scratch sans garder l'existant
- **Avantages:** Code 100% clean, pas de legacy
- **Inconvénients:** Temps énorme, risque de régression, app hors ligne longtemps
- **Raison du rejet:** 248 utilisateurs actifs, impossible de mettre l'app en pause

### Alternative 3: Migration Progressive (Choisie)

- **Description:** Migrer module par module en gardant l'existant fonctionnel
- **Avantages:** App toujours fonctionnelle, risques contrôlés
- **Inconvénients:** Legacy temporaire, complexité accrue
- **Raison du rejet:** N/A - Alternative choisie

---

## Références

- [EPIC-01 Tracking](../epics/EPIC-01-MIGRATION-CLEAN-ARCHITECTURE/TRACKING.md)
- `lib/flutter_flow/` - Code FlutterFlow conservé
- `lib/pages/` - Pages legacy
