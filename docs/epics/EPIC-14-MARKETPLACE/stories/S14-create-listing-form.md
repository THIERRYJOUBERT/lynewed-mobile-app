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

---

## Entity Definitions

### ListingEntity

```dart
/// Represents a marketplace listing for a wedding dress or shoes.
///
/// Immutable data class representing a listing created by a seller.
import 'package:flutter/foundation.dart';

@immutable
class ListingEntity {
  const ListingEntity({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.category,
    required this.priceCents,
    required this.size,
    required this.condition,
    required this.country,
    required this.status,
    this.description,
    this.designerBrand,
    this.sleeveLength,
    this.city,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.updatedAt,
    this.coverPhotoUrl,
  });

  /// Unique identifier (UUID from database).
  final String id;

  /// Seller ID (references profiles table).
  final String sellerId;

  /// Title of the listing (max 255 chars).
  final String title;

  /// Category: 'dress' or 'shoes'.
  final String category;

  /// Price in cents (e.g., 50000 = $500.00).
  final int priceCents;

  /// Size (dress: 'XS', 'S', 'M', 'L', 'XL'; shoes: '35', '36', etc.).
  final String size;

  /// Condition: 'new', 'excellent', 'good', 'fair'.
  final String condition;

  /// Country where the item is located.
  final String country;

  /// Status: 'draft', 'active', 'sold', 'cancelled'.
  final String status;

  /// Optional description (long text).
  final String? description;

  /// Optional designer brand name.
  final String? designerBrand;

  /// Optional sleeve length (dress only): 'long', '3-4', 'short', 'cap', 'sleeveless', 'strapless'.
  final String? sleeveLength;

  /// Optional city.
  final String? city;

  /// Optional latitude (for location-based filtering).
  final double? latitude;

  /// Optional longitude (for location-based filtering).
  final double? longitude;

  /// When the listing was created.
  final DateTime createdAt;

  /// When the listing was last updated (optional).
  final DateTime? updatedAt;

  /// Cover photo URL (first photo).
  final String? coverPhotoUrl;

  /// Formatted price with currency symbol.
  String get priceFormatted => '\$${(priceCents / 100).toStringAsFixed(2)}';

  /// Whether the listing is a dress.
  bool get isDress => category == 'dress';

  /// Whether the listing is shoes.
  bool get isShoes => category == 'shoes';

  /// Creates a ListingEntity from Supabase JSON row.
  factory ListingEntity.fromJson(Map<String, dynamic> json) {
    return ListingEntity(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      priceCents: json['price_cents'] as int,
      size: json['size'] as String,
      condition: json['condition'] as String,
      country: json['country'] as String,
      status: json['status'] as String,
      description: json['description'] as String?,
      designerBrand: json['designer_brand'] as String?,
      sleeveLength: json['sleeve_length'] as String?,
      city: json['city'] as String?,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      coverPhotoUrl: json['cover_photo_url'] as String?,
    );
  }

  /// Converts to JSON for database insert (excludes auto-generated fields).
  Map<String, dynamic> toJson() {
    return {
      'seller_id': sellerId,
      'title': title,
      'category': category,
      'price_cents': priceCents,
      'size': size,
      'condition': condition,
      'country': country,
      'status': status,
      if (description != null) 'description': description,
      if (designerBrand != null) 'designer_brand': designerBrand,
      if (sleeveLength != null) 'sleeve_length': sleeveLength,
      if (city != null) 'city': city,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  /// Creates a copy with updated fields.
  ListingEntity copyWith({
    String? id,
    String? sellerId,
    String? title,
    String? category,
    int? priceCents,
    String? size,
    String? condition,
    String? country,
    String? status,
    String? description,
    String? designerBrand,
    String? sleeveLength,
    String? city,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? coverPhotoUrl,
  }) {
    return ListingEntity(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      title: title ?? this.title,
      category: category ?? this.category,
      priceCents: priceCents ?? this.priceCents,
      size: size ?? this.size,
      condition: condition ?? this.condition,
      country: country ?? this.country,
      status: status ?? this.status,
      description: description ?? this.description,
      designerBrand: designerBrand ?? this.designerBrand,
      sleeveLength: sleeveLength ?? this.sleeveLength,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListingEntity &&
        other.id == id &&
        other.sellerId == sellerId &&
        other.title == title &&
        other.category == category &&
        other.priceCents == priceCents &&
        other.size == size &&
        other.condition == condition &&
        other.country == country &&
        other.status == status &&
        other.description == description &&
        other.designerBrand == designerBrand &&
        other.sleeveLength == sleeveLength &&
        other.city == city &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.coverPhotoUrl == coverPhotoUrl;
  }

  @override
  int get hashCode => Object.hash(
        id,
        sellerId,
        title,
        category,
        priceCents,
        size,
        condition,
        country,
        status,
        description,
        designerBrand,
        sleeveLength,
        city,
        latitude,
        longitude,
        createdAt,
        updatedAt,
        coverPhotoUrl,
      );

  @override
  String toString() => 'ListingEntity($id, $title, \$${priceFormatted})';
}
```

---

## Repository Interface

```dart
/// Repository interface for marketplace operations.
///
/// Provides methods to create, read, update, and delete marketplace listings.
abstract class MarketplaceRepository {
  /// Creates a new listing.
  ///
  /// Returns the created listing with generated ID.
  /// Throws if validation fails or seller is not authenticated.
  Future<ListingEntity> createListing({
    required String title,
    required String category,
    required int priceCents,
    required String size,
    required String condition,
    required String country,
    required String status,
    String? description,
    String? designerBrand,
    String? sleeveLength,
    String? city,
    double? latitude,
    double? longitude,
  });

  /// Updates an existing listing.
  ///
  /// Only the owner can update (enforced by RLS).
  /// Returns the updated listing with refreshed updated_at timestamp.
  Future<ListingEntity> updateListing({
    required String listingId,
    String? title,
    int? priceCents,
    String? size,
    String? condition,
    String? description,
    String? status,
  });

  /// Gets a listing by ID.
  ///
  /// Returns null if not found or not accessible.
  Future<ListingEntity?> getListingById(String listingId);

  /// Gets all listings for a seller.
  ///
  /// Returns listings ordered by creation date (newest first).
  Future<List<ListingEntity>> getMyListings();

  /// Uploads photos for a listing.
  ///
  /// Returns list of storage paths.
  /// Photos are compressed and uploaded to marketplace-listings/{listingId}/ bucket.
  /// Max 10 photos per listing.
  Future<List<String>> uploadListingPhotos({
    required String listingId,
    required List<File> photos,
  });

  /// Gets photo URLs for a listing.
  ///
  /// Returns ordered list of photo URLs (first is cover).
  Future<List<String>> getListingPhotoUrls(String listingId);
}
```

---

## Files to Create

```
CREATE:
- lib/features/marketplace/domain/entities/listing_entity.dart
- lib/features/marketplace/domain/repositories/marketplace_repository.dart
- lib/features/marketplace/data/repositories/supabase_marketplace_repository.dart
- lib/features/marketplace/data/brands_data.dart (predefined brand list)
- lib/features/marketplace/data/sizes_data.dart (size guide data)
- lib/features/marketplace/presentation/pages/create_listing_page.dart
- lib/features/marketplace/presentation/widgets/photo_upload_widget.dart
- lib/features/marketplace/presentation/widgets/listing_form_fields.dart
- lib/features/marketplace/presentation/widgets/size_selector_widget.dart
- lib/features/marketplace/presentation/widgets/brand_autocomplete_widget.dart
- lib/features/marketplace/presentation/widgets/condition_selector_widget.dart
- test/features/marketplace/domain/entities/listing_entity_test.dart
- test/features/marketplace/data/repositories/supabase_marketplace_repository_test.dart
- test/features/marketplace/presentation/pages/create_listing_page_test.dart

MODIFY:
- lib/core/di/injection_container.dart → add _initMarketplace()
- lib/core/navigation/routes.dart → add marketplace routes
- lib/flutter_flow/nav/nav.dart → add FFRoute entries
```

---

## DI Registration

```dart
// In injection_container.dart

/// Initializes marketplace feature dependencies.
Future<void> _initMarketplace() async {
  sl.registerLazySingleton<MarketplaceRepository>(
    () => SupabaseMarketplaceRepository(SupaFlow.client),
  );
}

// Call from initSupabaseDependencies():
Future<void> initSupabaseDependencies() async {
  await _initAuth();
  await _initReviews();
  await _initMarketplace(); // Add this
}
```

---

## Routes

```dart
// In routes.dart
/// Marketplace routes
static const String marketplace = '/marketplace';
static const String marketplaceFeed = '/marketplace/feed';
static const String createListing = '/marketplace/create';
static const String listingDetail = '/marketplace/listing';

// In nav.dart
FFRoute(
  name: 'CreateListing',
  path: '/marketplace/create',
  builder: (context, params) => const CreateListingPage(),
),
```

---

## Design System Usage

### Widgets
- **LynewedButton** (primary for "Publish", secondary for "Save Draft")
- **LynewedTextField** (title, description, price, city)
- **LynewedChip** (condition selector)
- **LynewedSheet** (size guide modal, CGVU modal)
- **LynewedSectionTitle** (section headers)
- **LynewedIconButton** (delete photo, reorder)

### Colors
- **LynewedColors.primary** (CTA buttons)
- **LynewedColors.textPrimary** (labels)
- **LynewedColors.textSecondary** (hints)
- **LynewedColors.gray200** (borders, dividers)
- **LynewedColors.error** (validation errors)

### Text Styles
- **LynewedTextStyles.sheetTitle** (page title)
- **LynewedTextStyles.titleSmall** (section titles)
- **LynewedTextStyles.bodyMedium** (form labels)
- **LynewedTextStyles.bodySmall** (hints, helper text)

### Spacing
- **LynewedSpacing.lg (24px)** between sections
- **LynewedSpacing.md (16px)** padding
- **LynewedSpacing.sm (8px)** between form fields

### Reference
- Copy **form pattern** from `lib/features/my_wedding/presentation/widgets/create_album_sheet.dart`
- Copy **photo upload pattern** from `lib/features/my_wedding/presentation/pages/album_detail_page.dart`

---

## Screen States

### Loading
- Show shimmer skeleton of form sections while checking CGVU/Stripe status.

### Draft Mode
- Form with "Save Draft" and "Publish" buttons at bottom.
- If editing existing draft, prefill fields.

### Publishing
- Show loading overlay with progress indicator.
- "Publishing your listing..." message.

### Error
- Show error banner at top of form with retry button.
- Field-level validation errors in red below each field.

---

## Technical Specifications

### Form Type
**Single scrollable form** with sections (simpler than multi-step):
1. Photos (5-10 required)
2. Basic Info (title, category, price)
3. Details (size, brand, condition, sleeve_length if dress)
4. Location (city, country)

### Photo Upload Specs
- **Quality**: 85% JPEG compression
- **Max dimension**: 1920x1920 pixels
- **Format**: JPEG only
- **Storage path**: `marketplace-listings/{listingId}/{timestamp}_{uuid}.jpg`
- **Progress**: Show per-photo upload progress

### Validation Rules

```dart
String? validateTitle(String? value) {
  if (value == null || value.isEmpty) return 'Title is required';
  if (value.length < 3) return 'Title must be at least 3 characters';
  if (value.length > 255) return 'Title must be less than 255 characters';
  return null;
}

String? validatePrice(String? value) {
  if (value == null || value.isEmpty) return 'Price is required';
  final price = double.tryParse(value);
  if (price == null || price <= 0) return 'Enter a valid price greater than 0';
  if (price >= 1000000) return 'Price must be less than $1,000,000';
  return null;
}

String? validateCategory(String? value) {
  if (value == null || value.isEmpty) return 'Category is required';
  if (value != 'dress' && value != 'shoes') return 'Invalid category';
  return null;
}

String? validateCondition(String? value) {
  if (value == null || value.isEmpty) return 'Condition is required';
  const validConditions = ['new', 'excellent', 'good', 'fair'];
  if (!validConditions.contains(value)) return 'Invalid condition';
  return null;
}

String? validateSize(String? value) {
  if (value == null || value.isEmpty) return 'Size is required';
  return null;
}

String? validateCountry(String? value) {
  if (value == null || value.isEmpty) return 'Country is required';
  return null;
}

String? validateSleeveLength(String? value, String category) {
  if (category == 'dress' && (value == null || value.isEmpty)) {
    return 'Sleeve length is required for dresses';
  }
  if (value != null && category == 'dress') {
    const validLengths = ['long', '3-4', 'short', 'cap', 'sleeveless', 'strapless'];
    if (!validLengths.contains(value)) return 'Invalid sleeve length';
  }
  return null;
}
```

### Brand Autocomplete
```dart
// lib/features/marketplace/data/brands_data.dart

const popularWeddingDressBrands = [
  'Vera Wang', 'Monique Lhuillier', 'Oscar de la Renta',
  'Carolina Herrera', 'Marchesa', 'Elie Saab', 'Zuhair Murad',
  'Pronovias', 'Rosa Clara', 'Maggie Sottero', 'Allure Bridals',
  'Mori Lee', 'Justin Alexander', 'Stella York', 'Essense of Australia',
  'David\'s Bridal', 'BHLDN', 'Delphine Manivet', 'Laure de Sagazan',
  'Other / Unknown',
];

const popularBridalShoeBrands = [
  'Jimmy Choo', 'Manolo Blahnik', 'Badgley Mischka', 'Bella Belle',
  'Rachel Simpson', 'Charlotte Mills', 'Emmy London', 'Freya Rose',
  'Stuart Weitzman', 'Louboutin', 'Aquazzura', 'Other / Unknown',
];
```

Allow custom entry if brand not in list.

### Size Guide Data
```dart
// lib/features/marketplace/data/sizes_data.dart

class SizeOption {
  const SizeOption({required this.value, required this.label});
  final String value;
  final String label;
}

const dressSizes = [
  SizeOption(value: 'XS', label: 'XS (EU 32-34 / US 0-2)'),
  SizeOption(value: 'S', label: 'S (EU 36-38 / US 4-6)'),
  SizeOption(value: 'M', label: 'M (EU 40-42 / US 8-10)'),
  SizeOption(value: 'L', label: 'L (EU 44-46 / US 12-14)'),
  SizeOption(value: 'XL', label: 'XL (EU 48-50 / US 16-18)'),
];

const shoeSizes = [
  SizeOption(value: '35', label: '35 (US 4 / UK 2.5)'),
  SizeOption(value: '36', label: '36 (US 5 / UK 3.5)'),
  SizeOption(value: '37', label: '37 (US 6 / UK 4.5)'),
  SizeOption(value: '38', label: '38 (US 7 / UK 5.5)'),
  SizeOption(value: '39', label: '39 (US 8 / UK 6.5)'),
  SizeOption(value: '40', label: '40 (US 9 / UK 7.5)'),
  SizeOption(value: '41', label: '41 (US 10 / UK 8.5)'),
  SizeOption(value: '42', label: '42 (US 11 / UK 9.5)'),
];
```

Size selector should show LynewedSheet modal with radio buttons and "Size Guide" button.

### Storage Path Convention
```
marketplace-listings/{listingId}/{timestamp}_{uuid}.jpg

Example:
marketplace-listings/550e8400-e29b-41d4-a716-446655440000/1706800000000_a1b2c3d4.jpg
```

### Draft Save
Save to Supabase with `status='draft'`. Draft can be edited later via "My Listings" page (S25).

### CGVU Integration
```dart
// Check if seller has accepted CGVU before publish
final hasAcceptedCgvu = await ref.read(cgvuRepositoryProvider)
  .hasAccepted(userId, 'marketplace_seller');

if (!hasAcceptedCgvu) {
  // Show CGVU modal from S08
  final accepted = await showCgvuModal(context, 'marketplace_seller');
  if (!accepted) return;
}
```

Import CGVU logic from S08 (reuse existing implementation).

### Stripe Check
```dart
// Check if seller has Stripe charges_enabled before publish
final stripeAccount = await ref.read(stripeRepositoryProvider)
  .getAccount(userId);

if (!stripeAccount.chargesEnabled) {
  // Show Stripe Connect onboarding prompt
  await showStripeSetupPrompt(context);
  return;
}
```

Verify via StripeRepository that seller can receive payments.

### Publish Flow

```dart
Future<void> _publishListing() async {
  // 1. Validate form
  if (!_formKey.currentState!.validate()) return;
  if (_photos.length < 5 || _photos.length > 10) {
    _showError('Please upload 5-10 photos');
    return;
  }

  setState(() => _isPublishing = true);

  try {
    // 2. Check CGVU
    final hasAcceptedCgvu = await _checkCgvu();
    if (!hasAcceptedCgvu) {
      setState(() => _isPublishing = false);
      return;
    }

    // 3. Check Stripe
    final stripeReady = await _checkStripe();
    if (!stripeReady) {
      setState(() => _isPublishing = false);
      return;
    }

    // 4. Upload photos (if not already uploaded)
    final photoUrls = await _uploadPhotos();

    // 5. Create listing with status = 'active'
    final listing = await ref.read(marketplaceRepositoryProvider).createListing(
      title: _titleController.text,
      category: _selectedCategory!,
      priceCents: (double.parse(_priceController.text) * 100).toInt(),
      size: _selectedSize!,
      condition: _selectedCondition!,
      country: _selectedCountry!,
      status: 'active',
      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      designerBrand: _selectedBrand,
      sleeveLength: _selectedCategory == 'dress' ? _selectedSleeveLength : null,
      city: _cityController.text.isNotEmpty ? _cityController.text : null,
    );

    // 6. Navigate to success/listing detail
    if (mounted) {
      context.pushNamed(AppRoutes.listingDetail, pathParameters: {'id': listing.id});
    }
  } catch (e) {
    _showError(e.toString());
  } finally {
    if (mounted) setState(() => _isPublishing = false);
  }
}
```

---

## Tests Requis

### Entity Tests
```dart
// test/features/marketplace/domain/entities/listing_entity_test.dart

- ListingEntity.fromJson parses all fields correctly
- ListingEntity.fromJson handles null optional fields
- ListingEntity.toJson excludes auto-generated fields (id, created_at, updated_at)
- ListingEntity.copyWith preserves unchanged fields
- ListingEntity equality (==, hashCode) works correctly
- ListingEntity.priceFormatted displays correct currency format
- ListingEntity.isDress returns true when category is 'dress'
- ListingEntity.isShoes returns true when category is 'shoes'
```

### Repository Tests
```dart
// test/features/marketplace/data/repositories/supabase_marketplace_repository_test.dart

- createListing inserts into database with correct fields
- createListing throws when title exceeds 255 chars
- createListing throws when price is negative
- updateListing updates only specified fields
- getListingById returns null when not found
- getMyListings returns only current user's listings
- uploadListingPhotos compresses images to max 1920x1920
- uploadListingPhotos uses correct storage path format
```

### Widget Tests
```dart
// test/features/marketplace/presentation/pages/create_listing_page_test.dart

- CreateListingPage renders form with all sections
- CreateListingPage shows error when < 5 photos
- CreateListingPage shows error when > 10 photos
- CreateListingPage requires sleeve_length when category is dress
- CreateListingPage does not require sleeve_length when category is shoes
- CreateListingPage shows CGVU modal when not accepted
- CreateListingPage shows Stripe prompt when not configured
- CreateListingPage saves draft when "Save Draft" clicked
- CreateListingPage publishes when "Publish" clicked and all validations pass
```

---

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
  // Single scrollable form (simpler than multi-step)
  // Section 1: Photos (required 5-10)
  // Section 2: Basic info (title, category, price)
  // Section 3: Details (size, brand, condition, sleeve_length)
  // Section 4: Location (city, country)
  // Bottom: "Save Draft" + "Publish" buttons
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
