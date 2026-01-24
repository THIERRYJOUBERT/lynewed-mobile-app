# Cycle TDD

> Test-Driven Development : La methode de developpement obligatoire pour {{PROJECT_NAME}}.

---

## Le Cycle

```
┌─────────┐
│   RED   │ ← Ecrire un test qui echoue
└────┬────┘
     │
     ▼
┌─────────┐
│  GREEN  │ ← Ecrire le code MINIMAL qui fait passer le test
└────┬────┘
     │
     ▼
┌─────────┐
│REFACTOR │ ← Nettoyer le code sans casser les tests
└────┬────┘
     │
     └──► Repeter pour chaque critere d'acceptance
```

---

## 1. RED - Test qui echoue

**Objectif** : Definir le comportement attendu AVANT d'ecrire le code.

```dart
// Exemple Flutter
test('should calculate SCE score correctly', () {
  final score = calculateSCE(volume: 1000, intensity: 0.8, quality: 0.9);
  expect(score, closeTo(72.0, 0.1));
});
```

**Regles** :
- Le test DOIT echouer (sinon il ne teste rien de nouveau)
- Le test definit le contrat de la fonction
- Run : `{{TEST_CMD}} test/specific_test.dart`

---

## 2. GREEN - Code minimal

**Objectif** : Faire passer le test avec le MOINS de code possible.

```dart
// Implementation minimale
double calculateSCE({required double volume, required double intensity, required double quality}) {
  return volume * intensity * quality / 10;
}
```

**Regles** :
- Pas d'optimisation
- Pas de features en plus
- Code "ugly" est OK a ce stade
- Le seul but : test vert

---

## 3. REFACTOR - Nettoyer

**Objectif** : Ameliorer le code SANS changer le comportement.

```dart
// Apres refactor
double calculateSCE({
  required double volume,
  required double intensity,
  required double quality,
}) {
  _validateInputs(volume, intensity, quality);
  return _computeScore(volume, intensity, quality);
}
```

**Regles** :
- Tests doivent rester verts
- Appliquer les patterns du codebase
- Supprimer duplication
- Ameliorer lisibilite

---

## Commandes Flutter

```bash
# Test specifique
{{TEST_CMD}} test/unit/sce_test.dart

# Tous les tests
{{TEST_CMD}}

# Avec couverture
{{TEST_CMD}} --coverage

# Analyse statique
{{LINT_CMD}}
```

---

## Checklist par Critere

- [ ] Test ecrit AVANT code
- [ ] Test echoue (RED confirme)
- [ ] Code minimal ecrit
- [ ] Test passe (GREEN confirme)
- [ ] Code refactore
- [ ] Tests toujours verts
- [ ] Passer au critere suivant
