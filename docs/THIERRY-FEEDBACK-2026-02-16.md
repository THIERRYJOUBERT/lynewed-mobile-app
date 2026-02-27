# Retour Thierry - Post-Livraison Mission 2026

> **Date** : 16 fevrier 2026
> **Source** : Mail + Whimsical (8 screenshots detailles) + Analyse code approfondie
> **Contexte** : Retour apres livraison EPIC-06 a EPIC-14
> **Objectif** : Documenter TOUS les bugs avec causes racines prouvees, prioriser fonctionnel > UI

---

## Methodologie

Chaque bug a ete **investigue dans le code source** pour identifier la cause racine.
Priorisation : **Fonctionnel bloquant → Fonctionnel important → Legal → UI/UX**

---

## PRIORITE 1 - BLOQUANTS FONCTIONNELS

> Ces bugs empechent des flux entiers de fonctionner.

---

### BUG-01 : Systeme d'invitation guest totalement non-fonctionnel

**Symptome** : QR code, SMS et email d'invitation ne fonctionnent pas. Les guests ne peuvent pas rejoindre un mariage.

**Sous-problemes identifies (4) :**

#### BUG-01a : Edge Function `send-wedding-invitation` INEXISTANTE
- **Constat code** : Le use case `SendGuestInvitation` appelle `supabase.functions.invoke('send-wedding-invitation')` mais cette Edge Function **n'existe pas** dans `/supabase/functions/`
- **Impact** : Aucun email/SMS d'invitation n'est envoye
- **Fichier** : `lib/features/guest/domain/usecases/send_guest_invitation.dart`
- **Correction** : Creer l'Edge Function avec template email + SMS + QR code

#### BUG-01b : Invite code "Generating..." bloque - erreur DB `duplicate key`
- **Constat code** : Le trigger `trg_generate_invite_code` (migration `20260129000004`) genere un code 8 caracteres sur `BEFORE INSERT`. Si un mariage a ete cree avant cette migration, son `invite_code` est `NULL` indefiniment car le trigger ne s'execute que sur INSERT, pas sur les lignes existantes.
- **Erreur visible** : `duplicate key value violates unique constraint` (screenshot Whimsical)
- **Fichier DB** : `supabase/migrations/20260129000004_create_generate_invite_code.sql`
- **Fichier UI** : `lib/features/my_wedding/presentation/pages/my_wedding_page.dart:645` ("Invite code generating...")
- **Correction** : Migration pour backfill les codes NULL + ajouter bouton "Regenerer" en UI

#### BUG-01c : Deep links `lynewed.com` → 404
- **Constat code** : L'architecture utilise les Universal Links (iOS) et App Links (Android) correctement configurees dans `Runner.entitlements` et `AndroidManifest.xml` avec `applinks:lynewed.com`.
- **Probleme reel** : Les fichiers de verification de domaine **n'existent probablement pas** sur le serveur lynewed.com :
  - `https://lynewed.com/.well-known/apple-app-site-association` (iOS)
  - `https://lynewed.com/.well-known/assetlinks.json` (Android)
- **De plus** : Le domaine `lynewed.com` lui-meme semble ne pas avoir de serveur web ("server IP address could not be found")
- **Correction** : Deployer les fichiers `.well-known/` + s'assurer que lynewed.com est accessible (ou utiliser un autre domaine)

#### BUG-01d : Email invitation contient `/join/null` et est en francais
- **Constat code** : L'URL generee concatene le code d'invitation : `https://lynewed.com/join/${inviteCode}`. Si `inviteCode` est `NULL` (BUG-01b), l'URL devient `/join/null`
- **Langue** : L'email est en francais ("Participez au mariage de...") alors que CLAUDE.md impose "ENGLISH ONLY IN CODE" pour tout texte user-facing
- **Correction** : Corriger BUG-01b resout le `/join/null`. Traduire le template email en anglais.

---

### BUG-02 : FedEx - Erreur OAuth `NOT.AUTHORIZED.ERROR`

**Symptome** : Impossible de generer une etiquette d'expedition FedEx. L'API retourne une erreur d'authentification.

**Constat code** :
- L'OAuth est implemente dans chaque Edge Function FedEx (`fedex-create-shipment/fedex-client.ts`, `fedex-calculate-rate/fedex-client.ts`, `fedex-track-shipment/fedex-client.ts`)
- Les credentials sont en mode **sandbox** : `FEDEX_API_URL=https://apis-sandbox.fedex.com`
- L'erreur `NOT.AUTHORIZED.ERROR` indique que les credentials (`FEDEX_CLIENT_ID`, `FEDEX_CLIENT_SECRET`) sont soit :
  1. Pas configurees dans les secrets Supabase (probablement deployees en local `.env.fedex` mais pas dans Supabase)
  2. Expirees (les credentials sandbox FedEx expirent periodiquement)
  3. Le compte sandbox FedEx a ete desactive

**Fichiers** :
- `supabase/functions/fedex-create-shipment/fedex-client.ts` (OAuth lines 14-22)
- `supabase/functions/fedex-calculate-rate/fedex-client.ts` (OAuth lines 84-107)
- `.env.fedex` (credentials locales)

**Correction** :
1. Verifier que les secrets FedEx sont configures dans Supabase (`FEDEX_CLIENT_ID`, `FEDEX_CLIENT_SECRET`, `FEDEX_ACCOUNT_NUMBER`)
2. Regenerer les credentials sur le FedEx Developer Portal si expirees
3. Tester l'auth en isolation avant de tester la generation d'etiquette

---

### BUG-03 : Frais de port marketplace - Forfait inadapte pour les robes

**Symptome** : $15 de frais fixes pour une robe de mariee lourde, impossible pour un envoi intercontinental.

**Constat code** :
- Les frais sont en **flat-rate 3 paliers** (pas $15 fixe comme dit dans le mail) :
  - Meme pays : **$15** (`sameCountryCents = 1500`)
  - Meme region (EU/NA) : **$25** (`sameRegionCents = 2500`)
  - International : **$35** (`internationalCents = 3500`)
- **L'Edge Function `fedex-calculate-rate` existe deja** et fonctionne, mais elle n'est **pas branchee** dans le checkout. Le checkout utilise `_computeFlatRate()` au lieu d'appeler l'API FedEx.
- Le poids est deja prevu dans le code (dress: 3kg par defaut dans `fedex-create-shipment`)

**Fichiers** :
- `lib/features/marketplace/data/sizes_data.dart:161-214` (flat-rate logic)
- `lib/features/marketplace/presentation/pages/checkout_page.dart:109-132` (`_computeFlatRate()`)
- `supabase/functions/fedex-calculate-rate/index.ts` (existe mais pas utilise)
- `lib/features/marketplace/domain/usecases/calculate_shipping_rate_use_case.dart` (use case existe)

**Correction** :
1. Brancher `fedex-calculate-rate` dans le checkout (remplacer `_computeFlatRate()`)
2. Ajouter un champ "poids" dans le listing pour que le vendeur le renseigne
3. Fallback sur flat-rate si l'API FedEx echoue (BUG-02 doit etre resolu d'abord)

**Dependance** : BUG-02 (FedEx auth) doit etre corrige avant

---

### BUG-04 : Tracking FedEx non actif

**Symptome** : Pas de suivi de colis apres expedition.

**Constat code** :
- L'Edge Function `fedex-track-shipment` **existe et est complete** : elle poll FedEx, stocke les events dans `fedex_events`, met a jour le statut de la transaction, envoie des notifications
- **Le probleme** : Cette fonction est concue pour etre appelee en mode **cron** (periodiquement) mais le cron job n'est probablement **pas configure** dans Supabase
- Cote Flutter, `getTrackingEvents()` lit les events depuis la table `fedex_events`

**Fichiers** :
- `supabase/functions/fedex-track-shipment/index.ts`
- `lib/features/marketplace/data/datasources/fedex_remote_datasource.dart:107-119`

**Correction** :
1. Configurer un cron job Supabase pour appeler `fedex-track-shipment` toutes les 2-4 heures
2. Verifier que les secrets FedEx sont presents (depend de BUG-02)

**Dependance** : BUG-02 (FedEx auth)

---

## PRIORITE 2 - BUGS FONCTIONNELS IMPORTANTS

> L'app fonctionne partiellement mais ces bugs degradent l'experience.

---

### BUG-05 : Carte - Crash/ecran noir au dezoom maximal

**Symptome** : Ecran noir puis crash de l'app quand on dezoome la carte au maximum.

**Constat code** :
- Utilise `google_maps_flutter` avec zoom min=1.0 / max=21.0
- A zoom ≤5, le backend charge jusqu'a **2000 markers**
- Chaque marker genere une icone custom async (144x144px, 3x DPI) avec chargement d'avatar reseau
- **Probleme critique** : Si la generation d'icone echoue (reseau lent, image 404), le marker est **silencieusement ignore** (pas de fallback icon). Resultat : 0 markers affiches = map "vide/noire"
- Charger 2000 icones custom simultanement peut causer un OOM (Out Of Memory) → crash

**Fichiers** :
- `lib/features/map/presentation/widgets/lynewed_map_widget.dart:288-290` (filtrage markers sans icone)
- `lib/features/map/presentation/widgets/lynewed_map_widget.dart:189-199` (catch silencieux)
- `lib/features/map/presentation/state/map_state.dart:158-164` (zoom limits)
- `lib/features/map/data/datasources/supabase_map_datasource.dart:16-22` (marker limits par zoom)

**Correction** :
1. Ajouter une **icone fallback** quand la generation custom echoue
2. Augmenter le zoom minimum a **4.0 ou 5.0** (empecher le world-view)
3. Limiter le nombre de markers a 500 max avec clustering
4. Ajouter un timeout de 2s sur le chargement d'avatar pour les icones

---

### BUG-06 : Points brides/mariages absents de la carte

**Symptome** : Les mariages/brides ne sont pas visibles sur la carte.

**Constat code** :
- Le type `MapMarkerType.wedding` existe et `showWeddings = true` par defaut dans `LayerToggles`
- L'icone wedding (cercle rose avec diamant) est generee dans `marker_icon_generator.dart:170-198`
- **Hypothese** : Soit les mariages n'ont pas de coordonnees GPS dans la DB, soit la requete RPC ne les retourne pas dans les bounds visibles

**Fichiers** :
- `lib/features/map/domain/entities/map_filter.dart:19` (showWeddings=true)
- `lib/features/map/presentation/services/marker_icon_generator.dart:170-198`

**Correction** : Verifier la requete RPC et les donnees GPS des mariages en DB

---

### BUG-07 : Magazine - Quantite limitee a 1 exemplaire

**Symptome** : Impossible de commander plusieurs exemplaires du meme magazine.

**Constat code** : A verifier dans le flow de commande magazine. Le use case et le checkout ne proposent probablement pas de selecteur de quantite.

**Correction** : Ajouter un selecteur de quantite dans l'UI de commande + adapter le calcul du prix

---

### BUG-08 : Marketplace visible/accessible par les pros

**Symptome** : Un pro peut acceder a la marketplace achat.

**Constat code** :
- Le bottom nav pro (`nav_bar_pro_widget.dart`) n'a **PAS de tab marketplace** - c'est correct
- Mais la page marketplace n'a **aucun controle de role** : si un pro y navigue par un autre chemin (deep link, back navigation), il voit la page achat
- La page marketplace hardcode `NavBarBridesWidget(number: 3)` en bottom nav

**Correction** : Ajouter un guard de role sur la route marketplace. Si le user est pro, rediriger vers son dashboard vendeur.

---

## PRIORITE 3 - OBLIGATIONS LEGALES

> Features manquantes pour conformite legale.

---

### BUG-09 : Modal CGUV absente avant upload photos/videos guest (SUPER IMPORTANT selon Thierry)

**Symptome** : Les guests uploadent des photos/videos sans accepter les conditions (droit a l'image).

**Constat code** :
- **Aucune modal** avant upload dans `guest_album_page.dart`
- Les 3 methodes d'upload (`_pickAndUploadPhoto()`, `_pickAndUploadVideo()`, `_pickAndUploadMultipleMedia()`) vont directement au media picker puis a l'upload
- **L'infrastructure existe** : `CgvuAcceptanceWidget`, table `cgvu_acceptances`, `AcceptCgvuUseCase` - deja utilises pour marketplace et magazine
- Le type `guest_media_upload` n'existe pas encore dans les CGUV

**Texte fourni par Thierry** :
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

**Fichiers** :
- `lib/features/guest/presentation/pages/guest_album_page.dart:485,520,203` (upload methods)
- `lib/features/marketplace/presentation/widgets/cgvu_acceptance_widget.dart` (pattern existant)
- `lib/features/my_wedding/presentation/dialogs/magazine_cgvu_dialog.dart` (exemple a suivre)

**Correction** :
1. Creer CGUV type `guest_media_upload` version `1.0` avec le texte de Thierry
2. Afficher la modal au premier upload (checker `cgvu_acceptances` avant)
3. Une fois accepte, ne plus redemander (stocke en DB)

---

### BUG-10 : Modal CGUV magazine - A verifier

**Symptome** : Thierry mentionne une modal CGUV magazine sur le Whimsical.

**Constat code** : La modal magazine **existe deja** dans `magazine_cgvu_dialog.dart` avec scroll obligatoire + checkbox + stockage en DB.

**Verdict** : **PROBABLEMENT PAS UN BUG** - La modal existe. Peut-etre que Thierry ne l'a pas vue car il n'a pas encore passe commande, ou elle ne s'affiche qu'a la premiere commande. A verifier avec Thierry.

---

## PRIORITE 4 - BUGS MINEURS / CONFORT

> L'app fonctionne, ces items ameliorent l'experience.

---

### BUG-11 : Chat - "Chat with Bride" generique au lieu du prenom

**Constat code** : Le widget `ConversationTileWidget` utilise `conversation.otherUserName` qui vient de la DB. Si la valeur est "Bride" au lieu du vrai prenom, c'est un probleme de JOIN SQL dans le repository chat.

**Fichier** : `lib/features/marketplace/presentation/widgets/conversation_tile_widget.dart:66-74`

---

### BUG-12 : Categorie "Suits" manquante dans la marketplace

**Constat code** : Seules 3 categories existent : All, Dresses, Shoes (`category_chips.dart:36-52`). Pas de "Suits".

**Correction** : Ajouter la categorie + potentiellement un filtre backend.

---

### BUG-13 : Icones manquantes/perdues sur la carte

**Constat code** : Lie a BUG-05 (pas de fallback icon quand generation echoue). Les icones disparaissent quand le chargement d'avatar echoue.

---

### BUG-14 : Suppression de messages dans le chat

**Constat** : Feature non implementee. Pas prioritaire pour le lancement.

---

## PRIORITE 5 - UI/UX (A FAIRE EN DERNIER)

> Cosmetique uniquement, n'impacte pas le fonctionnement.

---

### UI-01 : Redesign header Home (Pro + Bride)
- Remplacer "Home" par "LYNEWED" en gros centre
- Bande noire avec icones blanches sous le titre, avant la carte

### UI-02 : Marketplace - Suggestion fond noir
- Esthetique luxe pour la marketplace

### UI-03 : Affichage "Couples connectes" cote Pro
- Dashboard pro : montrer les brides en relation

### UI-04 : Email invitation en anglais
- Depends de BUG-01a (l'edge function n'existe pas encore)

---

## QUESTIONS BUSINESS DE THIERRY

### Q1. Qui determine le code de partage ?
**Reponse** : Le code est genere **automatiquement** par un trigger PostgreSQL a la creation du mariage (8 caracteres, ex: `ABCD1234`). La bride le partage ensuite via l'app (SMS, email, QR code). Elle peut aussi le regenerer via la fonction `regenerate_wedding_invite_code()`.

### Q2. Tables des ventes Marketplace
**Reponse** :
| Table | Contenu |
|-------|---------|
| `marketplace_transactions` | Toutes les transactions (montant item, shipping, commission 10%, payout vendeur, statut, tracking) |
| `purchases` | Vue generique de tous les achats (marketplace + magazines + albums) |
| `stripe_events` | Audit trail de tous les events Stripe |
| `stripe_accounts` | Comptes Stripe Connect des vendeurs |

**Commission** : 10% du prix de l'item. Exemple : item $100 + shipping $25 = buyer paye $125. Stripe transfere $90 + $25 = $115 au vendeur. Platform garde $10.

### Q3. Tables des commandes Magazine
**Reponse** :
| Table | Contenu |
|-------|---------|
| `magazine_orders` | Commandes (user, wedding, montant, statut, adresse livraison) |
| `magazine_order_items` | Details des items (photos selectionnees, layout) |
| `magazine_selections` | Selections de photos pour le magazine |

### Q4. Frais de port Magazines
**Reponse** : A verifier dans l'implementation EPIC-12. Probablement un forfait fixe aussi.

### Q5. Table d'acceptation conditions photos
**Reponse** : Table `cgvu_acceptances` avec colonnes `user_id`, `cgvu_type`, `cgvu_version`, `accepted_at`, `device_info`. Le type `guest_media_upload` sera ajoute avec BUG-09.

### Q6. Attribution des etoiles (Reviews)
**Reponse** : Les brides laissent des avis sur les pros (1-5 etoiles + commentaire). Implemente dans EPIC-07.

---

## RECAPITULATIF ET ORDRE D'EXECUTION

| # | Bug | Categorie | Dependances | Effort |
|---|-----|-----------|-------------|--------|
| **BUG-02** | FedEx OAuth credentials | BLOQUANT | Aucune | Petit (config secrets) |
| **BUG-01b** | Invite code NULL/Generating | BLOQUANT | Aucune | Petit (migration SQL) |
| **BUG-01c** | Deep links `.well-known/` | BLOQUANT | Domaine lynewed.com | Moyen (deploiement web) |
| **BUG-01a** | Edge Function invitation | BLOQUANT | BUG-01b, BUG-01c | Grand (creation complete) |
| **BUG-01d** | Email /join/null + francais | BLOQUANT | BUG-01a, BUG-01b | Inclus dans BUG-01a |
| **BUG-03** | Frais port dynamiques FedEx | FONCTIONNEL | BUG-02 | Moyen (brancher existant) |
| **BUG-04** | Tracking FedEx cron | FONCTIONNEL | BUG-02 | Petit (config cron) |
| **BUG-05** | Carte crash/ecran noir | FONCTIONNEL | Aucune | Moyen (fallback + limits) |
| **BUG-06** | Points brides carte | FONCTIONNEL | Aucune | Petit (verif DB/RPC) |
| **BUG-09** | Modal CGUV upload photos | LEGAL | Aucune | Moyen (reutiliser pattern) |
| **BUG-07** | Quantite magazine | FONCTIONNEL | Aucune | Petit |
| **BUG-08** | Marketplace acces pro | FONCTIONNEL | Aucune | Petit (guard route) |
| **BUG-11** | Chat prenom generique | MINEUR | Aucune | Petit (fix SQL) |
| **BUG-12** | Categorie Suits | MINEUR | Aucune | Petit |
| **BUG-13** | Icones carte | MINEUR | BUG-05 | Inclus dans BUG-05 |
| **BUG-14** | Suppression messages | MINEUR | Aucune | Moyen |
| **UI-01/02/03/04** | UI/UX changes | COSMETIQUE | Divers | Variable |

---

## GRAPHE DE DEPENDANCES

```
BUG-02 (FedEx auth) ─────┬──→ BUG-03 (frais dynamiques)
                          └──→ BUG-04 (tracking cron)

BUG-01b (invite codes) ──┬──→ BUG-01a (edge function invitation)
                          └──→ BUG-01d (email /join/null)

BUG-01c (deep links) ────────→ BUG-01a (edge function invitation)

BUG-05 (carte crash) ────────→ BUG-13 (icones carte) [inclus]

BUG-09 (CGUV photos) ────────→ Independant

BUG-01a (edge function) ─────→ UI-04 (email en anglais) [inclus]
```

---

## PLAN D'EXECUTION PROPOSE

### Vague 1 - Debloquer les flux critiques (parallelisable)
- [ ] **BUG-02** : Configurer/renouveler credentials FedEx dans Supabase secrets
- [ ] **BUG-01b** : Migration SQL pour backfill les invite codes NULL
- [ ] **BUG-01c** : Deployer `.well-known/` sur lynewed.com (ou domaine alternatif)
- [ ] **BUG-09** : Modal CGUV upload photos (legal, independant)

### Vague 2 - Completer les flux (depend de Vague 1)
- [ ] **BUG-01a** : Creer Edge Function `send-wedding-invitation` (depend BUG-01b + BUG-01c)
- [ ] **BUG-03** : Brancher `fedex-calculate-rate` dans le checkout (depend BUG-02)
- [ ] **BUG-04** : Configurer cron job tracking FedEx (depend BUG-02)
- [ ] **BUG-05** : Corriger carte (fallback icons + zoom limits)

### Vague 3 - Polish fonctionnel
- [ ] **BUG-06** : Points brides carte
- [ ] **BUG-07** : Quantite magazine
- [ ] **BUG-08** : Guard route marketplace pro
- [ ] **BUG-11** : Chat prenom
- [ ] **BUG-12** : Categorie Suits

### Vague 4 - UI/UX (a la fin)
- [ ] **UI-01** : Header Home redesign
- [ ] **UI-02** : Fond noir marketplace
- [ ] **UI-03** : Couples connectes pro
- [ ] **UI-14** : Suppression messages

---

*Document challenger et mis a jour le 2026-02-16 avec analyse de code approfondie*
*Chaque bug a sa cause racine prouvee dans le code source*
