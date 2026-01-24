import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core/design/design.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/compo_finaux/address_search/address_search_widget.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/features/map/domain/entities/wedding_details.dart' show WeddingVisibility;
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/repositories/my_wedding_repository.dart';

/// Wedding Onboarding Page - 9-step wizard for creating a wedding
///
/// Steps:
/// 1. Welcome - Introduction
/// 2. Date - Wedding date (required)
/// 3. Location - Venue location (required)
/// 4. Professionals - Which pros are needed (optional, skippable)
/// 5. Guest Count - Estimated guests (optional, skippable)
/// 6. Budget - Budget range (optional, skippable)
/// 7. Visibility - Map visibility (optional, skippable)
/// 8. Features Preview - Marketing screen
/// 9. Done - Celebration
class WeddingOnboardingPage extends StatefulWidget {
  const WeddingOnboardingPage({
    super.key,
    this.resumeAtStep,
    this.weddingId,
  });

  /// Step to resume at (if resuming incomplete onboarding)
  final int? resumeAtStep;

  /// Wedding ID (if resuming)
  final String? weddingId;

  static const String routeName = 'weddingOnboarding';
  static const String routePath = '/weddingOnboarding';

  @override
  State<WeddingOnboardingPage> createState() => _WeddingOnboardingPageState();
}

class _WeddingOnboardingPageState extends State<WeddingOnboardingPage> {
  late PageController _pageController;
  late MyWeddingRepository _repository;

  // Total pages
  static const int _totalPages = 9;

  // Current page (1-indexed for display) - used by progress indicator
  // ignore: unused_field
  int _currentPage = 1;

  // Wedding ID (set after step 2)
  String? _weddingId;

  // Loading state
  bool _isLoading = false;

  // Form data
  DateTime? _eventDate;
  String? _venueName;
  String? _venueAddress;
  double? _lat;
  double? _lng;
  String? _countryCode;
  final List<String> _professionsNeeded = [];
  int? _guestCount;
  // ignore: unused_field
  double? _budgetMin;
  double? _budgetMax;
  WeddingVisibility _visibility = WeddingVisibility.private;

  // Guest count options
  final List<int> _guestCountOptions = [50, 100, 150, 200, 300, 500];

  // Budget options (in EUR)
  final List<int> _budgetOptions = [10000, 25000, 50000, 100000, 200000];

  @override
  void initState() {
    super.initState();
    _repository = MyWeddingRepositoryImpl();
    _weddingId = widget.weddingId;

    final initialPage = (widget.resumeAtStep ?? 1) - 1;
    _currentPage = widget.resumeAtStep ?? 1;
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: LynewedColors.background,
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentPage = index + 1);
          },
          children: [
            _buildWelcomePage(),      // Step 1
            _buildDatePage(),         // Step 2
            _buildLocationPage(),     // Step 3
            _buildProfessionalsPage(), // Step 4
            _buildGuestCountPage(),   // Step 5
            _buildBudgetPage(),       // Step 6
            _buildVisibilityPage(),   // Step 7
            _buildFeaturesPreviewPage(), // Step 8
            _buildDonePage(),         // Step 9
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STEP 1: WELCOME
  // ============================================================
  Widget _buildWelcomePage() {
    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.asset(
            'assets/images/DSC_0004-2_(1).png',
            fit: BoxFit.cover,
          ),
        ),
        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 1),
                // Logo & Title
                Text(
                  'MY WEDDING',
                  style: LynewedTextStyles.sheetTitle.copyWith(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'YOUR WEDDING PLANNING\nHEADQUARTERS',
                  textAlign: TextAlign.center,
                  style: LynewedTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(flex: 2),
                // Description
                Text(
                  'Let\'s set up your wedding space. You\'ll be able to manage your team, budget, and inspiration all in one place.',
                  textAlign: TextAlign.center,
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 40),
                // Progress indicator
                _buildProgressIndicator(1, onDark: true),
                const SizedBox(height: 32),
                // Button
                _buildPrimaryButton(
                  text: 'Let\'s Start',
                  onPressed: () => _goToPage(2),
                  onDark: true,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STEP 2: DATE (Required)
  // ============================================================
  Widget _buildDatePage() {
    return Column(
      children: [
        // Header with image
        _buildImageHeader(pageNumber: 2),
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Text(
                  'WHEN IS YOUR WEDDING?',
                  style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  'You can modify this later if needed.',
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: LynewedColors.gray100,
                  ),
                ),
                const SizedBox(height: 32),
                // Date picker
                _buildDateInput(
                  date: _eventDate,
                  placeholder: 'Select your wedding date',
                  onTap: _selectDate,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        // Bottom buttons
        _buildBottomButtons(
          showBack: true,
          canContinue: _eventDate != null,
          onBack: () => _goToPage(1),
          onContinue: _saveStep2AndContinue,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? now.add(const Duration(days: 180)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: LynewedColors.primary,
              onPrimary: Colors.white,
              surface: LynewedColors.background,
              onSurface: LynewedColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _eventDate = picked);
    }
  }

  Future<void> _saveStep2AndContinue() async {
    if (_eventDate == null) return;

    // If we don't have location yet, just go to next page
    // Wedding will be created at step 3 when we have both date and location
    _goToPage(3);
  }

  // ============================================================
  // STEP 3: LOCATION (Required)
  // ============================================================
  Widget _buildLocationPage() {
    return Column(
      children: [
        _buildImageHeader(pageNumber: 3),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Text(
                  'WHERE IS YOUR WEDDING?',
                  style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  'You can modify this later if needed.',
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: LynewedColors.gray100,
                  ),
                ),
                const SizedBox(height: 32),
                // Address search
                AddressSearchWidget(
                  initialValue: _venueAddress,
                  onAddressSelected: (PlaceDetailsDataStruct details) {
                    setState(() {
                      _venueAddress = details.formattedAddress;
                      _venueName = details.city.isNotEmpty ? details.city : null;
                      _lat = details.coords?.latitude;
                      _lng = details.coords?.longitude;
                      _countryCode = details.countryCode.isNotEmpty ? details.countryCode : null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Location status
                if (_lat != null && _lng != null)
                  _buildLocationStatus(true)
                else if (_venueAddress != null && _venueAddress!.isNotEmpty)
                  _buildLocationStatus(false),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        _buildBottomButtons(
          showBack: true,
          canContinue: _lat != null && _lng != null,
          onBack: () => _goToPage(2),
          onContinue: _saveStep3AndContinue,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Future<void> _saveStep3AndContinue() async {
    if (_eventDate == null || _lat == null || _lng == null) return;

    setState(() => _isLoading = true);

    try {
      if (_weddingId == null) {
        // Create wedding
        final result = await _repository.createWedding(
          eventDate: _eventDate!,
          lat: _lat!,
          lng: _lng!,
          venueName: _venueName,
          venueAddress: _venueAddress,
          countryCode: _countryCode,
        );

        if (result.isSuccess && result.data != null) {
          _weddingId = result.data;
        } else {
          _showError(result.error ?? 'Failed to create wedding');
          return;
        }
      } else {
        // Update existing wedding
        final result = await _repository.updateOnboardingData(
          weddingId: _weddingId!,
          data: OnboardingData(
            eventDate: _eventDate,
            venueName: _venueName,
            venueAddress: _venueAddress,
            lat: _lat,
            lng: _lng,
            countryCode: _countryCode,
            onboardingStep: 3,
          ),
        );

        if (result.isFailure) {
          _showError(result.error ?? 'Failed to update wedding');
          return;
        }
      }

      _goToPage(4);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ============================================================
  // STEP 4: PROFESSIONALS (Optional)
  // ============================================================
  Widget _buildProfessionalsPage() {
    final professions = Profession.values
        .where((p) => p != Profession.OTHER)
        .toList();

    return Column(
      children: [
        _buildImageHeader(pageNumber: 4),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Text(
                  'WHICH PROFESSIONALS DO YOU NEED?',
                  style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select all that apply. You can skip this step.',
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: LynewedColors.gray100,
                  ),
                ),
                const SizedBox(height: 24),
                if (_professionsNeeded.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      '${_professionsNeeded.length} selected',
                      style: LynewedTextStyles.labelSmall.copyWith(
                        color: LynewedColors.textSecondary,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: professions.map((profession) {
                    final isSelected = _professionsNeeded.contains(profession.name);
                    return LynewedChip(
                      label: profession.name.toLowerCase().replaceAll('_', ' '),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _professionsNeeded.add(profession.name);
                          } else {
                            _professionsNeeded.remove(profession.name);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        _buildBottomButtons(
          showBack: true,
          showSkip: true,
          canContinue: true,
          onBack: () => _goToPage(3),
          onSkip: () => _saveStepAndContinue(4, null),
          onContinue: () => _saveStepAndContinue(4, OnboardingData(
            professionsNeeded: _professionsNeeded,
            onboardingStep: 4,
          )),
          isLoading: _isLoading,
        ),
      ],
    );
  }

  // ============================================================
  // STEP 5: GUEST COUNT (Optional)
  // ============================================================
  Widget _buildGuestCountPage() {
    return Column(
      children: [
        _buildImageHeader(pageNumber: 5),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Text(
                  'HOW MANY GUESTS?',
                  style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  'An estimate helps professionals prepare. You can skip this.',
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: LynewedColors.gray100,
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _guestCountOptions.map((count) {
                    final isSelected = _guestCount == count;
                    return _buildOptionChip(
                      label: count == 500 ? '500+' : '$count',
                      isSelected: isSelected,
                      onTap: () => setState(() => _guestCount = count),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        _buildBottomButtons(
          showBack: true,
          showSkip: true,
          canContinue: true,
          onBack: () => _goToPage(4),
          onSkip: () => _saveStepAndContinue(5, null),
          onContinue: () => _saveStepAndContinue(5, OnboardingData(
            guestCount: _guestCount,
            onboardingStep: 5,
          )),
          isLoading: _isLoading,
        ),
      ],
    );
  }

  // ============================================================
  // STEP 6: BUDGET (Optional)
  // ============================================================
  Widget _buildBudgetPage() {
    return Column(
      children: [
        _buildImageHeader(pageNumber: 6),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Text(
                  'WHAT\'S YOUR BUDGET?',
                  style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  'This helps you track expenses. You can skip this.',
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: LynewedColors.gray100,
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _budgetOptions.map((budget) {
                    final isSelected = _budgetMax == budget.toDouble();
                    final label = budget >= 1000
                        ? '€${(budget / 1000).toStringAsFixed(0)}k'
                        : '€$budget';
                    return _buildOptionChip(
                      label: budget == 200000 ? '€200k+' : label,
                      isSelected: isSelected,
                      onTap: () => setState(() => _budgetMax = budget.toDouble()),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        _buildBottomButtons(
          showBack: true,
          showSkip: true,
          canContinue: true,
          onBack: () => _goToPage(5),
          onSkip: () => _saveStepAndContinue(6, null),
          onContinue: () => _saveStepAndContinue(6, OnboardingData(
            budgetMax: _budgetMax,
            onboardingStep: 6,
          )),
          isLoading: _isLoading,
        ),
      ],
    );
  }

  // ============================================================
  // STEP 7: VISIBILITY (Optional)
  // ============================================================
  Widget _buildVisibilityPage() {
    return Column(
      children: [
        _buildImageHeader(pageNumber: 7),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Text(
                  'VISIBILITY ON MAP',
                  style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose if professionals can see your wedding on the map.',
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: LynewedColors.gray100,
                  ),
                ),
                const SizedBox(height: 32),
                _buildVisibilityOption(
                  WeddingVisibility.private,
                  Icons.lock_outline,
                  'Private',
                  'Only you can see',
                ),
                const SizedBox(height: 12),
                _buildVisibilityOption(
                  WeddingVisibility.visibleToPros,
                  Icons.visibility_outlined,
                  'Visible to Pros',
                  'Professionals can see your wedding',
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        _buildBottomButtons(
          showBack: true,
          showSkip: true,
          canContinue: true,
          onBack: () => _goToPage(6),
          onSkip: () => _saveStepAndContinue(7, null),
          onContinue: () => _saveStepAndContinue(7, OnboardingData(
            visibility: _visibility.name,
            onboardingStep: 7,
          )),
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildVisibilityOption(
    WeddingVisibility value,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final isSelected = _visibility == value;
    return InkWell(
      onTap: () => setState(() => _visibility = value),
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.black : LynewedColors.gray200,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : LynewedColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.black : LynewedColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: LynewedTextStyles.labelSmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: Colors.black, size: 20),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STEP 8: FEATURES PREVIEW (Marketing)
  // ============================================================
  Widget _buildFeaturesPreviewPage() {
    return Column(
      children: [
        _buildImageHeader(pageNumber: 8),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Text(
                  'PLAN LIKE A PRO',
                  style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  'Everything you need to organize your perfect day.',
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: LynewedColors.gray100,
                  ),
                ),
                const SizedBox(height: 32),
                _buildFeatureItem(
                  Icons.calendar_today_outlined,
                  'Agenda',
                  'Add your appointments and tasks',
                ),
                const SizedBox(height: 20),
                _buildFeatureItem(
                  Icons.note_outlined,
                  'Notes for Pros',
                  'Share important info with your team',
                ),
                const SizedBox(height: 20),
                _buildFeatureItem(
                  Icons.account_balance_wallet_outlined,
                  'Budget Tracker',
                  'Track your expenses at a glance',
                ),
                const SizedBox(height: 20),
                _buildFeatureItem(
                  Icons.photo_library_outlined,
                  'Inspiration Albums',
                  'Create moodboards from the feed',
                ),
                const SizedBox(height: 20),
                _buildFeatureItem(
                  Icons.chat_bubble_outline,
                  'Team Chat',
                  'Communicate with all your pros',
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        _buildBottomButtons(
          showBack: true,
          canContinue: true,
          onBack: () => _goToPage(7),
          onContinue: () => _saveStepAndContinue(8, const OnboardingData(onboardingStep: 8)),
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: LynewedColors.surface,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, color: LynewedColors.textPrimary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: LynewedTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: LynewedTextStyles.labelSmall.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STEP 9: DONE
  // ============================================================
  Widget _buildDonePage() {
    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.asset(
            'assets/images/Group_5.png',
            fit: BoxFit.cover,
          ),
        ),
        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  'LYNEWED',
                  style: LynewedTextStyles.sheetTitle.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                _buildProgressIndicator(9, onDark: true),
                const Spacer(),
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'You\'re all set!',
                  textAlign: TextAlign.center,
                  style: LynewedTextStyles.sheetTitle.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your wedding space is ready. Start adding your team and planning your perfect day!',
                  textAlign: TextAlign.center,
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const Spacer(),
                _buildPrimaryButton(
                  text: 'Start Planning',
                  onPressed: _completeOnboarding,
                  onDark: true,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _completeOnboarding() async {
    if (_weddingId == null) return;

    setState(() => _isLoading = true);

    try {
      final result = await _repository.completeOnboarding(weddingId: _weddingId!);

      if (result.isSuccess) {
        if (mounted) {
          Navigator.of(context).pop(true); // Return success
        }
      } else {
        _showError(result.error ?? 'Failed to complete onboarding');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  Future<void> _saveStepAndContinue(int step, OnboardingData? data) async {
    if (_weddingId == null) {
      _goToPage(step + 1);
      return;
    }

    if (data != null) {
      setState(() => _isLoading = true);

      try {
        final result = await _repository.updateOnboardingData(
          weddingId: _weddingId!,
          data: data,
        );

        if (result.isFailure) {
          _showError(result.error ?? 'Failed to save data');
          return;
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }

    _goToPage(step + 1);
  }

  void _goToPage(int pageNumber) {
    _pageController.animateToPage(
      pageNumber - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white)),
        backgroundColor: LynewedColors.error,
      ),
    );
  }

  // ============================================================
  // REUSABLE WIDGETS
  // ============================================================

  Widget _buildImageHeader({required int pageNumber}) {
    return Stack(
      children: [
        ClipRRect(
          child: Image.asset(
            'assets/images/25df1c17bbc96fe7af61b08e009c452b_2.png',
            width: double.infinity,
            height: 170,
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(
            padding: const EdgeInsets.fromLTRB(32, 60, 32, 0),
            child: Column(
              children: [
                Text(
                  'MY WEDDING',
                  style: LynewedTextStyles.sheetTitle.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                _buildProgressIndicator(pageNumber, onDark: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(int currentPage, {bool onDark = false}) {
    final progress = currentPage / _totalPages;
    final bgColor = onDark ? Colors.white.withValues(alpha: 0.3) : LynewedColors.gray200;
    final fgColor = onDark ? Colors.white : LynewedColors.primary;
    final textColor = onDark ? Colors.white : LynewedColors.primary;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: onDark ? const Color(0xCD141414) : LynewedColors.surface,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$currentPage / $_totalPages',
            style: LynewedTextStyles.bodySmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: bgColor,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateInput({
    required DateTime? date,
    required String placeholder,
    required VoidCallback? onTap,
  }) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: LynewedColors.gray200),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: date != null
                  ? LynewedColors.textPrimary
                  : LynewedColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              date != null ? dateFormat.format(date) : placeholder,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: date != null
                    ? LynewedColors.textPrimary
                    : LynewedColors.textSecondary,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStatus(bool hasCoordinates) {
    return Row(
      children: [
        Icon(
          hasCoordinates ? Icons.check_circle : Icons.warning_amber_rounded,
          size: 16,
          color: hasCoordinates ? LynewedColors.success : LynewedColors.warning,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            hasCoordinates
                ? 'Location confirmed'
                : 'Please select an address from suggestions',
            style: LynewedTextStyles.labelSmall.copyWith(
              color: hasCoordinates ? LynewedColors.success : LynewedColors.warning,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? LynewedColors.primary : LynewedColors.surface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: LynewedTextStyles.bodyMedium.copyWith(
            color: isSelected ? Colors.white : LynewedColors.textPrimary,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    bool onDark = false,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: LynewedSpacing.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: onDark ? Colors.white : LynewedColors.primary,
          foregroundColor: onDark ? LynewedColors.primary : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    onDark ? LynewedColors.primary : Colors.white,
                  ),
                ),
              )
            : Text(
                text,
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: onDark ? LynewedColors.primary : Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
      ),
    );
  }

  Widget _buildBottomButtons({
    required bool showBack,
    bool showSkip = false,
    required bool canContinue,
    VoidCallback? onBack,
    VoidCallback? onSkip,
    VoidCallback? onContinue,
    bool isLoading = false,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
      decoration: BoxDecoration(
        color: LynewedColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (showBack)
                  Expanded(
                    child: LynewedButton(
                      text: 'Back',
                      onPressed: onBack ?? () {},
                      type: LynewedButtonType.secondary,
                    ),
                  ),
                if (showBack) const SizedBox(width: 12),
                Expanded(
                  flex: showBack ? 2 : 1,
                  child: LynewedButton(
                    text: 'Continue',
                    onPressed: canContinue && !isLoading ? onContinue : null,
                    isLoading: isLoading,
                  ),
                ),
              ],
            ),
            if (showSkip)
              TextButton(
                onPressed: isLoading ? null : onSkip,
                child: Text(
                  'Skip for now',
                  style: LynewedTextStyles.bodySmall.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
