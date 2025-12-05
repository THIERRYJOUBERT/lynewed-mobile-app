# 📋 TODO FINALISATION V1 - PLAN COMPLET

> **Version**: 3.0  
> **Date**: 2025-12-05  
> **Objectif**: Finalisation v1 avant déploiement TestFlight  
> **Estimation totale**: 20-30 heures

---

## 🎯 CONTEXTE ACTUEL

### ✅ Modules Terminés
- **Design System v3** : Tokens unifiés validés
- **Map Module** : 100% refactorisé Clean Architecture
- **Chat Module** : Messages, contact, modération terminés  
- **Notifications** : 7/7 types validés, settings fonctionnels
- **Feed MVP** : ✅ Phase 1 + 1.5 terminées (2025-12-05)
- **Feed Pro** : ✅ Déjà implémenté
- **ProDetails Refonte** : ✅ Terminée (2025-12-04)

### 📊 Métriques Projet
- **Codebase** : ~15,000+ lignes Dart
- **Architecture** : Clean Architecture établie
- **Tests Map** : 63/63 passants
- **APIs** : 4 certifiées (Supabase, Google Places, Agora, Firebase)

---

## ✅ PHASE 1 - FEED REFACTORING - TERMINÉE (2025-12-05)

**Documentation** : `docs/FEED_REFACTORING_PLAN.md` (v5 - Ultra-rapide)

### 1.1 Backend RPC Patch (2h) - ✅ TERMINÉ
- [x] Ajouter `is_visible_in_market()` dans `get_portfolio_feed`
- [x] Ajouter `feed_enabled` + `ambassador` dans WHERE
- [x] Filtrer professions par marché (IN-only vs GLOBAL-only)
- [x] Tests avec utilisateur IN et GLOBAL

### 1.2 Enums + Professions (1h) - ✅ TERMINÉ
- [x] Ajouter 6 nouvelles professions à l'enum existant
  - 🇮🇳 Inde: CATERER, DJ, BRIDALWEARDESIGNER
  - 🌍 Global: JEWELLER, STATIONER, CONTENTCREATOR
- [x] Mettre à jour tous les fichiers utilisant l'enum

### 1.3 Filtres Localisation (2-3h) - ✅ TERMINÉ
- [x] Remplacer `AddressSearchWidget` par toggle Country/Nearby
- [x] Cacher filtres pour utilisateurs IN (India only)
- [x] Exclure India du dropdown pour utilisateurs GLOBAL
- [x] Copier pattern `FilterSheet` de la Map
- [x] `FeedLocationFilter` widget créé avec toggle mode
- [x] `CountryFilter` enum avec 200+ pays et aliases de recherche

### 1.4 Segmentation Marché IN/GLOBAL - ✅ TERMINÉ
- [x] Alertes filtrées par marché (`get_active_alerts_for_market` RPC)
- [x] Salons publics segmentés par marché (`market_region` colonne)
- [x] 3 salons GLOBAL + 3 salons IN créés
- [x] Dashboard Pro utilise alertes filtrées par marché

### 1.5 Chat Améliorations - ✅ TERMINÉ
- [x] Suppression `firstMessageTextOnly` (toujours media+audio)
- [x] Navigation chat depuis tous les points d'entrée

### 1.6 Tests & Validation (1h) - ✅ TERMINÉ
- [x] Test utilisateur IN (voit seulement pros IN)
- [x] Test utilisateur GLOBAL (voit pros GLOBAL, pas IN)
- [x] Test filtres mutuellement exclusifs
- [x] Test nouvelles professions par marché

---

## 🟡 PHASE 1.5 - FEED COMPLÉMENTS (POST-MVP) (8-10h)

**À faire APRÈS validation du Feed minimum viable**

### 1.5.1 Images V2 Migration (4-5h) - ✅ TERMINÉ
- [x] Migration Feed vers `slideshow_images_v2` / `portfolio_images_v2`
- [x] Format grille: `crop_3x4` (3:4) - **Modifié de 5:6 à 3:4**
- [x] Format fullscreen: `crop_9x16` (9:16)
- [x] Fallback legacy si colonnes V2 vides
- [x] Champs `fullscreenUrl` et `imageId` ajoutés à `FeedImageItemStruct`
- [x] Modifier `childAspectRatio` dans `feed_portfolio_grid.dart` de `1/1.2` à `3/4`
- [x] RPC `get_portfolio_feed` mise à jour avec support V2

### 1.5.2 ProDetails Images V2 (3-4h) - ✅ TERMINÉ
- [x] Header slider: `slideshow_images_v2` → `crop_1x1` affiché
- [x] Portfolio grid: `portfolio_images_v2` → `crop_3x4` affiché, `crop_9x16` fullscreen
- [x] Créé `ImageV2Struct` pour stocker les crops
- [x] RPC `get_pro_item_details` retourne `portfolioImagesV2` et `slideshowImagesV2`
- [x] `ProDetailsStruct` avec champs V2
- [x] `PortfolioGrid` utilise V2 avec fallback legacy

### 1.5.3 Wed of the Week (3h) - ✅ TERMINÉ
- [x] RPC `get_latest_wed_article` filtre déjà par market_region
- [x] Support `target_region`: 'all', 'IN', 'ROW'
- [ ] ~~Card Wed of the Week en haut du Feed~~ (non requis - page séparée)
- [ ] ~~Images V2 pour Wed of the Week~~ (à faire si besoin)

### 1.5.4 Bug Fixes & Design (1h) - ✅ TERMINÉ
- [x] Corrigé bug localisation Paris (données seed incorrectes dans DB)
- [x] Mis à jour `location_label` pour correspondre au `location_country_code`

### 1.5.5 Feed pour Pros - ✅ DÉJÀ FAIT
- [x] Feed Pro déjà implémenté et fonctionnel

---

## 🟡 PHASE 2 - AUTH REFACTORING (5-8h)

### 2.1 Pages Auth Unifiées
- [ ] Supprimer "reset password" côté pro (géré CRM)
- [ ] Page d'accueil avec choix rôle (Bride/Pro)
- [ ] Flow Pro : Login uniquement + redirection site si pas de compte
- [ ] Flow Bride : Login + Register complet dans app

### 2.2 Onboarding Progressif
- [ ] Demander permissions au bon moment (notif, localisation, photo)
- [ ] Écran d'accueil rôle explicite
- [ ] UX épurée sans demandes groupées

### 2.3 Design System v3
- [ ] Appliquer `LynewedTheme` sur toutes pages auth
- [ ] Utiliser composants unifiés (`LynewedSheet`, `LynewedButton`)

---

## 🟢 PHASE 3 - SETTINGS & PROFIL PRO (4-6h)

### 3.1 Restructuration Navigation Pro
- [ ] Supprimer page Profil de la navbar Pro
- [ ] Ajouter "Mon Profil" dans Settings Pro → ouvre ProDetails (read-only)
- [ ] Pro peut voir son propre profil via la nouvelle page ProDetails refactorisée

### 3.2 Upcoming Travels Connection
- [ ] Relier frontend existant au backend
- [ ] Tester création/modification/suppression de voyages
- [ ] Vérifier affichage sur la map

### 3.3 Validation Settings
- [ ] Système tickets support fonctionnel
- [ ] Notes App Store flow opérationnel
- [ ] Toutes préférences utilisateur testées
- [ ] Permissions iOS cohérentes

---

## 🔵 PHASE 4 - TESTS & VALIDATION (5-10h)

### 4.1 Tests Fonctionnels
- [ ] Tests end-to-end complets (Bride + Pro workflows)
- [ ] Navigation entre tous modules
- [ ] Flux contact (Pro→Bride, Bride→Pro, Pro→Pro)
- [ ] Géolocalisation (Inde vs reste du monde)

### 4.2 Tests Performance
- [ ] Temps chargement Feed < 2s
- [ ] Cache images stable
- [ ] Memory usage avec 100+ photos
- [ ] Latence API acceptable

### 4.3 Tests Sécurité
- [ ] Audit RLS policies Supabase
- [ ] Vérification permissions par rôle
- [ ] Tests edge cases (offline, mauvais réseau)
- [ ] Checker warnings Supabase advisors

---

## 🧹 PHASE 5 - CLEANUP & PRODUCTION READY (3-5h)

### 5.1 Nettoyage Code Mort
- [ ] Supprimer fichiers FlutterFlow non utilisés (`lib/compo_finaux/`, etc.)
- [ ] Supprimer composants legacy non référencés
- [ ] Nettoyer imports inutilisés

### 5.2 Sécurisation Logs
- [ ] Supprimer tous les `debugPrint` en production
- [ ] Remplacer logs sensibles par logging sécurisé
- [ ] Vérifier qu'aucune donnée utilisateur n'est loggée

### 5.3 Warnings & Advisors
- [ ] Résoudre warnings Flutter analyze
- [ ] Checker Supabase security advisors
- [ ] Checker Supabase performance advisors

---

## 🚀 PHASE 6 - TESTFLIGHT DÉPLOIEMENT (2-4h)

### 6.1 Préparation Technique
- [ ] Version bump (v2.0.0)
- [ ] Changelog complet
- [ ] Screenshots mises à jour
- [ ] Métadonnées App Store prêtes

### 6.2 Configuration Beta
- [ ] Liste testeurs interne
- [ ] Feedback collection setup
- [ ] Monitoring crash analytics
- [ ] Documentation rollback

---

## 📊 TIMELINE ESTIMÉ (OPTIMISÉ)

| Phase | Heures | Priorité | Statut |
|-------|--------|----------|--------|
| Feed MVP (Phase 1) | 6-7h | 🔴 CRITIQUE | ✅ TERMINÉ |
| Feed Compléments (Phase 1.5) | 8-10h | 🟡 IMPORTANTE | ✅ TERMINÉ |
| Auth Refactoring (Phase 2) | 5-8h | 🟡 IMPORTANTE | ⏳ À FAIRE |
| Settings & Profil Pro (Phase 3) | 4-6h | 🟢 MODÉRÉE | ⏳ À FAIRE |
| Tests & Validation (Phase 4) | 5-10h | 🔴 CRITIQUE | ⏳ À FAIRE |
| Cleanup & Production (Phase 5) | 3-5h | � IMPORTANTE | ⏳ À FAIRE |
| TestFlight Setup (Phase 6) | 2-4h | 🟡 IMPORTANTE | ⏳ À FAIRE |
| **TOTAL RESTANT** | **19-33h** | | |

---

## 🎯 POINTS DE VALIDATION

### ✅ Critères de Succès Feed
- Feed géolocalisé fonctionnel (Inde vs monde)
- Images multi-format avec fullscreen 9:16
- Ambassadeurs visibles et prioritaires
- Performance < 2s chargement

### ✅ Critères de Succès Auth
- Flow rôle-based fonctionnel
- Onboarding progressif sans friction
- Design System unifié

### ✅ Critères de Succès Globaux
- Tous modules interconnectés
- Performance stable
- Sécurité validée
- TestFlight prêt

---

## 🔄 STRATÉGIE DE DÉVELOPPEMENT

1. **Focus Feed** : Module le plus complexe, impacte découverte
2. **Auth ensuite** : Point d'entrée, ajustements mineurs
3. **Settings rapide** : Réorganisation UI principalement
4. **Tests intensifs** : Validation complète avant release
5. **TestFlight** : Déploiement beta contrôlé

---

## 📞 CONTACTS & RESSOURCES

### Références Techniques
- **Feed Plan** : `docs/FEED_REFACTORING_PLAN.md`
- **Design System** : `docs/App/DESIGN_SYSTEM.md`
- **Architecture** : `docs/App/APP_SOURCE_OF_TRUTH.md`
- **Images Guide** : `docs/GUIDE_EQUIPE_APP_MULTI_FORMAT_IMAGES.md`

### Modules Référence
- **Map** : `lib/features/map/` (pattern Clean Architecture)
- **Chat** : `lib/features/chat/` (Design System v3 appliqué)
- **Notifications** : `lib/features/notifications/` (settings pattern)

---

## ✅ CHECKLIST PRÉ-TESTFLIGHT

- [ ] Feed 100% fonctionnel avec géolocalisation
- [ ] Auth unifié et onboarding progressif
- [ ] Settings restructuré pour pros
- [ ] Tous les tests passent
- [ ] Performance optimisée
- [ ] Sécurité validée
- [ ] Documentation complète
- [ ] TestFlight configuré

---

**Statut**: ✅ PHASE 1 + 1.5 TERMINÉES - PROCHAINE: PHASE 2 AUTH  
**Dernière mise à jour**: 2025-12-05 12:25  
**Prochaine action**: Phase 2 - Auth Refactoring  
**Ordre d'exécution**: ~~Phase 1~~ ✅ → ~~Phase 1.5~~ ✅ → Phase 2 Auth → Phase 3 Settings → Phase 4 Tests → Phase 5 Cleanup → Phase 6 TestFlight
