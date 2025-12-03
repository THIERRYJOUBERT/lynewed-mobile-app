# 📱 GUIDE ÉQUIPE APP MOBILE - Modifications Requises

> **Date** : 03/12/2025  
> **Version** : 1.1  
> **Priorité** : 🔴 HAUTE  
> **Branche cible** : `develop`  
> **Base de données** : `LYNEWED-V1-APP` (Project ID: `hekyovgnovhfhmkpfrna`)

---

## 📋 RÉSUMÉ EXÉCUTIF

Ce document détaille les modifications que l'équipe App Mobile doit implémenter suite aux évolutions du système Admin Panel et de la base de données `LYNEWED-V1-APP`.

### Ce qui a été modifié côté Admin Panel / Backend

| Modification | Description | Impact App |
|--------------|-------------|------------|
| **Notifications Push** | Nouveau système temps réel via trigger PostgreSQL + Edge Function | L'app reçoit des notifications avec deep links |
| **Deep Links** | Sélecteur de page dans Admin Panel génère des liens `lynewed://` | L'app doit parser et naviguer |
| **Vidéo couverture WOW** | `cover_images[0]` peut être une URL YouTube/Vimeo | L'app doit détecter et afficher |
| **Vidéos dans WOW** | Blocs `type: "video"` dans `content_blocks` | L'app doit afficher un player |
| **Nom personnalisé WOW** | Bloc `type: "meta"` avec `custom_display_name` | L'app doit l'utiliser si présent |
| **Vidéos fiches pro** | `profile_video_url` contient déjà des URLs YouTube | L'app doit utiliser un player YouTube |

### Modifications à implémenter

| # | Fonctionnalité | Priorité | Complexité | Estimation |
|---|----------------|----------|------------|------------|
| 1 | Deep Linking pour notifications push | 🔴 Haute | Moyenne | 2-3h |
| 2 | Lecteur vidéo YouTube/Vimeo pour Wedding of the Week | 🔴 Haute | Moyenne | 3-4h |
| 3 | Lecteur vidéo YouTube/Vimeo pour fiches professionnelles | 🔴 Haute | Faible | 1-2h |
| 4 | Nom affiché personnalisé dans Wedding of the Week | 🟡 Moyenne | Faible | 30min |

---

## 🔄 CE QUI A ÉTÉ MODIFIÉ CÔTÉ BACKEND

### 1. Système de notifications push

**Avant** : Cron job toutes les minutes (latence jusqu'à 60s)  
**Après** : Trigger PostgreSQL temps réel (latence < 1s)

L'Edge Function `send-broadcast-notification` envoie maintenant les notifications avec un payload enrichi incluant le deep link.

### 2. Tables modifiées

| Table | Colonne | Changement |
|-------|---------|------------|
| `broadcast_history` | `link` | Contient maintenant des deep links `lynewed://` |
| `wed_articles` | `cover_images[0]` | Peut contenir une URL YouTube/Vimeo |
| `wed_articles` | `content_blocks` | Nouveau type `meta` avec `custom_display_name` |
| `professional_details` | `profile_video_url` | Contient des URLs YouTube (déjà en place) |

---

## 1️⃣ DEEP LINKING POUR NOTIFICATIONS PUSH

### Contexte

L'Admin Panel envoie désormais des notifications push avec un champ `link` contenant un **deep link** au format `lynewed://[page]`. L'app doit intercepter ce lien et naviguer vers la page correspondante.

### Format des deep links (définis dans Admin Panel)

```
lynewed://home          → Page d'accueil
lynewed://wedding       → Wedding of the Week
lynewed://replays       → Liste des Replays
lynewed://feed          → Feed
lynewed://profile       → Profil utilisateur
lynewed://settings      → Paramètres
lynewed://chat          → Messages
lynewed://notifications → Centre de notifications
```

### Payload EXACT envoyé par FCM (vérifié dans Edge Function)

```json
{
  "message": {
    "token": "FCM_DEVICE_TOKEN",
    "data": {
      "type": "broadcast",
      "broadcast_id": "uuid-xxx",
      "link": "lynewed://wedding"
    },
    "notification": {
      "title": "Nouveau Wedding of the Week 💒",
      "body": "Découvrez le mariage de Sarah & John..."
    },
    "android": {
      "priority": "high",
      "notification": { "sound": "default" }
    },
    "apns": {
      "headers": { "apns-priority": "10" },
      "payload": {
        "aps": {
          "alert": { "title": "...", "body": "..." },
          "sound": "default"
        }
      }
    }
  }
}
```

### Implémentation Flutter requise

#### 1. Configurer le URL Scheme (iOS)

**Fichier : `ios/Runner/Info.plist`**

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>lynewed</string>
    </array>
    <key>CFBundleURLName</key>
    <string>com.lynewed.app</string>
  </dict>
</array>
```

#### 2. Configurer le URL Scheme (Android)

**Fichier : `android/app/src/main/AndroidManifest.xml`**

```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="lynewed" />
</intent-filter>
```

#### 3. Gérer le deep link dans l'app

**Fichier : `lib/services/deep_link_service.dart` (à créer ou adapter)**

```dart
import 'package:flutter/material.dart';

class DeepLinkService {
  static final Map<String, String> _routes = {
    'home': '/home',
    'wedding': '/wedding',
    'replays': '/replays',
    'feed': '/feed',
    'profile': '/profile',
    'settings': '/settings',
    'chat': '/chat',
    'notifications': '/notifications',
  };

  /// Parse un deep link et retourne la route Flutter correspondante
  static String? parseDeepLink(String? link) {
    if (link == null || link.isEmpty) return null;
    
    // Format: lynewed://page
    final uri = Uri.tryParse(link);
    if (uri == null || uri.scheme != 'lynewed') return null;
    
    final page = uri.host; // "wedding", "replays", etc.
    return _routes[page];
  }

  /// Navigue vers la page correspondante au deep link
  static void handleDeepLink(BuildContext context, String? link) {
    final route = parseDeepLink(link);
    if (route != null) {
      Navigator.of(context).pushNamed(route);
    }
  }
}
```

#### 4. Intercepter le deep link depuis la notification

**Dans le handler de notification (firebase_messaging) :**

```dart
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  final link = message.data['link'];
  if (link != null && link.isNotEmpty) {
    DeepLinkService.handleDeepLink(context, link);
  }
});

// Pour les notifications reçues quand l'app était fermée
FirebaseMessaging.instance.getInitialMessage().then((message) {
  if (message != null) {
    final link = message.data['link'];
    if (link != null && link.isNotEmpty) {
      DeepLinkService.handleDeepLink(context, link);
    }
  }
});
```

---

## 2️⃣ LECTEUR VIDÉO YOUTUBE/VIMEO - WEDDING OF THE WEEK

### Contexte

L'Admin Panel permet désormais d'ajouter des **vidéos YouTube ou Vimeo** dans les articles Wedding of the Week :
1. **Vidéo de couverture** : Remplace l'image de couverture
2. **Vidéos dans le contenu** : Blocs vidéo intégrés dans l'article

### Structure des données RÉELLE (vérifiée en base)

#### Table `wed_articles` - Structure

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | uuid | Identifiant unique |
| `title` | jsonb | `{ "en": "...", "fr": "..." }` |
| `linked_pro_profile_id` | uuid | FK vers `profiles` |
| `cover_images` | text[] | Array d'URLs (image OU vidéo YouTube/Vimeo) |
| `content_blocks` | jsonb | Array de blocs de contenu |
| `is_published` | boolean | Statut de publication |
| `target_region` | text | `"all"`, `"IN"`, `"ROW"` |

#### Vidéo de couverture

Le champ `cover_images[0]` peut maintenant contenir :
- **Image Supabase** : `https://hekyovgnovhfhmkpfrna.supabase.co/storage/v1/object/public/public_images/xxx.jpg`
- **YouTube** : `https://youtube.com/watch?v=VIDEO_ID` ou `https://youtu.be/VIDEO_ID`
- **Vimeo** : `https://vimeo.com/VIDEO_ID`

**Détection du type :**

```dart
bool isYouTubeUrl(String url) {
  return url.contains('youtube.com') || url.contains('youtu.be');
}

bool isVimeoUrl(String url) {
  return url.contains('vimeo.com');
}

bool isVideoUrl(String url) {
  return isYouTubeUrl(url) || isVimeoUrl(url);
}
```

#### Exemple RÉEL de content_blocks (extrait de la base)

```json
[
  {
    "type": "meta",
    "custom_display_name": "Marcos Sánchez Photography"
  },
  {
    "type": "video",
    "url": "https://youtu.be/BlFm30JvcUY",
    "platform": "youtube",
    "videoId": "BlFm30JvcUY"
  },
  {
    "type": "gallery",
    "urls": [
      "https://hekyovgnovhfhmkpfrna.supabase.co/storage/v1/object/public/public_images/4kf98guynmj.jpg",
      "https://hekyovgnovhfhmkpfrna.supabase.co/storage/v1/object/public/public_images/a80bnjcnom.jpg"
    ],
    "layout": "grid",
    "columns": 2
  },
  {
    "type": "paragraph",
    "content": {
      "en": "This week, LYNEWED is proud to highlight...",
      "fr": "Cette semaine, LYNEWED est fier de mettre en avant..."
    }
  },
  {
    "type": "single_image",
    "urls": ["https://hekyovgnovhfhmkpfrna.supabase.co/storage/v1/object/public/public_images/qgn2zbb7wln.jpg"]
  }
]
```

#### Types de blocs à gérer

| Type | Description | Champs |
|------|-------------|--------|
| `meta` | Métadonnées (nom personnalisé) | `custom_display_name` |
| `video` | Vidéo YouTube/Vimeo | `url`, `platform`, `videoId` |
| `paragraph` | Texte | `content.en`, `content.fr` |
| `single_image` | Image unique | `urls[0]` |
| `gallery` | Galerie d'images | `urls[]`, `layout`, `columns` |

### Implémentation Flutter requise

#### 1. Ajouter les dépendances

**Fichier : `pubspec.yaml`**

```yaml
dependencies:
  youtube_player_flutter: ^8.1.2
  # OU
  youtube_player_iframe: ^5.1.2
  
  # Pour Vimeo (optionnel, peut utiliser webview)
  webview_flutter: ^4.4.2
```

#### 2. Créer un widget de lecteur vidéo

**Fichier : `lib/widgets/video_player_widget.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool loop;
  final bool showControls;

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    this.autoPlay = false,
    this.loop = true,
    this.showControls = true,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late YoutubePlayerController _controller;
  String? _videoId;
  String? _platform;

  @override
  void initState() {
    super.initState();
    _parseVideoUrl();
    _initController();
  }

  void _parseVideoUrl() {
    final url = widget.videoUrl;
    
    // YouTube
    final youtubeRegex = RegExp(
      r'(?:youtube\.com\/(?:watch\?v=|embed\/|v\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})'
    );
    final youtubeMatch = youtubeRegex.firstMatch(url);
    if (youtubeMatch != null) {
      _videoId = youtubeMatch.group(1);
      _platform = 'youtube';
      return;
    }
    
    // Vimeo
    final vimeoRegex = RegExp(r'vimeo\.com\/(\d+)');
    final vimeoMatch = vimeoRegex.firstMatch(url);
    if (vimeoMatch != null) {
      _videoId = vimeoMatch.group(1);
      _platform = 'vimeo';
      return;
    }
  }

  void _initController() {
    if (_platform == 'youtube' && _videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: _videoId!,
        flags: YoutubePlayerFlags(
          autoPlay: widget.autoPlay,
          loop: widget.loop,
          mute: false,
          hideControls: !widget.showControls,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_platform == 'youtube' && _videoId != null) {
      return YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: widget.showControls,
        aspectRatio: 16 / 9,
      );
    }
    
    if (_platform == 'vimeo' && _videoId != null) {
      // Utiliser WebView pour Vimeo
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: WebViewWidget(
          controller: WebViewController()
            ..loadRequest(Uri.parse(
              'https://player.vimeo.com/video/$_videoId?autoplay=${widget.autoPlay ? 1 : 0}'
            )),
        ),
      );
    }
    
    // Fallback: afficher un placeholder
    return Container(
      color: Colors.black,
      child: const Center(
        child: Icon(Icons.error, color: Colors.white),
      ),
    );
  }
}
```

#### 3. Modifier le rendu de Wedding of the Week

**Dans le widget qui affiche la couverture :**

```dart
Widget _buildCover(String coverUrl) {
  // Vérifier si c'est une vidéo
  if (isVideoUrl(coverUrl)) {
    return AspectRatio(
      aspectRatio: 1, // Carré pour la couverture
      child: VideoPlayerWidget(
        videoUrl: coverUrl,
        autoPlay: true,
        loop: true,
        showControls: false,
      ),
    );
  }
  
  // Sinon, afficher l'image
  return AspectRatio(
    aspectRatio: 1,
    child: Image.network(
      coverUrl,
      fit: BoxFit.cover,
    ),
  );
}
```

**Dans le rendu des content_blocks :**

```dart
Widget _buildContentBlock(Map<String, dynamic> block) {
  switch (block['type']) {
    case 'video':
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: VideoPlayerWidget(
          videoUrl: block['url'],
          autoPlay: false,
          showControls: true,
        ),
      );
    case 'paragraph':
      // ... existing code
    case 'single_image':
      // ... existing code
    case 'gallery':
      // ... existing code
    default:
      return const SizedBox.shrink();
  }
}
```

---

## 3️⃣ LECTEUR VIDÉO YOUTUBE/VIMEO - FICHES PROFESSIONNELLES

### Contexte

Les professionnels peuvent ajouter des **liens vidéo YouTube/Vimeo** dans leur fiche depuis le CRM (`/account` → section App). Ces liens sont stockés dans la base de données et doivent être lus par l'app.

### ⚠️ CHANGEMENT IMPORTANT

**AVANT** : Les vidéos étaient uploadées dans Supabase Storage et l'app lisait des URLs de type :
```
https://xxx.supabase.co/storage/v1/object/public/videos/xxx.mp4
```

**APRÈS** : Les vidéos sont des liens YouTube/Vimeo :
```
https://youtube.com/watch?v=VIDEO_ID
https://vimeo.com/VIDEO_ID
```

### Structure des données RÉELLE (vérifiée en base)

**Table : `professional_details`**

| Colonne | Type | Description |
|---------|------|-------------|
| `profile_video_url` | text | URL YouTube ou Vimeo |

**Exemples réels en base :**
```
https://www.youtube.com/watch?v=dQw4w9WgXcQ
https://youtu.be/VIDEO_ID
https://vimeo.com/123456789
```

> ⚠️ **Note** : Le champ s'appelle `profile_video_url` (pas `video_url`). Vérifiez que votre code utilise le bon nom de colonne.

### Implémentation Flutter requise

#### Modifier le widget de fiche professionnelle

```dart
Widget _buildProVideo(String? videoUrl) {
  if (videoUrl == null || videoUrl.isEmpty) {
    return const SizedBox.shrink();
  }
  
  // Utiliser le même VideoPlayerWidget créé précédemment
  return VideoPlayerWidget(
    videoUrl: videoUrl,
    autoPlay: false,
    showControls: true,
  );
}
```

#### Supprimer le code de lecture vidéo Supabase Storage

Le code qui téléchargeait/streamait les vidéos depuis Supabase Storage peut être supprimé. Tout passe maintenant par le `VideoPlayerWidget` qui gère YouTube et Vimeo.

---

## 4️⃣ NOM AFFICHÉ PERSONNALISÉ - WEDDING OF THE WEEK

### Contexte

L'Admin Panel permet maintenant de personnaliser le nom affiché du professionnel dans un article Wedding of the Week. Ce nom est stocké dans un bloc `meta` au début des `content_blocks`.

### Structure des données

```json
{
  "content_blocks": [
    {
      "type": "meta",
      "custom_display_name": "Marcos Sánchez Photography"
    },
    {
      "type": "paragraph",
      "content": { "en": "...", "fr": "..." }
    },
    // ... autres blocs
  ]
}
```

### Implémentation Flutter requise

```dart
String _getDisplayName(Map<String, dynamic> article, String defaultName) {
  final blocks = article['content_blocks'] as List<dynamic>?;
  if (blocks == null || blocks.isEmpty) return defaultName;
  
  // Chercher le bloc meta
  final metaBlock = blocks.firstWhere(
    (b) => b['type'] == 'meta',
    orElse: () => null,
  );
  
  if (metaBlock != null && metaBlock['custom_display_name'] != null) {
    return metaBlock['custom_display_name'];
  }
  
  return defaultName;
}
```

**Utilisation :**

```dart
final displayName = _getDisplayName(
  weddingArticle,
  professional.businessName, // Nom par défaut
);

// Afficher displayName au lieu de professional.businessName
```

---

## 📋 CHECKLIST D'IMPLÉMENTATION

### Phase 1 : Deep Linking (Priorité haute)

- [ ] Configurer URL scheme iOS (`Info.plist`)
- [ ] Configurer URL scheme Android (`AndroidManifest.xml`)
- [ ] Créer `DeepLinkService`
- [ ] Intercepter les deep links depuis les notifications
- [ ] Tester chaque route (`lynewed://home`, `lynewed://wedding`, etc.)

### Phase 2 : Lecteur Vidéo (Priorité haute)

- [ ] Ajouter dépendance `youtube_player_flutter`
- [ ] Créer `VideoPlayerWidget`
- [ ] Modifier le rendu de la couverture Wedding of the Week
- [ ] Modifier le rendu des blocs vidéo dans content_blocks
- [ ] Modifier le rendu des vidéos dans les fiches professionnelles
- [ ] Supprimer le code de lecture vidéo Supabase Storage (obsolète)

### Phase 3 : Nom personnalisé (Priorité moyenne)

- [ ] Implémenter `_getDisplayName()`
- [ ] Mettre à jour l'affichage dans Wedding of the Week

---

## 🧪 TESTS À EFFECTUER

### Deep Linking

1. Envoyer une notification avec `link: "lynewed://wedding"` → Doit ouvrir la page Wedding
2. Envoyer une notification avec `link: "lynewed://replays"` → Doit ouvrir la page Replays
3. Envoyer une notification sans lien → Doit juste ouvrir l'app

### Lecteur Vidéo

1. Créer un Wedding of the Week avec vidéo YouTube en couverture → Doit s'afficher et jouer
2. Créer un Wedding of the Week avec vidéo Vimeo en couverture → Doit s'afficher et jouer
3. Ajouter un bloc vidéo dans le contenu → Doit s'afficher avec contrôles
4. Tester une fiche pro avec lien YouTube → Doit s'afficher correctement

### Nom personnalisé

1. Créer un Wedding avec nom personnalisé → Doit afficher le nom personnalisé
2. Créer un Wedding sans nom personnalisé → Doit afficher le nom du professionnel

---

## � ENREGISTREMENT DES DEVICE TOKENS

### Structure de la table `device_tokens`

Pour que les notifications push fonctionnent, l'app doit enregistrer le token FCM de l'utilisateur.

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | uuid | Identifiant unique |
| `profile_id` | uuid | FK vers `profiles` |
| `token` | text | Token FCM du device |
| `platform` | text | `"ios"` ou `"android"` |
| `last_seen_at` | timestamp | Dernière activité |

### Code d'enregistrement (à vérifier/adapter)

```dart
Future<void> registerDeviceToken(String userId, String fcmToken, String platform) async {
  await supabase.from('device_tokens').upsert({
    'profile_id': userId,
    'token': fcmToken,
    'platform': platform,
    'last_seen_at': DateTime.now().toIso8601String(),
  }, onConflict: 'profile_id, token');
}
```

---

## �📞 CONTACT

Pour toute question sur ces modifications :
- **Admin Panel / Backend** : Équipe Web
- **Base de données** : Supabase Project ID `hekyovgnovhfhmkpfrna`

---

## 📜 HISTORIQUE

| Date | Version | Changement |
|------|---------|------------|
| 03/12/2025 | 1.0 | Création du document |
| 03/12/2025 | 1.1 | Ajout des données réelles vérifiées en base, payload FCM exact, structure device_tokens |
