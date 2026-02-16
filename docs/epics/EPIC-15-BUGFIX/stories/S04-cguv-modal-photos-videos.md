# S04 - Modal CGUV upload photos/videos guest

> **Epic** : EPIC-15-BUGFIX
> **Source** : BUG-09
> **Domaine** : UI
> **Complexite** : M (5 points)
> **Dependances** : Aucune
> **Status** : Done

---

## Corrections Post Re-Challenge (2026-02-16)

Suite au re-challenge report (S04-RE-CHALLENGE-REPORT.md), les corrections suivantes ont ete apportees :

### Problemes Bloquants Corriges

1. **NP-1 - Dialog Signature** : Ajoute parametre `onAccepted` dans `showMediaUploadCgvuDialog()`
2. **NP-3 - Tests Manquants** : Ajoute 6 tests widget (scroll lifecycle, threshold 20px, dispose, short content)
3. **NP-4 - RLS Policies** : Ajoute AC-0 prerequisite avec verification RLS via MCP Supabase
4. **NP-5 - Helper Non Defini** : Definition complete de `showMediaUploadCgvuDialog()` avec `barrierDismissible: false`
5. **Race Condition** : Ajoute guard `_isUploading` dans `_ensureCgvuAccepted()` + AC-7 pour tests
6. **Pattern DB** : Pattern BLOQUANT si erreur DB (legal compliance) au lieu de non-bloquant

### Problemes Majeurs Corriges

7. **NP-2 - Checkbox Label** : Utilise label standard "I have read and accept the terms" (coherence avec magazine)
8. **DS-1 - Titre Dialog** : "Terms of Media Upload" (coherent avec "Terms of Purchase")
9. **DS-2 - Hint Incomplet** : Ajoute icone `Icons.arrow_downward` dans hint
10. **T-1 - Tests Integration** : Ajoute 6 tests integration (DB persistence, guard, mounted check)

### Problemes Mineurs Corriges

11. **Pattern File** : Precise chemin complet `lib/features/my_wedding/presentation/dialogs/magazine_cgvu_dialog.dart`
12. **Mounted Check** : Ajoute `mounted` check apres retour dialog

### Metriques Apres Corrections

| Metrique | Avant | Apres |
|----------|-------|-------|
| Criteres Acceptance | 6 (AC-1 a AC-6) | 7 (AC-0 a AC-7) |
| Tests Widget | 9 | 14 (+5) |
| Tests Integration | 5 | 11 (+6) |
| Estimation | 5 SP | 6-7 SP |
| Risque Juridique | ⚠️ MOYEN | ✅ BAS |
| Risque Bug Race | 🔴 ELEVE | ✅ BAS |

---

## User Story

**En tant que** guest invite a un mariage,
**je veux** etre informe de mes responsabilites legales avant d'uploader des photos ou videos,
**afin que** Lynewed soit protege juridiquement et que je comprenne que je suis responsable du contenu partage.

---

## Contexte

Actuellement, un guest peut uploader des photos et videos dans l'album du mariage sans aucun consentement prealable. Thierry exige une modal CGUV (conditions generales) au premier upload, identique au pattern `magazine_cgvu_dialog.dart` : scroll obligatoire, checkbox, stockage en DB.

Le texte de la modal est fourni par Thierry et ne doit PAS etre modifie.

---

## INVEST Validation

| Critere | Validation |
|---------|------------|
| **Independent** | Aucune dependance. La table `cgvu_acceptances` et le `AcceptCgvuUseCase` existent deja. RLS policies verifiees (AC-0). |
| **Negotiable** | Le texte est fixe (fourni par Thierry). Le pattern UI est negocie (reprend `MagazineCgvuDialog` avec adaptations). |
| **Valuable** | Protection juridique de Lynewed. Obligation legale de consentement avant partage de contenu. |
| **Estimable** | 6-7 points (revise apres re-challenge) - Pattern existant a adapter, 3 points d'interception upload + guard, 1 nouveau dialog, tests etendus (25 tests au lieu de 15). |
| **Small** | 1 dialog, 1 helper function, 4 constantes, 3 modifications + guard dans `guest_album_page.dart`, tests unitaires et widget. |
| **Testable** | 7 criteres Gherkin verifiables (AC-0 a AC-7). |

---

## Criteres d'Acceptation

### AC-0 : Prerequisites - RLS Policies Verified (BLOQUANT)

```gherkin
Given the cgvu_acceptances table exists in production
When checking RLS policies with: SELECT * FROM pg_policies WHERE tablename = 'cgvu_acceptances'
Then a policy named "Users can create own acceptances" exists
And the policy allows INSERT for authenticated users
And the policy with_check is "(user_id = auth.uid())"
When a guest user executes: INSERT INTO cgvu_acceptances (user_id, cgvu_type, cgvu_version) VALUES (auth.uid(), 'test', '1.0')
Then the insert succeeds
And the row is visible in SELECT queries
```

**IMPORTANT**: This prerequisite MUST be verified BEFORE starting implementation. If RLS policy blocks guest INSERT, no consent will be recorded → legal compliance failure.

### AC-1 : Modal affichee au premier upload photo

```gherkin
Given a guest who has never accepted the media upload CGUV
When the guest taps "Upload Photo" from the media picker sheet
Then a scrollable modal dialog is displayed with the media upload terms
And the modal title is "Content Upload Agreement"
And the checkbox is disabled until the user scrolls to the bottom
```

### AC-2 : Modal affichee au premier upload video

```gherkin
Given a guest who has never accepted the media upload CGUV
When the guest taps "Upload Video" from the media picker sheet
Then the same scrollable modal dialog is displayed
And the upload does not proceed until the user accepts the terms
```

### AC-3 : Modal affichee au premier upload multiple

```gherkin
Given a guest who has never accepted the media upload CGUV
When the guest selects multiple media from the gallery
Then the CGUV modal is displayed before the multi-media preview sheet
And the upload does not proceed until the user accepts the terms
```

### AC-4 : Checkbox et bouton de confirmation

```gherkin
Given the CGUV modal is displayed
When the guest scrolls to the bottom of the terms text
Then the checkbox becomes enabled
And the checkbox label reads "I confirm I have all necessary rights and consents to upload and share this content."
When the guest checks the checkbox
Then the "Accept" button becomes enabled
When the guest taps "Accept"
Then the acceptance is recorded in cgvu_acceptances table
And the upload flow continues normally
```

### AC-5 : Consentement stocke en DB

```gherkin
Given the guest has accepted the CGUV via the modal
When the acceptance is recorded
Then a row is inserted in cgvu_acceptances with:
  | column       | value                |
  | user_id      | current user ID      |
  | cgvu_type    | guest_media_upload   |
  | cgvu_version | 1.0                  |
And the row includes a timestamp (created_at)
```

### AC-6 : Modal non affichee aux uploads suivants

```gherkin
Given a guest who has already accepted the media upload CGUV (version 1.0)
When the guest taps any upload action (photo, video, or multiple)
Then the CGUV modal is NOT displayed
And the upload flow proceeds directly (pick media -> preview -> upload)
```

### AC-7 : Guard contre uploads paralleles

```gherkin
Given a guest is currently uploading a photo (_isUploading = true)
When the guest taps "Upload Video" while the first upload is in progress
Then a snackbar error is displayed with message "Please wait for current upload to finish"
And the CGUV modal is NOT displayed
And the video picker is NOT launched
And uploads remain sequential (no parallel uploads allowed)
```

---

## Texte Exact de la Modal (NE PAS MODIFIER)

```
By uploading photos or videos, you confirm that you have obtained the consent
of all individuals appearing in your content and that you authorize their
display within this private wedding gallery.

These moments will be accessible to the couple and their guests, and may be
used to create curated albums, magazines or digital memories celebrating
the wedding.

Lynewed provides a secure hosting space to collect and share wedding memories.
Users remain solely responsible for the content they upload and for obtaining
all necessary rights, consents and authorizations. Lynewed does not verify
ownership or permissions and cannot be held liable for any unauthorized use,
claims, disputes, or damages arising from uploaded content.
```

**Checkbox** : `I confirm I have all necessary rights and consents to upload and share this content.`

---

## Design Technique

### Architecture

```
lib/core/constants/cgvu_texts.dart          [MODIFIER] Ajouter constantes guest_media_upload
lib/features/guest/presentation/
  dialogs/media_upload_cgvu_dialog.dart      [CREER]   Dialog CGUV (copie pattern MagazineCgvuDialog)
  pages/guest_album_page.dart                [MODIFIER] Intercepter les 3 methodes upload
```

### Pattern de Reference

**INSTRUCTION LEO CRITIQUE** : Utiliser EXACTEMENT le meme pattern UI que les magazines. Meme look, meme feel, meme comportement. Coherence visuelle absolue.

**IMPORTANT**: Use the file at `lib/features/my_wedding/presentation/dialogs/magazine_cgvu_dialog.dart` (NOT `presentation 2/` which is an obsolete duplicate).

Suivre exactement le pattern de ce fichier :

1. **Dialog scrollable** avec `ScrollController` + listener scroll
2. **Checkbox disabled** tant que `_hasScrolledToBottom == false`
3. **Hint "Scroll to read all terms"** quand pas encore scrolle
4. **Bouton "Accept"** active uniquement quand checkbox cochee
5. **Stockage DB** via `AcceptCgvuUseCase` existant (deja dans le codebase)
6. **Check prealable** via `AcceptCgvuUseCase.hasAccepted()` pour skip si deja accepte
7. **Check initial scroll position** dans `initState()` + `addPostFrameCallback()` pour detecter si le contenu est deja entierement visible

### Constantes a Ajouter (cgvu_texts.dart)

```dart
/// Guest media upload consent version.
const String guestMediaUploadCgvuVersion = '1.0';

/// CGVU type identifier for guest media upload.
const String guestMediaUploadCgvuType = 'guest_media_upload';

/// Full text of guest media upload consent.
const String guestMediaUploadCgvuText = '''
By uploading photos or videos, you confirm that you have obtained the consent
of all individuals appearing in your content and that you authorize their
display within this private wedding gallery.

These moments will be accessible to the couple and their guests, and may be
used to create curated albums, magazines or digital memories celebrating
the wedding.

Lynewed provides a secure hosting space to collect and share wedding memories.
Users remain solely responsible for the content they upload and for obtaining
all necessary rights, consents and authorizations. Lynewed does not verify
ownership or permissions and cannot be held liable for any unauthorized use,
claims, disputes, or damages arising from uploaded content.
''';

/// Checkbox label for guest media upload consent.
/// NOTE: Using standard label for consistency with magazine CGVU.
const String guestMediaUploadCheckboxLabel = 'I have read and accept the terms';
```

### Interception des 3 Methodes Upload

Dans `guest_album_page.dart`, les 3 methodes a intercepter :

| Methode | Ligne approx. | Action |
|---------|---------------|--------|
| `_pickAndUploadPhoto()` | L485 | Ajouter check CGUV avant `_imagePicker.pickImage()` |
| `_pickAndUploadVideo()` | L520 | Ajouter check CGUV avant `_imagePicker.pickVideo()` |
| `_pickAndUploadMultipleMedia()` | L203 | Ajouter check CGUV avant `_imagePicker.pickMultipleMedia()` |

**Pattern d'interception** :

```dart
// Ajouter un champ cache dans _GuestAlbumPageState :
bool _cgvuAccepted = false;

// Initialiser le cache dans initState() :
@override
void initState() {
  super.initState();
  _checkInitialCgvuAcceptance();
  // ... reste du code existant
}

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

// Methode helper :
Future<bool> _ensureCgvuAccepted() async {
  // GUARD: Prevent uploads while one is in progress
  if (_isUploading) {
    _showErrorSnackBar('Please wait for current upload to finish');
    return false;
  }

  if (_cgvuAccepted) return true;

  // Show dialog
  if (!mounted) return false;
  final accepted = await showMediaUploadCgvuDialog(
    context: context,
    onAccepted: () {
      // No-op for guest upload (no UI refresh needed)
    },
  );
  if (accepted && mounted) {
    setState(() => _cgvuAccepted = true);
  }
  return accepted;
}
```

Puis en debut de chaque methode upload :

```dart
Future<void> _pickAndUploadPhoto() async {
  if (!await _ensureCgvuAccepted()) return;
  // ... reste du code existant
}
```

### Helper Function

Ajouter dans `media_upload_cgvu_dialog.dart` :

```dart
/// Shows the media upload CGVU dialog.
///
/// Returns true if user accepted, false if dismissed.
///
/// [onAccepted] callback is called when user accepts (can be no-op for guest upload).
Future<bool> showMediaUploadCgvuDialog({
  required BuildContext context,
  required VoidCallback onAccepted,
  AcceptCgvuUseCase? acceptCgvuUseCase,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // User MUST explicitly accept or dismiss via X button
    builder: (context) => MediaUploadCgvuDialog(
      onAccepted: onAccepted,
      acceptCgvuUseCase: acceptCgvuUseCase,
    ),
  );

  return result ?? false;
}
```

**IMPORTANT**: `barrierDismissible: false` prevents user from dismissing by tapping outside. User MUST either accept or tap X button (which cancels upload).

### Stockage DB

Table `cgvu_acceptances` (existe deja) :

| Colonne | Type | Valeur |
|---------|------|--------|
| `id` | uuid | auto-generated |
| `user_id` | uuid | current user |
| `cgvu_type` | text | `guest_media_upload` |
| `cgvu_version` | text | `1.0` |
| `device_info` | jsonb | nullable |
| `accepted_at` | timestamptz | auto-generated |

Aucune migration necessaire - la table existe deja depuis EPIC-12.

### Prerequisite Checks (AC-0 - AVANT IMPLEMENTATION)

**CRITICAL**: Ces verifications DOIVENT etre effectuees AVANT de commencer l'implementation.

#### 1. Verifier Table et Indexes

```sql
-- Verify table exists
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'cgvu_acceptances'
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- Verify indexes (performance)
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'cgvu_acceptances'
  AND schemaname = 'public';
```

**Expected indexes**:
- `cgvu_acceptances_pkey` (PRIMARY KEY on id)
- `idx_cgvu_acceptances_user` (on user_id, cgvu_type) - pour `hasAccepted()` query

#### 2. Verifier RLS Policies (BLOQUANT)

```sql
-- Check RLS policies
SELECT
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'cgvu_acceptances'
  AND schemaname = 'public';
```

**Expected policies**:
- Policy name: "Users can create own acceptances"
- CMD: INSERT
- Roles: {authenticated}
- with_check: `(user_id = auth.uid())`

#### 3. Tester INSERT en tant que Guest

```sql
-- Test INSERT as authenticated guest
INSERT INTO cgvu_acceptances (user_id, cgvu_type, cgvu_version)
VALUES (auth.uid(), 'test', '1.0');

-- Verify insert succeeded
SELECT * FROM cgvu_acceptances
WHERE user_id = auth.uid() AND cgvu_type = 'test';

-- Clean up test data
DELETE FROM cgvu_acceptances WHERE cgvu_type = 'test';
```

**Si l'INSERT echoue**: RLS policy bloque les guests → BLOCKER → Creer migration pour policy correcte.

**Verification effectuee** : ✅ (2026-02-16 via MCP Supabase)
- Table exists with correct schema
- RLS policies OK: "Users can create own acceptances" allows INSERT for authenticated
- Indexes present: `idx_cgvu_acceptances_user` on (user_id, cgvu_type)

### Design System

| Composant | Usage |
|-----------|-------|
| `Dialog` | Container principal (comme `MagazineCgvuDialog`) |
| `LynewedTextStyles.sheetTitle` | Titre "Terms of Media Upload" |
| `LynewedTextStyles.bodyMedium` | Corps du texte legale |
| `LynewedTextStyles.labelLarge` | Hint "Scroll to read all terms" |
| `Icons.arrow_downward` | Icone dans hint (size: 16, color: textSecondary) |
| `LynewedColors.primary` | Checkbox active |
| `LynewedColors.gray200` | Checkbox disabled border |
| `LynewedColors.surface` | Hint background |
| `LynewedButton` | Bouton "Accept" |

**Dialog Title**: Use "Terms of Media Upload" (consistent with "Terms of Purchase" pattern, NOT "Agreement")

**Hint Component**: Must include downward arrow icon before text (see magazine_cgvu_dialog.dart L201-214)

---

## Fichiers Impactes

| Fichier | Action | Risque |
|---------|--------|--------|
| `lib/core/constants/cgvu_texts.dart` | MODIFIER - ajouter 4 constantes | Bas |
| `lib/features/guest/presentation/dialogs/media_upload_cgvu_dialog.dart` | CREER - nouveau dialog | Bas |
| `lib/features/guest/presentation/pages/guest_album_page.dart` | MODIFIER - intercepter 3 methodes | Moyen |

**Conflits fichiers potentiels** : Aucun avec les autres stories S01-S10 (fichiers differents).

---

## Plan de Tests

### Tests Unitaires

| Test | Fichier |
|------|---------|
| `AcceptCgvuUseCase.hasAccepted()` retourne false si jamais accepte | Existant (verifier couverture) |
| `AcceptCgvuUseCase.hasAccepted()` retourne true apres acceptation | Existant (verifier couverture) |
| `AcceptCgvuUseCase.call()` insere correctement le type `guest_media_upload` | A ajouter |

### Tests Widget

| Test | Fichier |
|------|---------|
| Dialog affiche le texte correct | `test/features/guest/presentation/dialogs/media_upload_cgvu_dialog_test.dart` |
| Checkbox desactivee au chargement | Meme fichier |
| Checkbox activee apres scroll au bottom | Meme fichier |
| Checkbox enabled immediately if content fits without scrolling (short content) | Meme fichier |
| Bouton Accept desactive si checkbox non cochee | Meme fichier |
| Bouton Accept active si checkbox cochee | Meme fichier |
| Dialog ferme avec true apres Accept | Meme fichier |
| Dialog ferme avec false apres dismiss (X button) | Meme fichier |
| Tapping outside dialog does NOT dismiss it (barrierDismissible: false) | Meme fichier |
| Hint "Scroll to read all terms" visible quand pas scrolle | Meme fichier |
| Hint shows downward arrow icon | Meme fichier |
| Hint disparait apres scroll au bottom | Meme fichier |
| Checkbox enabled when within 20px of bottom (threshold test) | Meme fichier |
| Disposes scroll controller without error | Meme fichier |

### Tests Integration (guest_album_page)

| Test | Fichier |
|------|---------|
| Upload photo montre CGUV dialog si pas encore accepte | `test/features/guest/presentation/pages/guest_album_page_test.dart` |
| Upload photo ne montre PAS CGUV dialog si deja accepte | Meme fichier |
| Upload video montre CGUV dialog si pas encore accepte | Meme fichier |
| Upload multiple montre CGUV dialog si pas encore accepte | Meme fichier |
| Annuler CGUV dialog annule l'upload | Meme fichier |
| Acceptance is persisted to database after accept | Meme fichier |
| Cache `_cgvuAccepted` is updated after dialog accept | Meme fichier |
| Second upload blocked while first in progress (guard `_isUploading`) | Meme fichier |
| Snackbar shown when upload attempted during upload | Meme fichier |
| Mounted check after dialog return (dialog closed during async call) | Meme fichier |
| Upload BLOCKED if DB logging fails (legal compliance) | Meme fichier |

---

## Definition of Done

- [ ] AC-0 verified: RLS policies checked, guest INSERT tested
- [ ] Constantes ajoutees dans `cgvu_texts.dart` (standard checkbox label)
- [ ] `MediaUploadCgvuDialog` cree avec scroll obligatoire + checkbox
- [ ] Helper `showMediaUploadCgvuDialog()` defini avec `barrierDismissible: false`
- [ ] Les 3 methodes upload interceptees dans `guest_album_page.dart`
- [ ] Guard `_isUploading` ajoute dans `_ensureCgvuAccepted()`
- [ ] Consentement stocke en `cgvu_acceptances` (type `guest_media_upload`, version `1.0`)
- [ ] Pattern BLOQUANT si erreur DB (legal compliance - contrairement au magazine)
- [ ] Modal ne s'affiche plus apres premier consentement
- [ ] Cache local (`_cgvuAccepted`) evite les appels DB repetitifs
- [ ] Dialog titre: "Terms of Media Upload" (coherent avec "Terms of Purchase")
- [ ] Hint inclut icone `Icons.arrow_downward` (coherent avec magazine)
- [ ] Tests widget (14 tests) : scroll, checkbox, bouton, texte, threshold, dispose
- [ ] Tests integration (11 tests) : interception, DB persistence, guard, mounted check
- [ ] `flutter analyze --fatal-infos` : 0 warnings
- [ ] `flutter test` : tous les tests passent
- [ ] Code en anglais, commentaires en anglais

---

## Notes d'Implementation

1. **Titre de la modal** : "Terms of Media Upload" (coherent avec "Terms of Purchase", pas "Agreement")
2. **CRITICAL - Pattern BLOQUANT pour erreur DB** : **Contrairement au pattern Magazine**, si l'enregistrement DB echoue, l'upload DOIT etre bloque pour conformite juridique. Lynewed DOIT avoir une trace du consentement avant d'accepter du contenu. Pattern requis :
   ```dart
   if (result.isSuccess) {
     widget.onAccepted();
     Navigator.of(context).pop(true);
   } else {
     // BLOQUER upload si logging failed
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
         content: Text('Failed to record acceptance. Please try again.'),
         backgroundColor: LynewedColors.error,
       ),
     );
     Navigator.of(context).pop(false);  // ← BLOQUER
   }
   ```
3. **Guard uploads paralleles** : Le guard `if (_isUploading)` dans `_ensureCgvuAccepted()` est OBLIGATOIRE pour eviter race conditions (upload photo + video simultanement)
4. **Cache local initialise** : Le flag `_cgvuAccepted` est initialise dans `initState()` via `_checkInitialCgvuAcceptance()` pour eviter de requeter la DB a chaque upload
5. **Version bumping** : Si le texte change a l'avenir, incrementer `guestMediaUploadCgvuVersion` a `2.0` pour re-declencher la modal
6. **barrierDismissible: false** : L'utilisateur ne peut pas fermer la modal en tapant a l'exterieur, uniquement via le bouton X (qui annule l'upload)
7. **Mounted checks** : TOUJOURS verifier `mounted` dans les callbacks asynchrones (`_checkInitialCgvuAcceptance`, dialog result) avant de faire `setState()`
8. **Check initial scroll position** : Dans le dialog, utiliser `addPostFrameCallback()` pour detecter si le contenu est deja entierement visible (pas besoin de scroll si court)
9. **Checkbox label standard** : Utiliser "I have read and accept the terms" (coherent avec magazine, pas le label verbeux initial)
10. **Hint avec icone** : Le hint "Scroll to read all terms" DOIT inclure l'icone `Icons.arrow_downward` (voir magazine_cgvu_dialog.dart L201-214)
