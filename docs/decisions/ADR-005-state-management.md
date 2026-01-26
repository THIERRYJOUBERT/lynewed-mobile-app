# ADR-005: Stratégie de State Management

**Date:** 2025-01
**Statut:** Accepté
**Décideurs:** Équipe fondatrice Lynewed

---

## Contexte

L'application Lynewed a différents besoins de gestion d'état:

- **État global**: Utilisateur connecté, préférences, thème
- **État feature**: Liste de conversations, marqueurs carte, messages
- **État local**: Formulaires, animations, UI temporaire

Le code FlutterFlow utilisait Provider avec `FFAppState` pour tout. Cette approche unique montrait ses limites avec la complexité croissante.

---

## Décision

Nous avons décidé d'adopter une stratégie **hybride** avec 3 solutions selon le use case:

### 1. Provider - État Global

Pour l'état partagé dans toute l'app:
- `FFAppState` (legacy, utilisateur, préférences)
- Configuration globale
- Thème

```dart
// Usage
final appState = context.read<FFAppState>();
final currentUser = appState.currentUser;
```

### 2. Cubit (flutter_bloc) - État Feature

Pour l'état complexe des modules Clean Architecture:
- `MapCubit`, `ChatCubit`, `MyWeddingCubit`
- Logique métier encapsulée
- Testable et prédictible

```dart
// Usage
BlocProvider(
  create: (_) => MapCubit(repository),
  child: MapPage(),
)

// Dans le widget
context.read<MapCubit>().loadMarkers(bounds);
```

### 3. ValueNotifier - État Local

Pour l'état UI simple et temporaire:
- État de formulaire
- Animations
- Toggles UI

```dart
// Usage
final isExpanded = ValueNotifier<bool>(false);

ValueListenableBuilder<bool>(
  valueListenable: isExpanded,
  builder: (_, value, __) => Icon(value ? Icons.expand_less : Icons.expand_more),
)
```

---

## Conséquences

### Positives

- **Flexibilité**: Outil adapté au problème
- **Testabilité**: Cubit très facile à tester avec `bloc_test`
- **Séparation**: Logique métier isolée dans les Cubits
- **Familiarité**: Provider connu de l'équipe (FlutterFlow)
- **Performance**: ValueNotifier léger pour l'UI

### Négatives

- **Complexité**: 3 patterns à maîtriser
- **Inconsistance potentielle**: Risque de mauvais choix de pattern
- **Overhead**: Plus de code que solution unique

### Risques

- **Confusion**: Quand utiliser quoi?
  - Mitigation: Guidelines clairs dans CONTRIBUTING.md
- **Migration Provider**: FFAppState legacy à migrer
  - Mitigation: Migration progressive vers Cubit

---

## Guidelines de Choix

| Situation | Solution |
|-----------|----------|
| Utilisateur connecté, préférences globales | Provider (FFAppState) |
| Feature complète (chat, carte, wedding) | Cubit |
| Formulaire, toggle UI, animation | ValueNotifier |
| Liste simple sans logique | setState ou ValueNotifier |

---

## Alternatives Considérées

### Alternative 1: Provider Uniquement

- **Description:** Utiliser Provider pour tout (comme FlutterFlow)
- **Avantages:** Simplicité, une seule approche
- **Inconvénients:** Difficile à tester, logique dispersée
- **Raison du rejet:** Insuffisant pour features complexes

### Alternative 2: Riverpod

- **Description:** Evolution de Provider, plus moderne
- **Avantages:** Compile-time safety, moins de boilerplate
- **Inconvénients:** Migration importante, équipe pas formée
- **Raison du rejet:** Trop de changement par rapport à l'existant

### Alternative 3: GetX

- **Description:** Package tout-en-un (state, routes, DI)
- **Avantages:** Simple, rapide
- **Inconvénients:** Magie noire, testabilité limitée, opinionated
- **Raison du rejet:** Pas assez prédictible pour une app production

---

## Références

- [flutter_bloc documentation](https://bloclibrary.dev)
- [Provider documentation](https://pub.dev/packages/provider)
- [CONTRIBUTING.md](../../CONTRIBUTING.md) - Guidelines state management
