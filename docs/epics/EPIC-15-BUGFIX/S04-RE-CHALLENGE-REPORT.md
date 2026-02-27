# RE-CHALLENGE REPORT - S04 Modal CGUV Photos/Videos

> **Date** : 2026-02-16
> **Reviewer** : Senior Flutter Tech Lead
> **Story** : EPIC-15-BUGFIX/S04-cguv-modal-photos-videos
> **Challenge Round** : 2 (post-corrections)

---

## SYNTHÈSE EXÉCUTIVE

**Verdict** : ⚠️ **CORRECTIONS PARTIELLES - NOUVEAUX PROBLÈMES TROUVÉS**

Sur 3 problèmes critiques du premier challenge :
- ✅ **1 corrigé** : Cache lifecycle documenté (initState pattern)
- ⚠️ **1 partiellement corrigé** : Fichier pattern (problème identifié, mais ambiguïté persiste)
- ❌ **1 non corrigé** : Pattern interception incomplet (problème grave détecté)

**Nouveaux problèmes critiques trouvés** : 5

---

## VÉRIFICATION DES CORRECTIONS DEMANDÉES

### ✅ CORRIGÉ : Cache Init dans initState()

**Problème initial** : Initialisation cache non documentée

**Correction apportée** :
```dart
// Verifier l'acceptance au demarrage de la page :
Future<void> _checkInitialCgvuAcceptance() async {
  try {
    final useCase = const AcceptCgvuUseCase();
    final alreadyAccepted = await useCase.hasAccepted(
      cgvuType: guestMediaUploadCgvuType,
      cgvuVersion: guestMediaUploadCgvuVersion,
    );
    if (!mounted) return;
    setState(() => _cgvuAccepted = alreadyAccepted);
  } catch (e) {
    // Si erreur DB, on reste a false -> dialog s'affichera
    if (!mounted) return;
    setState(() => _cgvuAccepted = false);
  }
}
```

**Validation** : ✅ Correct
- Mounted check avant setState() ✅
- Fallback en cas d'erreur ✅
- Non-bloquant (false par défaut) ✅

---

### ⚠️ PARTIELLEMENT CORRIGÉ : Fichier Pattern Référencé

**Problème initial** : `magazine_cgvu_dialog.dart` référencé n'existe pas (fichier "2")

**Découverte après investigation** :
```bash
# Glob retourne 2 fichiers :
/Users/.../lib/features/my_wedding/presentation 2/dialogs/magazine_cgvu_dialog.dart
/Users/.../lib/features/my_wedding/presentation/dialogs/magazine_cgvu_dialog.dart
```

**Situation réelle** :
- ✅ Le fichier "propre" existe bien : `lib/features/my_wedding/presentation/dialogs/magazine_cgvu_dialog.dart`
- ⚠️ Un fichier dupliqué "2" existe aussi (dossier `presentation 2/`)
- ⚠️ La story référence `magazine_cgvu_dialog.dart` SANS préciser le bon chemin

**Risque** :
- Si l'implémenteur copie le pattern du mauvais dossier ("2"), le code sera obsolète ou incorrect
- Les dossiers "2" sont typiquement des duplications accidentelles à supprimer

**Correction requise** :
- Préciser le chemin COMPLET dans la story : `lib/features/my_wedding/presentation/dialogs/magazine_cgvu_dialog.dart`
- Ajouter une note : "IMPORTANT: Use the file in `presentation/` (NOT `presentation 2/`)"

---

### ❌ NON CORRIGÉ : Pattern Interception Incomplet

**Problème initial** : Pattern interception ne couvre pas tout le lifecycle

**Ce qui est documenté** :
```dart
Future<bool> _ensureCgvuAccepted() async {
  if (_cgvuAccepted) return true;

  // Show dialog
  if (!mounted) return false;
  final accepted = await showMediaUploadCgvuDialog(context: context);
  if (accepted) {
    setState(() => _cgvuAccepted = true);
  }
  return accepted;
}
```

**PROBLÈME GRAVE DÉTECTÉ** : ⚠️ **RACE CONDITION CRITIQUE**

Scénario de bug :
```
1. User tap "Upload Photo"
2. _ensureCgvuAccepted() called → _cgvuAccepted = false
3. Dialog shown
4. User ACCEPTS → _cgvuAccepted = true
5. Upload starts...
6. User tap "Upload Video" WHILE FIRST UPLOAD IS IN PROGRESS
7. _ensureCgvuAccepted() called → _cgvuAccepted = true
8. Upload video starts WITHOUT WAITING for first upload to finish
```

**Conséquence** : Les 3 méthodes upload (`_pickAndUploadPhoto`, `_pickAndUploadVideo`, `_pickAndUploadMultipleMedia`) peuvent s'exécuter **en parallèle**, causant :
- Race conditions sur `_isUploading`
- Race conditions sur `_uploadProgress`
- Crash potentiel si Supabase storage utilisé simultanément
- UI incohérent (progress bar saute entre 2 uploads)

**Code actuel de guest_album_page.dart** (lignes 60-63) :
```dart
bool _isLoading = true;
bool _isUploading = false;
double _uploadProgress = 0.0;
String? _error;
```

**Pattern actuel des uploads** : AUCUN GUARD contre uploads parallèles.

**Correction BLOQUANTE requise** :

```dart
Future<bool> _ensureCgvuAccepted() async {
  // GUARD: Prevent uploads while one is in progress
  if (_isUploading) {
    _showErrorSnackBar('Please wait for current upload to finish');
    return false;
  }

  if (_cgvuAccepted) return true;

  // Show dialog
  if (!mounted) return false;
  final accepted = await showMediaUploadCgvuDialog(context: context);
  if (accepted && mounted) {
    setState(() => _cgvuAccepted = true);
  }
  return accepted;
}
```

**Ajouter dans la story** :
1. Documenter ce guard AVANT le check CGVU
2. Ajouter test d'intégration : "Upload photo pendant upload video montre snackbar error"
3. Mettre à jour AC-6 pour préciser "uploads séquentiels uniquement"

---

## NOUVEAUX PROBLÈMES CRITIQUES TROUVÉS

### 🔴 NP-1 : Dialog Signature Incompatible

**Fichier** : Pattern proposé vs pattern réel

**Problème** :
La story propose ce helper :
```dart
Future<bool> showMediaUploadCgvuDialog({
  required BuildContext context,
}) async {
  // ...
}
```

Mais le pattern réel (`MagazineCgvuDialog`) utilise :
```dart
Future<bool> showMagazineCgvuDialog({
  required BuildContext context,
  required VoidCallback onAccepted,  // ← PARAMETER MANQUANT
  AcceptCgvuUseCase? acceptCgvuUseCase,
}) async {
  // ...
}
```

**Conséquence** :
- La story S04 ne documente PAS le paramètre `onAccepted`
- L'implémenteur va copier le pattern INCOMPLET
- Le callback `onAccepted()` dans `MagazineCgvuDialog` sert à refresh l'UI parent

**Cas d'usage magazine** :
```dart
final accepted = await showMagazineCgvuDialog(
  context: context,
  onAccepted: () {
    // Refresh magazine list to show new purchase option
    setState(() => _showOrderButton = true);
  },
);
```

**Cas d'usage guest upload** :
```dart
final accepted = await showMediaUploadCgvuDialog(
  context: context,
  onAccepted: () {
    // No-op for guest upload (no UI refresh needed)
  },
);
```

**Correction requise** :
- Ajouter `VoidCallback onAccepted` dans la signature du helper
- Documenter que pour guest_album, le callback peut être no-op
- Mettre à jour Pattern de Reference section

---

### 🔴 NP-2 : Constante Checkbox Label Incorrect

**Fichier** : `cgvu_texts.dart` (story section L180-183)

**Problème** :
La story propose :
```dart
const String guestMediaUploadCheckboxLabel =
    'I confirm I have all necessary rights and consents to upload and share this content.';
```

Mais le pattern réel (`MagazineCgvuDialog` L250) utilise un label DIFFÉRENT :
```dart
Text(
  'I have read and accept the terms',  // ← Label générique
  style: LynewedTextStyles.bodyMedium.copyWith(...)
)
```

**Incohérence** :
- Magazine CGVU : "I have read and accept the terms"
- Guest Upload : "I confirm I have all necessary rights and consents..."

**Pourquoi c'est un problème** :
- Les 2 dialogs devraient avoir une UI cohérente
- Le label "I have read and accept" est plus standard juridiquement
- Le label long proposé est verbeux et ne fit pas dans le design

**Correction requise** :
1. **Option A** : Utiliser le même label générique "I have read and accept the terms"
2. **Option B** : Créer un composant `CgvuCheckbox` réutilisable pour garantir la cohérence

**Recommandation** : Option A (plus simple, cohérent avec magazine)

---

### 🔴 NP-3 : Tests Widget Manquent le Pattern ScrollController

**Fichier** : Plan de Tests (L301-313)

**Problème** :
Les tests widget proposés couvrent :
- ✅ Checkbox desactivee au chargement
- ✅ Checkbox activee apres scroll au bottom
- ✅ Hint disparait apres scroll

Mais ne couvrent PAS :
- ❌ Test du `addPostFrameCallback()` (check initial si contenu court)
- ❌ Test du listener scroll détaché sur dispose
- ❌ Test du threshold "within 20 pixels" (ligne 70 du pattern)

**Cas de test manquants** :

```dart
// Test 1 : Court contenu → checkbox enabled immédiatement
testWidgets('checkbox enabled if content fits without scrolling', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => MediaUploadCgvuDialog(
            shortContent: true,  // Texte de 2 lignes seulement
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();

  final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
  expect(checkbox.onChanged, isNotNull);  // Enabled
});

// Test 2 : Dispose ne crash pas
testWidgets('disposes scroll controller without error', (tester) async {
  // ...
  await tester.pumpWidget(Container());  // Dispose dialog
  // No crash expected
});

// Test 3 : 20px threshold
testWidgets('checkbox enabled when within 20px of bottom', (tester) async {
  // Mock scroll position at maxScrollExtent - 19
  // Expect checkbox enabled
});
```

**Correction requise** :
- Ajouter ces 3 tests dans le Plan de Tests (section Tests Widget)
- Documenter le paramètre `shortContent` pour les tests (mock texte court)

---

### 🔴 NP-4 : Migration DB Non Vérifiée

**Fichier** : Design Technique (L250-262)

**Problème** :
La story dit :
```
Aucune migration necessaire - la table existe deja depuis EPIC-12.
```

Mais ne vérifie PAS :
- ✅ Existence de la table `cgvu_acceptances`
- ❌ Existence d'un INDEX sur `(user_id, cgvu_type, cgvu_version)`
- ❌ Policy RLS permettant INSERT pour un guest authentifié

**Vérification manquante** :

```sql
-- Query 1 : Table existe ?
SELECT table_name FROM information_schema.tables
WHERE table_name = 'cgvu_acceptances';

-- Query 2 : INDEX existe ?
SELECT indexname FROM pg_indexes
WHERE tablename = 'cgvu_acceptances'
  AND indexname = 'idx_cgvu_user_type_version';

-- Query 3 : Policy INSERT pour guests ?
SELECT policyname, cmd FROM pg_policies
WHERE tablename = 'cgvu_acceptances'
  AND cmd = 'INSERT';
```

**Scénario d'échec potentiel** :
1. Guest tap "Accept" dans le dialog
2. `AcceptCgvuUseCase()` exécute INSERT
3. **RLS policy bloque l'INSERT** (guest non autorisé)
4. Dialog affiche snackbar erreur
5. Upload continue quand même (non-bloquant)
6. **MAIS** : L'acceptance n'est PAS enregistrée
7. Problème juridique : Lynewed n'a aucune trace du consentement

**Correction BLOQUANTE requise** :
1. Ajouter section "Prerequisite Checks" dans la story :
   - Vérifier table + index via MCP Supabase
   - Vérifier RLS policies avec `SELECT * FROM pg_policies`
   - Tester INSERT manuel en tant que guest
2. Ajouter AC-0 (prerequisite) :
   ```gherkin
   Given a guest user authenticated in the app
   When executing: INSERT INTO cgvu_acceptances (user_id, cgvu_type, cgvu_version) VALUES (auth.uid(), 'test', '1.0')
   Then the insert succeeds
   And the row is visible in SELECT queries
   ```

---

### 🔴 NP-5 : Méthode Helper showMediaUploadCgvuDialog() Non Définie

**Fichier** : Pattern d'Interception (L232)

**Problème** :
La story utilise :
```dart
final accepted = await showMediaUploadCgvuDialog(context: context);
```

Mais ne définit PAS cette fonction helper.

**Code du pattern MagazineCgvuDialog** (L278-296) :
```dart
/// Shows the magazine CGVU dialog.
///
/// Returns true if user accepted, false if dismissed.
Future<bool> showMagazineCgvuDialog({
  required BuildContext context,
  required VoidCallback onAccepted,
  AcceptCgvuUseCase? acceptCgvuUseCase,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,  // ← IMPORTANT
    builder: (context) => MagazineCgvuDialog(
      onAccepted: onAccepted,
      acceptCgvuUseCase: acceptCgvuUseCase,
    ),
  );

  return result ?? false;
}
```

**Détail manquant critique** : `barrierDismissible: false`

Sans cette propriété :
- User peut tap à l'extérieur pour fermer le dialog
- Aucun consentement n'est enregistré
- Upload ne commence PAS (return false)
- **MAIS** : User pense qu'il a annulé, alors que Lynewed n'a rien enregistré

**Correction requise** :
- Ajouter la définition complète de `showMediaUploadCgvuDialog()` dans la story
- Documenter `barrierDismissible: false` avec commentaire explicatif
- Ajouter test : "tapping outside dialog does not dismiss it"

---

## PROBLÈMES DESIGN SYSTEM

### 🟡 DS-1 : Titre Dialog Incohérent

**Problème** :
- Story S04 : "Content Upload Agreement"
- Pattern réel : "Terms of Purchase"

**Incohérence** :
- Les titres devraient suivre le même pattern : "Terms of [Action]"
- "Agreement" vs "Terms" : vocabulaire incohérent

**Recommandation** :
- Utiliser "Terms of Media Upload" (cohérent avec "Terms of Purchase")
- OU "Content Upload Terms"

---

### 🟡 DS-2 : Hint Text Incomplet

**Problème** :
La story propose :
```dart
Text('Scroll to read all terms')
```

Pattern réel utilise un **Row avec icon** (L201-214) :
```dart
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Icon(Icons.arrow_downward, size: 16, color: LynewedColors.textSecondary),
    const SizedBox(width: 8),
    Text('Scroll to read all terms', style: ...),
  ],
)
```

**Correction requise** :
- Documenter l'icône `Icons.arrow_downward` dans la story
- Ajouter test widget : "hint shows downward arrow icon"

---

## PROBLÈMES TESTS

### 🟡 T-1 : Tests Integration Incomplets

**Fichier** : Plan de Tests (L317-323)

**Tests proposés** :
```
Upload photo montre CGUV dialog si pas encore accepte
Upload photo ne montre PAS CGUV dialog si deja accepte
Upload video montre CGUV dialog si pas encore accepte
Upload multiple montre CGUV dialog si pas encore accepte
Annuler CGUV dialog annule l'upload
```

**Tests manquants** :
- ❌ Test de persistance DB après accept (vérifie INSERT réel)
- ❌ Test de refresh après dialog (cache `_cgvuAccepted` mis à jour)
- ❌ Test d'erreur DB non-bloquante (upload continue malgré échec DB)
- ❌ Test de mounted check (dialog fermé pendant async call)
- ❌ Test de guard `_isUploading` (upload pendant upload)

**Correction requise** :
Ajouter section "Tests Integration Avancés" :
```dart
// Test 1 : Persistance DB
testWidgets('acceptance is persisted to database', (tester) async {
  // Mock AcceptCgvuUseCase
  // Verify INSERT called with correct params
});

// Test 2 : Erreur DB non-bloquante
testWidgets('upload continues if DB logging fails', (tester) async {
  // Mock AcceptCgvuUseCase to return failure
  // Verify upload proceeds anyway
  // Verify snackbar shown
});

// Test 3 : Guard _isUploading
testWidgets('second upload blocked while first in progress', (tester) async {
  // Start photo upload
  // Tap video upload immediately
  // Verify dialog NOT shown
  // Verify snackbar "Please wait"
});
```

---

## ANALYSE CRITIQUE DU PATTERN

### ⚠️ Pattern "Non-Bloquant en Cas d'Erreur DB" Est-il Acceptable ?

**Code du pattern** (MagazineCgvuDialog L91-105) :
```dart
if (result.isSuccess) {
  widget.onAccepted();
  Navigator.of(context).pop(true);
} else {
  // Show error but still allow proceeding
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(result.error ?? 'Failed to record acceptance')),
  );
  // Still call onAccepted even if logging failed
  widget.onAccepted();
  Navigator.of(context).pop(true);
}
```

**Question juridique** :
Si l'enregistrement DB échoue, Lynewed n'a AUCUNE trace du consentement.
Est-ce acceptable de laisser l'upload continuer ?

**Analyse** :
- ✅ **Pour Magazine** : Oui, car le paiement Stripe fait foi (receipt externe)
- ❌ **Pour Guest Upload** : NON, car aucune autre trace du consentement n'existe

**Risque juridique** :
1. Guest upload du contenu sans consentement enregistré
2. Plainte d'une personne apparaissant dans la photo
3. Lynewed ne peut PAS prouver que le guest a accepté les termes
4. **Responsabilité juridique de Lynewed engagée**

**Correction RECOMMANDÉE** :
Pour `MediaUploadCgvuDialog`, utiliser un pattern **bloquant** :
```dart
if (result.isSuccess) {
  widget.onAccepted();
  Navigator.of(context).pop(true);
} else {
  // Logging failed - BLOCK upload for legal compliance
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Failed to record acceptance. Please try again.'),
      backgroundColor: LynewedColors.error,
    ),
  );
  Navigator.of(context).pop(false);  // ← BLOQUER
}
```

**Ajouter dans Notes d'Implementation** :
```
7. Erreur DB BLOQUANTE : Contrairement au pattern Magazine, l'échec
   d'enregistrement DB DOIT bloquer l'upload pour conformité juridique.
   Lynewed DOIT avoir une trace du consentement avant d'accepter du contenu.
```

---

## MÉTRIQUES GLOBALES

### Problèmes par Sévérité

| Sévérité | Nombre | IDs |
|----------|--------|-----|
| 🔴 BLOQUANT | 5 | NP-1, NP-2, NP-3, NP-4, NP-5 |
| 🟡 MAJEUR | 2 | DS-1, DS-2 |
| 🟢 MINEUR | 1 | T-1 |

### Correction Initial Challenge

| Problème Initial | Status | Note |
|------------------|--------|------|
| Cache init manquant | ✅ CORRIGÉ | Pattern mounted check correct |
| Fichier pattern inexistant | ⚠️ PARTIEL | Fichier existe, mais ambiguïté dossier "2" |
| Pattern interception incomplet | ❌ NON CORRIGÉ | Race condition upload + guard manquant |

### Estimation Impact

| Impact | Avant Corrections | Après Corrections |
|--------|-------------------|-------------------|
| Estimation story | 5 SP | 6-7 SP |
| Durée dev | ~3h | ~4-5h |
| Risque juridique | ⚠️ MOYEN | 🔴 ÉLEVÉ (si pattern non-bloquant utilisé) |

---

## ACTIONS REQUISES AVANT VALIDATION

### Corrections Bloquantes (AVANT développement)

1. ✅ **NP-1** : Ajouter paramètre `onAccepted` dans signature helper
2. ✅ **NP-3** : Ajouter 3 tests widget manquants (scroll lifecycle)
3. ✅ **NP-4** : Vérifier RLS policies + ajouter AC-0 prerequisite
4. ✅ **NP-5** : Définir fonction `showMediaUploadCgvuDialog()` complète
5. ✅ **Pattern non-bloquant** : Documenter pattern BLOQUANT pour erreur DB

### Corrections Majeures (RECOMMANDÉ)

6. ✅ **NP-2** : Utiliser label checkbox standard "I have read and accept the terms"
7. ✅ **DS-1** : Harmoniser titre dialog "Terms of Media Upload"
8. ✅ **DS-2** : Documenter icône arrow_downward dans hint
9. ✅ **T-1** : Ajouter 3 tests integration avancés

### Corrections Mineures

10. ✅ Préciser chemin complet pattern file (éviter confusion avec dossier "2")
11. ✅ Ajouter guard `_isUploading` dans `_ensureCgvuAccepted()`
12. ✅ Documenter mounted check après retour dialog

---

## RECOMMANDATIONS STRATÉGIQUES

### 1. Créer Composant Réutilisable `CgvuDialog`

**Raison** : Duplication code entre Magazine et Guest Upload

**Proposition** :
```dart
lib/core/design/widgets/cgvu_dialog.dart  // Base class

class CgvuDialog extends StatefulWidget {
  final String title;
  final String termsText;
  final String checkboxLabel;
  final String cgvuType;
  final String cgvuVersion;
  final VoidCallback onAccepted;
  final bool blockOnDbError;  // true for guest, false for magazine
}
```

**Bénéfice** :
- Garantit cohérence UI
- Réduit duplication code
- Facilite évolution future (ex: ajout analytics)

**Estimation** : +2 SP (mais amortie sur futures stories)

---

### 2. Audit Complet des CGVU

**Problème détecté** : Incohérences entre les 4 types de CGVU
- `magazine_purchase` : Pattern complet, tests OK
- `marketplace_seller` : Existe (cgvu_texts.dart L62-141)
- `marketplace_buyer` : Existe (cgvu_texts.dart L147-222)
- `guest_media_upload` : À créer (cette story)

**Recommandation** :
- Créer story S00-CGVU-AUDIT pour vérifier :
  - ✅ Tous les types ont une constante version
  - ✅ Tous les types ont un dialog
  - ✅ Tous les types ont des tests
  - ✅ Cohérence UI entre tous les dialogs

---

### 3. Réviser Estimation

**Estimation actuelle** : 5 SP (3h)

**Estimation réaliste après re-challenge** : 6-7 SP (4-5h)

**Décomposition** :
- 1h : Créer dialog + constantes
- 1h : Intercepter 3 méthodes upload + guard
- 1h : Tests widget (9 tests au lieu de 6)
- 1h : Tests integration (8 tests au lieu de 5)
- 0.5h : Vérifier RLS + prerequisite
- 0.5h : Review adversariale

**Total** : 5h (arrondi à 7 SP en sécurité)

---

## VERDICT FINAL

**Status** : ⚠️ **NE PAS DÉMARRER - CORRECTIONS REQUISES**

**Peut Démarrer ?** : NON

**Bloqueurs** :
1. Race condition upload (guard manquant)
2. RLS policies non vérifiées (risque échec DB)
3. Pattern non-bloquant DB (risque juridique)
4. Helper `showMediaUploadCgvuDialog()` non défini
5. Tests incomplets (manque 6 tests critiques)

**Stories à bloquer en amont** :
- Aucune (story indépendante)

**Prerequisites à ajouter** :
- AC-0 : Vérifier RLS policy INSERT sur `cgvu_acceptances`

---

## CONCLUSION

La story S04 a été **partiellement corrigée** suite au premier challenge, mais :

### Points Positifs ✅
- Cache lifecycle bien documenté (initState + mounted checks)
- Pattern scroll controller bien expliqué
- Texte CGVU fourni par Thierry (pas à inventer)

### Points Critiques Restants ❌
- **Race condition upload** : Problème GRAVE ignoré
- **RLS policies** : Prerequisite non vérifié
- **Pattern DB non-bloquant** : Risque juridique élevé
- **Helper function** : Définition manquante
- **Tests incomplets** : 6 tests critiques absents

### Recommandation Finale

**ACTION IMMÉDIATE** :
1. Corriger les 5 problèmes bloquants (NP-1 à NP-5)
2. Re-challenger la story après corrections
3. NE PAS lancer en dev avant validation finale

**DURÉE ESTIMÉE CORRECTIONS** : 2h (review + réécriture sections)

**RISQUE SI LANCÉ TEL QUEL** : 🔴 ÉLEVÉ
- Bug race condition → crash app
- Échec DB → aucune trace consentement → risque juridique
- Tests incomplets → bugs non détectés

---

**Rapport généré par** : Review Adversariale APEX Round 2
**Méthodologie** : Vérification exhaustive post-corrections, analyse code pattern réel, tests juridiques
