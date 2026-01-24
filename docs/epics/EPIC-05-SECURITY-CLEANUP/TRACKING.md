# TRACKING - EPIC-05: Audit Securite et Nettoyage Dead Code

## Statut Global

| Metrique | Valeur |
|----------|--------|
| **Statut** | NOT_STARTED |
| **Progression** | 0/10 stories |
| **Date Creation** | 2026-01-24 |
| **Derniere MAJ** | 2026-01-24 |

---

## Phase 1: Audit Securite

| Story | Titre | Statut | Priorite | Assignee |
|-------|-------|--------|----------|----------|
| S-01 | Audit et remediation secrets exposes | NOT_STARTED | P0 - CRITIQUE | - |
| S-02 | Audit validation inputs utilisateur | NOT_STARTED | P1 - HAUTE | - |
| S-03 | Audit flux d'authentification | NOT_STARTED | P1 - HAUTE | - |
| S-04 | Audit exposition donnees sensibles | NOT_STARTED | P1 - HAUTE | - |
| S-05 | Checklist OWASP Mobile Top 10 | NOT_STARTED | P2 - MOYENNE | - |

---

## Phase 2: Dead Code Cleanup

| Story | Titre | Statut | Priorite | Assignee |
|-------|-------|--------|----------|----------|
| C-01 | Identifier et supprimer fichiers orphelins | NOT_STARTED | P2 - MOYENNE | - |
| C-02 | Nettoyer fonctions inutilisees | NOT_STARTED | P2 - MOYENNE | - |
| C-03 | Purger assets non references | NOT_STARTED | P3 - BASSE | - |
| C-04 | Supprimer dependances inutilisees | NOT_STARTED | P3 - BASSE | - |
| C-05 | Refactor flutter_flow/ legacy | NOT_STARTED | P3 - BASSE | - |

---

## Changelog

### 2026-01-24
- Creation de l'Epic EPIC-05-SECURITY-CLEANUP
- Analyse initiale du codebase completee
- 10 stories creees (5 securite + 5 cleanup)

---

## Metriques de Succes

### Securite
- [ ] 0 secrets en dur dans le code
- [ ] 0 vulnerabilite critique ou haute
- [ ] Rapport d'audit securite documente

### Cleanup
- [ ] Reduction taille build: Objectif -15%
- [ ] Reduction lignes de code: Objectif -20%
- [ ] 0 warnings flutter analyze

---

## Blockers Actuels

_Aucun blocker actuellement_

---

## Notes

### Findings Critiques Initiaux

1. **Firebase API Key en dur** (`lib/firebase_options.dart`)
   - Cle: `AIzaSyAXDspp3RSvw234OfrfSHvkXgbvbsliedg`
   - Action: Migration vers solution securisee + rotation

2. **Fichier .env expose comme asset**
   - Contient: Supabase URL/Key, Google API Keys, Agora App ID
   - Action: Retirer de pubspec.yaml assets, utiliser dart-define ou --dart-define-from-file

3. **Assets vides avec placeholders**
   - Dossiers: audios/, videos/, jsons/, pdfs/, rive_animations/
   - Action: Supprimer ou nettoyer
