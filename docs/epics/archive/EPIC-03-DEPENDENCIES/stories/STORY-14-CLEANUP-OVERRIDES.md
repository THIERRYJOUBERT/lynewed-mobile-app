# Story STORY-14: Cleanup des Dependency Overrides

## Description

Supprimer les `dependency_overrides` qui ne sont plus necessaires apres la mise a jour de tous les packages.

### Overrides Actuels

```yaml
# pubspec.yaml actuel
dependency_overrides:
  http: 1.4.0
  rxdart: 0.27.7
  uuid: ^4.0.0
```

## Criteres d'Acceptance

- [ ] Analyser pourquoi chaque override existe
- [ ] Tenter de supprimer chaque override
- [ ] `flutter pub get` reussit sans conflits
- [ ] `flutter analyze --fatal-infos` passe
- [ ] App compile sur iOS et Android
- [ ] Tous les tests passent
- [ ] Pas de regression fonctionnelle

## Analyse des Overrides

### http: 1.4.0

**Pourquoi cet override existe-t-il?**
- Conflit de versions entre Supabase et d'autres packages
- Supabase packages avaient besoin d'une version specifique

**Peut-on le supprimer?**
- Apres mise a jour de Supabase (STORY-06), verifier si toujours necessaire
- Version disponible: 1.6.0
- Tester sans override

### rxdart: 0.27.7

**Pourquoi cet override existe-t-il?**
- Conflit entre packages utilisant rxdart
- Version 0.28.0 disponible avec breaking changes potentiels

**Peut-on le supprimer?**
- Apres mise a jour de tous les packages, verifier
- rxdart 0.28.0 a des breaking changes
- Tester avec la version resolue par pub

### uuid: ^4.0.0

**Pourquoi cet override existe-t-il?**
- Conflit de versions entre packages
- Force une version specifique

**Peut-on le supprimer?**
- Version 4.5.2 disponible
- Apres autres mises a jour, devrait se resoudre naturellement

## Procedure de Test

### Etape 1: Documenter l'etat initial

```bash
# Sauvegarder les versions resolues actuelles
flutter pub deps > deps_before.txt
```

### Etape 2: Tenter de supprimer les overrides un par un

```yaml
# Test 1: Supprimer http override
dependency_overrides:
  # http: 1.4.0  # Commente
  rxdart: 0.27.7
  uuid: ^4.0.0
```

```bash
flutter pub get
# Si echec -> noter l'erreur
# Si succes -> flutter analyze && flutter build
```

### Etape 3: Repeter pour chaque override

Documenter le resultat pour chaque:
- Override supprimable: OUI/NON
- Si NON, pourquoi (quel conflit)
- Version resolue si supprime

## Tests Manuels Requis

Si des overrides sont supprimes:

### 1. Test Supabase (http, potentiellement uuid)

```
a) Authentification
   - Login/Logout
   - Session persistence

b) Database operations
   - Read/Write

c) Realtime
   - Subscriptions
```

### 2. Test Streams (rxdart)

```
a) Reactive flows
   - Verifier les streams dans l'app
   - Verifier les debounce/throttle
   - Verifier les transformations
```

### 3. Test UUID Generation

```
a) Creation d'entites
   - Creer un nouveau record
   - Verifier que l'UUID est genere
   - Verifier le format
```

## Resultat Attendu

### Scenario Ideal

Tous les overrides peuvent etre supprimes:

```yaml
# pubspec.yaml apres cleanup
dependencies:
  # ...

# Plus de dependency_overrides!
```

### Scenario Realiste

Certains overrides peuvent encore etre necessaires:

```yaml
dependency_overrides:
  # Documenter pourquoi chaque override est encore necessaire
  some_package: x.x.x  # Raison: conflit avec package_a et package_b
```

## Documentation Post-Cleanup

Mettre a jour le CLAUDE.md ou un fichier de documentation avec:

```markdown
## Dependency Overrides

### Overrides supprimes
- `http` - Plus necessaire depuis Supabase 2.12.0
- `uuid` - Plus necessaire depuis package_x 1.2.3

### Overrides restants
- `rxdart: 0.27.7` - Necessaire car:
  - package_a requiert ^0.27.0
  - package_b requiert ^0.28.0
  - Incompatibilite non resolue upstream
```

## Rollback

```bash
# Restaurer tous les overrides
dependency_overrides:
  http: 1.4.0
  rxdart: 0.27.7
  uuid: ^4.0.0

flutter pub get
```

## Estimation

- **Effort**: S (2-3h)
- **Risque**: Faible (si bien teste)

## Notes

### Quand Executer Cette Story

**IMPORTANT**: Executer cette story EN DERNIER, apres toutes les autres mises a jour.

Les conflits qui necessitaient les overrides peuvent avoir ete resolus par les mises a jour.

### Monitoring

Apres suppression des overrides, surveiller:
- Logs d'erreur en production
- Performances (certains packages ont des perfs differentes selon version)
- Comportement des features impactees

### Issue Upstream

Si un override ne peut pas etre supprime a cause d'un conflit reel:
1. Documenter le probleme
2. Ouvrir une issue sur le repo du package concerne
3. Planifier une revue future quand le conflit sera resolu
