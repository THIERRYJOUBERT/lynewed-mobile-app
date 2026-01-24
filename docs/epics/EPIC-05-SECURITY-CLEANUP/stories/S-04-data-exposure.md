# Story S-04: Audit Exposition Donnees Sensibles

## Metadata
| Champ | Valeur |
|-------|--------|
| **ID** | S-04 |
| **Epic** | EPIC-05-SECURITY-CLEANUP |
| **Priorite** | P1 - HAUTE |
| **Estimation** | 3h |
| **Statut** | NOT_STARTED |

---

## Description

En tant que **security engineer**, je veux auditer la gestion des donnees sensibles afin de **garantir que les informations personnelles ne sont pas exposees**.

---

## Contexte

L'application gere des donnees sensibles:
- **Profiles utilisateurs** (nom, email, photo, budget mariage)
- **Messages prives** (conversations 1-1)
- **Photos/medias** (portfolio, albums inspiration)
- **Localisation** (weddings, alertes pros)
- **Preferences** (notifications, settings)

### Points de Risque

| Donnee | Risque | Localisation |
|--------|--------|--------------|
| Email utilisateur | Enumeration, spam | Profiles, auth |
| Messages chat | Fuite conversation privee | Realtime, storage |
| Photos portfolio | Acces non autorise | Supabase Storage |
| Localisation wedding | Stalking | Map markers |
| Budget mariage | Donnee financiere sensible | Wedding details |

---

## Criteres d'Acceptance

- [ ] Audit des donnees sensibles exposees
- [ ] Verification RLS Supabase (Row Level Security)
- [ ] Verification signed URLs pour media
- [ ] Verification acces profils (public vs prive)
- [ ] Audit des logs pour donnees sensibles
- [ ] Documentation des donnees protegees

---

## Checklist Securite

### Logs & Debug
- [ ] Audit tous les `debugPrint`, `print()` pour donnees sensibles
- [ ] Verifier `SecureLogger` utilise partout
- [ ] Pas d'email/nom en clair dans logs
- [ ] Pas de JWT/tokens dans logs
- [ ] Logs de production desactives

### Storage Media
- [ ] Photos portfolio via signed URLs (expiration)
- [ ] Photos chat via signed URLs
- [ ] Pas d'URL publique permanente pour media prive
- [ ] Verification bucket policies Supabase

### Profils
- [ ] Distinction public_profiles vs profiles
- [ ] Email non expose dans profils publics
- [ ] Phone number protege
- [ ] Budget mariage non visible par autres users

### Messages
- [ ] Messages accessibles uniquement aux participants
- [ ] Realtime subscriptions filtrees par room
- [ ] Historique messages protege

### Localisation
- [ ] Wedding locations visibles seulement par membres team
- [ ] Alertes pros filtrées par region

---

## Implementation

### Audit SecureLogger

Le projet a deja `lib/utils/secure_logger.dart`:

```dart
static void debugSanitized(String message, {List<String>? sensitiveKeys}) {
  if (kDebugMode) {
    String sanitized = message;
    // ... sanitization logic
  }
}
```

**Verifier:**
1. Est-il utilise partout?
2. Liste des cles sensibles complete?
3. Logs Firebase/Crashlytics securises?

### Audit Calls Supabase

Verifier que les queries respectent RLS:
```dart
// BON: RLS filtre automatiquement
final data = await SupaFlow.client
    .from('profiles')
    .select()
    .eq('id', currentUserUid);

// RISQUE: Si RLS mal configure
final data = await SupaFlow.client
    .from('chat_messages')
    .select(); // Retourne tous les messages?
```

### Audit Signed URLs

```dart
// Verifier expiration
final url = await SupaFlow.client.storage
    .from('chat_media')
    .createSignedUrl(path, 3600); // 1h expiration

// RISQUE: URL permanente
final url = SupaFlow.client.storage
    .from('chat_media')
    .getPublicUrl(path); // Accessible indefiniment!
```

---

## Fichiers a Auditer

### Logs
- [ ] `lib/utils/secure_logger.dart` - Implementation OK?
- [ ] `lib/utils/error_handler.dart` - Pas de data leak?
- [ ] `lib/custom_code/actions/*.dart` - Utilise SecureLogger?

### Data Access
- [ ] `lib/backend/supabase/database/tables/*.dart` - Queries securisees?
- [ ] `lib/features/chat/data/datasources/chat_remote_datasource.dart`
- [ ] `lib/features/my_wedding/data/datasources/supabase_my_wedding_datasource.dart`

### Media
- [ ] `lib/custom_code/actions/create_signed_url_for_chat_media_action.dart`
- [ ] `lib/custom_code/actions/upload_and_send_images_action.dart`
- [ ] `lib/custom_code/actions/upload_avatar.dart`

---

## Risques

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Messages visibles par non-participants | CRITIQUE | Verifier RLS chat_messages |
| Photos accessibles sans auth | HAUTE | Signed URLs avec expiration |
| Email leak via logs | MOYENNE | SecureLogger systematique |
| Localisation wedding exposee | HAUTE | RLS sur wedding_pins |

---

## Definition of Done

- [ ] Audit complet des donnees sensibles
- [ ] Logs securises (SecureLogger)
- [ ] Media via signed URLs
- [ ] RLS Supabase verifie (hors scope backend mais documenter)
- [ ] Tests de regression passent
- [ ] PR reviewee et mergee
