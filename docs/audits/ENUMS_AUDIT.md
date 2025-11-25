# Audit Complet des Enums - Projet Lynewed

**Date:** 2025-11-25  
**Projet:** Lynewed Mobile App v1.1.1+59  
**Environnement:** Développement (hekyovgnovhfhmkpfrna)  
**Scope:** Base de données Supabase + Application Flutter  

---

## 1. Résumé Exécutif

### Statistiques Globales
- **Enums Supabase:** 23 types enum identifiés
- **Enums Flutter:** 16 classes enum définies
- **Enums synchronisés:** 9 correspondances directes
- **Discrepances majeures:** 7 incohérences critiques

### Discrepances Critiques Identifiées
1. **AlertStatus:** Manque la valeur "cancelled" dans Flutter
2. **ConversationStatus:** Valeur "archived" manquante dans Supabase
3. **Enums système Supabase:** 14 enums techniques non implémentés dans Flutter
4. **CountryFilter:** Enum Flutter sans équivalent Supabase
5. **Enums UI:** MapMarkerType, MapActionType, DistanceUnit, etc. non présents en base

### Recommandations CRM
- Standardiser les 9 enums métier synchronisés
- Créer une table de mapping pour les enums UI-only
- Documenter les enums système comme "techniques uniquement"

---

## 2. Inventaire des Enums Supabase

### 2.1 Enums Métier (Synchronisés avec Flutter)

| Type Enum | Valeurs | Tables/Colonnes Utilisées |
|-----------|---------|---------------------------|
| **userRole** | bride, professional | profiles.role, public_profiles.role, public_chat_rooms.audience_role |
| **profession** | PHOTOGRAPHER, FILMMAKER, PLANNER, MAKEUP, HAIRDRESSER, DESIGNER, BRIDALDESIGNER, VENUE, BRIDALSHOP, FLORIST, PHOTOMOVIE, MAKEUPARTIST, EVENTDESIGNER, OTHER | professional_details.profession |
| **subscriptionTierType** | inactive, trial, earlyAccess, premiumVisibility, ultimateAccess | professional_subscriptions.subscription_tier |
| **alertStatus** | active, cancelled, expired | professional_alerts.status |
| **videoSessionStatus** | pending, accepted, declined, missed, completed, cancelled | video_sessions.status |
| **connectionRequestSource** | wishlist, weddingPin, map, alert, proToPro | connection_requests.source |
| **connectionRequestStatus** | pending, accepted, declined | connection_requests.status |
| **conversationStatus** | pending, active, declined, blocked, reportedPending, archived | chat_room_participants.conversation_status |
| **messageType** | text, image, audio | chat_messages.message_type |
| **notificationType** | chatMessage, connectionRequest, connectionRequestAccepted, connectionRequestDeclined, wishlistAdd, professionalAlert, professionalAlertReminder24h, videoIncoming, wedPublished, weddingPinMatch | notifications.type, notification_settings.notification_type |

### 2.2 Enums Système (Techniques)

| Type Enum | Valeurs | Utilisation |
|-----------|---------|-------------|
| **aal_level** | aal1, aal2, aal3 | sessions.aal (authentification) |
| **action** | INSERT, UPDATE, DELETE, TRUNCATE, ERROR | Logs et triggers système |
| **app_role** | admin, moderator | user_roles.role |
| **buckettype** | STANDARD, ANALYTICS, VECTOR | buckets.type, buckets_analytics.type, buckets_vectors.type |
| **code_challenge_method** | s256, plain | flow_state, oauth_authorizations |
| **contentModerationStatus** | pendingReview, approved, rejected | reports.status |
| **equality_op** | eq, neq, lt, lte, gt, gte, in | Opérateurs de comparaison système |
| **factor_status** | unverified, verified | mfa_factors.status |
| **factor_type** | totp, webauthn, phone | mfa_factors.factor_type |
| **key_status** | default, valid, invalid, expired | key.status, decrypted_key.status |
| **key_type** | aead-ietf, aead-det, hmacsha512, hmacsha256, auth, shorthash, generichash, kdf, secretbox, secretstream, stream_xchacha20 | key.key_type, decrypted_key.key_type |
| **oauth_authorization_status** | pending, approved, denied, expired | oauth_authorizations.status |
| **oauth_client_type** | public, confidential | oauth_clients.client_type |
| **oauth_registration_type** | dynamic, manual | oauth_clients.registration_type |
| **oauth_response_type** | code | oauth_authorizations.response_type |
| **one_time_token_type** | confirmation_token, reauthentication_token, recovery_token, email_change_token_new, email_change_token_current, phone_change_token | one_time_tokens.token_type |

---

## 3. Inventaire des Enums Flutter

### 3.1 Enums Métier (Correspondance Supabase)

#### UserRole
- **Fichier:** `/lib/backend/schema/enums/enums.dart:3-6`
- **Valeurs:** bride, professional
- **Sérialisation:** String (name)
- **Utilisation:** Authentification, permissions, UI conditionnelle

#### SubscriptionTierType
- **Fichier:** `/lib/backend/schema/enums/enums.dart:8-14`
- **Valeurs:** inactive, trial, earlyAccess, premiumVisibility, ultimateAccess
- **Sérialisation:** String (name)
- **Utilisation:** Features access, UI display, business logic

#### Profession
- **Fichier:** `/lib/backend/schema/enums/enums.dart:16-31`
- **Valeurs:** PHOTOGRAPHER, FILMMAKER, PLANNER, MAKEUP, HAIRDRESSER, DESIGNER, BRIDALDESIGNER, VENUE, BRIDALSHOP, FLORIST, PHOTOMOVIE, MAKEUPARTIST, EVENTDESIGNER, OTHER
- **Sérialisation:** String (name)
- **Utilisation:** Filtrage, recherche, profils professionnels

#### ConnectionRequestSource
- **Fichier:** `/lib/backend/schema/enums/enums.dart:64-70`
- **Valeurs:** wishlist, weddingPin, map, alert, proToPro
- **Sérialisation:** String (name)
- **Utilisation:** Tracking des origines de demandes de connexion

#### ConnectionRequestStatus
- **Fichier:** `/lib/backend/schema/enums/enums.dart:72-76`
- **Valeurs:** pending, accepted, declined
- **Sérialisation:** String (name)
- **Utilisation:** Gestion du cycle de vie des demandes

#### ConversationStatus
- **Fichier:** `/lib/backend/schema/enums/enums.dart:78-85`
- **Valeurs:** active, archived, pending, declined, blocked, reportedPending
- **Sérialisation:** String (name)
- **Utilisation:** UI des conversations, permissions d'accès

#### AlertStatus
- **Fichier:** `/lib/backend/schema/enums/enums.dart:87-90`
- **Valeurs:** active, expired
- **⚠️ DISCREPANCE:** Manque "cancelled" (présent dans Supabase)
- **Sérialisation:** String (name)

#### VideoSessionStatus
- **Fichier:** `/lib/backend/schema/enums/enums.dart:92-99`
- **Valeurs:** pending, accepted, declined, missed, completed, cancelled
- **Sérialisation:** String (name)
- **Utilisation:** États des appels vidéo, UI conditionnelle

#### MessageType
- **Fichier:** `/lib/backend/schema/enums/enums.dart:58-62`
- **Valeurs:** text, image, audio
- **Sérialisation:** String (name)
- **Utilisation:** UI des messages, validation d'envoi

#### NotificationType
- **Fichier:** `/lib/backend/schema/enums/enums.dart:101-112`
- **Valeurs:** chatMessage, connectionRequest, connectionRequestAccepted, connectionRequestDeclined, wishlistAdd, professionalAlert, professionalAlertReminder24h, videoIncoming, wedPublished, weddingPinMatch
- **Sérialisation:** String (name)
- **Utilisation:** Routing des notifications, UI display

### 3.2 Enums UI-Only (Flutter uniquement)

#### MapMarkerType
- **Fichier:** `/lib/backend/schema/enums/enums.dart:33-42`
- **Valeurs:** professional, fixedLocation, proRecent, professionalAlert, weddingPin, poiPrivate, searchTarget, user
- **Utilisation:** Affichage des marqueurs sur cartes

#### MapActionType
- **Fichier:** `/lib/backend/schema/enums/enums.dart:44-51`
- **Valeurs:** none, locateUser, moveToTarget, zoomIn, zoomOut, fitBounds
- **Utilisation:** Contrôles interactifs des cartes

#### DistanceUnit
- **Fichier:** `/lib/backend/schema/enums/enums.dart:53-56`
- **Valeurs:** km, miles
- **Utilisation:** Préférences utilisateur, affichage distances

#### RoomType
- **Fichier:** `/lib/backend/schema/enums/enums.dart:114-117`
- **Valeurs:** private, public
- **Utilisation:** Gestion des salons de chat

#### PermissionType
- **Fichier:** `/lib/backend/schema/enums/enums.dart:119-125`
- **Valeurs:** LOCATION, CAMERA, PHOTOS, MICROPHONE, NOTIFICATIONS
- **Utilisation:** Gestion des permissions Android/iOS

#### MapStyleType
- **Fichier:** `/lib/backend/schema/enums/enums.dart:127-132`
- **Valeurs:** normal, satellite, terrain, hybrid
- **Utilisation:** Styles de cartes

#### ChatEntryStatus
- **Fichier:** `/lib/backend/schema/enums/enums.dart:134-140`
- **Valeurs:** roomReady, requestPending, notAllowed, blocked, error
- **Utilisation:** États d'entrée dans les salons

#### CountryFilter
- **Fichier:** `/lib/backend/schema/enums/country_filter.dart:2-42`
- **Valeurs:** 42 pays + world
- **Propriétés:** code (ISO), displayName
- **Utilisation:** Filtrage géographique du feed

---

## 4. Matrice de Référencement Croisé

| Nom Enum | Type Supabase | Classe Flutter | Statut | Discrepances |
|----------|---------------|----------------|--------|--------------|
| UserRole | ✅ userRole | ✅ UserRole | **SYNCHRONISÉ** | Aucune |
| Profession | ✅ profession | ✅ Profession | **SYNCHRONISÉ** | Aucune |
| SubscriptionTierType | ✅ subscriptionTierType | ✅ SubscriptionTierType | **SYNCHRONISÉ** | Aucune |
| ConnectionRequestSource | ✅ connectionRequestSource | ✅ ConnectionRequestSource | **SYNCHRONISÉ** | Aucune |
| ConnectionRequestStatus | ✅ connectionRequestStatus | ✅ ConnectionRequestStatus | **SYNCHRONISÉ** | Aucune |
| VideoSessionStatus | ✅ videoSessionStatus | ✅ VideoSessionStatus | **SYNCHRONISÉ** | Aucune |
| MessageType | ✅ messageType | ✅ MessageType | **SYNCHRONISÉ** | Aucune |
| NotificationType | ✅ notificationType | ✅ NotificationType | **SYNCHRONISÉ** | Aucune |
| ConversationStatus | ✅ conversationStatus | ✅ ConversationStatus | **⚠️ DISCREPANCE** | Flutter a "archived" en plus |
| AlertStatus | ✅ alertStatus | ✅ AlertStatus | **⚠️ DISCREPANCE** | Flutter manque "cancelled" |
| MapMarkerType | ❌ N/A | ✅ MapMarkerType | **UI-ONLY** | Non présent en base |
| MapActionType | ❌ N/A | ✅ MapActionType | **UI-ONLY** | Non présent en base |
| DistanceUnit | ❌ N/A | ✅ DistanceUnit | **UI-ONLY** | Non présent en base |
| RoomType | ❌ N/A | ✅ RoomType | **UI-ONLY** | Non présent en base |
| PermissionType | ❌ N/A | ✅ PermissionType | **UI-ONLY** | Non présent en base |
| MapStyleType | ❌ N/A | ✅ MapStyleType | **UI-ONLY** | Non présent en base |
| ChatEntryStatus | ❌ N/A | ✅ ChatEntryStatus | **UI-ONLY** | Non présent en base |
| CountryFilter | ❌ N/A | ✅ CountryFilter | **UI-ONLY** | Non présent en base |
| aal_level | ✅ aal_level | ❌ N/A | **SYSTÈME** | Non implémenté dans Flutter |
| action | ✅ action | ❌ N/A | **SYSTÈME** | Non implémenté dans Flutter |
| app_role | ✅ app_role | ❌ N/A | **SYSTÈME** | Non implémenté dans Flutter |
| buckettype | ✅ buckettype | ❌ N/A | **SYSTÈME** | Non implémenté dans Flutter |
| contentModerationStatus | ✅ contentModerationStatus | ❌ N/A | **SYSTÈME** | Non implémenté dans Flutter |
| equality_op | ✅ equality_op | ❌ N/A | **SYSTÈME** | Non implémenté dans Flutter |
| factor_* | ✅ factor_* | ❌ N/A | **SYSTÈME** | Non implémenté dans Flutter |
| key_* | ✅ key_* | ❌ N/A | **SYSTÈME** | Non implémenté dans Flutter |
| oauth_* | ✅ oauth_* | ❌ N/A | **SYSTÈME** | Non implémenté dans Flutter |
| one_time_token_type | ✅ one_time_token_type | ❌ N/A | **SYSTÈME** | Non implémenté dans Flutter |

---

## 5. Patterns d'Utilisation & Logique Métier

### 5.1 Enums à Fort Impact Métier

#### UserRole
**Logique conditionnelle:**
```dart
// lib/custom_code/actions/load_initial_session_data.dart:16
switch (s) {
  case 'bride':
    // UI spécifique mariée
  case 'professional':
    // UI spécifique professionnel
}
```

**Flux d'état:** Authentification → Chargement profil → UI conditionnelle

#### Profession
**Logique de filtrage:**
```dart
// lib/custom_code/actions/reset_and_apply_default_filters.dart:17
// Récupère automatiquement toutes les valeurs de l'enum Profession
```

**Validation:** Recherche par profession, affichage profil, permissions

#### ConnectionRequestStatus
**Machine à états:**
```
pending → accepted/declined
         ↓
      (notifications envoyées)
```

**Utilisation:** UI des demandes, notifications, permissions de conversation

#### VideoSessionStatus
**Cycle de vie complet:**
```
pending → accepted/declined/missed → completed/cancelled
```

**Impact:** UI des appels, notifications, états des boutons

#### NotificationType
**Routing complexe:**
```dart
// lib/custom_code/actions/handle_notification_redirection.dart:53
switch (type) {
  case 'chatMessage':
    // Navigation vers conversation
  case 'connectionRequest':
    // Navigation vers demandes
  // ... 9 autres cas
}
```

### 5.2 Patterns de Sérialisation

#### Extension Standardisée
```dart
// lib/backend/schema/enums/enums.dart:142-149
extension FFEnumExtensions<T extends Enum> on T {
  String serialize() => name;
}

extension FFEnumListExtensions<T extends Enum> on Iterable<T> {
  T? deserialize(String? value) =>
      firstWhereOrNull((e) => e.serialize() == value);
}
```

#### Désérialisation Centralisée
```dart
// lib/backend/schema/enums/enums.dart:151-189
T? deserializeEnum<T>(String? value) {
  switch (T) {
    case (UserRole):
      return UserRole.values.deserialize(value) as T?;
    // ... 15 autres cas
  }
}
```

### 5.3 Patterns de Validation

#### Gestion des Valeurs Inconnues
```dart
// lib/custom_code/actions/get_notifications_action.dart:29
debugPrint('--- WARNING: Unmatched notificationType enum value from DB: "$s" ---');
```

#### Fallback par Défaut
```dart
// lib/backend/schema/enums/country_filter.dart:49-55
static CountryFilter fromCode(String? code) {
  if (code == null || code.isEmpty) return CountryFilter.world;
  return CountryFilter.values.firstWhere(
    (c) => c.code == code,
    orElse: () => CountryFilter.world,
  );
}
```

---

## 6. Feuille de Route pour Unification CRM

### 6.1 Actions Immédiates (Priorité Haute)

#### 1. Corriger AlertStatus
**Problème:** Flutter manque "cancelled"
**Action:** Ajouter `cancelled` à l'enum Flutter
**Impact:** Évite les erreurs de désérialisation

```dart
enum AlertStatus {
  active,
  expired,
  cancelled, // ← Ajouter cette valeur
}
```

#### 2. Gérer ConversationStatus.archived
**Problème:** Flutter a "archived" mais pas Supabase
**Action:** Ajouter "archived" à l'enum Supabase OU gérer en UI-only
**Recommandation:** Ajouter à Supabase pour cohérence

```sql
ALTER TYPE conversationStatus ADD VALUE 'archived';
```

### 6.2 Standardisation (Priorité Moyenne)

#### 1. Convention de Nommage
**État actuel:** Mixte camelCase/snake_case
**Standard proposé:** 
- Supabase: snake_case (existant)
- Flutter: camelCase (existant)
- Mapping automatique via extensions

#### 2. Création de Tables de Mapping
**Pour les enums UI-only:** Créer tables de référence si besoin de persistance
```sql
CREATE TABLE ui_enum_mappings (
  enum_name TEXT,
  flutter_value TEXT,
  display_value TEXT
);
```

### 6.3 Documentation & Architecture (Priorité Basse)

#### 1. Séparation des Responsabilités
- **Enums Métier:** Synchronisés Flutter ↔ Supabase
- **Enums UI:** Flutter uniquement, pas de persistance
- **Enums Système:** Supabase uniquement, technique

#### 2. Génération de Code Automatique
**Recommandation:** Utiliser build_runner pour générer automatiquement les mappings et extensions basés sur le schéma Supabase

---

## 7. Conclusions & Recommandations Finales

### État Actuel
- **9 enums métier** correctement synchronisés
- **2 enums** avec discrepancies critiques à corriger
- **8 enums UI-only** bien architecturés
- **14 enums système** correctement isolés

### Recommandations CRM
1. **Corriger immédiatement** AlertStatus et ConversationStatus
2. **Documenter** clairement les 3 catégories d'enums
3. **Automatiser** la génération des mappings pour éviter futures discrepancies
4. **Maintenir** l'architecture actuelle (séparation UI/métier/système)

### Prochaines Étapes
1. Appliquer les corrections identifiées
2. Mettre à jour les tests unitaires pour les enums modifiés
3. Configurer la surveillance des discrepancies enum dans CI/CD
4. Documenter les guidelines pour nouveaux enums

---

**Document généré le:** 2025-11-25  
**Prochaine révision prévue:** Après corrections des discrepancies identifiées  
**Responsable:** Développement Flutter & Backend Supabase
