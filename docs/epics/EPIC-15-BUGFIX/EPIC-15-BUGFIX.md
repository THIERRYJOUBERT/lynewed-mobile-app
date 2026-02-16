# EPIC-15-BUGFIX

> Resume : Correction de tous les bugs remontes par Thierry apres test de la Mission 2026 (EPIC-06 a EPIC-14). Focus fonctionnel d'abord, UI mineure a la fin.
> Status : 🔵 Draft
> Domaine : MULTI (API, DATA, UI, INFRA)
> Cree le : 2026-02-16

---

## Contexte

### Pourquoi cet Epic

Thierry a teste l'application en conditions reelles apres la livraison de la Mission 2026 (EPIC-06 a EPIC-14) et a remonte des bugs via Whimsical + mail. L'analyse de code approfondie a identifie chaque cause racine.

**Objectif** : Corriger TOUS les bugs fonctionnels pour permettre un push sur les stores et un test en conditions reelles avec de vrais utilisateurs.

**Contraintes** :
- Budget serre - pas de marge pour iterations supplementaires
- L'app doit fonctionner sans bug pour compenser le manque de brides au lancement
- Thierry prevoit un test e2e marketplace avec un contact aux USA

**Exigences Qualite CRITIQUES** :
- **Testing Backend Systematique** : Toutes les Edge Functions et migrations DB doivent etre testees en conditions reelles (pas seulement mocks)
- **Zero Francais dans l'App** : Tout texte UI/email/notif doit etre en anglais
- **Robustesse API** : Aucun fallback "backup" - les APIs doivent fonctionner ou afficher message retry explicite

**Hors scope (reporte)** :
- Redesign header Home (pas dans le devis)
- Fond noir marketplace (pas dans le devis)
- Categorie "Suits" marketplace (pas dans le devis)
- Affichage couples connectes cote pro (trop complexe)
- Suppression de messages chat (pas prioritaire)
- Points brides sur la carte (fonctionne deja si mariage public)

### Acces et Outils Disponibles

**IMPORTANT** : Les agents autonomes ont acces a TOUS les outils necessaires pour implementer cet Epic :

| Outil | Status | Usage |
|-------|--------|-------|
| **FedEx API (sandbox)** | ✅ Credentials dans `.env.fedex` | OAuth2, shipping labels, rates, tracking |
| **Stripe MCP** | ✅ Cle test dans `.mcp.json` | Liste produits/prix, create payment links, webhooks |
| **Supabase MCP** | ✅ Access token dans `.mcp.json` | SQL queries, migrations, Edge Functions deploy, logs |
| **Stripe CLI** | ⚠️ A installer si besoin | `brew install stripe/stripe-cli/stripe` puis `stripe login` |

**Credentials FedEx** (`.env.fedex`) :
```
FEDEX_CLIENT_ID=l7915167202dbc400c9c338d7bbf591bc0
FEDEX_CLIENT_SECRET=3be7c39d9ab1402eba0a867430edfcf6
FEDEX_ACCOUNT_NUMBER=740561073
FEDEX_API_URL=https://apis-sandbox.fedex.com
```

**MCP Supabase** : Projet `LYNEWED-V1-APP` (ID `hekyovgnovhfhmkpfrna`, region `eu-central-2`)

**Note securite** : Toutes les cles sont en mode TEST/SANDBOX. Passer en production apres validation.

### Piliers Techniques Concernes

| Pilier | Implication pour cet Epic |
|--------|---------------------------|
| Supabase (DB + Edge Functions) | Verifier/appliquer trigger invite code, creer Edge Function invitation (Resend), cron jobs |
| FedEx API | Debloquer credentials OAuth, brancher frais dynamiques, activer tracking |
| Deep Links (iOS/Android) | Diagnostiquer lynewed.com, fichiers `.well-known/`, incoherence domaine (`lynewed.com` vs `lynewed.app`) |
| Resend (email) | L'Edge Function `send-wedding-invitation` n'existe pas encore malgre la story EPIC-09/S06 documentee. Template email documente mais pas implemente |
| Flutter App | Modal CGUV, carte stabilite, onglet marketplace messagerie, quantite magazine, border radius marketplace |

---

## Architecture Cible

```
                    VAGUE 1 (parallelisable)
                    ┌──────────────────────────────┐
                    │ S01: FedEx debug credentials  │──┐
                    │ S02: Invite codes (trigger DB) │  │
                    │ S03: Deep links diagnostic     │  │
                    │ S04: CGUV photos modal         │  │
                    └──────────────────────────────┘  │
                                                       │
                    VAGUE 2 (depend Vague 1)           │
                    ┌──────────────────────────────┐  │
                    │ S05: Edge Fn invitation Resend│←─┤ (S02+S03)
                    │ S06: FedEx shipping dynamique │←─┤ (S01)
                    │ S07: FedEx tracking + lien    │←─┤ (S01)
                    │ S08: Carte optimisation       │  │
                    └──────────────────────────────┘  │
                                                       │
                    VAGUE 3 (independant)              │
                    ┌──────────────────────────────┐  │
                    │ S09: Quantite magazine         │  │
                    │ S10: Fixes mineurs batch       │  │
                    └──────────────────────────────┘  │
```

---

## Stories

| # | Story | Domaine | Dep. | Criteres cles | Source | Complexite |
|---|-------|---------|------|---------------|--------|------------|
| S01 | Debug + fix FedEx OAuth | INFRA | - | Auth OK, etiquette generee, error handling | BUG-02 | S |
| S02 | Fix invite codes (trigger + backfill) | DATA | - | Trigger actif en prod, codes generes pour tous les mariages | BUG-01b | S |
| S03 | Deep links diagnostic + fix | INFRA | - | Lien lynewed.com/join/ ouvre l'app, domaine coherent | BUG-01c | M |
| S04 | Modal CGUV upload photos/videos guest | UI | - | Modal au 1er upload, consentement stocke en DB | BUG-09 | M |
| S05 | Edge Function `send-wedding-invitation` (Resend) | API | S02, S03 | Emails envoyes en EN avec bon deep link et QR code | BUG-01a, BUG-01d | L |
| S06 | Frais de port dynamiques FedEx | API | S01 | Rates API branchee, poids vendeur, erreur+retry si echec (PAS de flat-rate) | BUG-03 | M |
| S07 | Tracking FedEx (lien suivi externe) | UI | S01 | Lien "Track on FedEx" seller (buyer deja fait). PAS de cron | BUG-04 | S |
| S08 | Carte - optimisation + error handling | UI | - | Fallback icons, meilleur cache, pas de crash | BUG-05, BUG-13 | S |
| S09 | Quantite magazine configurable | UI | - | Selecteur quantite, prix recalcule | BUG-07 | S |
| S10 | Fixes mineurs batch | MULTI | - | Onglet marketplace cache pro (messagerie), chat prenom, border radius marketplace | BUG-08, BUG-11 | S |

---

## Detail des Stories

### S01 : Debug + fix FedEx OAuth

**Criteres cles** :
- Les secrets FedEx sont presents dans Supabase (verifier via `supabase secrets list`)
- Si absents ou expires : configurer/renouveler les credentials sandbox FedEx
- L'appel OAuth `POST /oauth/token` retourne un `access_token` valide
- La generation d'etiquette via `fedex-create-shipment` fonctionne
- L'error handling est ameliore : parser la reponse JSON FedEx au lieu de throw brut

**Source** : BUG-02

**Complexite** : S

**Details techniques** :

**Edge Functions concernees** :
- `supabase/functions/fedex-create-shipment/fedex-client.ts`
- `supabase/functions/fedex-calculate-rate/fedex-client.ts`
- `supabase/functions/fedex-track-shipment/fedex-client.ts`

**Note** : Les API keys FedEx sont deja configurees selon Leo. Le probleme est probablement des credentials expirees ou un format incorrect. Diagnostic a faire en premier.

---

### S02 : Fix invite codes (trigger + backfill)

**Criteres cles** :
- Verifier que le trigger `trg_generate_invite_code` existe en production (`SELECT * FROM pg_trigger WHERE tgname = 'trg_generate_invite_code'`)
- Si absent : re-appliquer la migration `20260129000004`
- Si present mais codes NULL : la fonction `generate_invite_code_value()` a un probleme
- Backfill tous les mariages avec `invite_code = NULL` via `regenerate_wedding_invite_code()`
- Tester : creer un nouveau mariage → le code doit etre genere automatiquement
- L'UI n'affiche plus "Generating..." indefiniment

**Source** : BUG-01b

**Complexite** : S

**Details techniques** :

**Diagnostic SQL** :
```sql
-- 1. Verifier trigger
SELECT * FROM pg_trigger WHERE tgname = 'trg_generate_invite_code';

-- 2. Verifier fonction
SELECT proname FROM pg_proc WHERE proname = 'generate_secure_invite_code';

-- 3. Voir les mariages sans code
SELECT id, invite_code, created_at FROM weddings ORDER BY created_at DESC;

-- 4. Backfill si necessaire
DO $$ DECLARE w RECORD; BEGIN
  FOR w IN SELECT id FROM weddings WHERE invite_code IS NULL LOOP
    PERFORM regenerate_wedding_invite_code(w.id);
  END LOOP;
END $$;
```

---

### S03 : Deep links diagnostic + fix

**Criteres cles** :
- Diagnostiquer pourquoi `lynewed.com/join/` ne redirige pas vers l'app (Thierry dit que c'est configure)
- Resoudre l'incoherence de domaine : l'app utilise `lynewed.com` (QR code) mais la spec EPIC-09 dit `lynewed.app`
- Verifier que les fichiers `.well-known/apple-app-site-association` et `.well-known/assetlinks.json` sont accessibles
- Si manquants : les deployer (necessite acces serveur lynewed.com)
- Un lien `https://lynewed.com/join/ABCD1234` ouvre l'app sur iOS/Android si installee
- Si app pas installee : redirection vers App Store / Play Store
- **IMPORTANT** : Faire le maximum possible. Si bloque par acces serveur, documenter ce qui reste a faire pour finalisation ulterieure

**Source** : BUG-01c

**Complexite** : M

**Note Implementation** : Story divisee en 2 phases - Phase 1 completable sans acces serveur (templates + diagnostic), Phase 2 bloquee par deploiement serveur (responsabilite Thierry)

**Details techniques** :

**Incoherence domaine identifiee** :
- QR code Flutter (`my_wedding_page.dart:678`) genere : `https://lynewed.com/join/{code}`
- Story EPIC-09/S06 specifie : `https://lynewed.app/join/{code}`
- iOS entitlements : `applinks:lynewed.com`
- Android manifest : `host="lynewed.com"`
- → Tout pointe vers `lynewed.com`, sauf la spec. On reste sur `lynewed.com`.

**Dependance externe** : Thierry doit confirmer/fournir acces au serveur lynewed.com

---

### S04 : Modal CGUV upload photos/videos guest

**Criteres cles** :
- Au premier upload (photo, video, ou multiple), une modal scrollable s'affiche
- L'utilisateur doit scroller jusqu'en bas pour activer la checkbox
- La checkbox "I confirm..." doit etre cochee pour proceder
- Le consentement est enregistre dans `cgvu_acceptances` avec type `guest_media_upload` version `1.0`
- Aux uploads suivants, la modal ne s'affiche plus (consentement deja donne)
- Le consentement est consultable en DB pour protection juridique
- **Pattern UI Reference** : Utiliser EXACTEMENT le meme pattern que `magazine_cgvu_dialog.dart` (scroll obligatoire + checkbox + UI coherent)

**Source** : BUG-09

**Complexite** : M

**Testing Backend** : Verifier RLS policies permettent INSERT pour guests, tester consentement persiste correctement en DB

**Details techniques** :

**Texte de la modal** (fourni par Thierry - texte exact a utiliser) :
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

**Checkbox** : `[ ] I confirm I have all necessary rights and consents to upload and share this content.`

**Pattern a suivre** : `magazine_cgvu_dialog.dart` (scroll obligatoire + checkbox + stockage DB)

**Fichiers** :
- `lib/features/guest/presentation/pages/guest_album_page.dart` (3 methodes upload)
- Nouveau : `lib/features/guest/presentation/dialogs/media_upload_cgvu_dialog.dart`

---

### S05 : Edge Function `send-wedding-invitation` (Resend)

**Criteres cles** :
- L'Edge Function `send-wedding-invitation` est creee et deployee
- Elle utilise Resend (comme les autres emails du projet, `RESEND_API_KEY` deja configure)
- **CRITIQUE - ZERO FRANCAIS** : L'email est ENTIEREMENT en anglais - sujet, corps, labels, footer, date formatee en `en-US`
- L'email contient : nom du mariage, code d'invitation, QR code image, bouton deep link
- Le QR code est genere serveur-side (library `qrcode`) et embed en base64
- L'URL ne contient jamais `/join/null` (validation du code avant envoi)
- Le use case `SendGuestInvitation` fonctionne de bout en bout

**Source** : BUG-01a + BUG-01d

**Complexite** : L (Large)

**Exigence Langue CRITIQUE** : Aucun mot francais dans l'email. Date formatee avec `toLocaleDateString('en-US')` (pas 'fr-FR'). Template entierement en anglais.

**Details techniques** :

**Contexte** : La story EPIC-09/S06 documente cette Edge Function en detail mais elle n'a jamais ete implementee. Le template email, le flow, et les specs sont documentes dans `docs/epics/EPIC-09-INVITATIONS/stories/S06-edge-function-send-invitation.md`.

**A creer** : `supabase/functions/send-wedding-invitation/index.ts`
- Service : Resend (`RESEND_API_KEY` deja en secrets)
- From : `"Lynewed <noreply@lynewed.com>"` (ou `lynewed.app` selon domaine)
- QR : `npm:qrcode@1.5.3` → data URL base64
- Template : HTML inline (sujet EN, corps EN)

**Dependances** : S02 (codes non-NULL), S03 (deep links fonctionnels)

---

### S06 : Frais de port dynamiques FedEx

**Criteres cles** :
- Le checkout marketplace appelle `fedex-calculate-rate` pour calculer les frais reels basees sur le poids et la destination
- Le vendeur renseigne le poids de l'article lors de la creation du listing
- L'UI affiche le prix FedEx reel au checkout
- **CRITIQUE - PAS DE FALLBACK FLAT-RATE** : Si l'API FedEx echoue, afficher message "Unable to calculate shipping. Please try again." avec bouton Retry
- Raison : Flat-rate ($15/$25/$35) ne couvre pas les couts reels → perte d'argent
- Poids par defaut si non renseigne (3kg pour dress, 1kg pour shoes)

**Source** : BUG-03

**Complexite** : M

**Changement Majeur vs Spec Initiale** : SUPPRIMER tout le code de fallback flat-rate. FedEx DOIT fonctionner ou l'utilisateur doit reessayer. Pas de compromis sur les frais de port.

**Details techniques** :

**Code existant a brancher** :
- `supabase/functions/fedex-calculate-rate/index.ts` (pret)
- `lib/features/marketplace/domain/usecases/calculate_shipping_rate_use_case.dart` (pret)

**A modifier** :
- `checkout_page.dart` : Remplacer `_computeFlatRate()` par `CalculateShippingRateUseCase`
- `create_listing_page.dart` : Ajouter champ "Weight (kg)"
- `sizes_data.dart` : Garder comme fallback

**Dependance** : S01

---

### S07 : Tracking FedEx (cron + lien suivi externe)

**Criteres cles** :
- **APPROCHE SIMPLIFIEE** : Pas de cron job automatique toutes les heures
- Afficher un bouton "Track on FedEx" dans la page transaction (buyer ET seller)
- Le bouton ouvre `https://www.fedex.com/fedextrack/?trknbr={TRACKING_NUMBER}` dans le navigateur externe
- Approche pragmatique : laisser FedEx gerer le tracking detaille au lieu de reconstruire in-app
- Les statuts de transaction peuvent etre mis a jour manuellement ou lors de consultations ponctuelles

**Source** : BUG-04

**Complexite** : S

**Changement Majeur vs Spec Initiale** : SUPPRIMER le cron job horaire (over-engineering pour volume faible). Juste un lien vers FedEx. Si besoin de polling futur, on ajoutera une story separee.

**Details techniques** :

**Edge Function existante** : `fedex-track-shipment/index.ts` (complete)

**Approche pragmatique** : L'edge function met a jour les statuts en DB et envoie les notifs. Pour le suivi detaille, on affiche un lien `https://www.fedex.com/fedextrack/?trknbr={TRACKING_NUMBER}` dans la page transaction plutot que de reconstruire tout le tracking in-app.

**Dependance** : S01

---

### S08 : Carte - optimisation + error handling

**Criteres cles** :
- Ajout d'une icone fallback quand la generation d'icone custom echoue (plus de markers invisibles)
- Meilleure gestion du cache (eviter accumulation sans limite)
- Pas de crash au dezoom (gestion defensive des erreurs)
- **ATTENTION EXTREME** : La carte fonctionne actuellement. NE PAS tout casser. Approche defensive et minimale.

**Source** : BUG-05, BUG-13

**Complexite** : S (reduit - bug isole chez Thierry, on optimise sans tout refaire)

**Principe Implementation** : Toucher le MINIMUM de code. Pas de refactoring. Juste ajouter fallback icons + limiter cache. Tester exhaustivement pour eviter regression.

**Details techniques** :

**Note** : Ce bug n'est pas reproductible par Leo. L'approche est defensive : ameliorer le error handling et le cache sans tout casser.

**Fichiers** :
- `lynewed_map_widget.dart:189-199` : Fallback icon dans le catch au lieu de silencieux
- `marker_icon_generator.dart` : Timeout sur chargement avatar

---

### S09 : Quantite magazine configurable

**Criteres cles** :
- Selecteur de quantite (1-10) sur l'ecran de commande
- Le prix total = prix unitaire x quantite
- La commande DB enregistre la quantite
- Les frais de port s'adaptent si necessaire

**Source** : BUG-07

**Complexite** : M (8 points - story reecrite, code serveur a implementer)

---

### S10 : Fixes mineurs batch

**Criteres cles** :
- **Onglet Marketplace cache dans la messagerie cote pro** : Dans `messages_page.dart:339-372`, cacher le chip "Marketplace" si `profile.isProfessional`
- **Chat prenom** : Afficher le vrai prenom au lieu de "Bride" dans les conversations marketplace
- **Border radius marketplace** : Images produits avec 0-4px de border radius max (cohererent avec le reste de l'app, pas arrondis)

**Source** : BUG-08, BUG-11

**Complexite** : S

**Details techniques** :

**Onglet messagerie** :
- `lib/features/chat/presentation/pages/messages_page.dart:339-372` : Wrapper le chip "Marketplace" avec un check `!profile.isProfessional`
- Pattern : `BlocBuilder<AuthCubit, AuthState>` comme dans `profile_page.dart:111`

**Chat prenom** :
- Verifier le SQL dans le repository chat marketplace → JOIN `profiles.full_name`

**Border radius** :
- Chercher les images produits dans marketplace et remplacer les `borderRadius` arrondis par `BorderRadius.circular(4)`

---

## Risques et Mitigations

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Deep links lynewed.com ne marchent toujours pas apres fix | HAUT | Diagnostiquer DNS/hosting avec Thierry en premier (S03) |
| FedEx credentials sandbox re-expirent | MOYEN | Documenter le process de renouvellement, passer en prod quand pret |
| Trigger invite code pas en prod | HAUT | Verifier via SQL en premier (S02), re-appliquer migration si absent |
| Resend pas configure pour le bon domaine | MOYEN | Verifier domaine + SPF/DKIM dans dashboard Resend |
| Budget temps depasse | HAUT | 8 stories Small, 3 Medium, 1 Large = faisable en 2-3 jours |

---

## Graphe de Dependances

```
S01 (FedEx debug) ────┬──→ S06 (frais dynamiques)
                       └──→ S07 (tracking cron)

S02 (invite codes) ───┬──→ S05 (Edge Fn invitation)
                       │
S03 (deep links) ──────┘

S04, S08, S09, S10 ─→ Independants (parallelisables)
```

---

## Questions en Suspens

| # | Question | Impact | Action |
|---|----------|--------|--------|
| 1 | Pourquoi lynewed.com/join/ ne redirige pas ? (Thierry dit que c'est configure) | BLOQUANT pour S03/S05 | Diagnostic DNS + `.well-known/` en S03 |
| 2 | Incoherence `lynewed.com` vs `lynewed.app` dans les specs | A clarifier | On reste sur `lynewed.com` (tout le code l'utilise) |
| 3 | Apple Team ID pour `apple-app-site-association` | Requis pour S03 | Extraire depuis Apple Developer |
| 4 | Trigger invite code present en prod ? | Requis pour S02 | Verifier via SQL |

---

## References

| Source | Contenu principal |
|--------|-------------------|
| `docs/THIERRY-FEEDBACK-2026-02-16.md` | Document source challenge avec causes racines |
| `docs/epics/EPIC-09-INVITATIONS/stories/S06-edge-function-send-invitation.md` | Spec detaillee de l'Edge Function invitation (non implementee) |
| EPIC-14 (Marketplace) | Architecture FedEx, Stripe, checkout |
| EPIC-10 (Photos/Videos) | Flow upload guest album |
| EPIC-12 (Magazines) | Flow commande magazine |

---

## Estimation Globale (Post-Corrections)

| Story | SP Initial | SP Reel | Status |
|-------|-----------|---------|--------|
| S01 | 2 | 2 | READY |
| S02 | 2 | 2 | READY |
| S03 | 5 | 5 | READY (Phase 2 bloquee serveur) |
| S04 | 5 | 5 | READY |
| S05 | 8 | 8 | READY |
| S06 | 5 | 8 | READY |
| S07 | 3 | 2 | READY (simplifie - lien seulement) |
| S08 | 3 | 3 | READY |
| S09 | 3 | 8 | READY (reecrite - code serveur a implementer) |
| S10 | 3 | 6 | READY |
| **TOTAL** | **39** | **49** | **10/10 READY** |

---

## Plan de Lancement Autonome

### Vague 1 (4 agents paralleles - aucune dependance)

```
Agent 1 → S01 (FedEx OAuth debug)        ~2h
Agent 2 → S02 (Invite codes trigger)     ~1h
Agent 3 → S03 (Deep links diagnostic)    ~3h
Agent 4 → S04 (CGUV modal photos)        ~3h
Bonus   → S08 (Carte optimisation)        ~2h (peut demarrer en parallele)
```

### Vague 2 (3 agents - depend Vague 1)

```
Agent 1 → S05 (Email invitation)          ~4h  [attend S02 + S03]
Agent 2 → S06 (Frais port FedEx)          ~4h  [attend S01]
Agent 3 → S07 (Lien tracking FedEx)       ~1h  [attend S01]
```

### Vague 3 (2 agents paralleles - independant)

```
Agent 1 → S09 (Quantite magazine)          ~4h
Agent 2 → S10 (Fixes mineurs batch)        ~3h
```

**Duree totale estimee** : ~10-12h avec agents paralleles (3 vagues)

**Commande de lancement** : `/launch-epic EPIC-15-BUGFIX --mode=autonomous`

---

## Prochaine Etape

→ Lancer EPIC-15-BUGFIX en mode autonome par vagues
