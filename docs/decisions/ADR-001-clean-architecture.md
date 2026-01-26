# ADR-001: Adoption de Clean Architecture

**Date:** 2025-01
**Statut:** Accepté
**Décideurs:** Équipe fondatrice Lynewed

---

## Contexte

Le projet Lynewed a été initialement développé avec FlutterFlow, un outil low-code qui génère du code Flutter. Après plusieurs mois de développement, l'équipe a rencontré des difficultés:

- Code généré difficile à maintenir et à comprendre
- Logique métier mélangée avec l'UI
- Tests unitaires impossibles à écrire
- Duplication de code importante
- Dépendances circulaires entre composants

Avec 248 utilisateurs actifs et des fonctionnalités complexes (carte interactive, chat temps réel, appels vidéo), une architecture plus robuste était nécessaire.

---

## Décision

Nous avons décidé d'adopter Clean Architecture avec 3 couches distinctes:

1. **Domain** - Logique métier pure
   - Entities (modèles métier)
   - Repository interfaces (contrats)

2. **Data** - Accès aux données
   - Datasources (Supabase, APIs)
   - Repository implementations
   - Models/DTOs

3. **Presentation** - Interface utilisateur
   - Pages et Widgets
   - State management (Cubit)

Chaque module fonctionnel (`lib/features/[module]/`) suit cette structure.

---

## Conséquences

### Positives

- **Testabilité**: 3069 tests unitaires et widget possibles
- **Maintenabilité**: Modules indépendants, responsabilités claires
- **Onboarding**: Nouveaux développeurs comprennent rapidement la structure
- **Évolutivité**: Facile d'ajouter de nouveaux modules
- **Réutilisation**: Logique métier partageable entre plateformes

### Négatives

- **Boilerplate**: Plus de fichiers et de code structurel
- **Courbe d'apprentissage**: L'équipe doit maîtriser le pattern
- **Overhead initial**: Chaque feature nécessite domain/data/presentation

### Risques

- **Over-engineering**: Risque de créer trop de couches pour des features simples
  - Mitigation: Appliquer Clean Architecture uniquement aux modules complexes

---

## Alternatives Considérées

### Alternative 1: MVC/MVVM Simple

- **Description:** Architecture plus légère avec Model-View-Controller
- **Avantages:** Moins de boilerplate, plus rapide à implémenter
- **Inconvénients:** Testabilité limitée, couplage plus fort
- **Raison du rejet:** Insuffisant pour la complexité du projet (carte, chat, vidéo)

### Alternative 2: Garder le Code FlutterFlow

- **Description:** Continuer avec le code généré
- **Avantages:** Pas de migration, développement rapide
- **Inconvénients:** Maintenabilité catastrophique, pas de tests
- **Raison du rejet:** Dette technique insoutenable à long terme

---

## Références

- [ARCHITECTURE.md](../../ARCHITECTURE.md) - Documentation architecture actuelle
- [Clean Architecture - Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture Examples](https://resocoder.com/flutter-clean-architecture-tdd/)
