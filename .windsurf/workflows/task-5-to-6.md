---
description: Map refactoring step 5 - 6
auto_execution_mode: 1
---

🎯 MISSION : Map Module - Phases 5 & 6
Tu es un développeur Flutter/Supabase senior assigné à la refactorisation du module Map de l'application LYNEWED. Tu dois réaliser les Phases 5 (Système Wedding) puis Phase 6 (Système Alertes).

📚 CONTEXTE OBLIGATOIRE - À LIRE EN PREMIER
AVANT TOUTE ACTION, tu DOIS lire ces documents dans l'ordre :
docs/PROJECT.md - État général du projet
docs/MAP_STATUS.md - Status actuel du module map
docs/MAP_REFACTORING_PLAN.md - Plan détaillé (section PARTIE B)
docs/audits/MAP_MODULE_AUDIT_2025-11-28.md - Audit technique complet
lib/features/map/README.md - Documentation du module
Comprendre la structure avant de coder :
lib/features/map/ - Module map refactorisé (33 fichiers)
lib/core/design/ - Design System unifié
supabase/migrations/ - Migrations SQL

🔧 OUTILS À UTILISER
MCP Supabase (mcp1_*) - Pour :
mcp1_list_tables - Voir les tables existantes
mcp1_execute_sql - Requêtes de lecture
mcp1_apply_migration - Créer des migrations DDL
mcp1_search_docs - Chercher dans la doc Supabase
Lecture code - read_file, grep_search, code_search
Édition - edit, multi_edit (jamais écraser des fichiers entiers)

📋 PHASE 5 : Système Wedding (6-8h)
Objectif
Remplacer le concept confus de wedding_pins + poi_private par un système Wedding propre.
Nouveau Concept
1 mariage par bride = hub central
POI privé = SUPPRIMÉ (deprecated dans l'enum)
Tables : weddings + wedding_participants
Tâches Séquentielles
Étape 5.1 : Analyse Backend
Utiliser mcp1_list_tables pour voir les tables actuelles
Analyser la structure de wedding_pins existante
Comprendre les relations avec professional_details, bride_profiles
Documenter les données à migrer
Étape 5.2 : Migration SQL
Créer table weddings (id, bride_id, event_date, location, etc.)
Créer table wedding_participants (wedding_id, pro_profile_id, role, status)
Migrer données de wedding_pins vers weddings
Mettre à jour RPC search_map_bundle pour utiliser weddings
Étape 5.3 : Frontend
Mettre à jour wedding_details.dart si nécessaire
Créer sheet de création wedding (pour brides)
Connecter FAB dans map_page.dart
Supprimer poiPrivate de l'enum MapMarkerType
Étape 5.4 : Validation
Tester sur simulateur iOS
Vérifier que les weddings s'affichent sur la map
Vérifier la création de wedding fonctionne
Mettre à jour MAP_STATUS.md

📋 PHASE 6 : Système Alertes (6-8h)
Objectif
Améliorer le système d'alertes avec 4 types structurés.
Nouveaux Types (entraide, pas rémunération)
backup_needed - Remplaçant pour date
gear_emergency - Location matériel
team_member - Second shooter/assistant
emergency_help - Urgence événement
Tâches Séquentielles
Étape 6.1 : Analyse Backend
Analyser table professional_alerts actuelle
Vérifier les colonnes existantes (motif_code, expires_at, etc.)
Comprendre le RPC search_map_bundle pour les alertes
Étape 6.2 : Migration SQL
Créer enum alert_type en backend (si pas existant)
Ajouter colonne alert_type à professional_alerts
Ajouter colonne event_date pour expiration auto
Créer trigger/cron pour expiration automatique
Mettre à jour RPC pour filtrer par type
Étape 6.3 : Frontend
Vérifier que AlertType dans alert_details.dart est aligné
Créer sheet de création alerte (pour pros)
Mettre à jour AlertDetailsSheet avec nouveaux types
Connecter FAB dans map_page.dart
Étape 6.4 : Validation
Tester création des 4 types d'alertes
Vérifier expiration automatique
Tester affichage sur map
Mettre à jour MAP_STATUS.md

⚠️ RÈGLES CRITIQUES
Processus de Travail
TOUJOURS lire les docs avant de coder
TOUJOURS valider ton plan avec l'utilisateur avant d'exécuter
TOUJOURS procéder étape par étape (pas de big bang)
TOUJOURS tester après chaque modification significative
TOUJOURS mettre à jour la documentation après chaque phase
Raisonnement
Réfléchis à voix haute avant chaque action
Explique pourquoi tu fais chaque choix
Anticipe les effets de bord
Vérifie la cohérence avec le code existant
Code
Option B TOUJOURS : Jamais réutiliser les composants FlutterFlow
Design System : import '/core/design/design.dart';
Clean Architecture : domain/data/presentation
Immutabilité : Classes avec @immutable et copyWith
Documentation
Après chaque phase terminée, mettre à jour :
docs/MAP_STATUS.md - Cocher la phase
docs/MAP_REFACTORING_PLAN.md - Détails si nécessaire
lib/features/map/README.md - Si nouveaux fichiers

🚫 PIÈGES À ÉVITER
Ne pas modifier l'enum legacy lib/backend/schema/enums/enums.dart sans mettre à jour marker_type_mapper.dart
Ne pas oublier le filtre expires_at > now() pour les alertes
Ne pas utiliser Navigator.pop() avant une opération async (bug context invalidation)
Ne pas créer de fichiers dans lib/compo_finaux/ ou lib/components/
Ne pas hardcoder des IDs ou valeurs

🎯 COMMENCER
Lis les 5 documents de contexte listés ci-dessus
Utilise mcp1_list_tables pour voir l'état actuel du backend
Propose un plan détaillé pour Phase 5
Attends ma validation avant d'exécuter
Première action : Lis docs/audits/MAP_MODULE_AUDIT_2025-11-28.md et résume-moi ce que tu as compris.