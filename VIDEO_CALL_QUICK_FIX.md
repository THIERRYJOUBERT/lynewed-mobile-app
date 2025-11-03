# 🔧 Correction Rapide - Appels Vidéo

## 🎯 Problème Principal Suspecté

**Incohérence entre l'enum Flutter et la base de données Supabase**

---

## 1️⃣ Vérification Immédiate

### Dans Supabase Dashboard

1. Allez sur https://odzkhcplevcqbuhzqsmq.supabase.co
2. Ouvrez le **SQL Editor**
3. Exécutez cette requête :

```sql
-- Vérifier les valeurs de status utilisées
SELECT DISTINCT status, COUNT(*) 
FROM video_sessions 
GROUP BY status 
ORDER BY status;
```

### Résultats Possibles

**Scénario A** : Vous voyez `"completed"` ✅
```
status      | count
------------|------
pending     | 5
accepted    | 3
completed   | 10
declined    | 2
```
→ **Pas de problème**, l'enum est correct

**Scénario B** : Vous voyez `"ended"` ❌
```
status      | count
------------|------
pending     | 5
accepted    | 3
ended       | 10  ← PROBLÈME ICI
declined    | 2
```
→ **Problème confirmé**, il faut corriger

---

## 2️⃣ Solution si "ended" est Trouvé

### Option A : Modifier l'Enum Flutter (Rapide)

**Fichier** : `/lib/backend/schema/enums/enums.dart`

```dart
enum VideoSessionStatus {
  pending,
  accepted,
  declined,
  missed,
  ended,      // ← Changer "completed" en "ended"
  cancelled,
}
```

**Ensuite, modifier tous les usages** :

1. `/lib/pages/shared/video_call_page/video_call_page_widget.dart` (ligne 83)
```dart
VideoSessionStatus.ended,  // Au lieu de .completed
```

2. `/lib/pages/shared/video_call_page/video_call_page_widget.dart` (ligne 222)
```dart
VideoSessionStatus.ended,  // Au lieu de .completed
```

### Option B : Migrer la BDD (Recommandé)

**Dans Supabase SQL Editor** :

```sql
-- Étape 1: Mettre à jour les données existantes
UPDATE video_sessions 
SET status = 'completed' 
WHERE status = 'ended';

-- Étape 2: Vérifier le résultat
SELECT DISTINCT status FROM video_sessions;

-- Étape 3: Si vous avez des contraintes CHECK, les mettre à jour
ALTER TABLE video_sessions 
DROP CONSTRAINT IF EXISTS video_sessions_status_check;

ALTER TABLE video_sessions 
ADD CONSTRAINT video_sessions_status_check 
CHECK (status IN ('pending', 'accepted', 'declined', 'missed', 'completed', 'cancelled'));
```

---

## 3️⃣ Amélioration Immédiate : Vérification des Permissions

**Fichier** : `/lib/pages/shared/chat_details/chat_details_widget.dart`

**Trouver** (ligne ~305) :
```dart
onTap: () async {
  _model.createdVideoSession =
      await actions.startVideoSessionAction(
    _model.psRoomHeader!.otherProfileId,
  );
```

**Remplacer par** :
```dart
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
    return;
  }
  
  // Maintenant on peut démarrer l'appel
  _model.createdVideoSession =
      await actions.startVideoSessionAction(
    _model.psRoomHeader!.otherProfileId,
  );
```

---

## 4️⃣ Amélioration : Meilleure Gestion d'Erreur

**Dans le même fichier**, après la création de session :

**Trouver** (ligne ~312) :
```dart
if (_model.createdVideoSession != null) {
  _model.agoraToken = await actions.getAgoraTokenAction(
```

**Remplacer par** :
```dart
if (_model.createdVideoSession == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Impossible de démarrer l\'appel. Vérifiez votre connexion internet.',
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(milliseconds: 4000),
      backgroundColor: FlutterFlowTheme.of(context).error,
    ),
  );
  safeSetState(() {});
  return;
}

// Vérifier que les données sont valides
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
  safeSetState(() {});
  return;
}

// Maintenant on peut obtenir le token
_model.agoraToken = await actions.getAgoraTokenAction(
```

---

## 5️⃣ Test Rapide

Après avoir appliqué les corrections :

```bash
# Nettoyer et recompiler
flutter clean
flutter pub get
flutter run -d ios
```

### Tester

1. **Démarrer un appel** depuis chat_details
2. **Vérifier les logs** dans la console :
   ```
   [DEBUG] startVideoSessionAction: Video session created with ID: xxx
   [DEBUG] updateVideoSessionStatus: session=xxx, status=completed
   [DEBUG] updateVideoSessionStatus: Success.
   ```
3. **Vérifier dans Supabase** que le status est bien mis à jour

---

## 📊 Diagnostic des Logs

### Logs Normaux (✅)
```
[DEBUG] startVideoSessionAction: Video session created with ID: abc123
[DEBUG] updateVideoSessionStatus: session=abc123, status=completed
[DEBUG] updateVideoSessionStatus: Success.
```

### Logs avec Problème (❌)
```
[DEBUG] startVideoSessionAction: Video session created with ID: abc123
[DEBUG] updateVideoSessionStatus: session=abc123, status=completed
[DEBUG] updateVideoSessionStatus: Failed. Session ID not found or RLS issue.
```
→ **Problème** : Le status n'est pas reconnu par la BDD

```
[DEBUG] startVideoSessionAction CRITICAL ERROR: ...
```
→ **Problème** : Échec de création de session

---

## 🆘 Si Ça Ne Marche Toujours Pas

### Vérifications Supplémentaires

1. **Vérifier les Row Level Security (RLS)** dans Supabase :
   ```sql
   -- Voir les policies sur video_sessions
   SELECT * FROM pg_policies WHERE tablename = 'video_sessions';
   ```

2. **Vérifier les triggers** :
   ```sql
   -- Voir les triggers sur video_sessions
   SELECT * FROM pg_trigger WHERE tgrelid = 'video_sessions'::regclass;
   ```

3. **Tester manuellement** dans Supabase :
   ```sql
   -- Créer une session de test
   INSERT INTO video_sessions (initiator_id, receiver_id, status, agora_channel_name)
   VALUES ('user-id-1', 'user-id-2', 'pending', 'test-channel');
   
   -- Mettre à jour le status
   UPDATE video_sessions 
   SET status = 'completed' 
   WHERE agora_channel_name = 'test-channel';
   
   -- Vérifier
   SELECT * FROM video_sessions WHERE agora_channel_name = 'test-channel';
   ```

---

## ✅ Checklist de Correction

- [ ] Vérifier les valeurs de `status` dans Supabase
- [ ] Corriger l'enum si nécessaire (`ended` → `completed`)
- [ ] OU migrer la BDD (`ended` → `completed`)
- [ ] Ajouter vérification des permissions
- [ ] Améliorer la gestion d'erreur
- [ ] Tester un appel complet
- [ ] Vérifier les logs
- [ ] Vérifier dans Supabase que le status est mis à jour

---

**Temps estimé** : 15-30 minutes  
**Difficulté** : Facile à Moyenne  
**Impact** : ✅ Résout le problème principal
