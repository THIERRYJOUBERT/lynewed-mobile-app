# Story STORY-05: Mise a Jour des Packages Database

## Description

Mettre a jour les packages de base de donnees locale SQLite.

| Package | Actuel | Cible | Changelog |
|---------|--------|-------|-----------|
| sqflite | 2.3.3+1 | 2.4.2 | [pub.dev](https://pub.dev/packages/sqflite/changelog) |
| sqflite_common | 2.5.4+3 | 2.5.6 | [pub.dev](https://pub.dev/packages/sqflite_common/changelog) |

## Criteres d'Acceptance

- [ ] `sqflite` mis a jour de 2.3.3+1 a 2.4.2
- [ ] `sqflite_common` mis a jour de 2.5.4+3 a 2.5.6
- [ ] `flutter pub get` reussit sans erreur
- [ ] `flutter analyze --fatal-infos` passe sans warnings
- [ ] App compile sur iOS (`flutter build ios --no-codesign`)
- [ ] App compile sur Android (`flutter build apk --debug`)
- [ ] Donnees locales accessibles apres mise a jour
- [ ] Ecriture en base fonctionne
- [ ] Lecture en base fonctionne
- [ ] Migrations fonctionnent (si applicable)

## Breaking Changes Potentiels

### sqflite 2.4.x
- Verifier les changements d'API de `openDatabase`
- Potentiels changements dans la gestion des transactions
- Nouvelle gestion des erreurs possible

### sqflite_common 2.5.6
- Devrait etre transparent si sqflite est compatible

## Tests Manuels Requis

1. **Test Lecture**
   - Ouvrir l'app avec des donnees existantes
   - Verifier que toutes les donnees locales sont accessibles

2. **Test Ecriture**
   - Creer/modifier des donnees locales
   - Verifier la persistence

3. **Test Cache**
   - Verifier que le cache local fonctionne
   - Mettre en mode avion et verifier l'acces aux donnees cachees

4. **Test Migration** (si schema change)
   - Installer ancienne version
   - Ajouter des donnees
   - Mettre a jour
   - Verifier que les donnees sont preservees

## Rollback

```bash
# Dans pubspec.yaml, revenir a:
sqflite: 2.3.3+1
sqflite_common: 2.5.4+3

# Puis:
flutter pub get
```

## Estimation

- **Effort**: S (1-2h)
- **Risque**: Moyen (donnees locales critiques)

## Notes

- Tester sur une version de dev avec donnees reelles
- Backup recommande avant test
- Si le projet utilise Hive (2.2.3), verifier les interactions
