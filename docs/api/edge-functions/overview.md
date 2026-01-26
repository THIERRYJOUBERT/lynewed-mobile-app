# Edge Functions - Vue d'Ensemble

**Location:** `supabase/functions/`
**Runtime:** Deno (TypeScript)
**Deployment:** Supabase Edge Functions

---

## Liste Complète (16 fonctions)

### Authentification & Utilisateurs

| Fonction | Trigger | Description |
|----------|---------|-------------|
| `create-or-sync-user` | Auth hook | Crée/synchronise le profil après inscription/login |
| `delete-user` | HTTP POST | Supprime les données utilisateur (RGPD) |
| `account_delete` | HTTP POST | Suppression complète du compte |

### Notifications

| Fonction | Trigger | Description |
|----------|---------|-------------|
| `notifications_outbox_drain` | Cron (30s) | Draine la queue et envoie les push via FCM |
| `send-broadcast-notification` | HTTP POST | Envoie une notification à plusieurs users |

### Vidéo (Agora)

| Fonction | Trigger | Description |
|----------|---------|-------------|
| `agora_token_issue` | HTTP POST | Génère un token Agora pour rejoindre un channel |
| `video_sessions_cleanup` | Cron | Nettoie les sessions vidéo expirées |

### Synchronisation CRM

| Fonction | Trigger | Description |
|----------|---------|-------------|
| `sync-professional-profile` | HTTP POST | Sync un profil pro depuis le CRM |
| `sync-professional-to-app` | Webhook | Reçoit les updates pro du CRM |
| `sync-wed-articles-to-app` | Webhook | Reçoit les articles mariage du CRM |
| `sync-wedding-article` | HTTP POST | Sync un article individuel |
| `upload-professional-images` | HTTP POST | Upload les images pros vers Storage |

### Maintenance

| Fonction | Trigger | Description |
|----------|---------|-------------|
| `alerts_housekeeping` | Cron | Marque les alertes expirées, envoie rappels |
| `recent_locations_cleanup` | Cron | Nettoie les localisations obsolètes |

### Support

| Fonction | Trigger | Description |
|----------|---------|-------------|
| `send-ticket-reply` | HTTP POST | Envoie un email de réponse à un ticket |
| `send-verification-email` | HTTP POST | Envoie l'email de vérification |

---

## Appel depuis Flutter

### Pattern Standard

```dart
import '/backend/supabase/supabase.dart';

Future<Map<String, dynamic>> callEdgeFunction(
  String functionName,
  Map<String, dynamic> body,
) async {
  final response = await SupaFlow.client.functions.invoke(
    functionName,
    body: body,
  );

  if (response.status != 200) {
    throw Exception('Edge function error: ${response.status}');
  }

  return response.data as Map<String, dynamic>;
}
```

### Exemples Concrets

#### Génération Token Agora

```dart
Future<String> getAgoraToken(String channelName) async {
  final response = await SupaFlow.client.functions.invoke(
    'agora_token_issue',
    body: {
      'channelName': channelName,
      'uid': currentUser.uid,
    },
  );

  return response.data['token'] as String;
}
```

#### Suppression de Compte

```dart
Future<void> deleteAccount() async {
  await SupaFlow.client.functions.invoke(
    'account_delete',
    body: {
      'userId': currentUser.uid,
      'reason': 'user_request',
    },
  );
}
```

#### Envoi Broadcast (Admin)

```dart
Future<void> sendBroadcast({
  required String title,
  required String body,
  required List<String> targetRoles,
}) async {
  await SupaFlow.client.functions.invoke(
    'send-broadcast-notification',
    body: {
      'title': title,
      'body': body,
      'target_roles': targetRoles, // ['bride', 'professional']
      'target_region': 'all',
    },
  );
}
```

---

## Détails par Fonction

### `agora_token_issue`

Génère un token Agora RTC pour rejoindre un channel vidéo.

**Input:**
```json
{
  "channelName": "room-uuid-xxx",
  "uid": "user-uuid"
}
```

**Output:**
```json
{
  "token": "006xxx...",
  "channelName": "room-uuid-xxx",
  "uid": 12345
}
```

---

### `notifications_outbox_drain`

Cron job qui tourne toutes les 30 secondes. Lit la table `notifications_outbox`, envoie les push via Firebase Cloud Messaging, et marque comme traité.

**Pas d'input** (déclenché automatiquement)

---

### `create-or-sync-user`

Hook appelé automatiquement après auth Supabase. Crée le profil dans `profiles` si nouveau, ou synchronise si existant.

**Input (automatique):**
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "user_metadata": {
      "full_name": "John Doe",
      "avatar_url": "https://..."
    }
  }
}
```

---

### `send-verification-email`

Envoie un email de vérification via Resend.

**Input:**
```json
{
  "email": "user@example.com",
  "verificationLink": "https://app.lynewed.com/verify?token=xxx"
}
```

---

### `sync-professional-profile`

Synchronise un profil professionnel depuis le CRM vers l'app.

**Input:**
```json
{
  "profileId": "uuid",
  "businessName": "Studio Photo",
  "profession": "PHOTOGRAPHER",
  "budgetMin": 1500,
  "budgetMax": 5000,
  "portfolioImages": ["url1", "url2"]
}
```

---

## Architecture des Cron Jobs

| Fonction | Fréquence | Description |
|----------|-----------|-------------|
| `notifications_outbox_drain` | 30s | Push notifications queue |
| `alerts_housekeeping` | 1h | Alertes expirées |
| `video_sessions_cleanup` | 1h | Sessions vidéo |
| `recent_locations_cleanup` | 24h | Localisations |

Configuration dans Supabase Dashboard > Edge Functions > Schedules.

---

## Sécurité

### Authentification

La plupart des fonctions requièrent un JWT valide dans le header:

```dart
// Automatique avec supabase_flutter
SupaFlow.client.functions.invoke('function-name', body: {...});
// Le JWT de l'utilisateur connecté est inclus automatiquement
```

### Fonctions Publiques

Certaines fonctions sont publiques (pas de JWT requis):
- `create-or-sync-user` (appelé par Supabase Auth)
- `sync-*` webhooks (authentifiés par secret)

### Secrets

Les Edge Functions utilisent des secrets Supabase:
- `FIREBASE_SERVICE_ACCOUNT` - Pour FCM
- `AGORA_APP_CERTIFICATE` - Pour tokens vidéo
- `RESEND_API_KEY` - Pour emails

---

## Debugging

### Logs

Voir les logs dans Supabase Dashboard > Edge Functions > Logs.

```dart
// Depuis Flutter
final logs = await SupaFlow.client.functions.invoke(
  'get_logs',
  body: {'service': 'edge-function'},
);
```

### Erreurs Communes

| Erreur | Cause | Solution |
|--------|-------|----------|
| 401 | JWT invalide/expiré | Reconnecter l'utilisateur |
| 500 | Erreur interne | Vérifier logs Supabase |
| Timeout | Fonction trop lente | Optimiser ou augmenter timeout |

---

## Notes

- Toutes les fonctions utilisent TypeScript
- Le cold start est d'environ 200-500ms
- Les fonctions cron n'ont pas de limite de timeout
- Les webhooks doivent répondre en < 30s
