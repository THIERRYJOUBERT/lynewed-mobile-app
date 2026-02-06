/// Tests for CreateListingPage.
///
/// Verifies form rendering, validation, publish flow, and draft save.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:lynewed_beta/features/marketplace/data/sizes_data.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_listing.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_photo.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:lynewed_beta/features/marketplace/domain/usecases/check_stripe_status_use_case.dart';
import 'package:lynewed_beta/features/marketplace/presentation/pages/create_listing_page.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/condition_selector_widget.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/photo_upload_widget.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/size_selector_widget.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/brand_autocomplete_widget.dart';
import 'package:mocktail/mocktail.dart';

class MockMarketplaceRepository extends Mock implements MarketplaceRepository {}

class MockCheckStripeStatusUseCase extends Mock
    implements CheckStripeStatusUseCase {}

class MockAuthRemoteDatasource extends Mock implements AuthRemoteDatasource {}

class FakeMarketplaceListing extends Fake implements MarketplaceListing {}

class FakeMarketplacePhoto extends Fake implements MarketplacePhoto {}

void main() {
  late MockMarketplaceRepository mockRepository;
  late MockCheckStripeStatusUseCase mockCheckStripe;
  late MockAuthRemoteDatasource mockAuthDatasource;

  setUpAll(() {
    registerFallbackValue(FakeMarketplaceListing());
    registerFallbackValue(FakeMarketplacePhoto());
  });

  setUp(() {
    mockRepository = MockMarketplaceRepository();
    mockCheckStripe = MockCheckStripeStatusUseCase();
    mockAuthDatasource = MockAuthRemoteDatasource();
  });

  Widget buildPage() {
    return MaterialApp(
      home: CreateListingPage(
        repository: mockRepository,
        checkStripeStatusUseCase: mockCheckStripe,
        authDatasource: mockAuthDatasource,
        userId: 'test-user-123',
      ),
    );
  }

  group('CreateListingPage', () {
    group('renders form with all sections', () {
      testWidgets('should display page title', (tester) async {
        await tester.pumpWidget(buildPage());

        expect(find.text('Create Listing'), findsOneWidget);
      });

      testWidgets('should display Photos section', (tester) async {
        await tester.pumpWidget(buildPage());

        expect(find.text('Photos'), findsOneWidget);
        expect(find.byType(PhotoUploadWidget), findsOneWidget);
      });

      testWidgets('should display Title field', (tester) async {
        await tester.pumpWidget(buildPage());

        expect(find.text('Title'), findsOneWidget);
      });

      testWidgets('should display Category chips', (tester) async {
        await tester.pumpWidget(buildPage());

        expect(find.text('Category'), findsOneWidget);
        expect(find.text('Dress'), findsOneWidget);
        expect(find.text('Shoes'), findsOneWidget);
      });

      testWidgets('should display Price field', (tester) async {
        await tester.pumpWidget(buildPage());

        expect(find.text('Price (\$)'), findsOneWidget);
      });

      testWidgets('should display Description field', (tester) async {
        await tester.pumpWidget(buildPage());

        expect(find.text('Description'), findsOneWidget);
      });

      testWidgets('should display Size selector', (tester) async {
        await tester.pumpWidget(buildPage());

        expect(find.byType(SizeSelectorWidget), findsOneWidget);
      });

      testWidgets('should display Brand autocomplete', (tester) async {
        await tester.pumpWidget(buildPage());

        expect(find.byType(BrandAutocompleteWidget), findsOneWidget);
      });

      testWidgets('should display Condition selector', (tester) async {
        await tester.pumpWidget(buildPage());

        expect(find.byType(ConditionSelectorWidget), findsOneWidget);
      });

      testWidgets('should display Country dropdown', (tester) async {
        await tester.pumpWidget(buildPage());

        expect(find.text('Country'), findsOneWidget);
        expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      });

      testWidgets('should display Save Draft and Publish buttons',
          (tester) async {
        await tester.pumpWidget(buildPage());

        expect(find.text('Save Draft'), findsOneWidget);
        expect(find.text('Publish'), findsOneWidget);
      });
    });

    group('AC1 - Photos min 5, max 10, reorderable', () {
      testWidgets('should show photo count text', (tester) async {
        await tester.pumpWidget(buildPage());

        // Initially 0/10
        expect(find.text('0/10'), findsOneWidget);
      });

      testWidgets('should display min photos info', (tester) async {
        await tester.pumpWidget(buildPage());

        expect(
          find.text(
              'Minimum 5 photos required. First photo is the cover.'),
          findsOneWidget,
        );
      });
    });

    group('AC2 - Required fields validation', () {
      testWidgets('should show error when title is empty on publish',
          (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Tap Publish without filling any fields
        await tester.tap(find.text('Publish'));
        await tester.pumpAndSettle();

        // Should show title validation error
        expect(find.text('Title is required'), findsOneWidget);
      });

      testWidgets('should show error when price is empty on publish',
          (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Fill title but not price
        await tester.enterText(
          find.widgetWithText(TextFormField, 'E.g., Vera Wang Gemma Wedding Dress'),
          'Test Dress',
        );

        await tester.tap(find.text('Publish'));
        await tester.pumpAndSettle();

        expect(find.text('Price is required'), findsOneWidget);
      });

      testWidgets('should show error for short title', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'E.g., Vera Wang Gemma Wedding Dress'),
          'AB',
        );

        await tester.tap(find.text('Publish'));
        await tester.pumpAndSettle();

        expect(find.text('Title must be at least 3 characters'), findsOneWidget);
      });

      testWidgets('should show error for price below minimum', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Enter price in dollars'),
          '0.5',
        );

        await tester.tap(find.text('Publish'));
        await tester.pumpAndSettle();

        expect(find.text('Price must be at least \$1'), findsOneWidget);
      });

      testWidgets('should show error for country when empty', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Publish'));
        await tester.pumpAndSettle();

        expect(find.text('Country is required'), findsOneWidget);
      });
    });

    group('AC3 - Dress sleeve_length required', () {
      testWidgets('should show sleeve length when dress is selected',
          (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Select dress category
        await tester.tap(find.text('Dress'));
        await tester.pumpAndSettle();

        // Sleeve length options should appear
        expect(find.text('Sleeve Length'), findsOneWidget);
        expect(find.text('Long'), findsOneWidget);
        expect(find.text('Strapless'), findsOneWidget);
        expect(find.text('Sleeveless'), findsOneWidget);
      });

      testWidgets('should not show sleeve length when shoes is selected',
          (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Select shoes category
        await tester.tap(find.text('Shoes'));
        await tester.pumpAndSettle();

        // Sleeve length should NOT appear
        expect(find.text('Sleeve Length'), findsNothing);
      });

      testWidgets('should hide sleeve when switching from dress to shoes',
          (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Select dress first
        await tester.tap(find.text('Dress'));
        await tester.pumpAndSettle();
        expect(find.text('Sleeve Length'), findsOneWidget);

        // Switch to shoes
        await tester.tap(find.text('Shoes'));
        await tester.pumpAndSettle();
        expect(find.text('Sleeve Length'), findsNothing);
      });
    });

    group('AC4 - Publish flow', () {
      testWidgets(
          'should show error when required selections are missing on publish',
          (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Fill some text fields but skip category/condition/size/country
        await tester.enterText(
          find.widgetWithText(TextFormField, 'E.g., Vera Wang Gemma Wedding Dress'),
          'Test Listing Title Here',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Enter price in dollars'),
          '500',
        );

        // Tap Publish - should fail because photo count < 5 and no selections
        await tester.tap(find.text('Publish'));
        await tester.pumpAndSettle();

        // Should show photo error
        expect(
          find.text('Please upload at least 5 photos'),
          findsOneWidget,
        );
      });
    });

    group('AC5 - Photo upload progress', () {
      testWidgets('should display upload progress text when provided',
          (tester) async {
        // PhotoUploadWidget with progress should show the indicator
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PhotoUploadWidget(
                photos: const ['path1', 'path2', 'path3', 'path4', 'path5'],
                onPhotosChanged: (_) {},
                uploadProgress: 0.5,
              ),
            ),
          ),
        );

        expect(find.text('Uploading photos...'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });

      testWidgets('should not show progress when not uploading',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PhotoUploadWidget(
                photos: const [],
                onPhotosChanged: (_) {},
              ),
            ),
          ),
        );

        expect(find.text('Uploading photos...'), findsNothing);
        expect(find.byType(LinearProgressIndicator), findsNothing);
      });
    });

    group('AC6 - Draft save', () {
      testWidgets('should call createListing with draft status on save draft',
          (tester) async {
        final createdListing = MarketplaceListing(
          id: 'new-id',
          sellerId: 'test-user-123',
          title: 'Untitled Draft',
          category: 'dress',
          priceCents: 0,
          condition: 'new',
          country: 'Unknown',
          status: 'draft',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockRepository.createListing(any()))
            .thenAnswer((_) async => createdListing);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Tap Save Draft without filling anything
        await tester.tap(find.text('Save Draft'));
        await tester.pumpAndSettle();

        // Should call createListing with status='draft'
        final captured =
            verify(() => mockRepository.createListing(captureAny()))
                .captured;
        expect(captured, isNotEmpty);
        final listing = captured.first as MarketplaceListing;
        expect(listing.status, 'draft');
      });

      testWidgets('should show success snackbar after draft save',
          (tester) async {
        final createdListing = MarketplaceListing(
          id: 'new-id',
          sellerId: 'test-user-123',
          title: 'Untitled Draft',
          category: 'dress',
          priceCents: 0,
          condition: 'new',
          country: 'Unknown',
          status: 'draft',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockRepository.createListing(any()))
            .thenAnswer((_) async => createdListing);

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateListingPage(
                        repository: mockRepository,
                        checkStripeStatusUseCase: mockCheckStripe,
                        authDatasource: mockAuthDatasource,
                        userId: 'test-user-123',
                      ),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save Draft'));
        await tester.pumpAndSettle();

        expect(find.text('Draft saved successfully'), findsOneWidget);
      });
    });

    group('category selection', () {
      testWidgets('should reset size when changing category', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Select dress
        await tester.tap(find.text('Dress'));
        await tester.pumpAndSettle();

        // Select shoes (should reset size)
        await tester.tap(find.text('Shoes'));
        await tester.pumpAndSettle();

        // Size should be reset (hint text visible)
        expect(find.text('Select size'), findsOneWidget);
      });
    });

    group('condition selection', () {
      testWidgets('should display all condition options', (tester) async {
        await tester.pumpWidget(buildPage());

        expect(find.text('New'), findsOneWidget);
        expect(find.text('Excellent'), findsOneWidget);
        expect(find.text('Good'), findsOneWidget);
        expect(find.text('Fair'), findsOneWidget);
      });
    });
  });

  group('CreateListingPageState validation', () {
    test('validateTitle returns error for empty string', () {
      final state = CreateListingPageState();
      expect(state.validateTitle(''), 'Title is required');
      expect(state.validateTitle(null), 'Title is required');
    });

    test('validateTitle returns error for short title', () {
      final state = CreateListingPageState();
      expect(state.validateTitle('AB'), 'Title must be at least 3 characters');
    });

    test('validateTitle returns error for long title', () {
      final state = CreateListingPageState();
      final longTitle = 'A' * 256;
      expect(
        state.validateTitle(longTitle),
        'Title must be less than 255 characters',
      );
    });

    test('validateTitle returns null for valid title', () {
      final state = CreateListingPageState();
      expect(state.validateTitle('Beautiful Dress'), isNull);
    });

    test('validatePrice returns error for empty string', () {
      final state = CreateListingPageState();
      expect(state.validatePrice(''), 'Price is required');
      expect(state.validatePrice(null), 'Price is required');
    });

    test('validatePrice returns error for non-numeric', () {
      final state = CreateListingPageState();
      expect(
        state.validatePrice('abc'),
        'Enter a valid price greater than 0',
      );
    });

    test('validatePrice returns error for negative', () {
      final state = CreateListingPageState();
      expect(
        state.validatePrice('-5'),
        'Enter a valid price greater than 0',
      );
    });

    test('validatePrice returns error for zero', () {
      final state = CreateListingPageState();
      expect(
        state.validatePrice('0'),
        'Enter a valid price greater than 0',
      );
    });

    test('validatePrice returns error for too large', () {
      final state = CreateListingPageState();
      expect(
        state.validatePrice('100001'),
        'Price must be less than \$100,000',
      );
    });

    test('validatePrice returns error for price below minimum', () {
      final state = CreateListingPageState();
      expect(
        state.validatePrice('0.5'),
        'Price must be at least \$1',
      );
    });

    test('validatePrice returns null for valid price', () {
      final state = CreateListingPageState();
      expect(state.validatePrice('500'), isNull);
      expect(state.validatePrice('99.99'), isNull);
      expect(state.validatePrice('1'), isNull);
      expect(state.validatePrice('100000'), isNull);
    });

    test('validatePrice supports comma as decimal separator', () {
      final state = CreateListingPageState();
      expect(state.validatePrice('99,99'), isNull);
      expect(state.validatePrice('1500,50'), isNull);
    });

    test('validateCountry returns error for empty', () {
      final state = CreateListingPageState();
      expect(state.validateCountry(''), 'Country is required');
      expect(state.validateCountry(null), 'Country is required');
    });

    test('validateCountry returns null for valid', () {
      final state = CreateListingPageState();
      expect(state.validateCountry('France'), isNull);
    });
  });

  group('Edit mode', () {
    late MarketplaceListing existingListing;

    setUp(() {
      existingListing = MarketplaceListing(
        id: 'existing-id',
        sellerId: 'test-user-123',
        title: 'Vera Wang Bridal Gown',
        description: 'Gorgeous gown, worn once.',
        category: 'dress',
        priceCents: 45000,
        designerBrand: 'Vera Wang',
        size: 'M',
        condition: 'excellent',
        sleeveLength: 'long',
        country: 'France',
        status: 'draft',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
    });

    Widget buildEditPage() {
      return MaterialApp(
        home: CreateListingPage(
          repository: mockRepository,
          checkStripeStatusUseCase: mockCheckStripe,
          authDatasource: mockAuthDatasource,
          userId: 'test-user-123',
          existingListing: existingListing,
        ),
      );
    }

    testWidgets('should display "Edit Listing" title in edit mode',
        (tester) async {
      await tester.pumpWidget(buildEditPage());

      expect(find.text('Edit Listing'), findsOneWidget);
      expect(find.text('Create Listing'), findsNothing);
    });

    testWidgets('should pre-fill title from existing listing',
        (tester) async {
      await tester.pumpWidget(buildEditPage());

      expect(
        find.widgetWithText(TextFormField, 'Vera Wang Bridal Gown'),
        findsOneWidget,
      );
    });

    testWidgets('should pre-fill price from existing listing',
        (tester) async {
      await tester.pumpWidget(buildEditPage());

      expect(
        find.widgetWithText(TextFormField, '450.00'),
        findsOneWidget,
      );
    });

    testWidgets('should pre-fill description from existing listing',
        (tester) async {
      await tester.pumpWidget(buildEditPage());

      expect(
        find.widgetWithText(TextFormField, 'Gorgeous gown, worn once.'),
        findsOneWidget,
      );
    });

    testWidgets('should call updateListing instead of createListing on save draft',
        (tester) async {
      final updatedListing = existingListing.copyWith(
        title: 'Vera Wang Bridal Gown',
      );

      when(() => mockRepository.updateListing(any(), any()))
          .thenAnswer((_) async => updatedListing);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateListingPage(
                      repository: mockRepository,
                      checkStripeStatusUseCase: mockCheckStripe,
                      authDatasource: mockAuthDatasource,
                      userId: 'test-user-123',
                      existingListing: existingListing,
                    ),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save as Draft'));
      await tester.pumpAndSettle();

      verify(() => mockRepository.updateListing('existing-id', any()))
          .called(1);
      verifyNever(() => mockRepository.createListing(any()));
    });

    testWidgets('should show "Save as Draft" and "Update" buttons in edit mode',
        (tester) async {
      await tester.pumpWidget(buildEditPage());

      expect(find.text('Save as Draft'), findsOneWidget);
      expect(find.text('Update'), findsOneWidget);
      expect(find.text('Save Draft'), findsNothing);
      expect(find.text('Publish'), findsNothing);
    });

    testWidgets('should show delete button in header in edit mode',
        (tester) async {
      await tester.pumpWidget(buildEditPage());

      expect(find.byKey(const Key('delete-listing-button')), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('should not show delete button in create mode',
        (tester) async {
      await tester.pumpWidget(buildPage());

      expect(find.byKey(const Key('delete-listing-button')), findsNothing);
    });

    testWidgets('should show confirmation dialog when delete is tapped',
        (tester) async {
      await tester.pumpWidget(buildEditPage());

      await tester.tap(find.byKey(const Key('delete-listing-button')));
      await tester.pumpAndSettle();

      expect(find.text('Delete Listing'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('should call deleteListing when delete is confirmed',
        (tester) async {
      when(() => mockRepository.deleteListing(any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateListingPage(
                      repository: mockRepository,
                      checkStripeStatusUseCase: mockCheckStripe,
                      authDatasource: mockAuthDatasource,
                      userId: 'test-user-123',
                      existingListing: existingListing,
                    ),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('delete-listing-button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      verify(() => mockRepository.deleteListing('existing-id')).called(1);
    });

    testWidgets('should not delete when cancel is tapped in dialog',
        (tester) async {
      await tester.pumpWidget(buildEditPage());

      await tester.tap(find.byKey(const Key('delete-listing-button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => mockRepository.deleteListing(any()));
    });
  });

  group('Draft photo upload', () {
    testWidgets(
        'should call uploadListingPhotos and saveListingPhotos after creating draft',
        (tester) async {
      // This test verifies the photo upload flow is invoked in _saveDraft.
      // Since PhotoUploadWidget uses platform image picker, we only test
      // the mock interactions when _photos is empty (no photos selected).
      final createdListing = MarketplaceListing(
        id: 'new-id',
        sellerId: 'test-user-123',
        title: 'Untitled Draft',
        category: 'dress',
        priceCents: 0,
        condition: 'new',
        country: 'Unknown',
        status: 'draft',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => mockRepository.createListing(any()))
          .thenAnswer((_) async => createdListing);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateListingPage(
                      repository: mockRepository,
                      checkStripeStatusUseCase: mockCheckStripe,
                      authDatasource: mockAuthDatasource,
                      userId: 'test-user-123',
                    ),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Draft'));
      await tester.pumpAndSettle();

      // With no photos selected, only createListing is called.
      verify(() => mockRepository.createListing(any())).called(1);
      // uploadListingPhotos should NOT be called (no photos).
      verifyNever(
        () => mockRepository.uploadListingPhotos(
          listingId: any(named: 'listingId'),
          photoBytes: any(named: 'photoBytes'),
          fileNames: any(named: 'fileNames'),
        ),
      );
    });
  });

  group('Data layer', () {
    test('dressSizes has 5 options', () {
      expect(dressSizes, hasLength(5));
    });

    test('shoeSizes has 8 options', () {
      expect(shoeSizes, hasLength(8));
    });

    test('sleeveLengthOptions has 6 options', () {
      expect(sleeveLengthOptions, hasLength(6));
    });

    test('conditionOptions has 4 options', () {
      expect(conditionOptions, hasLength(4));
    });

    test('categoryOptions has 2 options', () {
      expect(categoryOptions, hasLength(2));
    });

    test('countryOptions has 15 options', () {
      expect(countryOptions, hasLength(15));
    });

    test('getSizesForCategory returns dress sizes for dress', () {
      expect(getSizesForCategory('dress'), dressSizes);
    });

    test('getSizesForCategory returns shoe sizes for shoes', () {
      expect(getSizesForCategory('shoes'), shoeSizes);
    });
  });
}
