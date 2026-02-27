# S07 - Tracking FedEx (lien suivi externe)

> **Epic** : EPIC-15-BUGFIX
> **Domaine** : UI + INFRA
> **Complexite** : S (Small - 2 points)
> **Source** : BUG-04
> **Dependance** : S01 (FedEx OAuth fonctionnel)
> **Status** : Done

---

## CHANGELOG

### v3 - 2026-02-16 (Instruction Leo - Simplification)

**CHANGEMENT MAJEUR** : Suppression du cron job. Approche simplifiee = juste un bouton lien vers FedEx.

**Justification Leo** : "Pourquoi faire toutes les heures ? On dit juste d'aller sur le site FedEx. C'est inutile de verifier en continu."

**Changements** :
1. **SUPPRIME** : Cron job pg_cron (toutes les heures)
2. **SUPPRIME** : Migration SQL pour cron
3. **CONSERVE** : Lien "Track on FedEx" cote seller (deja implemente cote buyer)
4. **CONSERVE** : Deploy Edge Function (peut etre appelee manuellement si besoin futur)
5. **REDUIT** : Complexite 3 SP → 2 SP

### v2 - 2026-02-16 (Post-Challenge - OBSOLETE)

*Corrections v2 rendues obsoletes par la simplification v3.*

---

## Description

En tant qu'acheteuse ou vendeuse marketplace, je veux pouvoir cliquer sur un lien "Track on FedEx" dans ma page transaction, afin de suivre mon colis directement sur le site officiel FedEx sans avoir besoin d'une solution de tracking in-app complexe.

---

## Contexte Technique

### Ce qui existe deja

| Element | Fichier | Status |
|---------|---------|--------|
| Edge Function tracking | `supabase/functions/fedex-track-shipment/index.ts` | Implementee, non deployee |
| FedEx client (track) | `supabase/functions/fedex-track-shipment/fedex-client.ts` | Implementee |
| Lien FedEx externe buyer | `lib/features/marketplace/presentation/widgets/buyer_tracking_timeline.dart:360-368` | Implementee ("Track on FedEx") |
| Timeline buyer | `buyer_tracking_timeline.dart` | Implementee |
| Table `fedex_events` | Migration EPIC-14 | Creee |
| Table `marketplace_transactions` | Migration EPIC-14 | Creee |

### Ce qui manque

| Element | Action |
|---------|--------|
| Cron job pg_cron | Creer migration SQL pour scheduler toutes les heures |
| Deploy Edge Function | `supabase functions deploy fedex-track-shipment` |
| Secrets FedEx en prod | Verifier via `supabase secrets list` (couvert par S01) |
| Lien FedEx cote seller | Ajouter dans `transaction_detail_page.dart` |

---

## Criteres d'Acceptance (Gherkin)

### AC-1 : Lien FedEx visible pour le seller

```gherkin
Given a seller views a transaction with a FedEx tracking number
When the transaction_detail_page loads
Then the tracking number is displayed
  And a tappable "Track on FedEx" link is visible
  And tapping the link opens https://www.fedex.com/fedextrack/?trknbr={TRACKING_NUMBER} in external browser
```

### AC-2 : Lien FedEx visible pour le buyer (verification existant)

```gherkin
Given a buyer views a transaction with a FedEx tracking number
When the buyer_tracking_timeline loads
Then a "Track on FedEx" link is already visible (code existant buyer_tracking_timeline.dart:360-368)
  And tapping the link opens the FedEx tracking page in external browser
```

### AC-3 : Pas de lien si pas de tracking number

```gherkin
Given a transaction without a FedEx tracking number (fedexTrackingNumber = null)
When the transaction_detail_page loads
Then no tracking section is displayed
  And no "Track on FedEx" link is visible
```

### AC-4 : Edge Function deployee (optionnel pour usage futur)

```gherkin
Given the Edge Function "fedex-track-shipment" exists locally
When it is deployed via supabase functions deploy
Then the function is accessible on Supabase
  And it can be called manuellement si besoin de mise a jour ponctuelle des statuts
```

**NOTE** : Le cron job automatique est SUPPRIME. L'Edge Function reste deployee pour usage manuel ponctuel si necessaire dans le futur.

---

## Implementation Plan

### Step 1 : Deploy Edge Function (optionnel - usage futur)

```bash
# Verifier que les secrets sont configures (S01 doit etre complete)
supabase secrets list | grep FEDEX

# Deployer pour usage manuel futur
supabase functions deploy fedex-track-shipment
```

**NOTE** : Pas de cron job. L'Edge Function est deployee uniquement pour usage manuel ponctuel si necessaire.

### ~~Step 2 : Migration cron job~~ SUPPRIME

**SUPPRIME (Instruction Leo)** : Pas de cron job automatique. Inutile de verifier en continu pour un volume faible. Les utilisateurs consultent le suivi directement sur le site FedEx.

### Step 2 : Lien FedEx cote seller

Ajouter dans `lib/features/marketplace/presentation/pages/transaction_detail_page.dart` un widget affichant le tracking number avec lien "Track on FedEx".

**Code a ajouter dans `_TransactionDetailPageState`** :

```dart
/// Opens the FedEx tracking website for the tracking number.
Future<void> _openFedExTracking() async {
  final trackingNumber = _transaction?.fedexTrackingNumber;
  if (trackingNumber == null) return;
  final url = Uri.parse(
    'https://www.fedex.com/fedextrack/?trknbr=$trackingNumber',
  );
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
```

**Code a ajouter dans `build()` apres `_buildShippingSection()`** :

```dart
const SizedBox(height: 30),
if (_transaction?.fedexTrackingNumber != null) ...[
  _buildTrackingLinkSection(),
  const SizedBox(height: 30),
],
```

**Nouveau widget builder** :

```dart
Widget _buildTrackingLinkSection() {
  final trackingNumber = _transaction!.fedexTrackingNumber!;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const LynewedSectionTitle('Package Tracking'),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: LynewedComponentStyles.cardDecoration(),
        child: Row(
          children: [
            const Icon(
              Icons.local_shipping,
              size: 18,
              color: LynewedColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                trackingNumber,
                style: LynewedTextStyles.titleSmall.copyWith(fontSize: 14),
              ),
            ),
            GestureDetector(
              onTap: _openFedExTracking,
              child: Text(
                'Track on FedEx',
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
```

**Import necessaire** :

```dart
import 'package:url_launcher/url_launcher.dart';
```

### Step 4 : Tests

---

## Files to Create/Modify

### ~~CREATE~~ SUPPRIME

```
# SUPPRIME : supabase/migrations/20260216000007_setup_fedex_tracking_cron.sql (pas de cron)
```

### MODIFY

```
lib/features/marketplace/presentation/pages/transaction_detail_page.dart  # Ajouter lien FedEx seller
```

### DEPLOY (optionnel - usage futur)

```
supabase/functions/fedex-track-shipment/index.ts    # Deploy pour usage manuel futur
supabase/functions/fedex-track-shipment/fedex-client.ts
```

---

## Tests Required

### Tests existants a verifier

| Fichier | Quoi verifier |
|---------|--------------|
| `test/features/marketplace/presentation/widgets/buyer_tracking_timeline_test.dart` | Lien FedEx buyer fonctionne |
| `test/features/marketplace/domain/usecases/get_tracking_events_use_case_test.dart` | Use case tracking |

### Tests a ajouter/modifier

```dart
// test/features/marketplace/presentation/pages/transaction_detail_page_test.dart

group('FedEx tracking link (seller)', () {
  testWidgets('displays tracking number when available', (tester) async {
    // Given a transaction with fedexTrackingNumber = '123456789'
    // When the page loads
    // Then the tracking number '123456789' is displayed
  });

  testWidgets('shows "Track on FedEx" link when tracking number exists', (tester) async {
    // Given a transaction with a tracking number
    // When the page loads
    // Then a "Track on FedEx" text is visible
  });

  testWidgets('hides tracking section when no tracking number', (tester) async {
    // Given a transaction with fedexTrackingNumber = null
    // When the page loads
    // Then no tracking link is displayed
  });
});
```

### Validation Edge Function (manuel)

```bash
# Test mode cron (track all active shipments)
curl -X POST \
  https://hekyovgnovhfhmkpfrna.supabase.co/functions/v1/fedex-track-shipment \
  -H "Authorization: Bearer $SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d '{"mode": "cron"}'

# Test mode manual (specific tracking number)
curl -X POST \
  https://hekyovgnovhfhmkpfrna.supabase.co/functions/v1/fedex-track-shipment \
  -H "Authorization: Bearer $SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d '{"mode": "manual", "tracking_number": "123456789"}'
```

### ~~Validation cron~~ SUPPRIME

~~Cron job supprime (Instruction Leo v3). Pas de validation SQL necessaire.~~

---

## Validation INVEST

| Critere | Validation |
|---------|-----------|
| **I**ndependent | Depend uniquement de S01 (OAuth). Pas de conflit fichier avec S06 |
| **N**egotiable | Deploy Edge Function optionnel (usage futur). Lien seller = minimum viable |
| **V**aluable | Lien direct FedEx pour suivi colis. Simple, fiable, zero maintenance |
| **E**stimable | 2 points. Lien buyer deja implemente, il reste : lien seller + (optionnel) deploy Edge Function |
| **S**mall | 1 fichier touche (transaction_detail_page.dart). Widget simple |
| **T**estable | Tests widget pour lien seller (3 tests), verification lien buyer existant |

---

## Risques et Mitigations

| Risque | Impact | Mitigation |
|--------|--------|------------|
| url_launcher non disponible | Tres faible | Package deja dans les deps du projet |
| FedEx change le format URL tracking | Faible | URL standard FedEx, stable depuis des annees. Facile a mettre a jour si besoin |

---

## Definition of Done

- [ ] Lien "Track on FedEx" visible sur `transaction_detail_page.dart` (seller)
- [ ] Import `url_launcher` ajoute dans `transaction_detail_page.dart`
- [ ] Lien ouvre `https://www.fedex.com/fedextrack/?trknbr={TRACKING_NUMBER}` dans navigateur externe
- [ ] Section tracking cachee si `fedexTrackingNumber == null`
- [ ] Tests widget seller tracking link passes (3 tests)
- [ ] Tests existants buyer tracking timeline toujours verts
- [ ] `flutter analyze --fatal-infos` passe sans warnings
- [ ] (Optionnel) Edge Function `fedex-track-shipment` deployee sur Supabase pour usage futur
- [ ] ~~Migration cron~~ SUPPRIME
- [ ] ~~Cron job~~ SUPPRIME

---

## Estimation

| Metrique | Valeur |
|----------|--------|
| **Story Points** | 2 (reduit de 3 → 2 apres suppression cron) |
| **Complexite** | Small |
| **Risque** | Tres faible (juste un lien + widget UI) |
| **Effort** | ~1-2h |

---

## Dependances

### Requires

- S01 COMPLETE (FedEx OAuth fonctionnel, secrets configures)

### Provides

- Lien tracking externe pour le seller (buyer deja fait)
- (Optionnel) Edge Function deployee pour usage manuel futur

### Blocks

- Aucun (cette story finalise le tracking)

---

## Notes

### ~~Frequence cron~~ SUPPRIME (Instruction Leo v3)

**Decision Leo** : "Pourquoi faire toutes les heures ? On dit juste d'aller sur le site FedEx. C'est inutile de verifier en continu."

Le cron job est supprime. Si un besoin de polling automatique apparait dans le futur (volume de transactions plus eleve), une story separee sera creee.

### Approche pragmatique : Lien direct vers FedEx

Le suivi detaille n'est PAS reconstruit dans l'app. Un lien `https://www.fedex.com/fedextrack/?trknbr={TRACKING_NUMBER}` ouvre le site FedEx dans le navigateur. Simple, fiable, pas de maintenance.

### Lien buyer deja implemente

Le widget `BuyerTrackingTimeline` (`buyer_tracking_timeline.dart:197-230`) affiche deja le tracking number et le lien "Track on FedEx" avec `url_launcher`. Aucune modification necessaire cote buyer.

### Ce qui reste a faire

Uniquement : ajouter le meme lien "Track on FedEx" cote **seller** dans `transaction_detail_page.dart`.
