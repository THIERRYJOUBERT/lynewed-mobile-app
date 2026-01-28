# EPIC-05: Audit Securite et Nettoyage Dead Code

## Resume Executif

Cet Epic adresse deux preoccupations critiques pour la sante a long terme du projet Lynewed:

1. **Audit Securite Complet** - L'application gere des donnees utilisateurs sensibles (profiles, messages, photos) et n'a jamais fait l'objet d'un audit securite systematique. Avec le code legacy FlutterFlow, des vulnerabilites potentielles peuvent exister.

2. **Nettoyage Dead Code** - Environ 40% du codebase est potentiellement inutilise (heritage FlutterFlow). Ce code mort augmente la surface d'attaque, ralentit les builds, et complique la maintenance.

---

## Analyse du Codebase (Findings Initiaux)

### Problemes Securite Identifies

| Categorie | Severite | Description |
|-----------|----------|-------------|
| **Secrets en dur** | CRITIQUE | Firebase API key en dur dans `lib/firebase_options.dart` (AIzaSyAXDspp3RSvw234OfrfSHvkXgbvbsliedg) |
| **Fichier .env expose** | HAUTE | `.env` contient des secrets (Supabase key, Google API keys, Agora App ID) et est reference dans pubspec.yaml comme asset |
| **TODOs securite** | MOYENNE | 10+ TODOs non resolus concernant logging, monitoring, crash reporting |
| **Debug prints** | MOYENNE | ~20 occurrences de debugPrint/print() pouvant fuiter des donnees en production |
| **HTTP sans validation** | MOYENNE | Appels HTTP directs sans validation systematique (8 occurrences Uri.parse) |

### Dead Code Identifie

| Categorie | Estimation | Details |
|-----------|-----------|---------|
| **flutter_flow/** | ~14 fichiers | Modules FlutterFlow legacy (theme, widgets, navigation, utils) |
| **Assets vides** | 5 dossiers | `assets/audios/`, `assets/videos/`, `assets/jsons/`, `assets/pdfs/`, `assets/rive_animations/` contiennent uniquement des favicon.png placeholder |
| **Images non referencees** | ~10 fichiers | Images dans `assets/images/` potentiellement non utilisees |
| **Dependances inutilisees** | ~5-10 packages | sqflite, hive (pas d'import reel), potentiellement d'autres |
| **Fichiers orphelins** | A auditer | Pages/widgets jamais importes dans nav.dart |

### Statistiques Codebase

- **Total lignes Dart**: ~88,600
- **Fichiers les plus volumineux**:
  - `my_wedding_page.dart` (1,822 lignes)
  - `weddings_hub_pro_page.dart` (1,546 lignes)
  - `wedding_onboarding_widget.dart` (1,477 lignes)
- **Dossiers principaux**:
  - `lib/flutter_flow/` - Legacy FlutterFlow utilities
  - `lib/custom_code/` - Actions et widgets custom (~85 fichiers)
  - `lib/features/` - Clean Architecture (chat, map, notifications, my_wedding, etc.)
  - `lib/pages/` - Pages principales

---

## Objectifs

### Phase 1: Audit Securite (Prioritaire)

1. **S-01**: Audit secrets exposes et remediation
2. **S-02**: Audit validation inputs utilisateur
3. **S-03**: Audit flux d'authentification
4. **S-04**: Audit exposition donnees sensibles
5. **S-05**: Checklist OWASP Mobile Top 10

### Phase 2: Cleanup Dead Code

6. **C-01**: Identifier et supprimer fichiers orphelins
7. **C-02**: Nettoyer fonctions inutilisees
8. **C-03**: Purger assets non references
9. **C-04**: Supprimer dependances inutilisees
10. **C-05**: Refactor flutter_flow/ legacy

---

## Contraintes

- **NE PAS supprimer de code sans verifier les imports** (analyse statique obligatoire)
- **Documenter TOUT ce qui est supprime** (pour rollback potentiel)
- **Prioriser securite sur cleanup** (securite = bloquant)
- **Ne pas toucher au backend Supabase** (hors scope)
- **Tests de regression obligatoires** apres chaque modification
- **Zero warnings** apres cleanup (`flutter analyze --fatal-infos`)

---

## Definition of Done (Epic)

- [ ] Tous les secrets migres vers une solution securisee
- [ ] Aucune vulnerabilite critique ou haute non resolue
- [ ] Rapport d'audit securite documente
- [ ] Dead code supprime avec documentation rollback
- [ ] Reduction mesurable de la taille du build
- [ ] Tous les tests passent
- [ ] Zero warnings flutter analyze

---

## Risques

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Casser des features en supprimant du code | HAUT | Analyse imports + tests exhaustifs avant suppression |
| Secrets deja compromis | CRITIQUE | Rotation immediate des cles apres remediation |
| Regression sur auth | HAUT | Tests E2E sur tous les flows auth |
| Dependances cachees | MOYEN | Flutter analyze + build complet avant merge |

---

## Timeline Estimee

| Phase | Duree | Dependances |
|-------|-------|-------------|
| Phase 1 (Securite) | 3-4 jours | - |
| Phase 2 (Cleanup) | 4-5 jours | Phase 1 completee |
| **Total** | **7-9 jours** | - |

---

## References

- [OWASP Mobile Security Testing Guide](https://owasp.org/www-project-mobile-security-testing-guide/)
- [Flutter Security Best Practices](https://flutter.dev/docs/deployment/obfuscate)
- [Dart Code Analysis](https://dart.dev/tools/analysis)
