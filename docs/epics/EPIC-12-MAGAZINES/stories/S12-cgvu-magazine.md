# S12 - CGVU Magazine (Scroll + Checkbox)

> **Epic** : EPIC-12-MAGAZINES
> **Status** : 🔵 Draft
> **Estimation** : 2 points (S)
> **Domaine** : Flutter UI + Legal

---

## Description

Modal CGVU specifiques aux commandes de magazines. Scroll obligatoire avant de pouvoir cocher la checkbox. Log dans cgvu_acceptances pour audit.

## Dependances

- S10 (checkout) - CGVU affiche dans checkout

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Magazine CGVU acceptance

  Scenario: Opening CGVU modal
    Given bride on checkout screen
    When bride taps "Terms of Purchase" link
    Then CGVU modal should open
    And full terms text should be displayed
    And checkbox should be disabled initially

  Scenario: Scroll requirement
    Given CGVU modal open
    And bride has not scrolled to bottom
    Then checkbox should remain disabled
    And message "Scroll to read all terms"

  Scenario: Enabling checkbox after scroll
    Given CGVU modal open
    When bride scrolls to bottom
    Then checkbox should become enabled
    And bride can tap to check

  Scenario: Accepting CGVU
    Given checkbox enabled and bride checks it
    When bride taps "Accept"
    Then modal should close
    And checkout checkbox should be checked
    And cgvu_acceptances should log:
      - user_id
      - cgvu_type = 'magazine_purchase'
      - cgvu_version = '1.0'
      - ip_address
      - user_agent
      - device_info
      - accepted_at

  Scenario: Declining CGVU
    Given CGVU modal open
    When bride taps "Close" without checking
    Then modal should close
    And checkout checkbox remains unchecked
    And no log created

  Scenario: Already accepted previously
    Given bride has accepted CGVU before
    When bride opens checkout
    Then checkbox should be pre-checked
    And bride can still view terms
```

## Details Techniques

### UI Components

```
CGVU MODAL
┌─────────────────────────────────────────────────────────────────────────┐
│  [X]            Terms of Purchase                                       │
│─────────────────────────────────────────────────────────────────────────│
│                                                                         │
│  LYNEWED MAGAZINE — TERMS OF PURCHASE                                   │
│                                                                         │
│  Please read these terms carefully before ordering                      │
│  your magazine.                                                         │
│                                                                         │
│  1. PRODUCT DESCRIPTION                                                 │
│  The Lynewed Wedding Magazine is a custom-printed                       │
│  photo book featuring photos you have selected from                     │
│  your wedding gallery. Each magazine is uniquely                        │
│  created based on your selections.                                      │
│                                                                         │
│  2. PRODUCTION & DELIVERY                                               │
│  • Magazines are produced manually by our partner                       │
│    printing service                                                     │
│  • Production typically takes 5-10 business days                        │
│  • Shipping time varies by location (7-21 days)                         │
│  • You will receive tracking information once shipped                   │
│                                                                         │
│  ... (more text) ...                                                    │
│                                                                         │
│  7. LIMITATION OF LIABILITY                                             │
│  Lynewed's liability is limited to the order value.                     │
│  We are not liable for indirect damages or delays                       │
│  beyond our control.                                                    │
│                                                                         │
│─────────────────────────────────────────────────────────────────────────│
│                                                                         │
│  [☐] I have read and accept the Lynewed Magazine Terms                  │  ← Disabled until scroll
│                                                                         │
│  [Cancel]                                         [Accept]              │  ← Accept disabled until checked
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘

AFTER SCROLL (bottom reached)
┌─────────────────────────────────────────────────────────────────────────│
│  ... beyond our control.                                                │
│                                                                         │
│  By checking the box below, you confirm you have                        │
│  read and accept these terms.                                           │
│                                                                         │
│─────────────────────────────────────────────────────────────────────────│
│                                                                         │
│  [☑] I have read and accept the Lynewed Magazine Terms                  │  ← Now enabled
│                                                                         │
│  [Cancel]                                         [Accept]              │  ← Accept enabled when checked
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### CGVU Text Content

```
LYNEWED MAGAZINE — TERMS OF PURCHASE

Please read these terms carefully before ordering your magazine.

1. PRODUCT DESCRIPTION
The Lynewed Wedding Magazine is a custom-printed photo book featuring photos you have selected from your wedding gallery. Each magazine is uniquely created based on your selections.

2. PRODUCTION & DELIVERY
• Magazines are produced manually by our partner printing service
• Production typically takes 5-10 business days
• Shipping time varies by location (7-21 days)
• You will receive tracking information once shipped

3. CUSTOM PRODUCT POLICY
As each magazine is custom-made with your personal photos:
• Orders cannot be cancelled once production begins
• Refunds are not available for delivered products
• Exchanges are only possible for production defects

4. PHOTO QUALITY
• Final print quality depends on original photo resolution
• We recommend high-resolution photos for best results
• Lynewed is not responsible for print quality issues caused by low-resolution source images

5. INTELLECTUAL PROPERTY
• You confirm you have rights to all photos included
• By ordering, you grant Lynewed permission to print your photos
• Photos are not shared or used for any other purpose

6. SHIPPING
• Shipping costs are calculated at checkout
• Risk of loss transfers upon delivery to carrier
• Lynewed is not responsible for shipping delays or damage by carriers

7. LIMITATION OF LIABILITY
Lynewed's liability is limited to the order value. We are not liable for indirect damages or delays beyond our control.

By checking the box below, you confirm you have read and accept these terms.
```

### Fichiers a Creer/Modifier

| Fichier | Action |
|---------|--------|
| `lib/features/my_wedding/presentation/dialogs/magazine_cgvu_dialog.dart` | Nouveau |
| `lib/features/my_wedding/domain/usecases/accept_cgvu_use_case.dart` | Nouveau |
| `lib/core/constants/cgvu_texts.dart` | Ajouter magazine text |

### Scroll Detection

```dart
class MagazineCgvuDialog extends StatefulWidget {
  @override
  State<MagazineCgvuDialog> createState() => _MagazineCgvuDialogState();
}

class _MagazineCgvuDialogState extends State<MagazineCgvuDialog> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels != 0) {
        // At bottom
        setState(() {
          _hasScrolledToBottom = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Terms of Purchase'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Text(CgvuTexts.magazinePurchase),
              ),
            ),
            const Divider(),
            CheckboxListTile(
              value: _isChecked,
              onChanged: _hasScrolledToBottom
                  ? (value) => setState(() => _isChecked = value ?? false)
                  : null,
              title: const Text('I have read and accept the terms'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isChecked
              ? () {
                  _logAcceptance();
                  Navigator.pop(context, true);
                }
              : null,
          child: const Text('Accept'),
        ),
      ],
    );
  }

  Future<void> _logAcceptance() async {
    await supabase.from('cgvu_acceptances').insert({
      'user_id': currentUserId,
      'cgvu_type': 'magazine_purchase',
      'cgvu_version': '1.0',
      'ip_address': await getIpAddress(),
      'user_agent': getUserAgent(),
      'device_info': getDeviceInfo(),
    });
  }
}
```

## Tests

- [ ] Modal ouvre correctement
- [ ] Checkbox disabled avant scroll
- [ ] Checkbox enabled apres scroll to bottom
- [ ] Accept button disabled si non coche
- [ ] Log cgvu_acceptances avec toutes les infos
- [ ] Cancel ferme sans log
- [ ] Pre-check si deja accepte

## Notes

- Version trackee pour changements futurs
- IP address via API ou package
- Device info: OS, app version, device model
- Scroll detection via ScrollController
