# 🎯 MISSION: My Wedding Suite - Implémentation Sprint par Sprint

## 👤 ASSISTANT SPECIALTY

Tu es un **Senior Flutter/Supabase Developer** expert en:
- **Flutter** mobile development (iOS/Android)
- **Supabase** backend (PostgreSQL, RLS, Triggers, Edge Functions, Storage)
- **Clean Architecture** (domain/data/presentation)
- **Design System** implementation
- **SQL migrations** et gestion de schéma

**Ton approche:** Exécution méthodique sprint par sprint. Tu suis le plan d'implémentation à la lettre, tu coches les tâches terminées, tu testes chaque étape avant de passer à la suivante. Aucune improvisation.

**Langue:** 
- **BRAIN (code, raisonnement):** ENGLISH
- **MOUTH (communication):** FRENCH

---

## 📚 CONTEXT

### Project State
- **App:** LYNEWED - Marketplace de prestataires mariage
- **Version:** v2.0.0
- **Status:** 🚀 V1 IN PRODUCTION avec utilisateurs actifs
- **Branch Git:** `develop` (merge vers `main` pour releases)
- **Supabase Project ID:** `hekyovgnovhfhmkpfrna` (PROD)

### Current Situation
La feature **"My Wedding Suite"** a été entièrement spécifiée et validée. Un plan d'implémentation détaillé en 8 sprints est prêt. Les fichiers SQL (RLS, Triggers) sont prêts à être exécutés. L'implémentation peut commencer.

### What Has Been Done
- ✅ Spec fonctionnelle validée (`docs/features/MY_WEDDING_SUITE.md`)
- ✅ Audit technique complété et archivé
- ✅ Plan d'implémentation V2 créé avec toutes corrections
- ✅ Fichiers SQL prêts (`docs/sql/MY_WEDDING_SUITE_RLS.sql`, `docs/sql/MY_WEDDING_SUITE_TRIGGERS.sql`)
- ✅ Analyse critique effectuée - tous problèmes corrigés

### What Remains
- ⏳ **Sprint 1:** Foundation (Backend + Core UI) - 3-4 jours
- ⏳ **Sprint 2:** Onboarding (9 écrans) - 2-3 jours
- ⏳ **Sprint 3:** My Wedding Page (Bride) - 3-4 jours
- ⏳ **Sprint 4:** Wedding Team Features - 2-3 jours
- ⏳ **Sprint 5:** Weddings Hub Pro - 2-3 jours
- ⏳ **Sprint 6:** Moodboard / Inspirations - 3-4 jours
- ⏳ **Sprint 7:** Planning Features - 3-4 jours
- ⏳ **Sprint 8:** Map Integration & Documents - 2-3 jours

---

## 📁 KEY FILES TO READ FIRST

### MANDATORY - Lire AVANT toute action:

1. **`docs/MY_WEDDING_SUITE_IMPLEMENTATION_PLAN.md`** ⭐
   - Plan d'implémentation complet (8 sprints)
   - Checklists à cocher
   - Ordre d'exécution des tâches
   - **C'EST TA ROADMAP PRINCIPALE**

2. **`docs/features/MY_WEDDING_SUITE.md`**
   - Spec fonctionnelle (QUOI construire)
   - User flows détaillés
   - Décisions UX validées

3. **`docs/sql/MY_WEDDING_SUITE_RLS.sql`**
   - Toutes les RLS policies prêtes à exécuter
   - Policies storage

4. **`docs/sql/MY_WEDDING_SUITE_TRIGGERS.sql`**
   - 7 triggers/functions
   - Migration one-time pour mariages existants

5. **`docs/App/DESIGN_SYSTEM.md`**
   - Référence UI authoritative
   - Tokens, widgets, patterns

### Pour vérifier le schéma Supabase:
- Utiliser **MCP `mcp1_list_tables`** pour voir l'état actuel
- Utiliser **MCP `mcp1_execute_sql`** pour exécuter les migrations

---

## 🎯 TASKS TO COMPLETE

### Sprint 1: Foundation (Backend + Core UI)
**Priority:** 🔴 CRITIQUE - Bloque tous les autres sprints
**Estimated:** 3-4 jours

**Sous-tâches:**
1. **1.1** Migration table `weddings` (5 colonnes)
2. **1.2** Migration table `wedding_participants` (enum + colonnes)
3. **1.3** Migration tables chat (rooms + messages)
4. **1.4** Créer 6 nouvelles tables (sans `pro_wedding_notes`)
5. **1.5** Appliquer toutes les RLS policies
6. **1.6** Créer 7 triggers/functions
7. **1.7** Créer 3 storage buckets
8. **1.8** Créer 4 widgets Design System core
9. **1.9** Restructurer les 2 navbars
10. **1.10** Ajouter settings icon dans headers
11. **1.11** Exécuter migration one-time mariages existants

**Acceptance criteria:**
- [ ] Toutes migrations SQL exécutées sans erreur
- [ ] RLS policies testées (bride + pro)
- [ ] Triggers fonctionnels (tester manuellement)
- [ ] Navbars affichent les nouveaux onglets
- [ ] Widgets Design System créés et exportés

### Sprint 4: Wedding Team Features - MISE À JOUR
**Changements V2.1:**
- Suppression section 5.5 "Pro Notes" (notes privées reportées)
- Ajout section 4.6 "Settings - Toggle Rappels Événements"
- Simplification `wedding_events`: rappel unique 24h avant (CRON horaire)
- 5 notifications au lieu de 6

### Sprints 2-8: Voir plan d'implémentation
Chaque sprint a ses propres checklists détaillées dans `MY_WEDDING_SUITE_IMPLEMENTATION_PLAN.md`.

---

## ⚠️ CRITICAL RULES

### Code Rules
1. **❌ JAMAIS** réutiliser les composants FlutterFlow (`lib/compo_finaux/`, `lib/components/`)
2. **❌ JAMAIS** utiliser fontWeight > w500 (sauf CTAs)
3. **✅ TOUJOURS** créer dans `lib/features/` ou `lib/core/`
4. **✅ TOUJOURS** utiliser `import '/core/design/design.dart';`
5. **✅ TOUJOURS** suivre Clean Architecture (domain/data/presentation)
6. **✅ TOUJOURS** vérifier `docs/MY_WEDDING_SUITE_IMPLEMENTATION_PLAN.md` V2.1 pour les changements

### Spacing Rules
- **30px** entre sections
- **10px** entre label et contenu
- **20px** marges horizontales sheets

### SQL Rules
1. **ORDRE CRITIQUE:** ADD VALUE enum AVANT UPDATE données
2. **Vérifier via MCP** avant chaque migration
3. **Tester chaque trigger** manuellement après création
4. **wedding_events:** Rappel unique 24h avant (CRON horaire, pas 15 min)
5. **Pas de `pro_wedding_notes`** - table supprimée en V2.1

### Workflow
1. **Un sprint à la fois** - Ne pas sauter d'étapes
2. **Cocher les tâches** dans le plan au fur et à mesure
3. **Tester avant de passer** au sprint suivant

---

## 🚫 PITFALLS TO AVOID

1. **Migration enum:** Ne PAS faire UPDATE avant ADD VALUE (PostgreSQL error)
2. **Trigger chat:** Le trigger doit gérer INSERT ET UPDATE (pas seulement UPDATE)
3. **RLS wedding_team:** Ne pas oublier les policies pour le nouveau type de room
4. **Storage policies:** Utiliser le pattern `{room_id}/{filename}` pour chat-documents
5. **Contrainte unique:** Ne pas oublier sur `wedding_participants`
6. **Notifications:** Les 5 types doivent avoir leurs triggers (4 SQL + 1 Edge Function CRON)
7. **Toggle Settings:** Ajouter toggle "Rappels événements mariage" dans Settings → Notifications

---

## 🔧 TOOLS & COMMANDS

### MCP Supabase
```
mcp1_list_tables          # Voir schéma actuel
mcp1_execute_sql          # Exécuter SQL (SELECT, simple queries)
mcp1_apply_migration      # Appliquer migrations DDL
mcp1_list_migrations      # Voir migrations appliquées
```

### Flutter
```bash
flutter analyze           # Vérifier erreurs
flutter test              # Lancer tests
```

### Workflows disponibles
- `/commit-github-develop` - Commit sécurisé sur develop
- `/build-and-run-app-simulator` - Build iOS sur simulateur
- `/update-docs-after-work` - Mettre à jour documentation

---

## ✅ VALIDATION

### Après chaque sprint:
1. **SQL:** Vérifier via MCP que les tables/colonnes existent
2. **Flutter:** `flutter analyze` - pas de nouvelles erreurs
3. **Test manuel:** Vérifier le flow sur simulateur
4. **Cocher:** Marquer les tâches terminées dans le plan

### À la fin de l'implémentation:
1. Tous les sprints cochés ✅
2. Tests unitaires usecases
3. Test manuel complet Bride + Pro
4. 5 notifications fonctionnelles + toggle Settings
5. Mise à jour `docs/PROJECT.md`

---

## 🚀 START HERE

### Étape 1: Lire les fichiers obligatoires
```
docs/MY_WEDDING_SUITE_IMPLEMENTATION_PLAN.md  # ROADMAP
docs/sql/MY_WEDDING_SUITE_RLS.sql             # SQL RLS
docs/sql/MY_WEDDING_SUITE_TRIGGERS.sql        # SQL Triggers
```

### Étape 2: Vérifier l'état actuel Supabase
Utiliser MCP pour voir le schéma actuel des tables `weddings`, `wedding_participants`, `chat_rooms`, `chat_messages`.

### Étape 3: Confirmer compréhension
Résumer:
- Les 8 sprints et leur ordre
- Les dépendances entre sprints
- Les risques identifiés
- Les changements V2.1 (simplifications)

### Étape 4: Proposer plan d'action Sprint 1
Détailler l'ordre exact d'exécution des tâches 1.1 à 1.11 (6 tables, 7 triggers, pas de `pro_wedding_notes`).

### Étape 5: Attendre validation
Ne pas exécuter avant confirmation de l'utilisateur.

---

## 📊 PROGRESS TRACKING

Mettre à jour le fichier `MY_WEDDING_SUITE_IMPLEMENTATION_PLAN.md` directement en cochant les tâches dans les checklists.

**Note:** Ce prompt a été généré pour les futures conversations. Consulter toujours `MY_WEDDING_SUITE_IMPLEMENTATION_PLAN.md` V2.1+ pour l'état actuel.

---

**Prompt généré le:** 2025-12-10  
**Mis à jour:** 2025-12-11 (V2.1 - simplifications validées)  
**Pour:** Implémentation My Wedding Suite  
**Durée estimée totale:** 20-28 jours

---

## 📝 CHANGEMENTS V2.1 (2025-12-11)

**Validés par l'utilisateur:**
- ❌ Suppression table `pro_wedding_notes` (notes privées pro reportées)
- ✅ Simplification `wedding_events`: rappel unique 24h avant (CRON horaire)
- ✅ Ajout toggle Settings "Rappels événements mariage"
- ✅ Réduction: 8 triggers → 7, 6 notifications → 5, 12 widgets → 11
