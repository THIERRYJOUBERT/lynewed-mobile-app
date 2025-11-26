# TODO & Améliorations Techniques - LYNEWED App

**Document créé:** 2025-11-26  
**Last Updated:** 2025-11-26 18:30  
**Objectif:** Gestion des tâches à faire et idées d'améliorations techniques  
**Version:** v1.3

---

## 🚨 **PRIORITÉS IMMÉDIATES**

### 🐛 Bug Fixes Critiques
- [✅] **Portfolio Images Bug** - Corrigé : slideshow_images rempli avec les mêmes images que portfolio_images (2025-11-26)
- [✅] **Google Places API** - Migré vers SDK natif (`flutter_google_places_sdk`) - Sécurisé avec restrictions bundle ID (2025-11-26)
- [ ] **Performance PostGIS** - Optimiser requêtes géospatiales avec grand volume

### 🧪 Tests & Validation
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

#### 🗂️ **REFACTORISATION MAP - DÉPLACÉE**
*(Toutes les tâches de refactorisation map ont été déplacées vers le document dédié)*

**Nouveau document:** `docs/MAP_REFACTORING_PLAN.md`  
**Contenu:** Plan complet de refactorisation en 6 phases avec décisions, changelog et suivi

##### Référence Rapide
- **Phase 1:** Nettoyage Enum (proRecent, user, searchTarget, fixedLocation)
- **Phase 2:** Source Pros unique (professional_fixed_locations uniquement)
- **Phase 3:** Brainstorming POI/WeddingPin → Concept "Wedding"
- **Phase 4:** Améliorations UX (style markers Uber/Mondial Relay)
- **Phase 5:** Séparation marché indien (market_region)
- **Phase 6:** Préparation Android

**Status:** 📋 Plan créé, prêt pour implémentation

#### 🗂️ **ANCIEN - Système de Localisation Professionnelle**
*(Audit et analyse déplacés vers MAP_FEATURE_AUDIT.md et MAP_REFACTORING_PLAN.md)*

**Acceptance Criteria:** 
- ✅ Diagramme complet du flux de données créé
- ✅ Debug logs confirmant présence/absence des fixedLocations dans le feed
- ✅ Analyse de performance du clustering existante

##### Phase 2: Correction Immédiate 🛠️ *(Fix rapide pour résoudre le problème principal)*
- [ ] **Ajouter fixedLocations** à ProSummaryStruct (champ optionnel, backward compatible)
- [ ] **Modifier get_feed_professionals_action.dart** pour parser les fixedLocations (GeoJSON → LatLng)
- [ ] **Mettre à jour la map** pour utiliser fixedLocations des ProSummaryStruct
- [ ] **Supprimer les calculs de distance** côté app devenus inutiles
- [ ] **Tester que les markers** ne se superposent plus

**Acceptance Criteria:**
- ✅ ProSummaryStruct contient les fixedLocations sans casser l'existant
- ✅ Map affiche les markers aux coordonnées précises
- ✅ Plus de superposition de markers sur la carte

##### Phase 3: Refactoring Architecture 🏗️ *(Solutions durables)*
- [ ] **Créer ProLocationStruct** unifié pour toutes les localisations (CRM + App)
- [ ] **Déplacer tous les calculs de distance** dans le backend (RPC functions optimisées)
- [ ] **Standardiser le flux**: CRM → Backend → Map (sans transformation côté app)
- [ ] **Implémenter cache intelligent** des positions calculées côté backend
- [ ] **Séparer clairement les responsabilités**: CRM gère, App affiche

**Acceptance Criteria:**
- ✅ Architecture claire avec séparation des responsabilités
- ✅ Calculs distances optimisés côté backend
- ✅ Cache fonctionnel pour les performances

##### Phase 4: Optimisations Avancées ⚡
- [ ] **Algorithme de clustering** optimisé pour grandes quantités (>1000 markers)
- [ ] **Système de mise à jour** temps réel des localisations (WebSocket/Realtime)
- [ ] **Performance monitoring** du système de localisation
- [ ] **Fallback strategy** si fixedLocations vide mais locationLabel existe
- [ ] **Compression des données** pour optimiser le transfert mobile

**Acceptance Criteria:**
- ✅ Map performante avec 1000+ markers
- ✅ Mises à jour temps réel fonctionnelles
- ✅ Monitoring des performances en place

##### Phase 5: Tests et Validation ✅
- [ ] **Tests unitaires** du système de localisation (parsing, calculs distances)
- [ ] **Tests de performance** avec dataset complet (40+ pros, 1000+ markers)
- [ ] **Tests d'intégration** CRM ↔ App pour la cohérence des données
- [ ] **Validation UX** de l'affichage des markers et clustering
- [ ] **Documentation technique** complète du nouveau système

**Acceptance Criteria:**
- ✅ Tous les tests passent avec 100% de couverture
- ✅ Performance validée sur device réel
- ✅ Documentation complète et à jour

#### Système de localisation amélioré (existants)
- [ ] Implémenter fixed point (point fixe)
- [ ] Gestion country (pays)
- [ ] Gestion e complète
- [ ] Tests système de localisation

#### Map - Affichage des points (existants)
- [ ] Refonte affichage points carte (style Uber/Mondial Relay)
- [ ] 1 point = 1 pro (plus de superposition)
- [ ] Passer des points regroupés à l'e précise
- [ ] Affichage e exacte sur la carte

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

### 🔄 Workflow Développement
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
- ✅ Audit complet des fonctionnalités cartographiques (12 fichiers Flutter + 6 tables Supabase)
- ✅ Audit complet des enums (23 enums Supabase + 16 enums Flutter)
- ✅ Correction des bugs critiques d'authentification
- ✅ Identification des problèmes API Google Places
- ✅ Migration des données de test complète
- ✅ **Audit Map Complet v2** (2025-11-26) - 48 fichiers Flutter + 18 RPCs + 16 triggers analysés
  - ✅ Inventaire complet: widgets, pages, structs, custom actions, composants UI
  - ✅ Analyse backend: tables, RPCs, triggers, index GiST, RLS policies
  - ✅ Identification des incohérences MapMarkerType (8 valeurs → 3-4 proposées)
  - ✅ Décisions stratégiques validées avec product owner
  - ✅ Plan de refactorisation en 5 phases documenté

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
