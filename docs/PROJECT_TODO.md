# PROJECT TODO - Tâches de Développement LYNEWED

**Document créé:** 2025-11-26  
**Last Updated:** 2025-12-04 11:35  
**Version:** v4.3

---

## ✅ MODULE MAP - TERMINÉ (2025-12-01)

Le module Map est 100% complet. Voir rapport final: `docs/archive/MAP_REFACTORING_COMPLETE_2025-12-01.md`

| Phase | Description | Status |
|-------|-------------|--------|
| 0-8 | Design System → Documentation | ✅ |

**Tests:** 63/63 passants

---

# PRIORITÉ 1 — FONCTIONNALITÉS CRITIQUES

> Focus: Logiques métier essentielles au bon fonctionnement de l'application.

---

## 1.1 Module Chat & Contact (Refonte Complète) ✅ AUDIT TERMINÉ

**Audit complet:** `docs/audits/CHAT_CONTACT_FEATURE_AUDIT.md` (v1.1)  
**Backup code:** `docs/archive/chat_backup_2025-12-02/`  
**Estimation:** 44-60 heures

### Travail Complété (2025-12-03)
- ✅ **Audio Player**: Refactorisé design compact (FlutterFlow style)
  - Removed waveform visualization
  - Added play/pause, timeline slider, duration, speed control
  - Fixed signed URL timing issue
- ✅ **Message Loading**: Optimisé avec cache synchrone + preloading
  - Replaced FutureBuilder with sync cache
  - Implemented _preloadSignedUrls() for async loading
  - Added ValueKey for widget reconstruction
- ✅ **Audio Recorder**: Améliorations UI/UX
  - Slowed animation (50ms → 100ms)
  - Reduced amplitude at silence (cubic curve)
  - Unified typography with player
  - Reduced spacing to 10px
- ✅ **Message Spacing**: Logique corrigée pour liste inversée
  - 8px entre messages du même utilisateur
  - 30px entre messages d'utilisateurs différents
  - Renommé `_isFirstFromSender` → `_needsLargeSpacing`
- ✅ **Map Sheets Navigation**: Contact depuis sheets fonctionne
  - `MapActionsService.navigateToChat()` utilise `action_blocks.contactChatRoom()`
  - Charge correctement nom, avatar, rôle du contact
- ✅ **ChatDetailsPage "Waiting" Bug**: Corrigé
  - `pendingRequestId` passé uniquement si `status == requestPending`
  - Évite "Waiting for response" pour rooms actives
- ✅ **Pro→Bride Contact Flow**: Status `requiresRequest` géré
  - Ajouté à enum `ChatEntryStatus`
  - Messages UX appropriés (demande requise, tier insuffisant, bloqué)
- ✅ **ContactRequestSheet**: Flux complet validé
  - Sheet s'ouvre pour Pro Premium+ contactant Bride
  - Validation message (10+ caractères)
  - Source correcte passée (fromWedding, fromProfile, etc.)
  - Textes traduits en anglais
- ✅ **ContactRequestReviewSheet**: Flux acceptation validé
  - Demandes visibles dans MessagesPage section "Contact Requests"
  - Accept crée room ET insère message initial
  - Decline supprime demande
- ✅ **Backend RPCs**: Corrigées et optimisées
  - `accept_connection_request`: Insère `initial_message` comme 1er message
  - `get_rooms_with_unread_counts`: Inclut rooms sans messages
  - `conn_req_before_insert`: Nouvelles valeurs enum
  - Données test nettoyées (demandes anormales supprimées)
- ✅ **Frontend Core**: Actions et traductions
  - `actions.dart`: Param `source`, séparation `roomReady`/`requestPending`
  - `chat_enums.dart`: `displayLabel` traduits EN
  - `contact_request_avatar.dart`: Labels "Waiting"/"New"
  - `chat_remote_datasource.dart`: Parsing `{items: [...]}` corrigé
- ⏳ **UX Block/Report**: Réorganisation en cours
  - MessageActionsSheet: Block retiré (Report uniquement)
  - ConversationActionsSheet: À ajouter Block/Report/Archive
  - MessagesPage: À afficher statut "Blocked"/"Reported"
  - ChatDetailsPage: À ajouter bouton "Unblock"

### Décisions Validées (2025-12-02)
- ✅ Plans: `inactive`, `earlyAccess`, `premiumVisibility`, `ultimateAccess`
- ✅ Bride→Pro: Contact direct (pas de demande)
- ✅ Pro→Bride: Demande via sheet (Premium+ requis)
- ✅ Pro→Pro: Contact direct (EarlyAccess+ requis)
- ✅ Sources: `fromWishlist`, `fromWedding`, `fromAlert`, `fromProfile`
- ✅ Modération: 4 raisons + ticket `support_tickets`
- ✅ Rooms publiques: Conservées (Brides only)

### Phases de Refactorisation
| Phase | Description | Heures | Priorité | Status |
|-------|-------------|--------|----------|--------|
| 0 | Audio Player & Message Loading | 4-6h | 🔴 | ✅ 2025-12-03 |
| 1 | Backend - Logique Contact | 6-8h | 🔴 | ⏳ |
| 2 | Foundation Frontend | 8-10h | 🔴 | ⏳ |
| 3 | Messages Page Unifiée | 8-12h | 🔴 | ⏳ |
| 4 | Chat Details | 12-16h | 🟡 | ⏳ |
| 5 | Modération | 6-8h | 🟢 | ⏳ |
| 6 | Tests & Cleanup | 4-6h | 🟢 | ⏳ |

### Tâches Backend Critiques
- [ ] Supprimer trigger `trg_on_first_msg_pro_bride`
- [ ] Créer RPC `create_contact_request(target_id, source, message)`
- [ ] Modifier RPC `accept_connection_request` pour créer la room
- [ ] Renommer enum `connectionRequestSource`

### Tâches Frontend Critiques
- [ ] Créer `ContactRequestSheet` (demande Pro→Bride) ⚠️ **PRIORITÉ** - UX placeholder actuel
- [ ] Unifier `MessagesPage` (bride + pro)
- [ ] Ajouter section "Bloqués" dans Messagerie
- [ ] Créer `ReportMessageSheet` (4 raisons)

---

## ✅ 1.2 SYSTÈME NOTIFICATIONS - TERMINÉ (2025-12-04)

**Rapport complet:** `docs/archive/NOTIFICATIONS_REFACTORING_COMPLETE_2025-12-04.md`

### Travail Complété
- ✅ 7/7 types de notifications validés (chatMessage, connectionRequest, connectionRequestAccepted, wishlistAdd, videoIncoming, wedPublished, replayPublished)
- ✅ Navigation correcte pour tous les types
- ✅ ChatDetailsPage affiche nom/avatar du sender
- ✅ Notification Settings fonctionnels (désactiver/réactiver par type)
- ✅ Ordre des notifications (plus récentes en haut)
- ✅ Tap sur badge "New" pour marquer sans naviguer
- ✅ Cohérence Bride/Pro par type
- ✅ Edge Function respecte les settings utilisateur
- ✅ Amélioration UX: tap sur badge "New" = marquer lu sans navigation

### Architecture Validée
- **Frontend**: `lib/features/notifications/` avec Design System v3
- **Backend**: Edge Function `notifications_outbox_drain` + `send-broadcast-notification`
- **Settings**: `notification_settings` table avec logique par rôle et tier
- **Types**: Transactionnels (5) + Broadcast (2)

---

## 1.3 Feed & Système Ambassadeurs (Interconnectés)

**Règle:** Seuls les ambassadeurs et les pros avec `feed_enabled = true` figurent dans le feed.

### Système Ambassadeurs
- [ ] Ajouter colonne `ambassador` (boolean) dans `professional_details`
- [ ] Migration Supabase
- [ ] Mise à jour RPCs concernées
- [ ] Logique métier ambassadeurs (badge? visibilité spéciale?)

### Feed - Règles d'Affichage
- [ ] Vérifier/corriger la logique d'affichage basée sur `professional_details.feed_enabled`
- [ ] Feed visible côté Bride
- [ ] Feed visible côté Pro
  - [ ] Ajouter un onglet dans la navbar côté pro
  - [ ] Voir si on déplace settings/profil ailleurs pour garder navbar à 5 éléments

---

## 1.3 ProDetails - Refonte Complète

### Contenu Multimédia
- [ ] **Vidéo pour pro Filmmaker**
  - [ ] Upload et stockage vidéo
  - [ ] Affichage dans fiche pro
- [ ] **Photo + Vidéo pour pro Photo&Vidéo**
  - [ ] Gestion combinée
  - [ ] Mise en page spécifique
- [ ] **Intégration vidéo externe (YouTube/Vimeo)**
  - [ ] Pro peut ajouter un lien YouTube ou Vimeo (sans upload Supabase)
  - [ ] Player vidéo intégré dans ProDetails

### Disponibilités (Upcoming Travel)
**Note:** Les pros peuvent ajouter leurs prochains voyages via le CRM. Afficher cette info dans l'app.
- [ ] Icône avion dans `professional_details_sheet.dart` (à côté de website/instagram)
- [ ] Icône avion dans `ProDetails` (même emplacement)
- [ ] Modal affichant les déplacements passés et à venir
- [ ] Données gérées depuis CRM

---

## 1.4 Wed of the Week - Vidéaste

- [ ] Possibilité de publier un vidéaste dans Wed of the Week
  - [ ] Vidéo en haut (par défaut)
  - [ ] Textes et photos en dessous

---

## 1.5 Nouvelles Professions

**PROFESSIONS ACTUELLES (14):**
PHOTOGRAPHER, FILMMAKER, PLANNER, MAKEUP, HAIRDRESSER, DESIGNER, BRIDALDESIGNER, VENUE, BRIDALSHOP, FLORIST, PHOTOMOVIE, MAKEUPARTIST, EVENTDESIGNER, OTHER

**À AJOUTER - INDE UNIQUEMENT:**
- CATERING (Traiteur)
- JEWELLERY (Bijouterie)
- DJ
- STATIONERY (Papeterie)
- BRIDALLEHENGAS (Lehengas & Sarees de mariée)

**À AJOUTER - RESTE DU MONDE:**
- CONTENTCREATOR (Créateur de contenu)

**Actions:**
- [ ] Mise à jour enums Supabase
- [ ] Mise à jour filtres UI (map, recherche)
- [ ] Tests avec les nouvelles catégories

---

# PRIORITÉ 2 — PARAMÈTRES & UX UTILISATEUR

> Focus: Gestion des préférences, autorisations et navigation.

---

## 2.1 Onboarding & Paramètres Complet

**Note:** Inclut la gestion des préférences, demandes d'autorisation (location, notifs, galerie... iOS), settings.

- [ ] Onboarding à revoir (flux et UX complet)
- [ ] Gestion des autorisations iOS (location, notifications, galerie, etc.)
- [ ] Page settings/paramètres utilisateur
- [ ] Préférences utilisateur persistantes

---

## 2.2 Navigation & Corrections UX

- [ ] Revoir et corriger le système de navigation et navback qui bug
- [ ] Supprimer option "reset password" côté pro (géré côté CRM)

---

## 2.3 Map - Amélioration Markers

- [ ] Si un pro n'a pas d'`avatar_url`, afficher ses initiales sur le cercle du marker

---

# PRIORITÉ 3 — VALIDATION & AMÉLIORATIONS

> Focus: Vérification que tout fonctionne correctement.

---

## 3.1 Tests & Validation Globale

- [ ] Tests end-to-end complets (Bride + Pro workflows)
- [ ] Performance testing (load times, API calls)
- [ ] Sécurité: audit RLS policies
- [ ] Accessibilité: WCAG 2.1 AA compliance

---

# PRIORITÉ 4 — TÂCHES GLOBALES (FIN DE MISSION)

> Focus: Standardisation, internationalisation, qualité de code.

---

## 4.1 Design System - Application Globale

- [ ] Appliquer le design system à toute l'application (actuellement uniquement map)
  - [ ] Définir les composants réutilisables
  - [ ] Standardiser les styles et tokens
  - [ ] Documentation complète design system

---

## 4.2 Internationalisation (i18n)

**Langues cibles:** FR, EN, IT, DE, IN, ES (à confirmer)

- [ ] Définir les langues supportées
- [ ] Traduction complète de l'interface (100%)
- [ ] Implémenter système i18n + l10n
- [ ] Tests multilingues
- [ ] Documentation système multilingue

---

## 4.3 Refactoring & Nettoyage

### Enums - Nettoyage Supabase & Flutter
- [ ] **subscriptionTierType:** Supprimer `trial`, garder: `inactive`, `earlyAccess`, `premiumVisibility`, `ultimateAccess`
- [ ] **connectionRequestSource:** Renommer vers `fromWishlist`, `fromWedding`, `fromAlert`, `fromProfile`
- [ ] Synchroniser enums Flutter avec Supabase
- [ ] Voir `docs/App/ENUMS.md` pour discrepances identifiées

### Datatypes & Structures
- [ ] Revoir les datatypes - Nettoyer et restructurer
  - [ ] Gestion `professional_details`
  - [ ] Autres datatypes mal définis
  - [ ] Cohérence entre structures

### Nettoyage Code FlutterFlow
- [ ] Supprimer le code mort et code hérité de FlutterFlow
- [ ] Nettoyage du code fantôme restant
- [ ] Architecture robuste et maintenable

---

## 4.4 Sécurité & Analytics

### Sécurité
- [ ] Audit complet de sécurité + correction vulnérabilités

### Analytics & Monitoring
- [ ] Implémenter analytics utilisateurs
  - [ ] Comprendre usage réel
  - [ ] Événements critiques trackés
- [ ] Monitoring de performance
  - [ ] Temps de chargement
  - [ ] Latence API
  - [ ] Métriques UX

---

## 4.5 Livrables Finaux

- [ ] Documentation complète architecture technique
- [ ] Code source nettoyé et commenté
- [ ] Tests complets fonctionnalités
- [ ] Préparation finale déploiement iOS
- [ ] Cession totale droits (code + designs)

---

# PHASE 2 — ANDROID & FUTURES (Janvier 2025+)

> Non prioritaire pour cette mission.

---

## Android

- [ ] Standardisation du code pour Android
- [ ] Adaptation architecture technique pour Play Store
- [ ] Préparation complète déploiement Android
- [ ] Sécurisation Google Places SDK Android
  - [ ] Générer SHA-1 keystore (debug + release)
  - [ ] Ajouter SHA-1 dans Google Cloud Console
  - [ ] Activer restrictions "Package names" avec com.lynewed.app

---

## Scénario Photo/Vidéo → Réels/Live (Vision Future)

- [ ] Photo/vidéo transformées en réels
  - [ ] Traitement vidéo
  - [ ] Export format réels
- [ ] Diffusion en live
  - [ ] Infrastructure streaming
  - [ ] Gestion multi-participants
- [ ] Renvoyer sur portables invités via QR Code
  - [ ] Partage instantané
  - [ ] Notifications push

---
