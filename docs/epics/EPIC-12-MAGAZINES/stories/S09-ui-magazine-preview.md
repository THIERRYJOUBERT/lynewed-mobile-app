# S09 - UI Magazine Preview Mockup

> **Epic** : EPIC-12-MAGAZINES
> **Status** : 🔵 Draft
> **Estimation** : 8 points (L)
> **Domaine** : Flutter UI
> **MAJ** : 2026-02-03

---

## Description

Afficher un preview mockup du magazine avec couverture personnalisee et pages interieures. Layout automatique base sur le nombre de photos. **Inclut la selection du format magazine avant checkout** (MAJ 2026-02-03).

## Dependances

- S08 (magazine selection)

## Note Importante (MAJ 2026-02-03)

> **4 formats magazine disponibles** - L'utilisateur doit selectionner le format avant de proceder au checkout.
> Chaque format a un nombre max de photos et un prix different.

| Format | Taille | Spreads | Max Photos | Prix |
|--------|--------|---------|------------|------|
| GUEST EDITION | 21×30 cm | 20 | 20 | $29 |
| ICONIC | 21×30 cm | 40 | 40 | $59 |
| MEMORY | 21×30 cm | 60 | 60 | $69 |
| COLLECTOR | 25×32 cm | 60 | 60 | $89 |

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Magazine preview mockup with format selection

  # === FORMAT SELECTION (NEW 2026-02-03) ===
  Scenario: Displaying format selection
    Given bride on preview screen with X photos selected
    When preview loads
    Then format selector should appear
    And formats where max_photos >= X should be selectable
    And formats where max_photos < X should be disabled with "Need to remove X photos"

  Scenario: Selecting magazine format
    Given 25 photos selected
    When format selector shows
    Then GUEST EDITION (20 max) should be disabled
    And ICONIC (40 max), MEMORY (60 max), COLLECTOR (60 max) should be enabled
    When bride selects ICONIC
    Then price should update to $59
    And "Order Magazine - $59" button should show

  Scenario: Format auto-selection
    Given 15 photos selected
    When preview opens
    Then GUEST EDITION should be pre-selected (cheapest valid option)
    And price should show $29

  Scenario: Format card display
    Given format selector visible
    Then each format card should show:
      - Format name (GUEST EDITION, ICONIC, etc.)
      - Size (21x30cm or 25x32cm)
      - Number of spreads
      - Price
      - Max photos allowed
      - Selected indicator (checkmark)

  # === COVER ===
  Scenario: Displaying magazine cover
    Given bride on preview screen with photos selected
    When preview loads
    Then cover page should show:
      - "DIGITAL EDITION" label top
      - "LYNEWED" branding
      - Cover photo (first selected or chosen)
      - Wedding title (e.g., "Jessica & Kyle")
      - Wedding date (e.g., "June 12, 2025")
      - "Captured by our loved ones" tagline
      - "THE LOVE STORY • EXCLUSIVE" subtitle

  Scenario: Changing cover photo
    Given cover displayed with photo 1
    When bride taps "Change cover photo"
    Then photo picker should open
    And bride can select different photo as cover

  # === INTERIOR PAGES ===
  Scenario: Auto-generating page layouts
    Given 20 photos selected
    When preview generates interior pages
    Then pages should have varied layouts:
      - Single large photo pages
      - 2-photo spread pages
      - 4-6 photo mosaic pages ("Guest Moments")
    And layouts should alternate for visual interest

  Scenario: Page with section title
    Given interior page generated
    Then some pages should have section titles:
      - "The Party"
      - "Guest Moments"
      - "Celebration"
      - "The Ceremony"

  # === NAVIGATION ===
  Scenario: Swiping between pages
    Given magazine preview open
    When bride swipes left
    Then next page should appear with animation
    And page indicator should update

  Scenario: Page number indicator
    Given magazine with 10 pages
    Then indicator should show "1/10"
    And update as bride navigates

  Scenario: Thumbnail page navigation
    Given bride taps page indicator
    Then thumbnail strip should appear
    And bride can jump to any page

  # === ACTIONS ===
  Scenario: Proceeding to checkout
    Given preview showing and format selected
    When bride taps "Order Magazine - $XX"
    Then checkout screen should open (S10)
    And selected format and price should be passed
    And photo count and cover should be confirmed

  Scenario: Going back to edit
    Given preview showing
    When bride taps "Edit Selection"
    Then should return to selection screen (S08)
    And current selection preserved

  Scenario: Viewing photo full screen
    Given preview showing a page
    When bride taps on a photo
    Then photo should open full screen
    And swipe to close
```

## Details Techniques

### Format Selector UI (NEW)

```
FORMAT SELECTION
┌──────────────────────────────────────────────────────────────────────────┐
│                                                                          │
│  Choose your magazine format                                             │
│  15 photos selected                                                      │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │ ✓ GUEST EDITION                                         $29    │    │
│  │   21×30cm • 20 spreads • Up to 20 photos                       │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │   ICONIC                                                $59    │    │
│  │   21×30cm • 40 spreads • Up to 40 photos                       │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │   MEMORY                                                $69    │    │
│  │   21×30cm • 60 spreads • Up to 60 photos                       │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │   COLLECTOR (Premium)                                   $89    │    │
│  │   25×32cm • 60 spreads • Up to 60 photos                       │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  [Continue to Preview →]                                                 │
└──────────────────────────────────────────────────────────────────────────┘
```

### UI Components - Cover

```
MAGAZINE COVER
┌──────────────────────────────────────────────────────────────────────────┐
│                                                                          │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │                                                                 │   │
│   │                          DIGITAL EDITION    June 12, 2025       │   │
│   │                                                                 │   │
│   │                              LYNEWED                            │   │
│   │                                                                 │   │
│   │                                                                 │   │
│   │                        [COVER PHOTO]                            │   │
│   │                                                                 │   │
│   │                                                                 │   │
│   │                                                                 │   │
│   │                          Jessica & Kyle                         │   │
│   │                      Captured by our loved ones                 │   │
│   │                                                                 │   │
│   │                    THE LOVE STORY  •  EXCLUSIVE                 │   │
│   │                                                                 │   │
│   │                   PHOTOGRAPHED BY LYNEWED STUDIO                │   │
│   │                                                                 │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│                              1/10                                        │
│                                                                          │
│  [← Edit]                                     [Order Magazine - $29 →]   │
└──────────────────────────────────────────────────────────────────────────┘
```

### UI Components - Interior Pages

```
DOUBLE PAGE SPREAD (The Party)
┌──────────────────────────────────────────────────────────────────────────┐
│                                                                          │
│   ┌────────────────────────────┬────────────────────────────┐           │
│   │ LYNEWED MAGAZINE           │                            │           │
│   │       Jessica & Kyle       │                            │           │
│   │                            │      The Party             │           │
│   │   ┌──────────────────┐    │                            │           │
│   │   │                  │    │   "Every love story is     │           │
│   │   │    [PHOTO 1]     │    │    beautiful, but ours     │           │
│   │   │    (vertical)    │    │    is my favorite."        │           │
│   │   │                  │    │                            │           │
│   │   │                  │    │   ┌──────────────────┐     │           │
│   │   └──────────────────┘    │   │    [PHOTO 2]     │     │           │
│   │                            │   │   (landscape)    │     │           │
│   │                            │   └──────────────────┘     │           │
│   │ ─────────────────────────  │                            │           │
│   │ 2      THE CEREMONY        │ 3             CELEBRATION  │           │
│   └────────────────────────────┴────────────────────────────┘           │
│                                                                          │
│                              2/10                                        │
└──────────────────────────────────────────────────────────────────────────┘

MOSAIC PAGE (Guest Moments)
┌──────────────────────────────────────────────────────────────────────────┐
│                                                                          │
│   ┌────────────────────────────┬────────────────────────────┐           │
│   │ GUEST MOMENTS              │                            │           │
│   │       Jessica & Kyle       │  ┌────────┬───────────┐   │           │
│   │                            │  │        │           │   │           │
│   │   ┌────────┬────────┐     │  │[PHOTO] │ [PHOTO]   │   │           │
│   │   │[PHOTO] │[PHOTO] │     │  │        │           │   │           │
│   │   └────────┴────────┘     │  ├────────┴───────────┤   │           │
│   │                            │  │                    │   │           │
│   │   ┌────────────────────┐  │  │     [PHOTO]        │   │           │
│   │   │                    │  │  │                    │   │           │
│   │   │     [PHOTO]        │  │  └────────────────────┘   │           │
│   │   │                    │  │                            │           │
│   │   └────────────────────┘  │  ┌────────────────────┐   │           │
│   │                            │  │     [PHOTO]        │   │           │
│   │                            │  └────────────────────┘   │           │
│   │ ─────────────────────────  │ ─────────────────────────  │           │
│   │ 4             CELEBRATION  │ 5                         │           │
│   └────────────────────────────┴────────────────────────────┘           │
│                                                                          │
│                              3/10                                        │
└──────────────────────────────────────────────────────────────────────────┘
```

### Magazine Format Entity

```dart
class MagazineFormat {
  final String id;      // 'guest_edition', 'iconic', 'memory', 'collector'
  final String name;    // 'GUEST EDITION', etc.
  final String size;    // '21x30cm' or '25x32cm'
  final int spreads;    // 20, 40, or 60
  final int maxPhotos;  // 20, 40, or 60
  final int priceCents; // 2900, 5900, 6900, 8900

  bool isValidForPhotoCount(int photoCount) => photoCount <= maxPhotos;
}

// Available formats
const magazineFormats = [
  MagazineFormat(
    id: 'guest_edition',
    name: 'GUEST EDITION',
    size: '21×30cm',
    spreads: 20,
    maxPhotos: 20,
    priceCents: 2900,
  ),
  MagazineFormat(
    id: 'iconic',
    name: 'ICONIC',
    size: '21×30cm',
    spreads: 40,
    maxPhotos: 40,
    priceCents: 5900,
  ),
  MagazineFormat(
    id: 'memory',
    name: 'MEMORY',
    size: '21×30cm',
    spreads: 60,
    maxPhotos: 60,
    priceCents: 6900,
  ),
  MagazineFormat(
    id: 'collector',
    name: 'COLLECTOR',
    size: '25×32cm',
    spreads: 60,
    maxPhotos: 60,
    priceCents: 8900,
  ),
];
```

### Layout Algorithm

```dart
// Auto-generate page layouts based on photo count
List<MagazinePage> generateLayouts(List<MagazinePhoto> photos) {
  final pages = <MagazinePage>[];

  // First page = cover
  pages.add(CoverPage(photo: photos.first));

  // Remaining photos distributed across layouts
  final remaining = photos.skip(1).toList();
  var index = 0;

  while (index < remaining.length) {
    final photosLeft = remaining.length - index;

    if (photosLeft >= 6 && Random().nextBool()) {
      // Mosaic page (6 photos)
      pages.add(MosaicPage(photos: remaining.sublist(index, index + 6)));
      index += 6;
    } else if (photosLeft >= 2) {
      // Double page (2 photos)
      pages.add(DoublePage(photos: remaining.sublist(index, index + 2)));
      index += 2;
    } else {
      // Single page
      pages.add(SinglePage(photo: remaining[index]));
      index++;
    }
  }

  return pages;
}
```

### Fichiers a Creer/Modifier

| Fichier | Action |
|---------|--------|
| `lib/features/my_wedding/presentation/pages/magazine_preview_page.dart` | Nouveau |
| `lib/features/my_wedding/presentation/widgets/magazine_format_selector.dart` | Nouveau (MAJ) |
| `lib/features/my_wedding/presentation/widgets/magazine_format_card.dart` | Nouveau (MAJ) |
| `lib/features/my_wedding/presentation/widgets/magazine_cover.dart` | Nouveau |
| `lib/features/my_wedding/presentation/widgets/magazine_double_page.dart` | Nouveau |
| `lib/features/my_wedding/presentation/widgets/magazine_mosaic_page.dart` | Nouveau |
| `lib/features/my_wedding/presentation/widgets/magazine_single_page.dart` | Nouveau |
| `lib/features/my_wedding/presentation/widgets/page_indicator.dart` | Nouveau |
| `lib/features/my_wedding/domain/entities/magazine_format.dart` | Nouveau (MAJ) |
| `lib/features/my_wedding/domain/services/magazine_layout_service.dart` | Nouveau |

### Page View

```dart
PageView.builder(
  controller: _pageController,
  itemCount: pages.length,
  itemBuilder: (context, index) {
    final page = pages[index];
    return switch (page) {
      CoverPage p => MagazineCover(page: p),
      DoublePage p => MagazineDoublePage(page: p),
      MosaicPage p => MagazineMosaicPage(page: p),
      SinglePage p => MagazineSinglePage(page: p),
    };
  },
);
```

## Tests

- [ ] Format selector affiche les 4 formats
- [ ] Formats invalides (trop de photos) sont desactives
- [ ] Format auto-selectionne (cheapest valid)
- [ ] Prix mis a jour quand format change
- [ ] Cover affiche correctement toutes infos
- [ ] Layouts varies generes
- [ ] Swipe navigation fluide
- [ ] Page indicator mis a jour
- [ ] Tap photo ouvre fullscreen
- [ ] Order button navigue vers checkout avec format selectionne
- [ ] Edit button retourne a selection

## UI Reference

Screenshots Thierry:
- Couverture avec "LYNEWED" branding
- Pages interieures avec "The Party", "Guest Moments"

## Notes

- V1 = layouts automatiques, pas d'edition manuelle
- Section titles hardcoded pour V1
- Utiliser PageView pour swipe
- Preload pages adjacentes pour fluidite
- **4 formats disponibles avec prix differencies** (MAJ 2026-02-03)
