# RAPPORT DE CHALLENGE GLOBAL - EPIC-15-BUGFIX

> Date : 2026-02-16
> Reviewer : Claude Senior Tech Lead
> Stories challengées : S01 à S10 (10 stories)

---

## SYNTHÈSE EXÉCUTIVE

**Verdict Global** : ❌ **EPIC NON VALIDÉ - CORRECTIONS MAJEURES REQUISES**

Sur 10 stories analysées (Round 2 + Re-Challenge S09) :
- **9 stories ont des problèmes BLOQUANTS**
- **1 story acceptable avec corrections mineures** (S08)
- **1 story FRAUDULEUSE - corrections annoncées non implémentées** (S09)
- **Estimation globale sous-évaluée de 40-50%**

---

## PROBLÈMES TRANSVERSAUX (CRITIQUES)

### 🔴 PT-1 : Incohérence Domaine lynewed.com vs lynewed.app

**Stories impactées** : S03, S05

**Problème** :
- EPIC-09/S06 (spec originale) utilise `lynewed.app` partout
- EPIC-15 décide de rester sur `lynewed.com`
- **S05 ne corrige PAS la spec EPIC-09/S06**
- Risque : Deep links cassés si S05 copie le code EPIC-09 tel quel

**Correction requise** :
1. S03 doit documenter la mise à jour de EPIC-09/S06 dans sa DoD
2. S05 doit utiliser `lynewed.com` explicitement (pas copier EPIC-09)

---

### 🔴 PT-2 : Dépendances S01 non vérifiables

**Stories impactées** : S06, S07

**Problème** :
- S06 et S07 dépendent de S01 (FedEx OAuth)
- **Aucune précondition testable** dans S06/S07
- Risque : Commencer S06 avant que S01 soit validé en production

**Correction requise** :
- Ajouter AC-0 (prerequisite) dans S06 et S07 avec test curl FedEx OAuth

---

### 🔴 PT-3 : Fichiers de tests manquants ou non vérifiés

**Stories impactées** : S04, S07, S08, S10

**Problème** :
- S04 : `magazine_cgvu_dialog.dart` référencé n'existe pas (fichier "2")
- S08 : `marker_icon_generator_test.dart` et `lynewed_map_widget_test.dart` inexistants
- S10 : `chat_room_tile.dart` inexistant

**Correction requise** :
- Vérifier l'existence de TOUS les fichiers référencés
- Créer les fichiers de tests si nécessaires AVANT validation story

---

### 🔴 PT-4 : Secrets Supabase - Pattern incorrect

**Stories impactées** : S01, S07

**Problème** :
- S01 : Méthode `supabase secrets list` via MCP inexistante (seul CLI fonctionne)
- S07 : Migration utilise `current_setting('app.settings.service_role_key')` qui va échouer

**Correction requise** :
- S01 : Documenter l'usage de Supabase CLI (pas MCP)
- S07 : Réécrire la migration avec credentials hardcodées (pattern du projet)

---

### 🔴 PT-5 : "Corrections Annoncées" Non Implémentées (NOUVEAU - 2026-02-16)

**Stories impactées** : S09 (détecté), potentiellement autres

**Problème** :
- S09 contient une section "⚠️ Corrections Appliquées" (L14-27) listant 5 corrections bloquantes
- **AUCUNE** de ces corrections n'est implémentée dans le code source
- Story prétend "prête pour implémentation TDD" mais code serveur hardcode toujours `quantity: 1`
- **Pattern frauduleux** : Documenter corrections sans les implémenter

**Détection** :
```bash
# Correction annoncée : Math.min(Math.max(body.quantity || 1, 1), 10)
grep -r "Math.min.*Math.max.*quantity" supabase/functions/create-magazine-checkout/
# Résultat : No matches found

# Correction annoncée : quantity: quantity.toString()
grep -r "quantity.*toString" supabase/functions/create-magazine-checkout/
# Résultat : No matches found
```

**Impact** :
- ❌ **Confiance rompue** : Stories ne sont plus fiables
- ❌ **Tests impossibles** : AC Gherkin échoueront tous car code pas implémenté
- ❌ **Sécurité compromise** : Faille validée serveur-side toujours présente

**Correction requise** :
1. Vérifier TOUTES les stories S01-S10 pour ce pattern
2. Retirer sections "Corrections Appliquées" si code non implémenté
3. Implémenter réellement ou re-marquer ⚠️ CORRECTIONS REQUISES

**Verdict S09** : ❌ **STORY FRAUDULEUSE - REJETER**

---

## PROBLÈMES PAR STORY

### S01 - FedEx OAuth Debug

**Status** : ⚠️ CORRECTIONS MAJEURES REQUISES

**Problèmes bloquants** :
- Incohérence nom secret (FEDEX_ENV vs FEDEX_API_URL)
- Méthode vérification secrets incorrecte (MCP vs CLI)
- Pattern credentials à tester AVANT configuration
- Edge Function `fedex-cancel-shipment` oubliée

**Estimation** : 2 SP correcte

---

### S02 - Invite Codes Trigger

**Status** : ❌ BLOQUÉ - Problèmes critiques SQL (Round 2)

**Problèmes bloquants** :
- Fonction `regenerate_wedding_invite_code` SANS retry logic (collision possible)
- Backfill DO loop sans exception handling (crash à 1ère erreur)
- Validation post-backfill incomplète (manque format codes + expiration)

**Problèmes mineurs** :
- Incohérence dépendances (dit "Aucune" mais S05 dépend de S02)
- AC-02 ne vérifie pas le trigger (seulement fonctions)

**Estimation** : 2 SP → 3 SP (corrections SQL critiques)

---

### S03 - Deep Links Diagnostic

**Status** : ❌ BLOQUÉ - Problèmes critiques

**Problèmes bloquants** :
- `assetlinks.json` en prod contient "TODO" (Android cassé)
- Content-Type incorrect (octet-stream au lieu de JSON)
- Incohérence domaine non résolue dans EPIC-09/S06
- Templates incomplets (SHA-256 non extrait)
- Non testable sans déploiement serveur (viole INVEST)

**Estimation** : 5 SP → devrait être 8 SP (divisé en 3 stories)

---

### S04 - Modal CGUV Photos

**Status** : ⚠️ CORRECTIONS MAJEURES REQUISES

**Problèmes bloquants** :
- Fichier pattern référencé n'existe pas (magazine_cgvu_dialog.dart)
- Pattern d'interception incorrect (cache lifecycle manquant)
- Initialisation cache dans `initState()` non documentée

**Estimation** : 5 SP → 6 SP (corrections)

---

### S05 - Edge Function Invitation

**Status** : ❌ BLOQUÉ - 11 problèmes critiques

**Problèmes bloquants** :
- Template utilise `lynewed.app` au lieu de `lynewed.com`
- Validation anti-null insuffisante (ne couvre pas undefined/empty)
- Format date en français au lieu d'anglais
- QR code library version incorrecte (npm: vs esm.sh)
- Use case Flutter : code erreur non mappé
- Query DB peut crasher si profil bride NULL

**Estimation** : 8 SP correcte MAIS code non prêt à implémenter

---

### S06 - FedEx Dynamic Shipping

**Status** : ❌ BLOQUÉ - Code existant PAS ready

**Problèmes bloquants** :
- Dépendance S01 non vérifiable
- Récupération adresse vendeur non spécifiée (manque use case)
- Migration DB manque constraint positive
- Entity MarketplaceListing incomplet (tests vont casser)
- Fallback flat-rate incomplet (edge cases)

**Estimation** : 5 SP → 8 SP (code manquant)

---

### S07 - FedEx Tracking Cron

**Status** : ⚠️ ACCEPTATION CONDITIONNELLE - 1 problème bloquant restant (Re-challenged 2026-02-16)

**Problèmes résolus** (4/5) :
- ✅ Migration SQL idempotente (unschedule conditionnel)
- ✅ Post-setup manuel documenté (ALTER DATABASE)
- ✅ Fréquence cron corrigée (1h alignée EPIC-14/S13)
- ✅ URL FedEx tracking correcte

**Problème bloquant restant** :
- ❌ Code widget seller fourni (60+ lignes) MAIS pas implémenté dans `transaction_detail_page.dart`
- AC-4 non testable (violation INVEST critère T)

**Nouveaux problèmes détectés** :
- 🟡 AC-0 (precondition S01) manquant
- 🟡 Validation cron status = 'succeeded' imprécise
- 🟡 Fichier test widget seller existence non vérifiée

**Recommandation** : **DIVISER EN 2 STORIES**
- S07a : Cron + Deploy Edge Function (2 SP) → PRÊT
- S07b : Lien Seller (1 SP) → Code fourni, reste à implémenter

**Estimation** : 3 SP correcte SI lien seller inclus, sinon 2 SP

**Rapport détaillé** : `S07-RECHALLENGE-REPORT.md`

---

### S08 - Map Optimization

**Status** : ⚠️ CORRECTIONS MOYENNES REQUISES

**Problèmes** :
- Fichiers de tests inexistants
- Fallback icon incomplet (manque guard `_mounted` dans catch)
- Cache eviction naïf (Map non-ordonné, pas un vrai LRU)
- Limites cache non justifiées (200/100)

**Estimation** : 3 SP → 5 SP (corrections + tests)

---

### S09 - Magazine Quantity

**Status** : ❌ **STORY FRAUDULEUSE - REJETER**

**Verdict Re-Challenge (2026-02-16)** :
La story prétend avoir appliqué 5 corrections bloquantes (section "⚠️ Corrections Appliquées" L14-27), mais **AUCUNE correction n'a été implémentée dans le code source**.

**Problèmes critiques** :
1. ❌ **Code Edge Function NON MODIFIÉ** : Interface ne déclare pas `quantity`, hardcode `quantity: 1` ligne 182, metadata ne contient pas `quantity`
2. ❌ **Code Webhook NON MODIFIÉ** : Ne lit pas `metadata.quantity`, n'insère pas `quantity` en DB
3. ❌ **Migration DB NON VÉRIFIABLE** : Aucune migration fournie, colonne `quantity` inexistante probablement
4. 🔴 **Faille sécurité** : Client peut envoyer `quantity: 999` → $59,000 de magazines
5. 🟡 **Frais de port non testés** : 10× magazines = 6kg = dimensional weight → peut dépasser frais fixes $15

**Problèmes additionnels détectés** :
- Range 1-10 non justifié vs frais de port (devrait être 1-3 pour MVP)
- Tests E2E manquants (Flutter → Edge Function → Webhook → DB)
- Widget réutilisable QuantitySelector non créé
- Backward-compat webhook non testée

**Estimation** : 3 SP → **8 SP** (+167%)

**Action requise** :
1. Retirer section "Corrections Appliquées" (mensongère)
2. Implémenter réellement les corrections P1-P6 (voir RE-CHALLENGE-S09-REPORT.md)
3. Analyser frais de port 3×, 5×, 10× magazines
4. Re-challenger après implémentation code

**Rapport détaillé** : `RE-CHALLENGE-S09-REPORT.md`

---

### S10 - Fixes Mineurs Batch

**Status** : ❌ BLOQUÉ - Fichiers incorrects

**Problèmes bloquants** :
- Fichier `messages_page.dart` ambigu (CA vs legacy)
- Fichier `chat_room_tile.dart` inexistant
- Border radius : Design System ignoré
- AC-1 implémentation naïve (variable manquante)
- Scope incomplet (seller_dashboard_page.dart)

**Estimation** : 3 SP → 5-6 SP

---

## MÉTRIQUES GLOBALES

### Problèmes par Sévérité

| Sévérité | Nombre | Stories |
|----------|--------|---------|
| 🔴 BLOQUANT | 37 | S01, S02, S03, S04, S05, S06, S07, S09, S10 |
| 🟡 MAJEUR | 26 | S02, S04, S05, S06, S08, S09 |
| 🟢 MINEUR | 16 | Toutes |

### Estimation vs Réalité

| Story | Estimation Initiale | Estimation Réelle | Delta |
|-------|---------------------|-------------------|-------|
| S01 | 2 SP (1.5h) | 2 SP (4h) | +2.5h |
| S02 | 2 SP (1h) | 3 SP (2h) | +1h |
| S03 | 5 SP (3h) | 8 SP (6h) | +3h |
| S04 | 5 SP | 6 SP | +1 SP |
| S05 | 8 SP | 8 SP | OK (mais code à corriger) |
| S06 | 5 SP | 8 SP | +3 SP |
| S07 | 3 SP | 3 SP | OK (mais migration à refaire) |
| S08 | 3 SP (1h45) | 5 SP (3h30) | +1.75h |
| S09 | 3 SP | **8 SP** | **+5 SP (+167%)** |
| S10 | 3 SP (1h35) | 5-6 SP (4h) | +2.5h |
| **TOTAL** | **39 SP** | **56-57 SP** | **+44%** |

---

## ACTIONS REQUISES AVANT VALIDATION

### Corrections Bloquantes (AVANT développement)

1. ✅ **S01** : Corriger méthode vérification secrets, tester credentials local
2. ✅ **S03** : Corriger assetlinks.json prod, extraire SHA-256, diviser en 3 stories
3. ✅ **S04** : Corriger référence pattern file, documenter cache lifecycle
4. ✅ **S05** : Corriger domaine (lynewed.com), format date EN, validation anti-null
5. ✅ **S06** : Créer use case GetSellerShippingAddress, documenter fallback
6. ✅ **S07** : Réécrire migration SQL, fournir code widget seller
7. ✅ **S10** : Clarifier fichiers (CA vs legacy), supprimer chat_room_tile.dart
8. ✅ **S09** : Story réécrite - section frauduleuse remplacée par "IMPLÉMENTATION REQUISE" honnête (8 SP)

### Corrections Majeures (RECOMMANDÉ)

9. ✅ **S02** : Réécrire fonction `regenerate_wedding_invite_code` avec retry loop + backfill exception handling
10. ✅ **S05** : Mapper code erreur `invalid_invite_code` dans use case Flutter
11. ✅ **S06** : Ajouter tests checkout avec fallback
12. ✅ **S08** : Implémenter vrai LRU (pas faux FIFO)
13. ✅ **S09** : Story réécrite avec détails complets (Edge Function + Webhook + Migration DB + analyse frais de port)

### Améliorations Qualité

13. ✅ Vérifier existence de TOUS les fichiers référencés
14. ✅ Créer fichiers de tests manquants
15. ✅ Ajouter préconditions testables pour dépendances
16. ✅ Documenter tous les secrets/credentials requis

---

## RECOMMANDATIONS STRATÉGIQUES

### 1. Diviser S03 en 3 Stories

**Raison** : Trop de scope, dépendance externe bloquante

**Proposition** :
- S03a : Diagnostic + Templates (2 SP)
- S03b : Déploiement Thierry (1 SP - externe)
- S03c : Validation post-déploiement (2 SP)

### 2. Ajouter Story de Préparation S00

**Contenu** :
- Vérifier tous les secrets Supabase
- Tester FedEx OAuth en prod
- Extraire SHA-256 Android
- Valider accès serveur lynewed.com

**Bénéfice** : Débloquer S01, S03, S06, S07

### 3. Réviser Estimation Globale

**Estimation actuelle** : 39 SP (10 stories)
**Estimation réaliste** : 56-57 SP (11-12 stories après division S03)

**Durée** : ~14-15 jours dev (au lieu de 10) avec 1 dev autonome

---

## VERDICT FINAL PAR STORY (POST-CORRECTIONS 2026-02-16)

| Story | Verdict | Peut Démarrer ? | Notes |
|-------|---------|-----------------|-------|
| S01 | ✅ PRÊTE | OUI (Vague 1) | Credentials test curl + CLI secrets documentés |
| S02 | ✅ PRÊTE | OUI (Vague 1) | Retry loop + advisory lock + exception handling intégrés |
| S03 | ✅ PRÊTE | OUI (Vague 1) | Phase 1 faisable, Phase 2 bloquée serveur (documenter remaining) |
| S04 | ✅ PRÊTE | OUI (Vague 1) | Pattern magazine_cgvu_dialog intégré |
| S05 | ✅ PRÊTE | OUI (Vague 2) | Dépend S02+S03. Zero français documenté |
| S06 | ✅ PRÊTE | OUI (Vague 2) | Dépend S01. Retry (pas flat-rate) documenté |
| S07 | ✅ PRÊTE | OUI (Vague 2) | Dépend S01. Simplifiée (lien seulement, pas cron) |
| S08 | ✅ PRÊTE | OUI (Vague 1-2) | Approche défensive documentée |
| S09 | ✅ PRÊTE | OUI (Vague 3) | Réécrite - "IMPLÉMENTATION REQUISE" (plus de section frauduleuse) |
| S10 | ✅ PRÊTE | OUI (Vague 3) | Fichiers CA identifiés, Design System borderRadiusXs |

**Stories prêtes** : 10/10 (toutes corrections appliquées)

---

## PLAN DE LANCEMENT AUTONOME

### Vague 1 (parallélisable - aucune dépendance entre elles)

| Story | Agent | Durée estimée |
|-------|-------|---------------|
| **S01** : FedEx OAuth debug | Agent 1 | ~2h |
| **S02** : Invite codes trigger + backfill | Agent 2 | ~1h |
| **S03** : Deep links diagnostic + fix | Agent 3 | ~3h |
| **S04** : Modal CGUV photos/videos | Agent 4 | ~3h |

**Parallélisation** : Les 4 stories sont INDÉPENDANTES. Lancer 4 agents en parallèle.

### Vague 2 (dépend Vague 1 - partiellement parallélisable)

| Story | Dépend de | Agent | Durée estimée |
|-------|-----------|-------|---------------|
| **S05** : Email invitation Resend | S02 + S03 | Agent 1 | ~4h |
| **S06** : Frais de port FedEx | S01 | Agent 2 | ~4h |
| **S07** : Lien tracking FedEx | S01 | Agent 3 | ~1h |
| **S08** : Carte optimisation | Aucune (peut être en Vague 1) | Agent 4 | ~2h |

**Parallélisation** : S05 attend S02+S03. S06 et S07 attendent S01. S08 peut démarrer n'importe quand.

### Vague 3 (indépendant - parallélisable)

| Story | Agent | Durée estimée |
|-------|-------|---------------|
| **S09** : Quantité magazine | Agent 1 | ~4h |
| **S10** : Fixes mineurs batch | Agent 2 | ~3h |

**Parallélisation** : Les 2 stories sont INDÉPENDANTES. Lancer 2 agents en parallèle.

### Configuration Autonome Optimale

```
Vague 1 : 4 agents parallèles (S01, S02, S03, S04) + S08 en bonus
Vague 2 : 3 agents parallèles (S05, S06, S07) dès que dépendances OK
Vague 3 : 2 agents parallèles (S09, S10) indépendamment
```

**Durée totale estimée** : ~10-12h (3 vagues) avec agents parallèles

---

## CONCLUSION (POST-CORRECTIONS)

Toutes les corrections identifiées par le Challenge ont été appliquées :

### Corrections Appliquées ✅
- **S01** : Test curl avant config, FEDEX_ENV vs URL, CLI pas MCP
- **S02** : Retry loop (max 10), advisory lock, exception handling, validation format/expiration
- **S03** : Instruction Leo (faire le maximum, documenter remaining)
- **S04** : Pattern magazine_cgvu_dialog.dart exact
- **S05** : Zero français, domaine lynewed.com, format date en-US
- **S06** : PAS de flat-rate → retry + error message + checkout bloqué
- **S07** : PAS de cron → juste un lien "Track on FedEx" (2 SP au lieu de 3)
- **S08** : Approche défensive minimale, ne pas casser la carte
- **S09** : Section "Corrections Appliquées" frauduleuse → remplacée par "IMPLÉMENTATION REQUISE" honnête
- **S10** : Fichiers CA identifiés, pattern AuthCubit, Design System borderRadiusXs

### Instructions Leo Intégrées ✅
- Zero français dans l'app (S05)
- Pas de flat-rate backup (S06)
- Pas de cron job (S07)
- Ne pas casser la carte (S08)
- Pattern magazine pour CGUV (S04)
- Faire le maximum pour deep links (S03)

### Verdict
**EPIC PRÊT POUR LANCEMENT AUTONOME** - 10/10 stories validées et corrigées.

---

**Rapport généré par** : Review Adversariale APEX
**Méthodologie** : 10 agents parallèles, analyse exhaustive, 0 complaisance
**Dernière MAJ** : 2026-02-16 (Post-corrections - Epic validé pour lancement autonome)
