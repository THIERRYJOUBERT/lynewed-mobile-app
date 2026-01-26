# ADR-006: Gestion des Secrets avec flutter_dotenv

**Date:** 2026-01-25
**Statut:** Accepté
**Décideurs:** Équipe Lynewed

---

## Contexte

EPIC-05 (Security Cleanup) avait migré la gestion des secrets de `flutter_dotenv` (runtime) vers `--dart-define-from-file` (compile-time) pour une meilleure sécurité.

**Problème découvert:**
- Les scripts de build (`scripts/build_and_run.sh`) n'utilisent pas `--dart-define-from-file`
- Résultat: Les secrets (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, etc.) étaient vides au runtime
- L'app crashait avec un écran blanc après le splash screen
- 248 utilisateurs actifs en production impactés

**Chronologie:**
1. EPIC-05: Migration vers `AppSecrets` avec `--dart-define-from-file`
2. Tests manuels: Build via IDE (Xcode/Android Studio) fonctionnait
3. Build via script: `build_and_run.sh` ne passait pas les secrets
4. Production: Écran blanc, Supabase non initialisé

---

## Décision

Nous avons décidé de **revenir à `flutter_dotenv`** pour le chargement des secrets au runtime:

```dart
// main.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  // ...
}

// Accès aux secrets
final supabaseUrl = dotenv.env['SUPABASE_URL'];
```

**Actions:**
1. Restaurer `flutter_dotenv` dans `main.dart`
2. Restaurer `dotenv.env['KEY']` dans `supabase.dart`, `app_constants.dart`
3. Garder la classe `AppSecrets` dans le code (pour future migration)
4. Documenter la décision dans cet ADR

---

## Conséquences

### Positives

- **Compatibilité totale**: Tous les scripts de build fonctionnent
- **Stabilité production**: 248 utilisateurs non impactés
- **Pas de modification CI/CD**: Workflows existants préservés
- **Flexibilité**: .env facile à modifier sans rebuild

### Négatives

- **Sécurité moindre**: Le fichier `.env` est dans le bundle de l'app
- **Secrets lisibles**: Si le bundle est décompilé, secrets accessibles
- **Non-recommandé**: Flutter recommande `--dart-define` pour les secrets

### Risques

- **Extraction de secrets**: Un attaquant peut décompiler l'app
  - Mitigation: Les clés sont publiques (anon key) ou limitées en scope
  - Mitigation: `.env` non commité dans git
  - Mitigation: Rotation des clés possible via dashboard Supabase

---

## Alternatives Considérées

### Alternative 1: `--dart-define-from-file` (Rejetée temporairement)

- **Description:** Secrets injectés au compile-time
- **Avantages:** Secrets non dans le bundle, tree-shaking possible
- **Inconvénients:** Nécessite modification de TOUS les scripts et CI/CD
- **Raison du rejet:** Effort trop important, risque de régression en prod
- **Note:** À reconsidérer quand CI/CD sera modernisé

### Alternative 2: Backend-only Secrets

- **Description:** Appeler une Edge Function pour obtenir les configs
- **Avantages:** Secrets jamais dans l'app
- **Inconvénients:** Latence, complexité, chicken-and-egg (besoin de URL Supabase pour appeler)
- **Raison du rejet:** Trop complexe pour le bénéfice

### Alternative 3: flutter_dotenv (Choisie)

- **Description:** Charger `.env` au runtime
- **Avantages:** Simple, compatible avec tout, flexible
- **Inconvénients:** Sécurité moindre
- **Raison du rejet:** N/A - Alternative choisie

---

## Plan de Migration Future

Quand le CI/CD sera modernisé:

1. Mettre à jour `scripts/build_and_run.sh` pour utiliser `--dart-define-from-file`
2. Mettre à jour les workflows GitHub Actions
3. Supprimer `flutter_dotenv` et utiliser `AppSecrets`
4. Créer ADR-007 pour documenter la migration

---

## Références

- [SESSION-2026-01-25-IOS-BUILD-FIX.md](../epics/EPIC-01-MIGRATION-CLEAN-ARCHITECTURE/stories/SESSION-2026-01-25-IOS-BUILD-FIX.md) - Documentation du fix
- [flutter_dotenv package](https://pub.dev/packages/flutter_dotenv)
- [Flutter: Configuring the environment](https://docs.flutter.dev/deployment/flavors)
