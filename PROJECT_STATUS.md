# Cahier des Charges Technique de l'Application Lynewed Alpha

**Version:** 1.1.0+56  
**Date de génération:** 7 novembre 2025  
**Environnement:** Production  
**Type:** Application Mobile Native (iOS & Android)  
**Dernière mise à jour sécurité:** 7 novembre 2025

---

## 1. Vue d'Ensemble & Architecture Globale

### 1.1. Description de l'Application

Lynewed Alpha est une application mobile marketplace dédiée à l'industrie du mariage, mettant en relation deux types d'utilisateurs :
- **Mariées (Brides)** : Recherchent et découvrent des professionnels du mariage
- **Professionnels (Professionals)** : Offrent leurs services et showcasent leur portfolio

### 1.2. Architecture Système

L'application suit une **architecture Client-Serveur moderne** de type **Mobile-First BaaS (Backend as a Service)** avec Supabase comme plateforme backend principale.

**Communication :**
- Frontend Flutter ↔ Supabase PostgreSQL (via PostgREST API)
- Frontend Flutter ↔ Supabase Edge Functions (serverless TypeScript/Deno)
- Frontend Flutter ↔ Supabase Realtime (WebSocket pour chat temps réel)
- Frontend Flutter ↔ Supabase Storage (S3-compatible pour médias)
- Frontend Flutter → Agora SDK (P2P pour visioconférence)
- Frontend Flutter → Google Maps API (cartographie et géolocalisation)
- Backend Edge Functions → Firebase Cloud Messaging (push notifications)

### 1.3. Flux de Communication Principaux

**Authentification :**
```
User Sign-in → Supabase Auth → JWT Token → Stored in Secure Storage
```

**Appel Vidéo :**
```
User A initiates call → Edge Function (agora_token_issue) → Token generated
→ Agora SDK joins channel → FCM push to User B → User B joins with token
```

**Recherche Géographique :**
```
User searches city → Google Places Autocomplete → Coordinates
→ PostGIS spatial query → Filtered professionals list
```

---

## 2. Stack Technologique Détaillée

### 2.1. Frontend

**Framework & Versions**
- **Framework:** Flutter SDK 3.22.4 - 3.32.4
- **Langage:** Dart 3.0.0+
- **Plateformes cibles:** iOS 12.0+, Android API 21+

### 2.2. Backend

**Infrastructure**
- **Plateforme:** Supabase Cloud
- **URL:** https://odzkhcplevcqbuhzqsmq.supabase.co
- **Base de données:** PostgreSQL 17.x
- **Runtime Edge Functions:** Deno 2.x

### 2.3. Services Tiers Principaux

**Visioconférence**
- **Service:** Agora Video SDK
- **Version package:** agora_rtc_engine 6.3.2
- **Modèle:** Communication 1-to-1

**Cartographie**
- **Service:** Google Maps Platform
- **APIs:** Maps SDK, Places API, Geocoding API
- **Version package:** google_maps_flutter ^2.12.2

**Notifications Push**
- **Service:** Firebase Cloud Messaging (FCM)
- **Projet:** lynewed-app
- **Version:** firebase_messaging ^15.2.7

**Email**
- **Service:** Resend
- **Usage:** Emails transactionnels depuis Edge Functions

**Géocodage**
- **Service:** Nominatim (OpenStreetMap)
- **Usage:** Conversion villes → coordonnées GPS gratuitement

---

## 3. Architecture Frontend (Flutter)

### 3.1. Structure du Projet

```
lib/
├── main.dart                    # Point d'entrée
├── app_constants.dart           # Constantes globales
├── app_state.dart              # State management global
├── firebase_options.dart       # Config Firebase
├── auth/                       # Authentification
├── backend/                    # Backend layer
│   ├── schema/                # Data models (40+ structs)
│   └── supabase/              # Database queries
├── flutter_flow/              # Code généré FlutterFlow
├── pages/                     # Écrans (71 items)
│   ├── auth/                 # Login, signup
│   ├── bride/                # Pages mariées
│   ├── pro/                  # Pages professionnels
│   └── shared/               # Commun (chat, video, etc.)
├── compo_finaux/             # Composants UI finaux
├── components/               # Composants UI base
├── conversation_sheet/       # Components chat
├── custom_code/              # Code custom (96+ actions)
└── services/                 # Services (Agora manager, etc.)
```

### 3.2. Gestion de l'État

**Architecture:** Provider + App State global
- `provider: 6.1.5` pour propagation du state
- `FFAppState` classe singleton avec persistance
- Streams pour données temps réel (auth, JWT, Agora events)

### 3.3. Dépendances Clés

**Backend & Database**
- supabase_flutter: 2.9.0
- postgrest: 2.4.2
- storage_client: 2.4.0
- realtime_client: 2.5.0
- functions_client: 2.4.2

**Navigation**
- go_router: 12.1.3
- uni_links: ^0.5.1
- app_links: 6.3.2

**Cartographie & Géolocalisation**
- google_maps_flutter: ^2.12.2
- geolocator: ^14.0.1

**Médias**
- cached_network_image: 3.4.1
- image_picker: ^1.0.7
- flutter_image_compress: ^2.0.4
- video_player: ^2.9.1

**Audio & Visioconférence**
- agora_rtc_engine: 6.3.2
- record: ^6.0.0
- just_audio: ^0.10.4
- permission_handler: 12.0.0+1

**Notifications**
- firebase_core: ^3.14.0
- firebase_messaging: ^15.2.7

**UI Components**
- flutter_animate: 4.5.0
- google_fonts: 6.1.0
- font_awesome_flutter: 10.7.0

**Stockage Local**
- flutter_secure_storage: 10.0.0-beta.4
- shared_preferences: 2.5.3
- sqflite: 2.3.3+1
- hive: 2.2.3

**Utilitaires**
- flutter_dotenv: ^5.1.0
- intl: 0.20.2
- uuid: ^4.5.1

### 3.4. Configuration Environnement

**Variables .env:**
```
SUPABASE_URL=https://odzkhcplevcqbuhzqsmq.supabase.co
SUPABASE_ANON_KEY=[clé publique]
GOOGLE_PLACES_API_KEY=[clé API]
AGORA_APP_ID=[ID Agora]
FIREBASE_PROJECT_ID=lynewed-app
```

**Accès sécurisé:**
- Chargement via `flutter_dotenv`
- Classe `FFAppConstants` pour l'accès
- `.env` dans `.gitignore`

### 3.5. Permissions

**iOS (Info.plist):**
- Camera, Photo Library, Microphone
- Location When In Use
- Bluetooth
- Remote notifications background mode

**Android (AndroidManifest.xml):**
- INTERNET, CAMERA, RECORD_AUDIO
- ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION
- BLUETOOTH, BLUETOOTH_CONNECT
- POST_NOTIFICATIONS

---

## 4. Architecture Backend (Supabase)

### 4.1. Base de Données PostgreSQL

**Version:** PostgreSQL 17.x

**Extensions principales activées:**
- **postgis 3.3.7** : Géométries spatiales (types geometry, POINT)
- **pg_cron 1.6.4** : Tâches planifiées
- **uuid-ossp 1.1** : Génération UUID
- **pgcrypto 1.3** : Fonctions cryptographiques
- **pgsodium 3.1.8** : Cryptographie libsodium
- **supabase_vault 0.3.1** : Stockage sécurisé secrets
- **pg_graphql 1.5.11** : API GraphQL
- **vector 0.8.0** : Support embeddings AI
- **pg_net 0.19.5** : Requêtes HTTP async

**Tables principales (36 au total):**

| Table | Description | RLS |
|-------|-------------|-----|
| profiles | Profils utilisateurs (bride/professional) | ✅ |
| professional_details | Détails professionnels | ✅ |
| professional_subscriptions | Abonnements (tiers, Stripe) | ✅ |
| professional_fixed_locations | Lieux travail multiples (PostGIS) | ✅ |
| connection_requests | Demandes de connexion | ✅ |
| wishlist_items | Favoris mariées | ✅ |
| video_sessions | Sessions vidéo Agora | ✅ |
| chat_rooms | Salons chat | ✅ |
| chat_room_participants | Participants rooms | ✅ |
| chat_messages | Messages chat | ✅ |
| notifications | Notifications (partitionnée) | ✅ |
| device_tokens | Tokens FCM devices | ✅ |
| professional_alerts | Alertes géographiques pros | ✅ |
| user_pois | Points d'intérêt mariées | ✅ |
| wedding_pins | Épingles mariage | ✅ |
| content | Contenus feed | ✅ |
| replays | Vidéos replay événements | ✅ |
| wed_articles | Articles mariage | ✅ |
| support_tickets | Tickets support | ✅ |
| user_roles | Rôles admin/moderator | ✅ |

**Partitionnement temporel:**
- Table `notifications` partitionnée par mois
- Partitions: notifications_2025_09, _10, _11, _12

**Types de données spécifiques:**
- `geometry (POINT)` pour coordonnées GPS
- `jsonb` pour données flexibles
- Enums custom: `userRole`, `profession`, `subscriptionTierType`, `notificationType`, etc.

### 4.2. Authentification (GoTrue)

**Fournisseurs activés:**
- Email/Password
- Sign in with Apple

**Configuration:**
- JWT expiration: 3600s (1h)
- Refresh token rotation: activé
- Signup: activé
- Email confirmation: désactivé (auto-confirmed)
- Minimum password length: 6 caractères

### 4.3. Stockage (Storage)

**Buckets (8 buckets):**

| Nom | Public | Usage |
|-----|--------|-------|
| avatars | ✅ | Avatars utilisateurs |
| portfolio | ✅ | Images portfolio pros |
| users_profiles | ✅ | Photos profils |
| public_images | ✅ | Images publiques |
| replays | ✅ | Vidéos replays |
| chat-images | ❌ | Images chat (privé) |
| chat-audio | ❌ | Audio chat (privé) |
| chat_attachments | ❌ | Pièces jointes chat |

**Configuration:**
- Taille max fichier: 50 MiB (52,428,800 bytes)
- Image transformation: activée
- Protocole S3: activé

**Politiques d'accès:**
- Buckets publics: lecture ouverte, écriture authentifiée
- Buckets privés: RLS sur user_id

### 4.4. Logique Serverless

**Edge Functions (15 déployées):**

| Function | Version | Usage | Auth JWT |
|----------|---------|-------|----------|
| agora_token_issue | 26 | Génération tokens Agora vidéo | ✅ |
| create-or-sync-user | 46 | Sync CRM → App users | ✅ |
| delete-user | 16 | Suppression compte cascade | ✅ |
| account_delete | 19 | Suppression compte (alt) | ❌ |
| notifications_outbox_drain | 30 | Envoi notifications FCM | ✅ |
| alerts_housekeeping | 18 | Nettoyage alertes expirées | ✅ |
| recent_locations_cleanup | 18 | Nettoyage localisations anciennes | ✅ |
| video_sessions_cleanup | 2 | Nettoyage sessions vidéo | ✅ |
| sync-professional-profile | 14 | Sync profils pros CRM | ❌ |
| sync-professional-to-app | 43 | Sync pros vers app | ❌ |
| sync-wed-articles-to-app | 31 | Sync articles mariage | ❌ |
| sync-wedding-article | 9 | Sync article unique | ❌ |
| upload-professional-images | 14 | Upload images pros | ❌ |
| send-verification-email | 28 | Email vérification | ❌ |
| send-ticket-reply | 19 | Réponse ticket support | ❌ |

**Cron Jobs (pg_cron):**
- Nettoyage video_sessions anciennes (quotidien)
- Nettoyage professional_alerts expirées
- Nettoyage pro_recent_locations anciennes
- Drainage notifications_outbox

**Procédures Stockées (RPCs):**
- get_favorited_professionals
- get_feed_professionals
- search_professionals_advanced
- get_bride_interest_items
- get_notifications_paginated
- Et 20+ autres RPCs métier

---

## 5. Services Tiers & Intégrations API

### 5.1. Agora Video SDK

**Configuration:**
- App ID: Stocké dans .env
- App Certificate: Stocké côté serveur uniquement
- Token lifetime: 3600s (1h)

**Flow d'intégration:**
1. User initie appel → `start_video_session_action.dart`
2. Flutter calcule UID numérique
3. Appel Edge Function `agora_token_issue` avec channelName + UID
4. Edge Function vérifie JWT auth
5. Edge Function génère token Agora avec `RtcTokenBuilder`
6. Flutter reçoit token → `AgoraEngineManager.instance.joinChannel()`
7. Notification FCM envoyée au destinataire
8. Destinataire rejoint avec son propre token

**Gestion SDK:**
- Singleton `AgoraEngineManager` dans `lib/services/`
- Initialisation au démarrage de l'app
- Stream d'événements (`onUserJoined`, `onUserOffline`, etc.)
- Mode: Communication (pas broadcast)

### 5.2. Google Maps Platform

**APIs utilisées:**
- **Maps SDK for iOS/Android** : Affichage cartes
- **Places API** : Autocomplete recherche lieux
- **Geocoding API** : Conversion adresses ↔ GPS

**Implémentation:**
- Widget `GoogleMap` dans pages search
- Autocomplete via `get_place_predictions.dart`
- Details via `get_place_details_rich.dart`
- API key dans `.env` → `FFAppConstants.googlePlacesApiKey`

**Sécurité recommandée:**
- Restriction API key par bundle ID iOS
- Restriction par package name Android

### 5.3. Firebase Cloud Messaging (FCM)

**Configuration:**
- Projet: lynewed-app
- Sender ID: 774379904347
- iOS App ID: 1:774379904347:ios:059f99d3dbad53c1bf4e7e
- Android App ID: 1:774379904347:android:059f99d3dbad53c1bf4e7e

**Types de notifications:**
- `chatMessage` : Nouveau message chat
- `connectionRequest` : Demande de connexion
- `connectionRequestAccepted` / `Declined`
- `wishlistAdd` : Ajouté en favori
- `professionalAlert` : Alerte géographique pro
- `videoIncoming` : Appel vidéo entrant
- `wedPublished` : Article publié
- `weddingPinMatch` : Match épingle mariage

**Flow notifications:**
1. Event dans l'app → Insert dans `notifications` table
2. Trigger DB → Insert dans `notifications_outbox`
3. Edge Function `notifications_outbox_drain` (cron)
4. Récupère tokens FCM depuis `device_tokens`
5. Envoie via Firebase Admin SDK
6. Marque outbox comme envoyé

**Gestion côté Flutter:**
- `init_push_notifications.dart` : Initialisation
- `handle_notification_redirection.dart` : Routing sur tap
- Stockage tokens dans `device_tokens` table

### 5.4. Resend (Email Service)

**Usage:**
- Vérification email utilisateur
- Réponse tickets support
- Notifications admin

**Edge Functions concernées:**
- `send-verification-email`
- `send-ticket-reply`

**Configuration:**
- API key Resend stockée dans secrets Supabase
- Templates email customisables

### 5.5. Nominatim (OpenStreetMap)

**Usage:**
- Géocodage gratuit de villes en coordonnées GPS
- Alternative à Google Geocoding API

**Implémentation:**
- Dans Edge Function `create-or-sync-user`
- Fonction `geocodeCity(cityName)` retourne `POINT(lon lat)`
- User-Agent: "LynewedApp/1.0"
- Contact email: contact@lynewed.com

---

## 6. Sécurité & Bonnes Pratiques

### 6.1. Sécurité des Données

**Row Level Security (RLS):**
- ✅ Activé sur toutes les tables (36/36)
- Policies basées sur `auth.uid()`
- Users voient uniquement leurs données ou données publiques
- Service role bypass RLS pour fonctions admin

**Exemples de policies:**
```sql
-- profiles: lecture si profil public ou own
CREATE POLICY "Users can view public profiles or their own"
ON profiles FOR SELECT
USING (auth.uid() = id OR is_public = true);

-- chat_messages: lecture si participant de la room
CREATE POLICY "Users can read messages in their rooms"
ON chat_messages FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM chat_room_participants
    WHERE room_id = chat_messages.room_id
    AND profile_id = auth.uid()
  )
);
```

### 6.2. Gestion des Secrets

**Côté Client (Flutter):**
- Clés API non sensibles dans `.env`
- `.env` exclu du versioning (`.gitignore`)
- Supabase anon key: public (c'est normal)
- Google Places API key: à restreindre par bundle ID
- Agora App ID: public (tokens générés serveur)

**Côté Serveur (Supabase):**
- Secrets Supabase: `SUPABASE_SERVICE_ROLE_KEY`
- Secrets Edge Functions: `AGORA_APP_CERTIFICATE`, `RESEND_API_KEY`
- Stockage dans Supabase Vault

**Tokens JWT:**
- Expiration: 1h
- Refresh tokens: rotation activée
- Stockage: `flutter_secure_storage`

### 6.3. Politiques de Stockage

**Buckets publics:**
- Lecture: ouverte à tous
- Écriture: authentifiée uniquement
- Validation: type MIME, taille max 50MB

**Buckets privés:**
- Lecture/Écriture: RLS basée sur user_id
- Génération URL signées pour partage temporaire

### 6.4. Protection API

**Rate Limiting (Supabase Auth):**
- Email sent: 2/heure
- Sign-in/up: 30 requests/5min/IP
- Token refresh: 150 requests/5min/IP
- OTP verifications: 30/5min/IP

**Edge Functions:**
- Vérification JWT sur fonctions sensibles
- Validation input (zod, type checking)
- Logging détaillé pour audit

---

## 7. Performance & Optimisations

### 7.1. Frontend

**Caching:**
- Images réseau: `cached_network_image`
- API responses: `flutter_cache_manager`
- State persistence: `shared_preferences`, `sqflite`

**Lazy Loading:**
- Lists infinies avec pagination
- Images chargées on-demand
- Defer loading screens non critiques

### 7.2. Backend

**Index Database:**
- Index sur colonnes fréquemment requêtées
- Index PostGIS GIST sur `location_coords`
- Index B-tree sur foreign keys

**Partitionnement:**
- Table `notifications` partitionnée par mois
- Améliore performances queries récentes
- Facilite archivage données anciennes

**Connection Pooling:**
- Supabase gère automatiquement
- Mode: transaction pooling

---

## 8. Monitoring & Observabilité

### 8.1. Logging

**Edge Functions:**
- Console logs détaillés avec emojis (🚀, ✅, ❌)
- Format: `[SERVICE] Action: details`
- Masquage données sensibles (channelName, tokens)

**PostgreSQL:**
- `pg_stat_statements` pour analyse requêtes
- `pg_stat_monitor` pour monitoring avancé
- Logs Supabase Dashboard

### 8.2. Métriques

**Supabase Dashboard:**
- Requêtes DB (queries/s, latency)
- Storage usage
- Edge Functions invocations
- Realtime connections

**Firebase Console:**
- Notifications deliveries
- Crash reports (si Crashlytics activé)

---

## 9. Déploiement & Environments

### 9.1. Environnements

**Production:**
- Supabase: https://odzkhcplevcqbuhzqsmq.supabase.co
- Firebase: lynewed-app

**Local Development:**
- Supabase CLI avec `supabase start`
- Local PostgreSQL sur port 54322
- Local Studio sur port 54323

### 9.2. CI/CD

**Flutter:**
- Build iOS: Xcode + CocoaPods
- Build Android: Gradle
- Version: 1.0.52+55 (semantic versioning)

**Supabase:**
- Migrations: Versionnées dans `supabase/migrations/`
- Edge Functions: Déployées via Supabase CLI
- 51 migrations appliquées

### 9.3. Versions

**App Versioning:**
- Format: `MAJOR.MINOR.PATCH+BUILD`
- Actuelle: 1.0.52+55
- iOS: CFBundleShortVersionString & CFBundleVersion
- Android: versionName & versionCode

---

## 10. Considérations Futures

### 10.1. Scalabilité

**Database:**
- Partitionnement automatique notifications
- Sharding si volume > 1M users
- Read replicas pour performances

**Storage:**
- CDN pour assets statiques
- Image transformation on-the-fly (déjà activé)

### 10.2. Features Prévues

- Internationalization (EN, FR, ES)
- Payment intégration (Stripe checkout)
- Advanced analytics (Mixpanel/Amplitude)
- AI recommendations (vector embeddings activés)

---

## Annexes

### A. Commandes Utiles

**Flutter:**
```bash
flutter clean && flutter pub get
flutter run -d ios
flutter build ios --release
flutter build appbundle --release
```

**Supabase:**
```bash
supabase start
supabase db reset
supabase functions deploy
supabase migration new <name>
```

**iOS:**
```bash
cd ios && pod install && cd ..
```

### B. Documentation de Référence

- [Flutter Docs](https://docs.flutter.dev/)
- [Supabase Docs](https://supabase.com/docs)
- [Agora Docs](https://docs.agora.io/)
- [Google Maps Platform](https://developers.google.com/maps)
- [Firebase Docs](https://firebase.google.com/docs)

### C. Contacts & Support

- **Email technique:** contact@lynewed.com
- **Repository:** (privé)
- **Supabase Project ID:** odzkhcplevcqbuhzqsmq

---

## 🔒 Améliorations de Sécurité & Robustesse (v1.1.0)

**Date de mise à jour:** 7 novembre 2025

### Corrections Appliquées

#### 1. Migration des Secrets vers Variables d'Environnement ✅
- **Problème résolu:** Clés API hardcodées dans le code source (extractibles depuis binaires)
- **Solution:** Migration complète vers fichier `.env`
- **Fichiers modifiés:**
  - `lib/backend/supabase/supabase.dart` - Secrets Supabase depuis .env
  - `lib/firebase_options.dart` - Secrets Firebase depuis .env
  - `.env.example` - Template mis à jour
- **Impact:** Secrets non extractibles, rotation simplifiée, support multi-environnement

#### 2. Cleanup Agora Engine Manager ✅
- **Problème résolu:** Memory leaks potentiels, ressources non libérées
- **Solution:** Amélioration du lifecycle management
- **Fichiers modifiés:**
  - `lib/services/agora_engine_manager.dart` - dispose() amélioré
  - `lib/main.dart` - Appel dispose au shutdown
- **Impact:** Pas de memory leaks, ressources correctement libérées

#### 3. Error Boundaries & Validation ✅
- **Problème résolu:** Erreurs silencieuses, pas de validation au démarrage
- **Solution:** Validation stricte + error handling centralisé
- **Fichiers créés:**
  - `lib/utils/error_handler.dart` - Utilitaire centralisé
- **Fichiers modifiés:**
  - `lib/backend/supabase/supabase.dart` - Validation env vars
  - `lib/app_constants.dart` - Warnings pour clés manquantes
- **Impact:** Fail-fast, messages explicites, debugging facilité

#### 4. Retry Logic pour Appels Critiques ✅
- **Problème résolu:** Échecs réseau temporaires = échec complet
- **Solution:** Retry automatique avec exponential backoff
- **Fichiers créés:**
  - `lib/utils/network_helper.dart` - Retry logic réutilisable
- **Fichiers modifiés:**
  - `lib/custom_code/actions/get_agora_token_action.dart` - Retry sur token Agora
- **Impact:** Résilience réseau, meilleure UX

#### 5. Nettoyage du Code ✅
- **33 issues corrigées** (502 → 469)
- Imports inutilisés supprimés
- Variables inutilisées supprimées
- Comparaisons null inutiles supprimées
- Print remplacés par debugPrint

### Recommandations Additionnelles

**Actions manuelles requises avant production:**
1. ⚠️ Restreindre Google Places API Key par bundle ID/package name
2. ⚠️ Activer Firebase App Check (DeviceCheck iOS, Play Integrity Android)
3. ⚠️ Implémenter rate limiting sur Edge Functions critiques
4. ⚠️ Configurer crash reporting (Firebase Crashlytics)

**Documentation créée:**
- `SECURITY_RECOMMENDATIONS.md` - Checklist sécurité complète
- `CORRECTIONS_APPLIED.md` - Documentation détaillée des corrections

---

### 📊 Résumé des Découvertes
- **Architecture Globale** :

- Application Flutter mobile-first (iOS/Android)
- Backend Supabase (PostgreSQL 17 + Edge Functions Deno)
- 15 Edge Functions serverless déployées
- 36 tables PostgreSQL avec RLS activé sur toutes
- 8 buckets Storage (publics et privés)

- **Stack Technique** :

- Frontend : Flutter 3.22.4-3.32.4, 100+ dépendances
- Backend : Supabase, PostgreSQL 17 avec 28 extensions (dont PostGIS)
- Visioconférence : Agora Video SDK 6.3.2
- Cartographie : Google Maps Platform (Maps, Places, Geocoding)
- Notifications : Firebase Cloud Messaging
- Email : Resend
- Géocodage : Nominatim (OpenStreetMap)

- **Fonctionnalités Clés Identifiées** :

- Marketplace mariées ↔ professionnels du mariage
- Recherche géographique avec PostGIS
- Chat temps réel (Supabase Realtime)
- Visioconférence 1-to-1 avec tokens serveur sécurisés
- Système de notifications push multi-type
- Gestion favoris/wishlist
- Demandes de connexion
- Alertes géographiques professionnels
- Portfolio professionnels avec images/vidéos
- Articles de blog mariage

- **Sécurité :**

- Row Level Security (RLS) sur 100% des tables
- JWT tokens avec rotation
- Secrets gérés via Supabase Vault
- Storage avec politiques d'accès granulaires

- **Infrastructure :**

- Partitionnement temporel (notifications par mois)
- Cron jobs automatiques (nettoyage données)
- 51 migrations appliquées
- Version app : 1.1.0+56

**Document généré automatiquement via rétro-ingénierie complète du codebase.**  
**Dernière mise à jour:** 7 novembre 2025  
**Dernière mise à jour sécurité:** 7 novembre 2025 (v1.1.0)

---

## 🔄 Structure du Repository GitHub (v1.1.1+59)

**Date de mise à jour:** 24 novembre 2025

### Architecture de Branches

**Structure actuelle :**
- `main` : Version production MVP v1.1.1+59 (App Store) - **protégée, stable**
- `release/v1.x` : Branche de maintenance pour hotfixes v1.x - **isolée de v2.0.0**
- `develop` : Branche de développement pour refactorisation v2.0.0

**Workflow Git amélioré :**
1. **MVP conservé** : `main` reste l'historique de référence du MVP déployé
2. **Hotfixes v1.x** : Si nécessaire sur `release/v1.x` (bugs critiques App Store)
3. **Refactorisation** : Tous les changements v2.0.0 se font sur `develop`
4. **Sync hotfixes** : `release/v1.x` → `main` (production) + `develop` (si pertinent)
5. **Release** : Quand v2.0.0 prête → merge `develop` → `main` + tag `v2.0.0`

**Tags et versions :**
- Tag actuel : `v1.1.1+59` (sur commit `0992be1`)
- Prochain tag : `v2.0.0` (après refactorisation)

### Prochaines Étapes

**Phase de Refactorisation (sur branche `develop`) :**
- 🏗️ Architecture clean code (separation layers, dependency injection)
- 🔧 Refactorisation FlutterFlow → Flutter natif
- 📊 Amélioration performance et scalabilité
- 🧪 Tests unitaires et intégration
- 📚 Documentation technique complète

**Objectif v2.0.0 :**
- Application production-ready et scalable
- Code maintenable et testable
- Architecture moderne (clean architecture + TDD)
- Performance optimisée
