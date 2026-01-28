# Story S14: Formulaire creation annonce vendeur

## Description
En tant que vendeur, je veux creer une annonce complete avec photos et details, afin de mettre en vente ma robe ou mes chaussures de mariage.

## Criteres d'Acceptance (Gherkin)

- [ ] Given a seller creating a listing When they upload photos Then minimum 5 photos required And maximum 10 photos allowed And photos should be reorderable via drag-and-drop And first photo is the cover
- [ ] Given the listing form Then these fields should be required: title (max 255 chars), category (dress/shoes), price (>0), condition (new/excellent/good/fair), country
- [ ] Given a dress listing When filling the form Then sleeve_length should be required (long/3-4/short/cap/sleeveless/strapless)
- [ ] Given a completed listing form When seller clicks "Publish" Then if CGVU not accepted show CGVU modal Then if Stripe not setup show Stripe setup prompt Then listing status should change to 'active'
- [ ] Given photos being uploaded Then progress indicator should show And photos should be uploaded to marketplace-listings bucket
- [ ] Given a draft listing When seller saves without publishing Then listing status remains 'draft' And seller can edit later

## Fichiers Concernes

### A Creer
- `lib/features/marketplace/presentation/pages/create_listing_page.dart` - Main form page
- `lib/features/marketplace/presentation/widgets/photo_upload_widget.dart` - Photo upload with reordering
- `lib/features/marketplace/presentation/widgets/listing_form_fields.dart` - Form fields widget
- `lib/features/marketplace/presentation/widgets/size_selector_widget.dart` - Size selection with guide
- `lib/features/marketplace/presentation/widgets/brand_autocomplete_widget.dart` - Brand autocomplete
- `lib/features/marketplace/presentation/widgets/condition_selector_widget.dart` - Condition chips
- `lib/features/marketplace/data/repositories/listing_repository_impl.dart` - Repository
- `lib/features/marketplace/domain/usecases/create_listing.dart` - Use case
- `lib/features/marketplace/domain/usecases/upload_listing_photos.dart` - Use case

### A Modifier
- `lib/features/marketplace/presentation/pages/marketplace_page.dart` - Add FAB to create listing

## Notes Techniques

### Form Structure
```dart
class CreateListingPage extends ConsumerStatefulWidget {
  // Multi-step form or single scrollable form
  // Step 1: Photos (required 5-10)
  // Step 2: Basic info (title, category, price)
  // Step 3: Details (size, brand, condition, sleeve_length)
  // Step 4: Location (city, country)
  // Step 5: Review & Publish
}
```

### Photo Upload Widget
```dart
class PhotoUploadWidget extends StatefulWidget {
  final int minPhotos = 5;
  final int maxPhotos = 10;
  final Function(List<File>) onPhotosChanged;

  // Use ReorderableListView for drag-and-drop
  // Use image_picker for selection
  // Show upload progress per photo
  // First photo marked as "Cover"
}
```

### Size Guide Integration
```dart
// Dress sizes
const dressSizes = [
  SizeOption(label: 'XS (EU 32-34 / US 0-2)', value: 'XS'),
  SizeOption(label: 'S (EU 36-38 / US 4-6)', value: 'S'),
  SizeOption(label: 'M (EU 40-42 / US 8-10)', value: 'M'),
  SizeOption(label: 'L (EU 44-46 / US 12-14)', value: 'L'),
  SizeOption(label: 'XL (EU 48-50 / US 16-18)', value: 'XL'),
];

// Shoe sizes
const shoeSizes = [
  SizeOption(label: '35 (US 4 / UK 2.5)', value: '35'),
  SizeOption(label: '36 (US 5 / UK 3.5)', value: '36'),
  // ...
];
```

### Brand Autocomplete
```dart
// Use Flutter Autocomplete widget
// Filter from predefined list of popular brands
// Allow custom entry for unlisted brands
// See S17 for full brand list
```

### Publish Flow
```dart
Future<void> _publishListing() async {
  // 1. Validate form
  if (!_formKey.currentState!.validate()) return;

  // 2. Check CGVU
  final hasAcceptedCgvu = await ref.read(cgvuRepositoryProvider)
    .hasAccepted(userId, 'marketplace_seller');
  if (!hasAcceptedCgvu) {
    final accepted = await _showCgvuModal();
    if (!accepted) return;
  }

  // 3. Check Stripe
  final stripeAccount = await ref.read(stripeConnectProvider).getAccount(userId);
  if (!stripeAccount.chargesEnabled) {
    await _showStripeSetupPrompt();
    return;
  }

  // 4. Upload photos (if not already uploaded)
  final photoUrls = await _uploadPhotos();

  // 5. Create/Update listing with status = 'active'
  await ref.read(listingRepositoryProvider).createListing(
    listing: _buildListingEntity(),
    photoUrls: photoUrls,
    status: 'active',
  );

  // 6. Navigate to success/listing detail
}
```

### Validation Rules
```dart
String? validateTitle(String? value) {
  if (value == null || value.isEmpty) return 'Title is required';
  if (value.length > 255) return 'Title must be less than 255 characters';
  return null;
}

String? validatePrice(String? value) {
  final price = double.tryParse(value ?? '');
  if (price == null || price <= 0) return 'Enter a valid price';
  return null;
}
```

## Definition of Done
- [ ] Form page complete avec tous les champs
- [ ] Photo upload avec reordering (5-10 photos)
- [ ] Size guide affiche
- [ ] Brand autocomplete fonctionne
- [ ] CGVU check integre
- [ ] Stripe check integre
- [ ] Draft save fonctionne
- [ ] Publish flow complet
- [ ] Tests unitaires
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 8
**Complexite** : Haute
**Risque** : Moyen (UX complexe)

## Dependances
- S01 (marketplace_listings table)
- S02 (marketplace_photos table)
- S07 (storage bucket)
- S08 (CGVU seller)
- S10 (Stripe Connect)

## Stories Dependantes
- S15 (feed - listings apparaissent)
- S25 (mes ventes - gestion listings)
