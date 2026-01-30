# Optimisation des Tests Flutter

> Regles pour executer les tests efficacement et eviter les problemes d'output.

---

## Problemes a Eviter

1. **Output too large** : Le terminal sature avec l'output verbeux
2. **Temps excessif** : Compilation repetee inutilement
3. **Tests non cibles** : Executer tous les tests quand un seul suffit

---

## Commandes Optimisees

### Test Specifique (PREFERE)

```bash
# Optimal : compact + no-pub + fichier specifique
flutter test --reporter compact --no-pub path/to/test.dart

# Pour voir juste le resultat
flutter test path/to/test.dart 2>&1 | grep -E "All tests|passed|failed"
```

### Tests d'un Dossier

```bash
# Feature specifique
flutter test --reporter compact --no-pub test/features/map/

# Avec summary seulement
flutter test --reporter compact --no-pub test/features/map/ 2>&1 | tail -3
```

### Tous les Tests (Rare)

```bash
# Seulement avant commit/PR
flutter test --reporter compact --no-pub 2>&1 | tail -10
```

---

## Regles d'Application

1. **TOUJOURS** utiliser `--reporter compact` pour eviter output trop large
2. **TOUJOURS** utiliser `--no-pub` sauf si les deps ont change
3. **PREFERER** tester le fichier/dossier specifique au lieu de tout
4. **UTILISER** `| tail -N` ou `| grep` pour filtrer l'output
5. **EVITER** d'executer `flutter test` sans options

---

## Analyse Statique

```bash
# Fichier specifique (rapide)
flutter analyze path/to/file.dart

# Projet entier (avant commit)
flutter analyze --fatal-infos
```

---

## Quand Utiliser Quoi

| Situation | Commande |
|-----------|----------|
| Apres edit d'un fichier | `flutter test --reporter compact --no-pub test/.../fichier_test.dart` |
| Apres edit d'une feature | `flutter test --reporter compact --no-pub test/features/xxx/` |
| Avant commit | `flutter test --reporter compact --no-pub 2>&1 \| tail -10` |
| Debug test fail | `flutter test path/to/test.dart` (output complet) |
