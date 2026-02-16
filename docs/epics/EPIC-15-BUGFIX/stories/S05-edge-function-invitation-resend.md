# Story S05: Edge Function `send-wedding-invitation` (Resend)

> **Epic** : EPIC-15-BUGFIX
> **Domaine** : API (Edge Function Supabase)
> **Complexite** : L (Large) - 8 points
> **Statut** : Done
> **Source** : BUG-01a (emails jamais envoyes), BUG-01d (template en francais)
> **Dependances** : S02 (invite codes non-NULL), S03 (deep links fonctionnels)

---

## Description

En tant que mariee, je veux pouvoir envoyer des invitations par email a mes guests depuis l'app, afin qu'ils recoivent un email professionnel contenant le code du mariage, un QR code scannable, et un lien direct pour rejoindre le mariage dans Lynewed.

**Contexte** : La story EPIC-09/S06 a documente cette Edge Function en detail mais elle n'a JAMAIS ete implementee. Le use case Flutter `SendGuestInvitation` et le widget `SendInvitationButton` existent deja et appellent `supabase.functions.invoke('send-wedding-invitation')`, mais la fonction cible n'existe pas cote serveur. Il faut la creer, la deployer, et valider le flux de bout en bout.

**INSTRUCTION LEO CRITIQUE** : **ZERO FRANCAIS dans l'email**. Tout en anglais : sujet, corps, labels, footer, date. Date formatee avec `toLocaleDateString('en-US')` PAS 'fr-FR'. Aucun compromis sur ce point.

---

## Criteres d'Acceptance (Gherkin)

### AC-0: Prerequis (S02 et S03 validees)

```gherkin
Given S02 (invite codes trigger) est COMPLETE
When on execute SELECT COUNT(*) FROM weddings WHERE invite_code IS NULL
Then le resultat doit etre 0 (tous les weddings ont un invite_code)

Given S03 (deep links diagnostic) est COMPLETE
When on cree un wedding de test avec invite_code "TESTCODE"
  And on ouvre le lien https://lynewed.com/join/TESTCODE sur iOS Simulator
Then l'app Lynewed s'ouvre sur la page JoinWedding
  And le code "TESTCODE" est pre-rempli dans le champ
  And la page affiche "Join Smith Wedding" (bride name)
```

- [ ] Valide

### AC-1: Envoi d'email reussi

```gherkin
Given a guest "Jane" with email "jane@example.com" in wedding "Smith Wedding"
  And the wedding has invite_code "ABCD1234" (non-NULL)
  And the Edge Function "send-wedding-invitation" is deployed
When the function is called with guest_id and wedding_id
Then an email is sent to "jane@example.com" via Resend
  And the email subject is "You're invited to Smith Wedding!"
  And the email body is entirely in English
  And the email contains the invite code "ABCD1234"
  And the email contains a QR code image (base64 inline)
  And the email contains a deep link "https://lynewed.com/join/ABCD1234"
  And the deep link uses domain `lynewed.com` (NOT `lynewed.app`)
  And the email sender is "Lynewed <noreply@lynewed.com>"
  And wedding_guests.status is updated to 'invited'
  And wedding_guests.invited_at is set to current timestamp
  And the response is { success: true, email_id: "...", status: "invited" }
```

- [ ] Valide

### AC-2: Validation anti-null sur invite_code

```gherkin
Given a wedding where invite_code IS NULL, undefined, empty string, or whitespace-only
When the function is called for a guest of this wedding
Then the function returns HTTP 400
  And the error is "invalid_invite_code"
  And NO email is sent
  And the URL "/join/null", "/join/undefined", or "/join/" is NEVER generated
  And wedding_guests.status remains unchanged
```

- [ ] Valide

### AC-3: Template email en anglais

```gherkin
Given the email is generated for guest "Jane" in "Smith Wedding" with code "ABCD1234"
Then the email contains:
  | Element        | Content                                          |
  |----------------|--------------------------------------------------|
  | Header         | "You're invited to Smith Wedding!"                |
  | Greeting       | "Hello Jane,"                                     |
  | Instructions   | "Download the Lynewed app and join the wedding"   |
  | Code label     | "Wedding code:"                                   |
  | Code value     | "ABCD1234" (large, styled)                        |
  | QR code        | Inline image encoding "https://lynewed.com/join/ABCD1234" |
  | CTA button     | "Join the Wedding" linking to deep link            |
  | Expiry note    | "This code expires on {date}" (formatted in en-US locale) |
  | Footer         | "Sent with love by Lynewed"                        |
And NO French text appears anywhere in the email
```

- [ ] Valide

### AC-4: QR code scannable

```gherkin
Given the QR code is generated for invite code "ABCD1234"
When the QR code image is scanned
Then it resolves to "https://lynewed.com/join/ABCD1234"
  And the QR code dimensions are 200x200 pixels
  And the QR code is embedded as a base64 data URL in the <img> tag
```

- [ ] Valide

### AC-5: Validation email invalide

```gherkin
Given a guest with email "not-an-email"
When the Edge Function is called
Then it returns HTTP 400
  And the error is "invalid_email"
  And no email is sent
  And wedding_guests.status remains unchanged
```

- [ ] Valide

### AC-6: Guest non trouve

```gherkin
Given a non-existent guest_id "00000000-0000-0000-0000-000000000000"
When the Edge Function is called
Then it returns HTTP 404
  And the error is "guest_not_found"
```

- [ ] Valide

### AC-7: Re-invitation (guest deja invite)

```gherkin
Given a guest already has status 'invited' and invited_at = "2026-02-10T10:00:00Z"
When the Edge Function is called again
Then a new email is sent (re-invitation)
  And invited_at is updated to the current timestamp (more recent than "2026-02-10")
  And status remains 'invited'
```

- [ ] Valide

### AC-8: Rate limiting Resend

```gherkin
Given Resend rate limit has been exceeded
When the Edge Function is called
Then it returns HTTP 429
  And the error is "rate_limited"
  And the response includes a retry_after timestamp
  And no status update is performed on wedding_guests
```

- [ ] Valide

### AC-9: Service email non configure

```gherkin
Given RESEND_API_KEY is not set in Supabase secrets
When the Edge Function is called
Then it returns HTTP 500
  And the error is "email_service_not_configured"
```

- [ ] Valide

### AC-10: Authentification requise

```gherkin
Given a request without Authorization header
When the Edge Function is called
Then it returns HTTP 401
  And the error is "unauthorized"
```

- [ ] Valide

### AC-11: Flutter use case end-to-end

```gherkin
Given the Edge Function is deployed on Supabase
  And a bride is logged in on the app
  And she views her guest list
  And a guest has email "jane@example.com" and status "pending"
When she taps "Send Invitation"
Then SendInvitationButton shows a loading spinner
  And SendGuestInvitation use case calls the Edge Function
  And on success, a snackbar "Invitation sent!" appears
  And the guest status in the list updates to "invited"
  And jane@example.com receives the email in her inbox
```

- [ ] Valide

---

## Fichiers Concernes

### A Creer

| Fichier | Description |
|---------|-------------|
| `supabase/functions/send-wedding-invitation/index.ts` | Edge Function principale (Deno, Resend, QR code) |

### A Lire (reference, NE PAS modifier)

| Fichier | Pourquoi |
|---------|----------|
| `lib/features/my_wedding/domain/usecases/send_guest_invitation.dart` | Use case Flutter qui appelle la fonction - verifier compatibilite API |
| `lib/features/my_wedding/presentation/widgets/send_invitation_button.dart` | Widget UI - verifier le flow |
| `supabase/functions/send-verification-email/index.ts` | Pattern Resend existant dans le projet |
| `lib/core/navigation/deep_link_handler.dart` | Domaine deep link = `lynewed.com` |

### Hors Scope

- Aucun fichier Flutter a modifier (le use case et le widget existent deja)
- Aucune migration DB (les colonnes `status`, `invited_at` existent deja)

---

## Notes Techniques

### IMPORTANT : Mise a jour EPIC-09/S06 requise

**Probleme** : La spec originale EPIC-09/S06 utilise :
- Domaine `lynewed.app` (ligne 102 : `https://lynewed.app/join/${inviteCode}`)
- Template email en francais (lignes 213-259)
- Date formatee en `fr-FR` (ligne 194)

**Decision EPIC-15** : Le code actuel et la config iOS/Android utilisent `lynewed.com` partout. S05 acte cette decision et corrige les bugs.

**Action requise** : Apres implementation de S05, mettre a jour EPIC-09/S06 pour :
1. Remplacer `lynewed.app` par `lynewed.com` (template, deep links)
2. Traduire le template email en anglais (cf. S05 section "Template Email (EN)")
3. Changer `fr-FR` en `en-US` pour le formatage date

**Objectif** : Eviter qu'un futur developpeur copie EPIC-09/S06 tel quel et reintroduise les bugs BUG-01a et BUG-01d.

**Responsable** : Story owner de S05 (inclus dans DoD).

### Stack

| Element | Valeur |
|---------|--------|
| Runtime | Deno (Supabase Edge Functions) |
| Email service | Resend (`https://esm.sh/resend@4.0.0` - aligne sur `send-verification-email`) |
| QR generation | `https://esm.sh/qrcode@1.5.3` |
| From address | `Lynewed <noreply@lynewed.com>` |
| Deep link domain | `lynewed.com` (PAS `lynewed.app` - cf. EPIC-15 decision) |

### Domaine : `lynewed.com` (decision actee)

L'Epic EPIC-15 acte la decision de rester sur `lynewed.com` :
- QR code Flutter (`my_wedding_page.dart:679`) genere `https://lynewed.com/join/{code}`
- iOS entitlements : `applinks:lynewed.com`
- Android manifest : `host="lynewed.com"`
- Deep link handler Flutter supporte `lynewed.com`

La spec EPIC-09/S06 mentionnait `lynewed.app` mais c'est **overrule** par le code existant.

### Validation anti-null CRITIQUE

Le bug BUG-01a vient du fait que `invite_code` peut etre NULL en base. La fonction DOIT :

```typescript
// AVANT toute generation d'URL - validation exhaustive
const trimmedCode = inviteCode?.trim();
if (!trimmedCode || trimmedCode.length === 0) {
  return new Response(
    JSON.stringify({ error: 'invalid_invite_code' }),
    { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}
```

Il ne faut JAMAIS generer l'URL `https://lynewed.com/join/null` ou `https://lynewed.com/join/undefined`.

### Template Email (EN)

Le template EPIC-09/S06 est en francais. Il faut le traduire integralement. Voici le template cible :

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background-color: #f5f5f5; margin: 0; padding: 20px;">
  <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">

    <!-- Header -->
    <div style="background: linear-gradient(135deg, #D4A574 0%, #C4956C 100%); padding: 40px 30px; text-align: center;">
      <h1 style="color: #ffffff; margin: 0; font-size: 28px; font-weight: 600;">
        You're invited to ${brideName}'s Wedding!
      </h1>
    </div>

    <!-- Content -->
    <div style="padding: 40px 30px;">
      <p style="color: #333333; font-size: 16px; line-height: 1.6; margin: 0 0 20px;">
        Hello ${guestName},
      </p>

      <p style="color: #333333; font-size: 16px; line-height: 1.6; margin: 0 0 30px;">
        Download the Lynewed app and join the wedding to share your photos
        and chat with other guests.
      </p>

      <!-- Code -->
      <div style="background-color: #f8f8f8; border-radius: 12px; padding: 24px; text-align: center; margin-bottom: 30px;">
        <p style="color: #666666; font-size: 14px; margin: 0 0 12px;">Wedding code:</p>
        <p style="color: #D4A574; font-size: 32px; font-weight: bold; letter-spacing: 6px; margin: 0;">
          ${inviteCode}
        </p>
      </div>

      <!-- QR Code -->
      <div style="text-align: center; margin-bottom: 30px;">
        <img src="${qrCodeDataUrl}" alt="QR Code" style="width: 200px; height: 200px; border-radius: 8px;" />
        <p style="color: #666666; font-size: 12px; margin: 12px 0 0;">
          Scan this QR code with your phone
        </p>
      </div>

      <!-- CTA Button - DOMAIN = lynewed.com -->
      <div style="text-align: center; margin-bottom: 30px;">
        <a href="https://lynewed.com/join/${inviteCode}" style="display: inline-block; background: linear-gradient(135deg, #D4A574 0%, #C4956C 100%); color: #ffffff; text-decoration: none; padding: 16px 40px; border-radius: 30px; font-size: 16px; font-weight: 600; box-shadow: 0 4px 12px rgba(212, 165, 116, 0.4);">
          Join the Wedding
        </a>
      </div>

      <!-- Footer note -->
      <p style="color: #999999; font-size: 12px; text-align: center; margin: 0;">
        This code expires on ${formattedDate}.
      </p>
    </div>

    <!-- Footer -->
    <div style="background-color: #f8f8f8; padding: 20px 30px; text-align: center; border-top: 1px solid #eeeeee;">
      <p style="color: #999999; font-size: 12px; margin: 0;">
        Sent with love by Lynewed
      </p>
    </div>

  </div>
</body>
</html>
```

### Compatibilite avec le use case Flutter

Le use case `SendGuestInvitation` (`send_guest_invitation.dart`) attend :
- **Endpoint** : `send-wedding-invitation` (nom exact)
- **Body** : `{ "guest_id": "uuid", "wedding_id": "uuid" }`
- **Success** : status 200 avec `{ "success": true, ... }`
- **Errors** : status != 200 avec `{ "error": "error_code" }` ou les codes sont `invalid_email`, `guest_not_found`, `rate_limited`, `email_service_error`, `unauthorized`

**NOUVEAU code erreur** : `invalid_invite_code` (AC-2).

**Mapping Flutter** : Le use case `SendGuestInvitation._mapErrorToMessage()` NE mappe PAS ce code erreur. Il tombera dans le `default` case :
```dart
default:
  return 'Failed to send invitation';
```

**Justification** : Acceptable pour V1 car :
1. Le trigger DB (S02) empeche les `invite_code` NULL en production
2. L'erreur `invalid_invite_code` est un **edge case ultra-rare** (corromption DB, bug trigger)
3. Le message generique "Failed to send invitation" est suffisant pour alerter l'utilisateur sans exposer les details internes
4. Ajouter un mapping specifique dans Flutter necessiterait de modifier le use case (hors scope S05)

**Amelioration future** : Ajouter `case 'invalid_invite_code': return 'Invalid wedding code';` dans `send_guest_invitation.dart` (post-EPIC-15).

### Pattern Resend a suivre

Le projet utilise Resend v4.0.0 (cf. `send-verification-email/index.ts`). Utiliser la meme version et le meme pattern d'import :

```typescript
import { Resend } from "https://esm.sh/resend@4.0.0";
import QRCode from "https://esm.sh/qrcode@1.5.3";
```

**IMPORTANT** : Utiliser `esm.sh` (PAS `npm:` qui ne fonctionne pas dans Deno Edge Functions).

### Formatage Date en Anglais

Le template email DOIT afficher la date d'expiration en anglais (pas francais). Utiliser `toLocaleDateString` avec locale `en-US` :

```typescript
const formattedDate = expiresAt
  ? new Date(expiresAt).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    })
  : 'N/A';
// Exemple output: "February 28, 2026"
```

Si `invite_code_expires_at` est NULL, ne pas afficher la ligne d'expiration (ou afficher "N/A").

### Query Supabase

La query doit joindre `wedding_guests` -> `weddings` -> `profiles` pour obtenir :
- `guest.email`, `guest.name`
- `wedding.invite_code`, `wedding.invite_code_expires_at`
- `profile.first_name` (de la mariee, pour le sujet email)

**Attention** : La relation Supabase `weddings.bride_profile_id -> profiles.id` doit etre accessible via le service role key.

**CRITIQUE** : Valider que la query retourne des donnees AVANT d'acceder aux proprietes :

```typescript
const { data, error } = await supabaseClient
  .from('wedding_guests')
  .select(`
    email,
    name,
    weddings!inner (
      invite_code,
      invite_code_expires_at,
      profiles!bride_profile_id (
        first_name
      )
    )
  `)
  .eq('id', guestId)
  .single();

if (error || !data) {
  return new Response(
    JSON.stringify({ error: 'guest_not_found' }),
    { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}

// Valider que la jointure weddings a retourne des donnees
if (!data.weddings || !Array.isArray(data.weddings) || data.weddings.length === 0) {
  return new Response(
    JSON.stringify({ error: 'wedding_not_found' }),
    { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}

const wedding = data.weddings[0];
const inviteCode = wedding.invite_code?.trim();
// ... validation anti-null suit
```

### Deploiement

```bash
# Via MCP Supabase
mcp__supabase__deploy_edge_function:
  - project_id: "hekyovgnovhfhmkpfrna"
  - function_slug: "send-wedding-invitation"
  - entrypoint_path: "supabase/functions/send-wedding-invitation/index.ts"

# Verification secrets
# RESEND_API_KEY doit deja etre configure (utilise par send-verification-email)
```

---

## Checklist Securite

- [ ] JWT verifie (header Authorization obligatoire)
- [ ] Service role key utilisee pour les queries DB (pas la anon key)
- [ ] Validation email avec regex
- [ ] Validation invite_code non-NULL/undefined/empty/whitespace avant generation URL
- [ ] Validation query DB retourne bien des donnees (profiles peut etre null)
- [ ] Pas de secrets en dur dans le code
- [ ] CORS headers presents
- [ ] Rate limiting Resend gere proprement

---

## Definition of Done

- [ ] **AC-0 validee** : S02 et S03 sont COMPLETE avant de commencer S05
- [ ] Edge Function `send-wedding-invitation/index.ts` creee
- [ ] Template email entierement en anglais (zero texte francais)
- [ ] Date d'expiration formatee en `en-US` locale (ex: "February 28, 2026", PAS "28 fevrier 2026")
- [ ] Validation : URL ne contient JAMAIS `/join/null`, `/join/undefined`, ou `/join/` (empty)
- [ ] QR code genere en base64 et embed dans le HTML
- [ ] QR code scannable, resolvant vers `https://lynewed.com/join/{code}`
- [ ] Tous les codes erreur documentes retournes (AC-2 a AC-10)
- [ ] Edge Function deployee sur Supabase prod
- [ ] Test manuel : email recu dans Gmail/Outlook avec rendu correct
- [ ] Test manuel : bouton "Send Invitation" dans l'app -> email recu
- [ ] `flutter test --no-pub test/features/my_wedding/` passe
- [ ] `flutter analyze --fatal-infos` 0 warnings
- [ ] **EPIC-09/S06 mise a jour** :
  - [ ] Template email traduit EN (copier depuis S05)
  - [ ] Domaine `lynewed.app` remplace par `lynewed.com` (6 occurrences)
  - [ ] Date formatee en `en-US` au lieu de `fr-FR`
  - [ ] Note ajoutee en haut du fichier : "DEPRECATED - See EPIC-15/S05 for production implementation"

---

## Estimation

| Critere | Valeur |
|---------|--------|
| Points | 8 |
| Complexite | Large |
| Risque | Moyen (integration Resend, deliverabilite, domaine DNS) |
| Estimation | 0.5 jour |

---

## Dependances

### Bloquantes (doit etre fait AVANT)

| Story | Raison |
|-------|--------|
| S02 (invite codes trigger) | Les `invite_code` doivent etre non-NULL en base pour generer des URLs valides |
| S03 (deep links diagnostic) | Les liens `lynewed.com/join/{code}` doivent fonctionner quand le guest clique |

### Non-bloquantes

| Element | Status |
|---------|--------|
| `RESEND_API_KEY` en secrets Supabase | Deja configure (utilise par `send-verification-email`) |
| Colonnes `status`, `invited_at` dans `wedding_guests` | Deja presentes (EPIC-09) |
| Use case Flutter `SendGuestInvitation` | Deja implemente |
| Widget `SendInvitationButton` | Deja implemente |

---

## Validation INVEST

| Critere | Status | Justification |
|---------|--------|---------------|
| **I**ndependent | OK | Livrable independant (une Edge Function), dependencies techniques claires et limitees |
| **N**egotiable | OK | Le template email peut etre ajuste, le wording est negociable |
| **V**aluable | OK | Debloque la fonctionnalite "inviter des guests par email" - feature core du produit |
| **E**stimable | OK | 8 points - une Edge Function avec template, QR code, et validations |
| **S**mall | OK | 8 points (limite haute mais reste une seule unite de travail) |
| **T**estable | OK | 11 criteres Gherkin, test manuel email, test Flutter existant |

---

## Risques

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Domaine `lynewed.com` pas verifie dans Resend | Emails en spam | Verifier SPF/DKIM dans Resend dashboard, fallback sur `onboarding@resend.dev` pour tests |
| `invite_code_expires_at` NULL en base | Crash template date | Gerer le cas : si NULL, ne pas afficher la ligne expiration |
| Relation FK `weddings.bride_profile_id -> profiles` pas accessible | Query echoue | Tester la query avec service role key, ajuster le `.select()` si necessaire |
| Images base64 bloquees par certains clients mail | QR code invisible | Le code textuel `ABCD1234` est toujours affiche en fallback |

---

## Corrections a Appliquer sur EPIC-09/S06 (Post-Implementation)

**Fichier** : `docs/epics/EPIC-09-INVITATIONS/stories/S06-edge-function-send-invitation.md`

**Changements requis** :

| Ligne | Ancien | Nouveau | Raison |
|-------|--------|---------|--------|
| 102 | `https://lynewed.app/join/${inviteCode}` | `https://lynewed.com/join/${inviteCode}` | Alignement avec iOS/Android config |
| 128 | `from: 'Lynewed <noreply@lynewed.app>'` | `from: 'Lynewed <noreply@lynewed.com>'` | Alignement domaine email |
| 130 | `Vous etes invite(e) au mariage de ${brideName} !` | `You're invited to ${brideName}'s Wedding!` | Template EN |
| 194 | `toLocaleDateString('fr-FR', ...)` | `toLocaleDateString('en-US', ...)` | Date anglais |
| 213-259 | Template email en francais (tout le HTML) | Template email en anglais (cf. S05 Notes Techniques) | BUG-01d fix |
| 313 | `Compte Resend configure avec domaine lynewed.app verifie` | `Compte Resend configure avec domaine lynewed.com verifie` | Alignement domaine |

**Methode** :
1. Copier le template HTML anglais de S05 (lignes 248-315 de ce fichier)
2. Remplacer integralement la fonction `generateEmailTemplate()` dans EPIC-09/S06
3. Ajuster les exemples dans les AC Gherkin (ligne 8-9)

**Verification** : Apres mise a jour, relire EPIC-09/S06 en entier et valider que :
- Aucun texte francais ne subsiste
- Tous les domaines pointent vers `lynewed.com`
- La date est formatee en `en-US`

---

## References

| Source | Contenu |
|--------|---------|
| `docs/epics/EPIC-09-INVITATIONS/stories/S06-edge-function-send-invitation.md` | Spec originale (FR, non implementee) - **A METTRE A JOUR post-S05** |
| `supabase/functions/send-verification-email/index.ts` | Pattern Resend existant |
| `lib/features/my_wedding/domain/usecases/send_guest_invitation.dart` | Use case Flutter (contrat API) |
| `lib/features/my_wedding/presentation/widgets/send_invitation_button.dart` | Widget UI existant |
| `lib/core/navigation/deep_link_handler.dart` | Deep link domain = `lynewed.com` |
