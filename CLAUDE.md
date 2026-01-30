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
| `stripe_accounts` | 0 | Comptes Stripe Connect (EPIC-11) |
| `purchases` | 0 | Achats/transactions (EPIC-11) |
| `stripe_events` | 0 | Events Stripe webhook (EPIC-11) |

## Commandes

```bash
# Tests
flutter test                              # Tous les tests (3069 tests)
flutter test --no-pub                     # Skip pub check (plus rapide)
flutter test path/to/test.dart            # Test spécifique
flutter test --reporter compact           # Output minimal (évite Output too large)
flutter test --reporter compact --no-pub  # Combinaison optimale

# Analyse
flutter analyze --fatal-infos             # Linting (0 warnings obligatoire)
flutter analyze path/to/file.dart         # Analyser un fichier spécifique

# Build/Run
flutter build                             # Build
flutter run                               # Run
```

### Optimisation des Tests (IMPORTANT)

**Pour éviter "Output too large" et accélérer :**

```bash
# ✅ RECOMMANDÉ - Output minimal + skip pub
flutter test --reporter compact --no-pub path/to/test.dart 2>&1 | tail -5

# ✅ Pour voir juste le résultat final
flutter test path/to/test.dart 2>&1 | grep -E "All tests|passed|failed"

# ❌ ÉVITER - Output verbeux qui sature
flutter test  # Sans options = output ligne par ligne
```

**Gains approximatifs :**
- `--no-pub` : -2-3s par run
- `--reporter compact` : output 10x plus petit
- Test spécifique vs all : -80% du temps

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
| Tests | 3148+ |
| Warnings | 0 |
| Features CA | **16 modules** |

**Modules Clean Architecture (`lib/features/`):**
auth, chat, content, dashboard, feed, **guest**, home, map, my_wedding, notifications, **payments**, profile, **reviews**, settings, support, video_call, **weddings_hub_pro**, wishlist

> **Note**: iOS minimum 15.0 (Firebase 12.x requirement). Secrets via flutter_dotenv (runtime .env).

### Epics Complétés

| Epic | Description | Status |
|------|-------------|--------|
| EPIC-01 | Migration Clean Architecture | ✅ COMPLETE |
| EPIC-02 | Tests additionnels | ✅ COMPLETE |
| EPIC-04 | Documentation | ✅ COMPLETE (2026-01-26) |
| EPIC-05 | Security cleanup | ✅ COMPLETE |
| EPIC-06 | Prerequisites | ✅ COMPLETE (2026-01-29) |
| EPIC-07 | Reviews (Avis clients) | ✅ COMPLETE (2026-01-29) |
| EPIC-09 | Invitations (Guests) | ✅ COMPLETE (2026-01-30) |
| EPIC-11 | Stripe Integration | ✅ COMPLETE (2026-01-29) |
| EPIC-13 | Map Filters | ✅ COMPLETE (2026-01-30) |

### Epics En Cours / Attente

| Epic | Description | Status |
|------|-------------|--------|
| EPIC-03 | Dependencies update | ⏸️ PARTIAL (64%) |

### Mission 2026 (NEW - 2026-01-28)

| Epic | PRD | Description | Stories | Est. |
|------|-----|-------------|---------|------|
| EPIC-06 | APP-00 | Prerequisites (BLOQUANT) | 6 | ✅ DONE |
| EPIC-07 | APP-01 | Reviews (Avis clients) | 9 | ✅ DONE |
| EPIC-08 | APP-02 | Reminders (Rappels RDV) | 8 | 0.5j |
| EPIC-09 | APP-03 | Invitations (Guests) | 12 | ✅ DONE |
| EPIC-10 | APP-04 | Photos/Videos | 10 | 1.5j |
| EPIC-11 | APP-05 | Stripe Integration | 12 | ✅ DONE |
| EPIC-12 | APP-06 | Magazines Photo | 12 | 1.5j |
| EPIC-13 | APP-07 | Map Filters | 9 | ✅ DONE |
| EPIC-14 | APP-08 | Marketplace | 26 | 7j |

**Total** : 106 stories (créées), 15 jours, 4500€ - PRD: `docs/specs/MISSION-01-EVOLUTIONS-2026.md`

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

## MCP Connectés

### MCP Supabase

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

#### Autres Projets Supabase (même organisation)

| Projet | ID | Usage |
|--------|-----|-------|
| LYNEWED-V1-CRM | `pjcorrkwafjskmzmimon` | Back-office admin |
| Tom Leo App Lynewed | `odzkhcplevcqbuhzqsmq` | Dev/Test |
| WEBSITE LYNEWED | `ojnyblbxrndhirjqdhro` | Site web |

---

### MCP Stripe ⚠️ COMPTE PRODUCTION

| Élément | Valeur |
|---------|--------|
| **Statut** | 🔴 **PRODUCTION** (mode test activé) |
| **Compte** | Compte officiel Lynewed |
| **Mode** | `sk_test_*` (test) - clés live disponibles |
| **Config** | `.mcp.json` (racine projet) |

#### ⛔ PRODUITS EXISTANTS - NE PAS MODIFIER

Ces produits sont les **offres d'abonnement pro du CRM** - déjà en production :

| Produit | ID | Description |
|---------|-----|-------------|
| **EARLY ACCESS** | `prod_TCeouF5WM5cN8Z` | Plan essentiel pour démarrer |
| **PREMIUM VISIBILITY** | `prod_TCesp37xX9fPKZ` | CRM étendu, masterclasses |
| **ULTIMATE ACCESS** | `prod_TCeuXHDpPaS7hB` | Package leaders, CRM illimité |

**RÈGLES STRICTES :**
1. **JAMAIS** modifier/supprimer ces produits existants
2. **JAMAIS** modifier leurs prix associés
3. **TOUJOURS** créer de NOUVEAUX produits pour les features (magazines, etc.)
4. **TOUJOURS** utiliser des metadata claires pour identifier l'origine

#### Outils MCP Stripe Disponibles

| Outil | Usage | Sécurité |
|-------|-------|----------|
| `list_products` | Lister les produits | ✅ Safe |
| `list_prices` | Lister les prix | ✅ Safe |
| `list_customers` | Lister les clients | ✅ Safe |
| `create_product` | Créer un produit | ⚠️ Nouveaux uniquement |
| `create_price` | Créer un prix | ⚠️ Pour nouveaux produits |
| `create_payment_link` | Créer lien de paiement | ✅ Safe |
| `list_subscriptions` | Lister abonnements | ✅ Safe |
| `search_stripe_documentation` | Rechercher docs Stripe | ✅ Safe |

#### Usage pour EPIC-11 et EPIC-12

Pour les **Magazines Photo** (EPIC-12), créer de NOUVEAUX produits :
```
Nom: "Magazine Photo Mariage"
Type: one_time (pas subscription)
Metadata: { "source": "lynewed-app", "feature": "magazine" }
```

Pour toute intégration Stripe, utiliser le MCP pour :
- Vérifier la structure existante avant création
- Créer les produits/prix nécessaires
- Tester les webhooks avec les clés test

---

### API FedEx - Marketplace Shipping

| Élément | Valeur |
|---------|--------|
| **Statut** | 🟡 **TEST** (sandbox) |
| **Projet** | Lynewed Marketplace Mobile |
| **Compte** | `740561073` |
| **Config** | `.env.fedex` (racine projet - gitignored) |
| **Docs** | Context7 `/websites/developer_fedex_api_en-us` |

#### APIs Activées

| API | Usage | Endpoint |
|-----|-------|----------|
| **Address Validation** | Valider adresses avant envoi | `/address/v1/addresses/resolve` |
| **Rates and Transit Times** | Calculer frais de port au checkout | `/rate/v1/rates/quotes` |
| **Ship API** | Générer étiquettes + tracking | `/ship/v1/shipments` |

#### Credentials (TEST)

```
FEDEX_CLIENT_ID=l7915167202dbc400c9c338d7bbf591bc0
FEDEX_CLIENT_SECRET=3be7c39d9ab1402eba0a867430edfcf6
FEDEX_ACCOUNT_NUMBER=740561073
FEDEX_API_URL=https://apis-sandbox.fedex.com
```

> ⚠️ **Production** : Remplacer par `https://apis.fedex.com` et nouvelles clés prod

#### Authentification OAuth2

```typescript
// Obtenir un token (valide 1h)
const response = await fetch('https://apis-sandbox.fedex.com/oauth/token', {
  method: 'POST',
  headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  body: `grant_type=client_credentials&client_id=${FEDEX_CLIENT_ID}&client_secret=${FEDEX_CLIENT_SECRET}`
});
const { access_token } = await response.json();
```

#### Usage pour EPIC-14 Marketplace

Workflow automatisé :
1. **Checkout** : Rates API → afficher frais de port
2. **Paiement OK** : Ship API → générer étiquette PDF
3. **Envoi** : Vendeuse télécharge étiquette dans l'app
4. **Suivi** : Tracking automatique via numéro retourné par Ship API

#### Documentation Context7

Pour rechercher dans la doc FedEx :
```
mcp__plugin_context7_context7__query-docs:
- libraryId: "/websites/developer_fedex_api_en-us"
- query: "create shipment label"
```
