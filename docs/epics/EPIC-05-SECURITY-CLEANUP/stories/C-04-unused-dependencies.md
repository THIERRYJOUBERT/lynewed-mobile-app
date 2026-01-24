# Story C-04: Supprimer Dependances Inutilisees

## Metadata
| Champ | Valeur |
|-------|--------|
| **ID** | C-04 |
| **Epic** | EPIC-05-SECURITY-CLEANUP |
| **Priorite** | P3 - BASSE |
| **Estimation** | 2h |
| **Statut** | NOT_STARTED |

---

## Description

En tant que **maintainer**, je veux supprimer les dependances inutilisees afin de **reduire la taille du build et la surface d'attaque**.

---

## Contexte

Le `pubspec.yaml` contient de nombreuses dependances. Certaines peuvent etre:
- Non importees (jamais utilisees)
- Redondantes (fonctionnalite couverte par autre package)
- Legacy (FlutterFlow heritage)

### Dependances Suspectes

| Package | Version | Suspicion | Raison |
|---------|---------|-----------|--------|
| `hive` | 2.2.3 | HAUTE | Aucun import `import.*hive` trouve |
| `sqflite` | 2.3.3+1 | HAUTE | Aucun import direct, peut-etre transitif |
| `sqflite_common` | 2.5.4+3 | HAUTE | Dependance de sqflite |
| `csv` | 6.0.0 | MOYENNE | A verifier usage |
| `json_path` | 0.7.2 | MOYENNE | A verifier usage |
| `flutter_staggered_grid_view` | 0.7.0 | MOYENNE | Peut-etre remplace |
| `percent_indicator` | 4.2.2 | MOYENNE | A verifier usage |
| `page_transition` | 2.1.0 | MOYENNE | Peut-etre remplace par go_router |
| `aligned_dialog` | 0.0.6 | MOYENNE | A verifier usage |
| `from_css_color` | 2.0.0 | BASSE | Utilise dans schema_util |

---

## Criteres d'Acceptance

- [ ] Audit de chaque dependance dans pubspec.yaml
- [ ] Pour chaque package, verifier les imports
- [ ] Identifier dependances transitives vs directes
- [ ] Supprimer dependances confirmees inutiles
- [ ] `flutter pub get` reussi
- [ ] `flutter analyze` passe
- [ ] Tests passent
- [ ] Build iOS/Android reussi

---

## Checklist Cleanup

### Audit Dependances

Pour chaque package:
```bash
grep -r "import.*package:PACKAGE_NAME" lib/
```

### Packages a Auditer

| Package | Grep Result | Action |
|---------|-------------|--------|
| `hive` | 0 imports directs | Supprimer? |
| `sqflite` | 0 imports directs | Supprimer? |
| `csv` | ? | Verifier |
| `json_path` | ? | Verifier |
| `flutter_staggered_grid_view` | ? | Verifier |
| `percent_indicator` | ? | Verifier |
| `page_transition` | ? | Verifier |
| `aligned_dialog` | ? | Verifier |
| `from_css_color` | 2 (schema_util) | Garder |

### Verification Transitives

Certains packages sont dependances d'autres:
```bash
flutter pub deps --style=tree
```

### Suppression

1. Commenter le package dans pubspec.yaml
2. `flutter pub get`
3. `flutter analyze`
4. Si pas d'erreur, supprimer la ligne
5. `flutter test`
6. `flutter build ios --no-codesign`

---

## Implementation

### Script Audit Dependances

```bash
#!/bin/bash
# audit_dependencies.sh

# Extraire packages de pubspec.yaml
packages=$(grep -E "^\s+[a-z_]+:" pubspec.yaml | grep -v "sdk:" | sed 's/:.*//' | tr -d ' ')

for pkg in $packages; do
  imports=$(grep -r "import.*package:$pkg" lib --include="*.dart" | wc -l)
  if [ "$imports" -eq 0 ]; then
    echo "UNUSED?: $pkg (0 direct imports)"
  fi
done
```

### Analyser Dependances Transitives

```bash
# Voir l'arbre de dependances
flutter pub deps --style=tree

# Voir qui depend de quoi
flutter pub deps --style=list | grep sqflite
```

---

## Dependances Confirmees Utilisees

| Package | Usage |
|---------|-------|
| `supabase_flutter` | Backend principal |
| `firebase_messaging` | Push notifications |
| `google_maps_flutter` | Map |
| `flutter_google_places_sdk` | Places search |
| `agora_rtc_engine` | Video calls |
| `go_router` | Navigation |
| `provider` | State management |
| `flutter_secure_storage` | Secure storage |
| ... | ... |

---

## Impact sur Taille Build

| Package | Taille Estimee |
|---------|----------------|
| hive | ~200KB |
| sqflite | ~300KB |
| Autres | ~100KB |
| **Total potentiel** | **~600KB** |

---

## Risques

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Supprimer dependance transitive | MOYEN | flutter pub get echouera |
| Package utilise dynamiquement | BAS | Tests E2E |
| Plugin natif manquant | HAUT | Build iOS/Android test |

---

## Definition of Done

- [ ] Audit dependances complete
- [ ] Packages inutiles supprimes
- [ ] flutter pub get reussi
- [ ] flutter analyze passe
- [ ] Tests passent
- [ ] Build iOS/Android reussi
- [ ] PR reviewee et mergee
