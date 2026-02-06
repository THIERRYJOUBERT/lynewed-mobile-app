/// Create Listing Page - Main form for creating marketplace listings.
///
/// A single scrollable form with sections:
/// 1. Photos (5-10, reorderable, first = cover)
/// 2. Basic Info (title, category, price)
/// 3. Details (size, brand, condition, sleeve_length for dresses)
/// 4. Location (country)
/// Bottom: "Save Draft" + "Publish" buttons
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/core/design/design.dart';
import '/core/di/injection_container.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../data/sizes_data.dart';
import '../../domain/entities/marketplace_listing.dart';
import '../../domain/entities/marketplace_photo.dart';
import '../../domain/entities/shipping_address.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../../domain/usecases/check_stripe_status_use_case.dart';
import '../../domain/usecases/setup_stripe_connect_use_case.dart';
import 'stripe_setup_page.dart';
import '../widgets/address_form_widget.dart';
import '../widgets/brand_autocomplete_widget.dart';
import '../widgets/cgvu_seller_dialog.dart';
import '../widgets/condition_selector_widget.dart';
import '../widgets/photo_upload_widget.dart';
import '../widgets/size_selector_widget.dart';

/// Page for creating a new marketplace listing.
///
/// Implements a single scrollable form with photo upload, required fields,
/// and publish/draft save functionality.
///
/// Publish flow: Validate form -> Check CGVU -> Check Stripe -> Upload photos -> Create listing.
class CreateListingPage extends StatefulWidget {
  /// Creates the listing page.
  const CreateListingPage({
    super.key,
    this.userId,
    this.repository,
    this.checkStripeStatusUseCase,
    this.authDatasource,
    this.existingListing,
  });

  /// Route name for navigation.
  static const String routeName = 'CreateListing';

  /// Route path for navigation.
  static const String routePath = '/marketplace/create';

  /// Optional repository override for testing.
  final MarketplaceRepository? repository;

  /// Optional stripe status use case override for testing.
  final CheckStripeStatusUseCase? checkStripeStatusUseCase;

  /// Optional auth datasource override for testing.
  final AuthRemoteDatasource? authDatasource;

  /// The current authenticated user's ID. Falls back to [currentUserUid] if not provided.
  final String? userId;

  /// When set, the page operates in edit mode for this listing.
  final MarketplaceListing? existingListing;

  @override
  State<CreateListingPage> createState() => CreateListingPageState();
}

/// State for the create listing page.
///
/// Exposed as public for testing access to validation methods.
class CreateListingPageState extends State<CreateListingPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _brandController = TextEditingController();

  // Form state
  String? _selectedCountry;
  String? _selectedCategory;
  String? _selectedSize;
  String? _selectedCondition;
  String? _selectedSleeveLength;
  List<String> _photos = [];

  // UI state
  bool _isPublishing = false;
  bool _isSavingDraft = false;
  double? _uploadProgress;
  String? _errorMessage;
  String? _photoError;

  // Dependencies
  late final MarketplaceRepository _repository;
  late final CheckStripeStatusUseCase _checkStripeStatusUseCase;
  late final AuthRemoteDatasource _authDatasource;

  /// Whether we are editing an existing listing.
  bool get _isEditMode => widget.existingListing != null;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? sl<MarketplaceRepository>();
    _checkStripeStatusUseCase =
        widget.checkStripeStatusUseCase ?? sl<CheckStripeStatusUseCase>();
    _authDatasource = widget.authDatasource ?? sl<AuthRemoteDatasource>();

    if (widget.existingListing != null) {
      _populateFromListing(widget.existingListing!);
      _loadExistingPhotos(widget.existingListing!.id);
    }
  }

  void _populateFromListing(MarketplaceListing listing) {
    _titleController.text = listing.title;
    _descriptionController.text = listing.description ?? '';
    _priceController.text = listing.priceCents > 0
        ? (listing.priceCents / 100).toStringAsFixed(2)
        : '';
    _brandController.text = listing.designerBrand ?? '';
    _selectedCategory = listing.category;
    _selectedSize = listing.size;
    _selectedCondition = listing.condition;
    _selectedSleeveLength = listing.sleeveLength;
    _selectedCountry = listing.country;
  }

  Future<void> _loadExistingPhotos(String listingId) async {
    try {
      final urls = await _repository.getPhotoUrls(listingId);
      if (mounted && urls.isNotEmpty) {
        setState(() => _photos = urls);
      }
    } catch (_) {
      // Non-blocking: photos just won't be pre-loaded.
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  /// Validates the title field.
  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) return 'Title is required';
    if (value.trim().length < 3) return 'Title must be at least 3 characters';
    if (value.length > 255) return 'Title must be less than 255 characters';
    return null;
  }

  /// Validates the price field.
  String? validatePrice(String? value) {
    if (value == null || value.isEmpty) return 'Price is required';
    final normalized = value.replaceAll(',', '.');
    final price = double.tryParse(normalized);
    if (price == null || price <= 0) {
      return 'Enter a valid price greater than 0';
    }
    if (price < 1) return 'Price must be at least \$1';
    if (price > 100000) return 'Price must be less than \$100,000';
    return null;
  }

  /// Validates the country field.
  String? validateCountry(String? value) {
    if (value == null || value.trim().isEmpty) return 'Country is required';
    return null;
  }

  /// Validates the photo count.
  bool _validatePhotos() {
    if (_photos.length < 5) {
      setState(() => _photoError = 'Please upload at least 5 photos');
      return false;
    }
    if (_photos.length > 10) {
      setState(() => _photoError = 'Maximum 10 photos allowed');
      return false;
    }
    setState(() => _photoError = null);
    return true;
  }

  /// Validates all required selections (category, condition, size).
  bool _validateSelections() {
    bool valid = true;

    if (_selectedCategory == null) {
      valid = false;
    }
    if (_selectedCondition == null) {
      valid = false;
    }
    if (_selectedSize == null) {
      valid = false;
    }
    if (_selectedCategory == 'dress' && _selectedSleeveLength == null) {
      valid = false;
    }

    if (!valid) {
      setState(() {
        _errorMessage = 'Please fill in all required fields';
      });
    }
    return valid;
  }

  /// Saves the listing as a draft.
  Future<void> _saveDraft() async {
    if (_isSavingDraft || _isPublishing) return;

    // Allow saving draft with partial data
    setState(() {
      _isSavingDraft = true;
      _errorMessage = null;
    });

    try {
      final userId = widget.userId ?? currentUserUid;

      final listing = MarketplaceListing(
        id: '',
        sellerId: userId,
        title: _titleController.text.trim().isEmpty
            ? 'Untitled Draft'
            : _titleController.text.trim(),
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        category: _selectedCategory ?? 'dress',
        priceCents: _parsePriceCents(),
        designerBrand: _brandController.text.isNotEmpty
            ? _brandController.text
            : null,
        size: _selectedSize,
        condition: _selectedCondition ?? 'new',
        sleeveLength: _selectedCategory == 'dress'
            ? _selectedSleeveLength
            : null,
        country: _selectedCountry ?? 'Unknown',
        countryCode: countryCodeFromName(_selectedCountry),
        status: 'draft',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      String listingId;
      if (_isEditMode) {
        final updated = await _repository.updateListing(
          widget.existingListing!.id,
          listing.toJson(),
        );
        listingId = updated.id;
      } else {
        final created = await _repository.createListing(listing);
        listingId = created.id;
      }

      // Upload photos if any were selected.
      if (_photos.isNotEmpty) {
        await _uploadPhotos(listingId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Draft saved successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to save draft: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingDraft = false;
          _uploadProgress = null;
        });
      }
    }
  }

  int _parsePriceCents() {
    final normalized = _priceController.text.replaceAll(',', '.');
    final price = double.tryParse(normalized);
    if (price == null || price <= 0) return 0;
    return (price * 100).toInt();
  }

  /// Publishes the listing.
  ///
  /// Flow: Validate form -> Check CGVU -> Check Stripe -> Upload photos -> Create listing.
  Future<void> _publishListing() async {
    if (_isPublishing || _isSavingDraft) return;

    // 1. Validate form
    final formValid = _formKey.currentState?.validate() ?? false;
    final photosValid = _validatePhotos();
    final selectionsValid = _validateSelections();

    if (!formValid || !photosValid || !selectionsValid) return;

    setState(() {
      _isPublishing = true;
      _errorMessage = null;
    });

    try {
      // 2. Check CGVU
      final cgvuAccepted = await _checkCgvu();
      if (!cgvuAccepted) {
        setState(() => _isPublishing = false);
        return;
      }

      // 3. Check Stripe
      final stripeReady = await _checkStripe();
      if (!stripeReady) {
        setState(() => _isPublishing = false);
        return;
      }

      // 3b. Check shipping address
      final hasShippingAddress = await _checkShippingAddress();
      if (!hasShippingAddress) {
        setState(() => _isPublishing = false);
        return;
      }

      // 4. Create listing first (to get the ID)
      final userId = widget.userId ?? currentUserUid;
      final listing = MarketplaceListing(
        id: '',
        sellerId: userId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        category: _selectedCategory!,
        priceCents: _parsePriceCents(),
        designerBrand: _brandController.text.isNotEmpty
            ? _brandController.text
            : null,
        size: _selectedSize,
        condition: _selectedCondition!,
        sleeveLength:
            _selectedCategory == 'dress' ? _selectedSleeveLength : null,
        country: _selectedCountry!,
        countryCode: countryCodeFromName(_selectedCountry),
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      String listingId;
      if (_isEditMode) {
        final updated = await _repository.updateListing(
          widget.existingListing!.id,
          listing.toJson(),
        );
        listingId = updated.id;
      } else {
        final created = await _repository.createListing(listing);
        listingId = created.id;
      }

      // 5. Upload photos with progress
      if (_photos.isNotEmpty) {
        await _uploadPhotos(listingId);
      }

      // 6. Navigate back on success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing published successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to publish: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
          _uploadProgress = null;
        });
      }
    }
  }

  Future<bool> _checkCgvu() async {
    if (!mounted) return false;

    bool accepted = false;
    await showCgvuSellerDialog(
      context: context,
      onAccepted: () => accepted = true,
    );
    return accepted;
  }

  Future<bool> _checkStripe() async {
    final userId = widget.userId ?? currentUserUid;
    try {
      final isReady = await _checkStripeStatusUseCase(userId);
      if (!isReady && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Please set up your payment account before publishing.',
            ),
            action: SnackBarAction(
              label: 'Setup',
              textColor: LynewedColors.textOnDark,
              onPressed: () => _navigateToStripeSetup(userId),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
        return false;
      }
      return isReady;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not verify payment setup. Please try again.'),
          ),
        );
      }
      return false;
    }
  }

  /// Checks if the seller has a shipping address in their profile.
  ///
  /// If not, opens a bottom sheet to collect it. Returns true if the address
  /// exists or was just saved.
  Future<bool> _checkShippingAddress() async {
    final userId = widget.userId ?? currentUserUid;
    try {
      final profile = await _authDatasource.getProfile(userId);
      if (profile?.shippingAddress != null) return true;

      if (!mounted) return false;

      // Show bottom sheet to collect shipping address.
      final address = await _showShippingAddressSheet();
      if (address == null) return false;

      // Save to profile.
      await _authDatasource.updateProfile(userId, {
        'shipping_address': address.toJson(),
      });
      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Could not verify shipping address. Please try again.'),
          ),
        );
      }
      return false;
    }
  }

  /// Shows a bottom sheet to collect the seller's shipping address.
  Future<ShippingAddress?> _showShippingAddressSheet() async {
    ShippingAddress? result;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        ShippingAddress? currentAddress;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return LynewedSheet(
              title: 'Shipping Address',
              onClose: () => Navigator.pop(ctx),
              bottomAction: LynewedButton(
                text: 'Save Address',
                onPressed: currentAddress != null
                    ? () {
                        result = currentAddress;
                        Navigator.pop(ctx);
                      }
                    : null,
                width: double.infinity,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add your shipping address to sell on the marketplace. '
                      'This will be used for all your listings.',
                      style: LynewedTextStyles.bodySmall.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AddressFormWidget(
                      onAddressChanged: (addr) {
                        setSheetState(() => currentAddress = addr);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    return result;
  }

  Future<void> _confirmDeleteListing() async {
    if (!_isEditMode || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Listing'),
        content: const Text(
          'Are you sure you want to delete this listing? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(color: LynewedColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteListing();
    }
  }

  Future<void> _deleteListing() async {
    try {
      await _repository.deleteListing(widget.existingListing!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing deleted')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: ${e.toString()}')),
        );
      }
    }
  }

  void _navigateToStripeSetup(String userId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StripeSetupPage(
          userId: userId,
          email: currentUserEmail,
          setupUseCase: sl<SetupStripeConnectUseCase>(),
          checkStatusUseCase: _checkStripeStatusUseCase,
        ),
      ),
    );
  }

  Future<void> _uploadPhotos(String listingId) async {
    // Only upload new local photos (skip existing network URLs).
    final localPhotos =
        _photos.where((p) => !p.startsWith('http')).toList();
    if (localPhotos.isEmpty) return;

    final photoBytes = <Uint8List>[];
    final fileNames = <String>[];
    final uuid = const Uuid();

    for (var i = 0; i < localPhotos.length; i++) {
      setState(() {
        _uploadProgress = i / localPhotos.length;
      });

      final file = File(localPhotos[i]);
      final bytes = await file.readAsBytes();
      photoBytes.add(bytes);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${timestamp}_${uuid.v4().substring(0, 8)}.jpg';
      fileNames.add(fileName);
    }

    setState(() => _uploadProgress = 0.9);

    final storagePaths = await _repository.uploadListingPhotos(
      listingId: listingId,
      photoBytes: photoBytes,
      fileNames: fileNames,
    );

    // Save photo records. Position offset accounts for existing network photos.
    final existingCount =
        _photos.where((p) => p.startsWith('http')).length;
    final photos = storagePaths.asMap().entries.map((entry) {
      return MarketplacePhoto(
        id: '',
        listingId: listingId,
        storagePath: entry.value,
        position: existingCount + entry.key,
        createdAt: DateTime.now(),
      );
    }).toList();

    await _repository.saveListingPhotos(
      listingId: listingId,
      photos: photos,
    );

    setState(() => _uploadProgress = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildForm(),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      child: Row(
        children: [
          LynewedComponentStyles.backButton(context),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              _isEditMode ? 'Edit Listing' : 'Create Listing',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
          if (_isEditMode)
            IconButton(
              key: const Key('delete-listing-button'),
              icon: const Icon(Icons.delete_outline, color: LynewedColors.error),
              onPressed: _confirmDeleteListing,
              tooltip: 'Delete listing',
            ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: LynewedSpacing.sheetHorizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Error banner
              if (_errorMessage != null) ...[
                _buildErrorBanner(),
                const SizedBox(height: LynewedSpacing.lg),
              ],

              // Section 1: Photos
              PhotoUploadWidget(
                photos: _photos,
                onPhotosChanged: (photos) {
                  setState(() {
                    _photos = photos;
                    _photoError = null;
                  });
                },
                uploadProgress: _uploadProgress,
                errorText: _photoError,
              ),
              const SizedBox(height: LynewedSpacing.formSectionGap),

              // Section 2: Basic Info
              _buildBasicInfoSection(),
              const SizedBox(height: LynewedSpacing.formSectionGap),

              // Section 3: Details
              _buildDetailsSection(),
              const SizedBox(height: LynewedSpacing.formSectionGap),

              // Section 4: Location
              _buildLocationSection(),
              const SizedBox(height: LynewedSpacing.formSectionGap),

              // Bottom padding for scrolling
              const SizedBox(height: LynewedSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LynewedColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: LynewedColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: LynewedColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        LynewedTextField(
          controller: _titleController,
          label: 'Title',
          hint: 'E.g., Vera Wang Gemma Wedding Dress',
          maxLength: 255,
          validator: validateTitle,
        ),
        const SizedBox(height: LynewedSpacing.lg),

        // Category
        const LynewedSectionTitle('Category'),
        const SizedBox(height: LynewedSpacing.labelFieldGap),
        Wrap(
          spacing: LynewedSpacing.sm,
          children: categoryOptions.map((cat) {
            return LynewedChip(
              label: categoryLabels[cat] ?? cat,
              selected: _selectedCategory == cat,
              onSelected: (_) {
                setState(() {
                  _selectedCategory = cat;
                  _selectedSize = null;
                  _selectedSleeveLength = null;
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: LynewedSpacing.lg),

        // Price
        LynewedTextField(
          controller: _priceController,
          label: 'Price (\$)',
          hint: 'Enter price in dollars',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          validator: validatePrice,
        ),
        const SizedBox(height: LynewedSpacing.lg),

        // Description (optional)
        LynewedTextField(
          controller: _descriptionController,
          label: 'Description',
          hint: 'Describe your item (optional)',
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Size
        SizeSelectorWidget(
          category: _selectedCategory,
          selectedSize: _selectedSize,
          onSizeSelected: (size) {
            setState(() => _selectedSize = size);
          },
        ),
        const SizedBox(height: LynewedSpacing.lg),

        // Brand (optional)
        BrandAutocompleteWidget(
          category: _selectedCategory,
          controller: _brandController,
          onBrandSelected: (_) {},
        ),
        const SizedBox(height: LynewedSpacing.lg),

        // Condition
        ConditionSelectorWidget(
          selectedCondition: _selectedCondition,
          onConditionSelected: (condition) {
            setState(() => _selectedCondition = condition);
          },
        ),
        const SizedBox(height: LynewedSpacing.lg),

        // Sleeve length (dress only)
        if (_selectedCategory == 'dress') ...[
          const LynewedSectionTitle('Sleeve Length'),
          const SizedBox(height: LynewedSpacing.labelFieldGap),
          Wrap(
            spacing: LynewedSpacing.sm,
            runSpacing: LynewedSpacing.sm,
            children: sleeveLengthOptions.map((sleeve) {
              return LynewedChip(
                label: sleeveLengthLabels[sleeve] ?? sleeve,
                selected: _selectedSleeveLength == sleeve,
                onSelected: (_) {
                  setState(() => _selectedSleeveLength = sleeve);
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LynewedSectionTitle('Country'),
        const SizedBox(height: LynewedSpacing.labelFieldGap),
        DropdownButtonFormField<String>(
          value: _selectedCountry,
          decoration: InputDecoration(
            hintText: 'Select country',
            hintStyle: LynewedTextStyles.inputHint,
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(
                color: LynewedColors.textPrimary,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: LynewedColors.error),
            ),
          ),
          style: LynewedTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w300,
          ),
          items: countryOptions.map((c) {
            return DropdownMenuItem(value: c, child: Text(c));
          }).toList(),
          validator: validateCountry,
          onChanged: (country) {
            setState(() => _selectedCountry = country);
          },
        ),
        const SizedBox(height: LynewedSpacing.sm),
        Text(
          'This is the country from which you will ship the item.',
          style: LynewedTextStyles.bodySmall.copyWith(
            color: LynewedColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: LynewedColors.background,
        border: Border(
          top: BorderSide(color: LynewedColors.gray200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: LynewedButton(
              text: _isEditMode ? 'Save as Draft' : 'Save Draft',
              type: LynewedButtonType.secondary,
              onPressed: _isSavingDraft || _isPublishing ? null : _saveDraft,
              isLoading: _isSavingDraft,
            ),
          ),
          const SizedBox(width: LynewedSpacing.md),
          Expanded(
            child: LynewedButton(
              text: _isEditMode ? 'Update' : 'Publish',
              onPressed: _isPublishing || _isSavingDraft ? null : _publishListing,
              isLoading: _isPublishing,
            ),
          ),
        ],
      ),
    );
  }
}
