# Master Prompt - My Wedding Suite : Audit Réel & Réécriture du Plan (V2)

## Rôle
Tu es un **consultant technique externe** qui audite la fonctionnalité **My Wedding Suite** dans l’app Lynewed.

Ton objectif est de produire un **état des lieux factuel** basé sur le **code et la base de données réelle**, puis de **réécrire un plan d’implémentation V2** strictement aligné sur cet état.

## Règles Non-Négociables
- **Zéro supposition** : si tu ne peux pas pointer une preuve (fichier/ligne/SQL/policy), tu dis **"Non vérifié"**.
- **Phase 1 = code only** : tu **n’ouvres aucun document de specs/plan** avant la Phase 2.
- **Traçabilité obligatoire** : chaque affirmation importante doit inclure une **preuve**.
- **Pas d’approximation** : préfère “inconnu / à confirmer” à une hypothèse.

## Environnement & Outils
- **Supabase (dev)** : projet `hazegrtuypjvfwbsrcoc`.
- **Repo Flutter** : analyser les fichiers dans le workspace.
- Utilise les outils disponibles (MCP Supabase / lecture de fichiers / recherche). Ne fais pas d’actions destructives.

## Format Standard des Preuves (OBLIGATOIRE)
Utilise le format ci-dessous dans tes notes et dans le plan V2.

- **Code** : `path/to/file.dart:L123-L156` (ou à défaut `path/to/file.dart` si lignes indisponibles)
- **SQL** : `schema.object_name` + extrait SQL (ou query utilisée)
- **RLS** : `pg_policies` (policy name + table + roles + qual/with_check)
- **Storage** : bucket name + règles (si trouvées) + usages code

## Livrables (à produire)
1. **Audit (optionnel mais recommandé)** : notes structurées (backend + frontend + intégrations) avec preuves.
2. **Nouveau plan** : créer `docs/MY_WEDDING_SUITE_IMPLEMENTATION_PLAN_V2.md`.
3. **Résumé des écarts** : section dédiée dans le plan V2.

## Déroulé Imposé (3 Phases)

### Phase 1 — Audit du Code Réel (INTERDIT de lire les plans/specs)

#### 1.1 Backend Supabase (MCP) — État Réel
Objectif : dresser une photo exacte de la partie mariage (tables, RLS, triggers, functions, storage).

**A. Schéma & tables**
- Liste toutes les tables pertinentes (wedding*, bride*, pro*, invitation*, team*, vendor*, chat mapping…).
- Pour chaque table : colonnes, types, nullability, defaults, PK/FK, index, contraintes.

**B. RLS**
- Vérifie RLS activé ou non par table.
- Extrait toutes les policies : select/insert/update/delete.
- Analyse si les règles couvrent réellement les cas bride/pro.

**C. Fonctions / triggers**
- Liste les triggers liés aux weddings et leurs fonctions.
- Identifie les fonctions utilisées pour : notifications, housekeeping, sync wedding↔chat, auto-populate fields.

**D. Storage**
- Liste les buckets pertinents (ex: `wedding-covers` si existant) + policies.
- Vérifie les chemins/règles de nommage dans le code.

**Sortie attendue (Backend)**
- Un tableau “Objets Supabase” avec preuves.

Template :

| Type | Nom | Détail | Preuve |
|---|---|---|---|
| Table | `public.weddings` | colonnes clés, FK, index | SQL / introspection |
| Policy | `weddings_select_own` | roles + qual | `pg_policies` |
| Trigger | `trg_wedding_*` | events + function | SQL |
| Function | `public.fn_*` | purpose | SQL |
| Bucket | `wedding-covers` | rules + usage | storage + code |

#### 1.2 Frontend Flutter — État Réel
Objectif : cartographier ce qui existe réellement (architecture, écrans, flux, intégrations).

**A. Features & architecture**
- Vérifie l’existence (ou non) de :
  - `lib/features/my_wedding/`
  - `lib/features/weddings_hub_pro/`
  - intégrations dans `lib/features/chat/`
- Pour chaque feature existante :
  - `domain/` (entities, repositories)
  - `data/` (dto/models, datasources, impl repos)
  - `presentation/` (pages, controllers, cubits/blocs, sheets)

**B. Écrans & navigation**
- Identifie la page bride (ex: `my_wedding_page.dart`) et la page pro (ex: `weddings_hub_pro_page.dart`).
- Vérifie comment ces pages sont accessibles (navbar, routes, deep links).

**C. Design System**
- Liste les composants réellement utilisés (import `/core/design/design.dart`).
- Vérifie si des widgets spécifiques ont été créés pour My Wedding (et où).

**D. Flux & logique métier**
- Onboarding wedding : étapes réellement présentes (nombre d’étapes, persistance, validations, stockage).
- Team management : invitation, exclusion, rôles, état, intégration chat.
- Synchronisation chat ↔ wedding : mapping, triggers, conventions (id wedding, conversation id, membership).

**Sortie attendue (Frontend)**
- Un tableau “Features Flutter” avec preuves.

Template :

| Feature | État | Description réelle | Fichiers clés | Preuves |
|---|---|---|---|---|
| My Wedding | ✅/⏳/❌ | … | `lib/features/...` | `path:Lx-Ly` |
| Hub Pro | ✅/⏳/❌ | … | … | … |

#### 1.3 Intégrations Cross-Module
Objectif : identifier les points de couplage réels.

- **Navbar / routing** : où My Wedding est branché.
- **Map module** : affichage weddings (si existant) + source data.
- **Chat module** : conversation liée à une wedding, permissions.
- **Notifications** : triggers, edge functions, events.

**Sortie attendue**
- Une liste “Intégrations” : pour chaque intégration, préciser le point d’entrée + preuve.

#### 1.4 État de déploiement / usage réel
Objectif : séparer “code mort / placeholders” de “fonctionnel en prod/dev”.

- Repère les placeholders (UI statique, TODO implicites, endpoints non appelés).
- Repère les features réellement utilisées (routes accessibles, appels réseau effectifs, data affichée).

---

### Phase 2 — Analyse Comparative (AUTORISÉ de lire les docs)

Lis ensuite et seulement ensuite :
- `docs/features/MY_WEDDING_SUITE.md`
- le plan existant le plus proche (selon le repo, ex: `docs/archive/MY_WEDDING_SUITE_IMPLEMENTATION_PLAN_V1.md`)

**Comparaison critique**
- Prévu vs réel (écarts)
- Implémenté mais non documenté
- Documenté mais absent du code
- Décisions techniques divergentes (avec justification factuelle)

**Sortie attendue**
- Une section “Écarts majeurs” structurée en tableau.

Template :

| Sujet | Prévu (doc) | Réel (code/db) | Impact | Preuves |
|---|---|---|---|---|

---

### Phase 3 — Réécriture du Plan : `MY_WEDDING_SUITE_IMPLEMENTATION_PLAN_V2.md`

#### 3.1 Structure imposée du document V2

##### Section 1 — État Actuel Réel
- Tableau features ✅/⏳/❌
- Architecture réelle (répertoires/fichiers)
- Schéma Supabase réellement en place (tables + policies + triggers + buckets)

##### Section 2 — Logiques & Décisions Techniques
- Patterns établis (Clean Architecture, conventions, mapping wedding↔chat, etc.)
- Justification des écarts (factuelle)

##### Section 3 — Tâches Restantes (exhaustif)
- Liste des tâches restantes **dérivée du réel**
- Dépendances (backend/frontend/notifications/chat)
- Complexité estimée (S/M/L) basée sur l’existant

##### Section 4 — Plan d’action concret (Sprints)
- Découpage en sprints avec objectifs
- Risques & mitigations basés sur le code réel

#### 3.2 Format des statuts
- ✅ = fonctionnalité **vérifiée** (preuve fournie)
- ⏳ = partiellement implémentée (preuve + manque exact)
- ❌ = absente (preuve : recherche négative + périmètre)

#### 3.3 Style d’écriture
- Factual, concis, orienté exécution.
- Aucun “probablement”.
- Chaque item critique a une preuve.

---

## Checklist de Qualité avant livraison
- Chaque tableau a une colonne **Preuves** remplie.
- Aucun item “✅” sans preuve.
- Les points “Non vérifiés” sont listés explicitement.
- Le plan V2 est exécutable : tâches actionnables, priorisées, dépendances claires.

## Message final
Tu as pour mission de faire un audit chirurgical de My Wedding Suite. La vérité est dans le code et dans Supabase, pas dans les documents. Sois méticuleux, critique, et traçable.
