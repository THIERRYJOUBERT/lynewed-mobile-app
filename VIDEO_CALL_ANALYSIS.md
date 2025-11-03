# 🎥 Analyse de la Fonctionnalité d'Appel Vidéo Agora

## 📋 Résumé de l'Analyse

**Date** : 24 octobre 2025  
**Version** : 1.0.21+22  
**Fonctionnalité** : Appels vidéo via Agora RTC dans chat_details

---

## ✅ Bonne Nouvelle : Pas de Bug "ended" vs "completed"

Après analyse complète du code, **il n'y a PAS de problème d'enum entre "ended" et "completed"**.

### Enum Correctement Défini

**Fichier** : `/lib/backend/schema/enums/enums.dart`

```dart
enum VideoSessionStatus {
  pending,      // En attente (session créée)
  accepted,     // Acceptée par le destinataire
  declined,     // Refusée par le destinataire
  missed,       // Manquée (pas de réponse)
  completed,    // ✅ Terminée (utilisé correctement)
  cancelled,    // Annulée
}
```

### Utilisation Cohérente dans le Code

Tous les endroits utilisent correctement `VideoSessionStatus.completed` :

1. **Fin d'appel automatique** (ligne 83) : `VideoSessionStatus.completed`
2. **Bouton de fin d'appel** (ligne 222) : `VideoSessionStatus.completed`
3. **Action de mise à jour** : Utilise `newStatus.name` qui retourne `"completed"`

✅ **Conclusion** : L'enum est correct et cohérent dans tout le code.

---

## 🔍 Problèmes Potentiels Identifiés

### 1. ⚠️ Incohérence Possible avec la Base de Données Supabase

**Problème Potentiel** : Le schéma de la base de données Supabase pourrait utiliser `"ended"` au lieu de `"completed"`.

#### Vérification Nécessaire

Dans votre base de données Supabase, vérifiez la table `video_sessions` :

```sql
-- Vérifier les valeurs possibles pour le champ status
SELECT DISTINCT status FROM video_sessions;
```

**Si vous voyez `"ended"` dans les résultats**, c'est là le problème !

#### Solution si "ended" est dans la BDD

**Option A** : Modifier l'enum Flutter pour correspondre à la BDD

```dart
// Dans /lib/backend/schema/enums/enums.dart
enum VideoSessionStatus {
  pending,
  accepted,
  declined,
  missed,
  ended,      // ← Changer "completed" en "ended"
  cancelled,
}
```

**Option B** : Modifier la BDD pour utiliser "completed" (Recommandé)

```sql
-- Migration Supabase
UPDATE video_sessions 
SET status = 'completed' 
WHERE status = 'ended';

-- Mettre à jour les contraintes/triggers si nécessaire
```

---

### 2. 🐛 Gestion d'Erreur Incomplète dans chat_details

**Fichier** : `/lib/pages/shared/chat_details/chat_details_widget.dart`  
**Lignes** : 305-406

#### Problème

Le code ne vérifie pas si la session vidéo a été créée avec succès avant de tenter d'obtenir le token Agora.

```dart
// ❌ PROBLÈME : Pas de vérification du statut de création
_model.createdVideoSession = await actions.startVideoSessionAction(
  _model.psRoomHeader!.otherProfileId,
);

if (_model.createdVideoSession != null) {
  // Continue sans vérifier si la session est valide
  _model.agoraToken = await actions.getAgoraTokenAction(...);
}
```

#### Scénarios d'Échec Possibles

1. **Utilisateur non authentifié** → `startVideoSessionAction` retourne `null`
2. **Erreur Supabase** → Session créée mais avec des données incomplètes
3. **Problème réseau** → Timeout sans notification claire
4. **RLS (Row Level Security)** → Permission refusée silencieusement

#### Solution Recommandée

Ajouter des vérifications supplémentaires :

```dart
// ✅ MEILLEURE APPROCHE
_model.createdVideoSession = await actions.startVideoSessionAction(
  _model.psRoomHeader!.otherProfileId,
);

if (_model.createdVideoSession == null) {
  // Afficher un message d'erreur plus spécifique
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Impossible de démarrer l\'appel. Vérifiez votre connexion.',
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(milliseconds: 4000),
      backgroundColor: FlutterFlowTheme.of(context).error,
    ),
  );
  return; // Arrêter l'exécution
}

// Vérifier que les données essentielles sont présentes
if (_model.createdVideoSession!.id.isEmpty || 
    _model.createdVideoSession!.agoraChannelName.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Session vidéo invalide. Veuillez réessayer.',
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(milliseconds: 4000),
      backgroundColor: FlutterFlowTheme.of(context).error,
    ),
  );
  return;
}

// Maintenant on peut obtenir le token en toute sécurité
_model.agoraToken = await actions.getAgoraTokenAction(
  _model.createdVideoSession!.agoraChannelName,
  functions.generateAgoraUid(currentUserUid).toString(),
);
```

---

### 3. 🔄 Gestion des États de Session Incomplète

#### Problème

Le code ne gère pas tous les états possibles d'une session vidéo :

| État | Géré ? | Action Nécessaire |
|------|--------|-------------------|
| `pending` | ✅ Oui | Session créée, en attente |
| `accepted` | ✅ Oui | Appel accepté, démarrage |
| `declined` | ✅ Oui | Appel refusé |
| `missed` | ❌ Non | Pas de gestion spécifique |
| `completed` | ✅ Oui | Appel terminé |
| `cancelled` | ❌ Non | Pas de gestion spécifique |

#### Solution

Ajouter une gestion pour les états `missed` et `cancelled` :

```dart
// Dans la logique de notification ou de vérification de session
switch (videoSession.status) {
  case 'pending':
    // Afficher la notification d'appel entrant
    break;
  case 'accepted':
    // Rejoindre l'appel
    break;
  case 'declined':
    // Afficher "Appel refusé"
    break;
  case 'missed':
    // Afficher "Appel manqué"
    break;
  case 'completed':
    // Appel terminé normalement
    break;
  case 'cancelled':
    // Appel annulé par l'initiateur
    break;
  default:
    debugPrint('État de session inconnu: ${videoSession.status}');
}
```

---

### 4. ⏱️ Pas de Timeout pour les Appels en Attente

#### Problème

Une session en état `pending` peut rester indéfiniment sans être acceptée ou refusée.

#### Solution

Implémenter un timeout côté client et/ou serveur :

**Option A : Timeout Côté Client**

```dart
// Dans startVideoSessionAction ou après création
Future<void> _handleVideoSessionTimeout(String sessionId) async {
  await Future.delayed(Duration(seconds: 30)); // 30 secondes
  
  // Vérifier si la session est toujours en pending
  final session = await SupaFlow.client
      .from('video_sessions')
      .select()
      .eq('id', sessionId)
      .single();
  
  if (session['status'] == 'pending') {
    // Marquer comme missed
    await actions.updateVideoSessionStatusAction(
      sessionId,
      VideoSessionStatus.missed,
    );
    
    // Notifier l'utilisateur
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('L\'appel n\'a pas été répondu.'),
        backgroundColor: FlutterFlowTheme.of(context).warning,
      ),
    );
  }
}
```

**Option B : Trigger Supabase (Recommandé)**

```sql
-- Créer une fonction qui marque les sessions comme missed après 30 secondes
CREATE OR REPLACE FUNCTION mark_missed_video_sessions()
RETURNS void AS $$
BEGIN
  UPDATE video_sessions
  SET status = 'missed'
  WHERE status = 'pending'
    AND created_at < NOW() - INTERVAL '30 seconds';
END;
$$ LANGUAGE plpgsql;

-- Créer un cron job pour exécuter cette fonction
-- (via l'extension pg_cron ou Supabase Edge Functions)
```

---

### 5. 🔐 Vérification des Permissions Manquante

#### Problème

Le code ne vérifie pas si les permissions Camera et Microphone sont accordées avant de démarrer l'appel.

#### Solution

Ajouter une vérification avant `startVideoSessionAction` :

```dart
// Dans chat_details_widget.dart, avant de démarrer l'appel
onTap: () async {
  // Vérifier les permissions d'abord
  final cameraPermission = await actions.checkAndRequestPermission(
    PermissionType.CAMERA,
  );
  
  final micPermission = await actions.checkAndRequestPermission(
    PermissionType.MICROPHONE,
  );
  
  if (cameraPermission != 'granted' || micPermission != 'granted') {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Les permissions caméra et microphone sont nécessaires pour passer un appel vidéo.',
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(milliseconds: 4000),
        backgroundColor: FlutterFlowTheme.of(context).error,
      ),
    );
    return; // Ne pas démarrer l'appel
  }
  
  // Maintenant on peut démarrer l'appel en toute sécurité
  _model.createdVideoSession = await actions.startVideoSessionAction(
    _model.psRoomHeader!.otherProfileId,
  );
  // ... reste du code
},
```

---

### 6. 📱 Gestion de l'État de l'Application

#### Problème

Si l'application passe en arrière-plan pendant un appel, il n'y a pas de gestion claire de la reconnexion.

#### Solution

Implémenter un `AppLifecycleObserver` :

```dart
class _VideoCallPageWidgetState extends State<VideoCallPageWidget> 
    with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        // App en arrière-plan
        debugPrint('[VideoCall] App paused');
        // Optionnel : Mettre en pause la vidéo
        break;
      case AppLifecycleState.resumed:
        // App revient au premier plan
        debugPrint('[VideoCall] App resumed');
        // Optionnel : Reprendre la vidéo
        break;
      case AppLifecycleState.inactive:
        // App inactive (ex: appel téléphonique)
        debugPrint('[VideoCall] App inactive');
        break;
      case AppLifecycleState.detached:
        // App fermée
        debugPrint('[VideoCall] App detached');
        break;
      default:
        break;
    }
  }
}
```

---

## 🎯 Flux Complet de l'Appel Vidéo

### Séquence Actuelle

```
1. Utilisateur A clique sur l'icône vidéo dans chat_details
   ↓
2. startVideoSessionAction() crée une session en BDD
   - Status: 'pending'
   - Génère un channel Agora
   ↓
3. Notification envoyée à l'utilisateur B
   ↓
4. getAgoraTokenAction() obtient le token
   ↓
5. Navigation vers VideoCallPage avec:
   - videoSessionId
   - channelName
   - agoraToken
   - isInitiator: true
   ↓
6. AgoraVideoView se connecte au channel
   ↓
7. Utilisateur B reçoit la notification
   ↓
8. B accepte → updateVideoSessionStatusAction('accepted')
   ↓
9. B rejoint le channel Agora
   ↓
10. Appel en cours
   ↓
11. Fin d'appel → updateVideoSessionStatusAction('completed')
   ↓
12. Retour à la page précédente
```

### Points de Défaillance Potentiels

| Étape | Problème Potentiel | Impact |
|-------|-------------------|--------|
| 2 | Échec création session | ❌ Pas d'appel |
| 3 | Notification non reçue | ⚠️ B ne sait pas |
| 4 | Token invalide/expiré | ❌ Impossible de rejoindre |
| 6 | Connexion Agora échoue | ❌ Pas de vidéo |
| 8 | Mise à jour status échoue | ⚠️ État incohérent |
| 11 | Status non mis à jour | ⚠️ Session reste "active" |

---

## 📝 Recommandations de Correction

### Priorité 1 : Critique

1. **Vérifier la cohérence BDD** : `"ended"` vs `"completed"`
2. **Ajouter vérification des permissions** avant l'appel
3. **Implémenter un timeout** pour les sessions pending

### Priorité 2 : Important

4. **Améliorer la gestion d'erreur** dans chat_details
5. **Gérer les états `missed` et `cancelled`**
6. **Ajouter logs de debug** pour tracer les problèmes

### Priorité 3 : Amélioration

7. **Implémenter AppLifecycleObserver**
8. **Ajouter un indicateur de chargement** pendant la création de session
9. **Tester la reconnexion** en cas de perte réseau

---

## 🧪 Tests à Effectuer

### Test 1 : Appel Normal
1. A démarre un appel vers B
2. B reçoit la notification
3. B accepte l'appel
4. Vidéo fonctionne des deux côtés
5. A termine l'appel
6. ✅ Vérifier : Status = 'completed' dans la BDD

### Test 2 : Appel Refusé
1. A démarre un appel vers B
2. B reçoit la notification
3. B refuse l'appel
4. ✅ Vérifier : Status = 'declined' dans la BDD
5. ✅ Vérifier : A reçoit une notification de refus

### Test 3 : Appel Non Répondu
1. A démarre un appel vers B
2. B reçoit la notification
3. B ne répond pas pendant 30 secondes
4. ✅ Vérifier : Status = 'missed' dans la BDD
5. ✅ Vérifier : A reçoit une notification "non répondu"

### Test 4 : Permissions Manquantes
1. Révoquer les permissions Camera/Microphone
2. A tente de démarrer un appel
3. ✅ Vérifier : Message d'erreur affiché
4. ✅ Vérifier : Pas de session créée

### Test 5 : Perte de Connexion
1. A et B en appel
2. Couper le WiFi de A
3. ✅ Vérifier : Gestion gracieuse de la déconnexion
4. ✅ Vérifier : Status mis à jour correctement

### Test 6 : App en Arrière-Plan
1. A et B en appel
2. A met l'app en arrière-plan
3. A revient à l'app
4. ✅ Vérifier : Appel continue ou reconnexion automatique

---

## 🔧 Fichiers à Modifier

### Corrections Critiques

1. **`/lib/backend/schema/enums/enums.dart`**
   - Vérifier/corriger `VideoSessionStatus.completed` vs `ended`

2. **`/lib/pages/shared/chat_details/chat_details_widget.dart`**
   - Ajouter vérification des permissions
   - Améliorer la gestion d'erreur
   - Ajouter validation de session

3. **Base de données Supabase**
   - Vérifier les valeurs de `status` dans `video_sessions`
   - Créer un trigger pour timeout automatique

### Améliorations

4. **`/lib/pages/shared/video_call_page/video_call_page_widget.dart`**
   - Implémenter `AppLifecycleObserver`
   - Ajouter gestion de reconnexion

5. **`/lib/custom_code/actions/start_video_session_action.dart`**
   - Ajouter timeout côté client
   - Améliorer les logs de debug

---

## ✅ Checklist de Validation

Avant de considérer la fonctionnalité comme stable :

- [ ] Vérifier cohérence enum/BDD (`completed` vs `ended`)
- [ ] Tester appel normal (A → B → accepté → terminé)
- [ ] Tester appel refusé
- [ ] Tester appel non répondu (timeout)
- [ ] Tester sans permissions Camera/Microphone
- [ ] Tester avec perte de connexion réseau
- [ ] Tester app en arrière-plan pendant appel
- [ ] Vérifier logs de debug (pas d'erreurs)
- [ ] Tester sur iPhone et iPad
- [ ] Tester avec plusieurs utilisateurs simultanés

---

**Date d'analyse** : 24 octobre 2025  
**Version** : 1.0.21+22  
**Statut** : ⚠️ **Fonctionnel mais nécessite des améliorations**

**Prochaine étape** : Vérifier la base de données Supabase pour confirmer si le problème est `"ended"` vs `"completed"`
