# TODO & Améliorations Techniques - LYNEWED App

**Document créé:** 2025-11-26  
**Last Updated:** 2025-11-27 12:05  
**Objectif:** Gestion des tâches à faire et idées d'améliorations techniques  
**Version:** v1.6

---

## 🚨 **PRIORITÉS IMMÉDIATES**

### 🐛 Bug Fixes Critiques
- [✅] **Portfolio Images Bug** - Corrigé : slideshow_images rempli avec les mêmes images que portfolio_images (2025-11-26)
- [✅] **Google Places API** - Migré vers SDK natif (`flutter_google_places_sdk`) - Sécurisé avec restrictions bundle ID (2025-11-26)
- [✅] **Cron Jobs Abusifs** - Désactivés et corrigés (2025-11-27)
  - ✅ `notifications_outbox_drain` : Désactivé via Dashboard
  - ✅ `alerts_housekeeping` : Erreurs RLS identifiées et désactivées
  - ✅ Base de dev stabilisée (plus de 4000+ requêtes/heure)
- [ ] **Performance PostGIS** - Optimiser requêtes géospatiales avec grand volume

### 🗺️ **MAP REFACTORING** - CORRECTIONS UI/UX REQUISES
- [🔄] **MAP CORRECTION PLAN** - Tests simulateur révèlent problèmes (2025-11-27)
  - 📋 **Source de vérité**: `docs/MAP_CORRECTION_PLAN.md` (17-24h)
  - ✅ Backend validé: RPC 44ms, index PostGIS, RLS policies OK
  - ⚠️ **Problèmes identifiés lors tests simulateur**:
    - ❌ Design system non respecté (couleurs, typographie)
    - ❌ Éléments UI manquants (zoom, search, FAB, géoloc)
    - ❌ Filtres non fonctionnels
    - ❌ Markers style incorrect (pins au lieu de cercles avatar)
    - ❌ Sheets style incorrect + boutons non fonctionnels
  - 🎯 **7 Phases de correction**:
    - Phase 0: Design System Unifié (2-3h)
    - Phase 1: Restauration Layout Map (3-4h)
    - Phase 2: Correction Filtres (2-3h)
    - Phase 3: Markers Style Correct (2-3h)
    - Phase 4: Sheets avec Design System (4-5h)
    - Phase 5: Actions Fonctionnelles (3-4h)
    - Phase 6: Tests Finaux (1-2h)

### 🧪 Tests & Validation - ÉTAPE FINALE MAP
- [🔄] **Tests Simulateur Map Module** - Validation finale avant déploiement (2025-11-27)
  - 📱 **Tests iOS**: Lancer app sur simulateur iOS, tester flux map complet
  - 🤖 **Tests Android**: Lancer app sur simulateur Android, tester flux map complet  
  - 🗺️ **Validation Map**: 
    - ✅ Navigation map bride/pro fonctionne
    - ✅ Markers affichés correctement (pros, alertes, wedding pins)
    - ✅ Filtres map appliqués correctement
    - ✅ Sheets détails s'ouvrent avec bonnes données
    - ✅ Performance fluide (< 1s chargement)
  - 🎯 **Objectif**: Validation finale refactorisation map avant merge main
- [ ] **Tests End-to-End** - Valider tous les flux avec données seeded (Agora, Resend, Firebase, Places, Supabase Realtime)
- [ ] **Performance App** - Valider performance avec 40 utilisateurs et dataset complet
- [ ] **Monitoring Setup** - Implémenter crash reporting et analytics

### 📚 Documentation Urgente
- [ ] **Documentation API** - Documenter toutes les fonctions RPC et edge functions

---

## 📋 **TO-DO LIST - Développement Application V2**

### 🏗️ ARCHITECTURE & SÉCURITÉ (Socle V1)
- [ ] Restructuration complète base de données Supabase
- [ ] Nettoyage et suppression du code fantôme
- [ ] Audit complet de sécurité + correction des vulnérabilités
- [ ] Atteindre "Zéro Warnings" sur Supabase
- [ ] Optimisation des temps de chargement de l'App
- [ ] Standardisation du code pour Android
- [ ] Adaptation architecture technique pour Play Store
- [ ] Préparation complète déploiement Android
- [ ] Mise à jour et nettoyage des options d'abonnements
- [ ] Livraison documentation architecture technique (Flux CRM ↔ App ↔ Site)

### 🔧 REFACTORING TECHNIQUE
- [ ] Revoir les datatypes - Nettoyer et restructurer proprement
- [ ] Gestion professional_details
- [ ] Autres datatypes mal définis
- [✅] **Widget AddressSearchWidget** - Composant réutilisable créé et migration COMPLÈTE (2025-11-26)
  - ✅ Migré: feed_brides, map_brides_large, map_pro_large, create_edit_alert_sheet, create_edit_point_of_interest_sheet
  - ✅ 5/5 écrans migrés avec 0 erreurs de compilation
  - ✅ Mode overlay avec positionnement flexible (below/above)
  - ✅ Container dynamique AnimatedContainer (420px) pour mapLarge
  - ✅ Documentation technique complète: `docs/App/ADDRESS_SEARCH_WIDGET.md`
  - ✅ Nettoyage des fichiers temporaires et optimisation du code
- [ ] Ajouter colonne "is_ambassador" dans profiles (boolean) + "ambassador_since" (timestamptz)
- [ ] Nettoyage FlutterFlow - Refactoriser code verbeux généré en Flutter propre
- [ ] Gestion Erreurs - Améliorer messages d'erreur et feedback utilisateur
- [ ] Architecture - Implémenter patterns clean architecture
- [ ] Performance - Optimiser requêtes DB et rendu UI

### 🔐 SÉCURITÉ & INFRASTRUCTURE
- [ ] **Android SHA-1 Security** : Ajouter restrictions SHA-1 pour clé API Google Places Android
  - Actuel : Clé configurée mais sans restrictions SHA-1
  - Action : Récupérer SHA-1 du certificat de production et ajouter aux restrictions Google Cloud Console
  - Priorité : Haute (sécurité production)

### 🎨 DESIGN SYSTEM & UI/UX
- [ ] Créer/uniformiser le design system propre de l'application
- [ ] Définir les composants réutilisables
- [ ] Standardiser les styles et tokens
- [ ] **Navigation back** - Revoir la navigation retour (lent, mal conçu, ne fonctionne pas bien)
- [ ] **Sélection pays** - Améliorer la recherche de pays avec search, ajouter les pays manquants (ex: Japon) dans le feed

### 🌍 LOCALISATION & LANGUES
- [ ] Implémenter système multilingue
- [ ] Définir les langues supportées
- [ ] Traduction complète de l'interface
- [ ] Tests des langues

### 🍎 COMPTES DÉVELOPPEUR
- [ ] Configuration compte Apple Developer propre
- [ ] Gestion et paramétrage du compte

### 🇮🇳 MARCHÉ INDIEN - SEGMENTATION GÉOGRAPHIQUE
- [ ] Mettre en place filtre géographique hermétique
- [ ] Configurer : Utilisateurs Inde = contenu Indien uniquement
- [ ] Configurer : Utilisateurs hors Inde = pas de contenu Indien
- [ ] Créer onglet Admin dédié pour gestion contenu Inde séparé
- [ ] Tester la segmentation stricte (Brides & Vendors)

### 📍 LOCALISATION & CARTOGRAPHIE
*(Toutes les tâches de cartographie sont gérées dans MAP_REFACTORING_PLAN.md)*

### 👤 GESTION PROFILS PROS
#### Statut & Visibilité
- [ ] Gestion pro inactif - Définir comportement fiche pro inactive
- [ ] Définir règles d'affichage pros inactifs
- [ ] Message/statut pour pros inactifs
- [ ] Tests affichage selon statut

#### Fiches Pros - Photo & Vidéo
- [ ] Mise en page spécifique : Vidéo en en-tête
- [ ] Grille de 4 photos en dessous de la vidéo
- [ ] Slider vertical pleine page
- [ ] Intégration liens externes (YouTube/Vimeo)
- [ ] Correction ratio d'image photos (éviter effet "square")
- [ ] Option prévisualisation (carré 9:16) dans CRM lors upload

#### Fiches Pros - Fonctionnalités
- [ ] Ajouter bouton/icon "Disponibilités" (Upcoming Travels)
- [ ] Gestion modale des disponibilités via CRM

### 🔔 FEED PRO & VISIBILITÉ (Mise à jour 2025-11-26)

**Décision Thierry:** Feed visible côté Pro + Bride, mais visibilité payante séparée de l'abonnement.

#### Structure
- [ ] **Créer Feed côté Pro** - Miroir du feed bride
- [ ] **Ajouter `is_feed_visible`** dans professional_details (boolean, default false)
- [ ] **Ajouter `feed_visibility_expires_at`** dans professional_details (timestamptz)
- [ ] **Paiement unique $900/an** - Pas lié à l'abonnement, séparé
- [ ] **Exception Ambassadeurs** - Feed gratuit si `is_ambassador = true`
- [ ] **Créer flow paiement** pour activer visibilité feed

#### Règles Métier
| Condition | Visible dans Feed |
|-----------|------------------|
| `is_feed_visible = true` ET `feed_visibility_expires_at > now()` | ✅ |
| `is_ambassador = true` | ✅ |
| Sinon | ❌ (trouvable via map/filtres) |

### 🏅 AMBASSADEURS (Nouveau 2025-11-26)

**Concept:** Titre honorifique (pas un rôle) pour fidéliser les pros actifs.

- [ ] **Ajouter `is_ambassador`** dans profiles (boolean, default false)
- [ ] **Ajouter `ambassador_since`** dans profiles (timestamptz, nullable)
- [ ] **Badge profil** - Afficher "Ambassador" sur le profil public
- [ ] **Avantage Feed** - Visibilité gratuite (pas besoin des $900)
- [ ] **Interface Admin** - Permettre attribution/retrait du titre
- [ ] **Définir autres avantages** avec Thierry (à clarifier)

### 💰 PLANS D'ABONNEMENT (Clarification 2025-11-26)

**Source:** Mail Thierry + Site lynewed.com/professionals

#### Tiers Validés
```dart
enum SubscriptionTier {
  free,              // Pas d'abonnement
  earlyAccess,       // $42/mo ou $444/an
  premiumVisibility, // $64/mo ou $700/an  
  ultimateAccess,    // $94/mo ou $1000/an
}
```

#### Matrice Fonctionnalités à Implémenter
| Fonctionnalité | Free | Early | Premium | Ultimate |
|----------------|------|-------|---------|----------|
| Profil basique | ✅ | ✅ | ✅ | ✅ |
| Visible sur map | ❌ | ✅ | ✅ | ✅ |
| Live mode | ❌ | ✅ | ✅ | ✅ |
| CRM clients | ❌ | 5 | 10 | ∞ |
| Vendor-to-vendor chat | ❌ | ❌ | ✅ | ✅ |
| Contactable par couples | ❌ | ❌ | ✅ | ✅ |
| Voir mariages visibles | ❌ | ❌ | ✅ | ✅ |
| Demander contact bride | ❌ | ❌ | ✅ | ✅ |
| Alertes Community | ✅ | ✅ | ✅ | ✅ |
| Contrats SignNow | ❌ | ❌ | ✅ | ✅ |
| Marketplace achats | ❌ | ❌ | ✅ | ✅ |
| Marketplace ventes | ❌ | ❌ | ❌ | ✅ |
| Wedding Slot Exchange | ❌ | ❌ | ❌ | ✅ |
| Lead Transfer | ❌ | ❌ | ❌ | ✅ |

- [ ] **Valider matrice** avec Thierry
- [ ] **Implémenter checks** dans l'app pour chaque fonctionnalité
- [ ] **Mettre à jour enum** `subscriptionTierType` si nécessaire
- [ ] **Documenter** dans APP_SOURCE_OF_TRUTH.md

### 📱 FONCTIONNALITÉS APPLICATION
#### Wed of the Week (App)
- [ ] Système d'historique (anciens mariages consultables)
- [ ] Réception des notifications

#### Wording & Design
- [ ] Ajuster textes boutons Home Pro/Bride ("Find vendors & pin my wed", etc.)
- [ ] Intégrer images Header selon validation client

---

## 💡 **AMÉLIORATIONS FUTURES**

### � Refonte Système Notifications (Priorité Haute)

**Contexte:** Le système actuel génère 4000+ requêtes/heure sur une base de dev inactive (2025-11-27).

#### Problèmes Identifiés
1. **Architecture Outbox inefficace:**
   - Polling toutes les minutes même sans événements
   - Pas de backoff exponentiel sur erreurs
   - Pas de circuit breaker

2. **RLS vs Service Role mal configuré:**
   - Edge Functions utilisent `service_role` mais RLS bloque quand même
   - Requêtes 403 en cascade sur `device_tokens`, `user_preferences`, `notification_settings`

3. **Cron Jobs mal calibrés:**
   - `notifications_outbox_drain`: `* * * * *` (toutes les minutes) → devrait être `*/5 * * * *`
   - `alerts_housekeeping`: `*/15 * * * *` → devrait être `0 * * * *` (toutes les heures)

4. **Pas de métriques/monitoring:**
   - Impossible de détecter les anomalies sans vérification manuelle
   - Pas d'alertes sur erreurs 500 répétées

#### Solutions Proposées
- [ ] **Court terme:** Désactiver cron jobs + corriger fréquences
- [ ] **Moyen terme:** Ajouter policies RLS pour `service_role` sur tables notifications
- [ ] **Long terme:** Migrer vers Supabase Realtime + Database Webhooks (push vs poll)
- [ ] **Monitoring:** Ajouter alertes sur taux d'erreur Edge Functions

#### Architecture Cible (V2)
```
Trigger DB → Database Webhook → Edge Function (on-demand)
```
Au lieu de:
```
Cron Job → Edge Function (polling) → Query DB
```

**Avantages:**
- Exécution uniquement quand nécessaire
- Pas de polling à vide
- Réduction drastique des requêtes

---

### �🔄 Workflow Développement
- [ ] **GitHub MCP** - Utiliser outils GitHub MCP pour commits/branches pour éviter désynchronisation
- [ ] **Processus Git** - `git add .` → `git commit -m "message"` → `git push origin branch` → Vérification avec MCP

### 📱 Features Avancées
- [ ] **Support Offline** - Implémenter cache local pour données critiques
- [ ] **Sync Background** - Synchroniser données quand app revient en ligne
- [ ] **Recherche Avancée** - Implémenter filtres et recherches sauvegardées
- [ ] **Analytics** - Tracking comportement utilisateur et insights

---

## 📋 **LIVRABLES FINAUX**
- [ ] Documentation complète architecture technique
- [ ] Code source nettoyé et commenté
- [ ] Tests complets fonctionnalités
- [ ] Préparation finale déploiement Android (Play Store)
- [ ] Configuration finale compte Apple Developer
- [ ] Cession totale droits (code + designs)
- [ ] Formation/documentation système multilingue
- [ ] Documentation design system

---

## ✅ **TÂCHES TERMINÉES**

### 🏗️ Architecture & Sécurité (Socle V1)
- ✅ Environment sécurisé et fonctionnel
- ✅ Authentification opérationnelle (login/signup)
- ✅ Permissions base de données corrigées
- ✅ Seeding complet des données (40 utilisateurs avec relations complètes)
- ✅ Documentation réorganisée et mise à jour
- ✅ Audit de sécurité complet (secrets, configurations, Edge Functions)
- ✅ Synchronisation de 15 Edge Functions avec URLs CRM correctes
- ✅ Configuration Firebase validée
- ✅ Configuration Google Maps API (Android + iOS)

### 🔧 Technique & Performance
- ✅ Correction des bugs critiques d'authentification
- ✅ Identification des problèmes API Google Places
- ✅ Migration des données de test complète
- ✅ **Audits techniques complets** - Voir `audits/MAP_FEATURE_AUDIT.md` pour détails cartographiques

### 📊 Base de Données
- ✅ 52 migrations appliquées
- ✅ Politiques RLS actives et fonctionnelles
- ✅ PostGIS activé pour requêtes géospatiales
- ✅ 40 utilisateurs seeded (10 brides + 30 professionnels)
- ✅ Relations complètes : Wedding Pins, Wishlist, Chat Rooms, Messages, etc.

---

## 🔄 **Processus de Travail**

### Quand consulter ce fichier
- **Planning:** Pour voir les tâches en cours et idées d'améliorations
- **Développement:** Pour prioriser les features et corrections
- **Review:** Pour mettre à jour le statut des tâches

### Mise à jour des statuts
- **[ ]** - À faire
- **[🔄]** - En cours
- **[✅]** - Terminé
- **[❌]** - Bloqué/Annulé

### Priorités
1. **Critique:** Bugs bloquants, sécurité
2. **Haute:** Features principales, performance
3. **Moyenne:** Améliorations UX, refactoring
4. **Basse:** Features futures, documentation

---

**Note:** Ce fichier est complémentaire à PROJECT_STATUS.md. PROJECT_STATUS.md contient l'état du projet, tandis que PROJECT_TODO.md contient les tâches à faire et améliorations futures.
