# LYNEWED V1 - Application Mobile

Application Flutter de mise en relation mariées/professionnels du mariage.

## ⚠️ ENVIRONNEMENT PRODUCTION

**CE PROJET EST EN PRODUCTION** avec des utilisateurs actifs sur iOS et Android.

| Élément | Valeur |
|---------|--------|
| **Statut** | 🔴 PRODUCTION |
| **Projet Supabase** | `LYNEWED-V1-APP` |
| **Project ID** | `hekyovgnovhfhmkpfrna` |
| **Région** | `eu-central-2` |
| **MCP Connecté** | ✅ Oui (plugin Supabase) |

### Règles de Sécurité Production

1. **JAMAIS** modifier le schéma DB sans migration testée
2. **JAMAIS** exécuter de DELETE/UPDATE sans WHERE précis
3. **TOUJOURS** tester sur une branche Supabase avant merge en prod
4. **TOUJOURS** vérifier l'impact sur les 248 utilisateurs actifs
5. **PRÉFÉRER** les migrations réversibles (avec rollback plan)

## Contexte de Travail

Ce projet utilise une **methodologie structuree** avec des workflows, des agents, et une documentation rigoureuse.

**Mode de travail** via workflows definis dans `.claude/skills/`. Mode **supervised** (interactif) ou **autonomous** (agent autonome).

---

## Regles Principales

### Qualite Production

- Code maintenable, bien architecture
- 0 warnings (`flutter analyze --fatal-infos`)
- Tests pour chaque feature
- Pas de dette technique

### Documentation

- Documenter les decisions importantes
- Mettre a jour TRACKING.md apres chaque story

### Code

- **Commentaires en anglais** (code et commentaires)
- **Nommage clair** et conventions Dart

---

## Tech Stack

| Élément | Technologie |
|---------|-------------|
| **Langage** | Dart |
| **Framework** | Flutter |
| **Backend** | Supabase (PostgreSQL + Auth + Storage + Realtime + Edge Functions) |
| **Video Calls** | Agora |
| **Notifications** | Firebase Cloud Messaging |
| **Géolocalisation** | PostGIS |
| **Paiements** | Stripe |

## Supabase - Tables Principales

| Table | Rows | Description |
|-------|------|-------------|
| `profiles` | 248 | Utilisateurs (bride/professional) |
| `professional_details` | 49 | Détails pros (portfolio, tarifs) |
| `weddings` | 8 | Mariages avec lieu, budget, équipe |
| `chat_rooms` / `chat_messages` | 80/199 | Chat temps réel |
| `notifications_outbox` | 245 | Queue push notifications |
| `video_sessions` | 59 | Sessions vidéo Agora |

## Commandes

```bash
flutter test                       # Tests (3069 tests)
flutter analyze --fatal-infos      # Linting (0 warnings obligatoire)
flutter build                      # Build
flutter run                        # Run
```

---

## Structure Projet

### Documentation (`docs/`)

| Dossier | Role |
|---------|------|
| `docs/specs/` | **Vision produit** - PRD, specs |
| `docs/detailed/` | **Details techniques** |
| `docs/epics/` | **Developpement** - Stories, tracking |

### Configuration Claude (`.claude/`)

| Dossier | Role |
|---------|------|
| `.claude/skills/` | **Workflows** - `/dev-story`, `/debug`, etc. |
| `.claude/rules/` | **Regles** - Qualite, TDD |
| `.claude/context/` | **Architecture** - SYSTEM.md |
| `.claude/agents/` | **Agents** - PM, SM, explorers |

---

## Workflows Disponibles

### Developper

| Workflow | Usage |
|----------|-------|
| `/dev-story` | Implementer une story (TDD, Review Adversariale) |
| `/oneshot` | Dev rapide sans Epic/Story |
| `/debug` | Investigation scientifique de bugs |
| `/commit` | Commit avec verifications |
| `/build-ios` | Build et lance l'app iOS sur simulateur |

### Creer

| Workflow | Usage |
|----------|-------|
| `/create-epic` | Creer un Epic depuis PRD |
| `/create-story` | Decomposer Epic en Stories |
| `/create-workflow` | Creer un nouveau workflow |
| `/create-slash-commands` | Creer des slash commands personnalisees |
| `/create-subagents` | Creer des agents specialises |
| `/claude-memory` | Gerer CLAUDE.md et .claude/rules/ |
| `/mission` | Brief client → Mission + Epics + Stories (cascade adaptative) |

### Maintenance

| Workflow | Usage |
|----------|-------|
| `/project-cleanup` | Nettoyer, optimiser, moderniser le projet (Ralph) |
| `/security-audit` | Audit securite OWASP + proposition Epic remediation |

### Qualite

| Workflow | Usage |
|----------|-------|
| `/challenge` | Critique iterative de livrables avant commit |

### Utilitaires

| Workflow | Usage |
|----------|-------|
| `/learn` | Comprendre une feature/concept |
| `/documentation` | Documenter session de travail |
| `/sync-project` | Synchroniser references |
| `/sync-template` | Synchroniser depuis template distant |
| `/update-config` | Mettre a jour config depuis template distant |
| `/launch-epic` | Lancer execution d'un Epic (supervised/autonomous) |
| `/setup-ralph` | Configurer boucle autonome Ralph (features pendant la nuit) |

---

## État du Projet

### EPIC-01: Migration Clean Architecture ✅ COMPLETE (2026-01-26)

| Métrique | Valeur |
|----------|--------|
| Stories | 42/42 (100%) |
| Tests | 3069 |
| Warnings | 0 |
| Features CA | **15 modules** |

**Modules Clean Architecture (`lib/features/`):**
auth, chat, content, dashboard, feed, home, map, my_wedding, notifications, profile, settings, support, video_call, **weddings_hub_pro**, wishlist

> **Note**: iOS minimum 15.0 (Firebase 12.x requirement). Secrets via flutter_dotenv (runtime .env).

### Epics Complétés

| Epic | Description | Status |
|------|-------------|--------|
| EPIC-01 | Migration Clean Architecture | ✅ COMPLETE |
| EPIC-02 | Tests additionnels | ✅ COMPLETE |
| EPIC-04 | Documentation | ✅ COMPLETE (2026-01-26) |
| EPIC-05 | Security cleanup | ✅ COMPLETE |

### Epics En Cours / Attente

| Epic | Description | Status |
|------|-------------|--------|
| EPIC-03 | Dependencies update | ⏸️ PARTIAL (64%) |

### Mission 2026 (NEW - 2026-01-28)

| Epic | PRD | Description | Stories | Est. |
|------|-----|-------------|---------|------|
| EPIC-06 | APP-00 | Prerequisites (BLOQUANT) | 6 | 0.5j |
| EPIC-07 | APP-01 | Reviews (Avis clients) | 9 | 0.5j |
| EPIC-08 | APP-02 | Reminders (Rappels RDV) | 8 | 0.5j |
| EPIC-09 | APP-03 | Invitations (Guests) | 12 | 2j |
| EPIC-10 | APP-04 | Photos/Videos | 10 | 1.5j |
| EPIC-11 | APP-05 | Stripe Integration | 12 | 1j |
| EPIC-12 | APP-06 | Reels Generation | 10 | 1.5j |
| EPIC-13 | APP-07 | Map Filters | 9 | 1j |
| EPIC-14 | APP-08 | Marketplace | 26 | 7j |

**Total** : 102 stories, 15 jours, 4500€ - PRD: `docs/specs/MISSION-01-EVOLUTIONS-2026.md`

---

## Index Rapide

| Besoin | Où chercher |
|--------|-------------|
| Architecture technique | `ARCHITECTURE.md` |
| Guide contribution | `CONTRIBUTING.md` |
| Documentation API | `docs/api/INDEX.md` |
| Décisions architecture | `docs/decisions/INDEX.md` |
| Architecture workflows | `.claude/context/SYSTEM.md` |
| Règles techniques | `.claude/rules/` |
| Epics et Stories | `docs/epics/` |
| Design System | `docs/App/DESIGN_SYSTEM.md` |

---

## MCP Supabase - Outils Disponibles

Le MCP Supabase est connecté et permet :

| Outil | Usage |
|-------|-------|
| `list_tables` | Voir le schéma de la base |
| `execute_sql` | Requêtes SELECT (lecture) |
| `apply_migration` | DDL avec versioning |
| `get_logs` | Debug (auth, postgres, edge-function) |
| `get_advisors` | Audit sécurité/performance |
| `list_edge_functions` | Voir les Edge Functions |
| `deploy_edge_function` | Déployer une Edge Function |

### Autres Projets Supabase (même organisation)

| Projet | ID | Usage |
|--------|-----|-------|
| LYNEWED-V1-CRM | `pjcorrkwafjskmzmimon` | Back-office admin |
| Tom Leo App Lynewed | `odzkhcplevcqbuhzqsmq` | Dev/Test |
| WEBSITE LYNEWED | `ojnyblbxrndhirjqdhro` | Site web |
