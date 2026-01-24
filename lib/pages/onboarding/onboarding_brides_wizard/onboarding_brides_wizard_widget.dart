import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/enums/country_filter.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/permissions_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/core/design/design.dart';
import '/core/widgets/currency_dropdown.dart';
import '/core/widgets/distance_unit_dropdown.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'onboarding_brides_wizard_model.dart';
export 'onboarding_brides_wizard_model.dart';

/// Onboarding Brides Wizard - Refactored v2
/// 
/// Structure: 5 pages with uniform layout
/// - Page 1: Welcome (introduction)
/// - Page 2: Profile (avatar, name)
/// - Page 3: Preferences (country, currency, unit)
/// - Page 4: Location permission
/// - Page 5: Notifications permission + Finish
class OnboardingBridesWizardWidget extends StatefulWidget {
  const OnboardingBridesWizardWidget({super.key});

  static String routeName = 'OnboardingBridesWizard';
  static String routePath = '/onboardingBridesWizard';

  @override
  State<OnboardingBridesWizardWidget> createState() =>
      _OnboardingBridesWizardWidgetState();
}

class _OnboardingBridesWizardWidgetState
    extends State<OnboardingBridesWizardWidget> {
  late OnboardingBridesWizardModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Total pages for progress indicator
  static const int _totalPages = 5;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OnboardingBridesWizardModel());
    _model.firstNameTextController ??= TextEditingController();
    _model.firstNameFocusNode ??= FocusNode();
    _model.lastnameTextController ??= TextEditingController();
    _model.lastnameFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
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
        key: scaffoldKey,
        backgroundColor: LynewedColors.background,
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _model.pageViewController ??= PageController(initialPage: 0),
          children: [
            _buildWelcomePage(),
            _buildProfilePage(),
            _buildPreferencesPage(),
            _buildLocationPage(),
            _buildNotificationsPage(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PAGE 1: WELCOME
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
                  'LYNEWED',
                  style: LynewedTextStyles.sheetTitle.copyWith(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'THE WORLD WEDDING INDUSTRY\nIN YOUR POCKET',
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
                  'Discover the best wedding professionals worldwide and plan your perfect day.',
                  textAlign: TextAlign.center,
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha:0.9),
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
                  text: 'Get Started',
                  onPressed: () => _goToPage(1),
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
  // PAGE 2: PROFILE (Avatar + Name)
  // ============================================================
  Widget _buildProfilePage() {
    return Column(
      children: [
        // Header with image
        _buildImageHeader(
          imagePath: 'assets/images/25df1c17bbc96fe7af61b08e009c452b_2.png',
          pageNumber: 2,
        ),
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                // Title
                Text(
                  'LET\'S GET TO KNOW YOU',
                  style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add a photo and your name to personalize your profile.',
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: LynewedColors.gray100,
                  ),
                ),
                const SizedBox(height: 32),
                // Avatar picker
                Center(child: _buildAvatarPicker()),
                const SizedBox(height: 32),
                // First name
                _buildTextField(
                  controller: _model.firstNameTextController!,
                  focusNode: _model.firstNameFocusNode!,
                  label: 'First name*',
                ),
                const SizedBox(height: 16),
                // Last name
                _buildTextField(
                  controller: _model.lastnameTextController!,
                  focusNode: _model.lastnameFocusNode!,
                  label: 'Last name*',
                ),
                const SizedBox(height: 100), // Space for button
              ],
            ),
          ),
        ),
        // Fixed bottom button
        _buildBottomButton(
          text: 'Continue',
          onPressed: _validateAndContinueProfile,
        ),
      ],
    );
  }

  // ============================================================
  // PAGE 3: PREFERENCES (Country, Currency, Unit)
  // ============================================================
  Widget _buildPreferencesPage() {
    return Column(
      children: [
        // Header with image
        _buildImageHeader(
          imagePath: 'assets/images/25df1c17bbc96fe7af61b08e009c452b_2.png',
          pageNumber: 3,
        ),
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                // Title
                Text(
                  'PERSONALIZE YOUR EXPERIENCE',
                  style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  'Set your preferences to see relevant content.',
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: LynewedColors.gray100,
                  ),
                ),
                const SizedBox(height: 32),
                // Country
                Text(
                  'Country*',
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: LynewedColors.gray100,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                _buildCountrySelector(),
                const SizedBox(height: 24),
                // Currency & Unit row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Currency',
                            style: LynewedTextStyles.bodyMedium.copyWith(
                              color: LynewedColors.gray100,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CurrencyDropdown(
                            value: _model.dropDownCurrencyValue ??
                                (FFAppState().currentUserPreferences.currency.isNotEmpty 
                                    ? FFAppState().currentUserPreferences.currency 
                                    : 'USD'),
                            onChanged: (code) {
                              safeSetState(() {
                                _model.dropDownCurrencyValue = code;
                                // Auto-set coherent unit based on currency
                                _model.dropDownDistanceValue = 
                                    DistanceUnitData.getDefaultForCurrency(code);
                              });
                            },
                            compact: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Distance unit',
                            style: LynewedTextStyles.bodyMedium.copyWith(
                              color: LynewedColors.gray100,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DistanceUnitDropdown(
                            value: _model.dropDownDistanceValue ??
                                FFAppState().currentUserPreferences.distanceUnit.name,
                            onChanged: (code) => safeSetState(
                                () => _model.dropDownDistanceValue = code),
                            compact: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100), // Space for button
              ],
            ),
          ),
        ),
        // Fixed bottom button
        _buildBottomButton(
          text: 'Continue',
          onPressed: _validateAndSavePreferences,
        ),
      ],
    );
  }

  // ============================================================
  // PAGE 4: LOCATION PERMISSION
  // ============================================================
  Widget _buildLocationPage() {
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
                // Logo
                Text(
                  'LYNEWED',
                  style: LynewedTextStyles.sheetTitle.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                _buildProgressIndicator(4, onDark: true),
                const Spacer(),
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  'Find professionals near you',
                  textAlign: TextAlign.center,
                  style: LynewedTextStyles.sheetTitle.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 16),
                // Description
                Text(
                  'Enable location to discover the best wedding vendors in your area and get personalized recommendations.',
                  textAlign: TextAlign.center,
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha:0.9),
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const Spacer(),
                // Enable button
                _buildPrimaryButton(
                  text: 'Enable Location',
                  onPressed: () async {
                    await requestPermission(locationPermission);
                    _goToPage(4);
                  },
                  onDark: true,
                ),
                const SizedBox(height: 16),
                // Skip button
                TextButton(
                  onPressed: () => _goToPage(4),
                  child: Text(
                    'Skip for now',
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha:0.8),
                      decoration: TextDecoration.underline,
                    ),
                  ),
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
  // PAGE 5: NOTIFICATIONS PERMISSION + FINISH
  // ============================================================
  Widget _buildNotificationsPage() {
    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.asset(
            'assets/images/Group_5_(1).png',
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
                // Logo
                Text(
                  'LYNEWED',
                  style: LynewedTextStyles.sheetTitle.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                _buildProgressIndicator(5, onDark: true),
                const Spacer(),
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  'Never miss an update',
                  textAlign: TextAlign.center,
                  style: LynewedTextStyles.sheetTitle.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 16),
                // Description
                Text(
                  'Get notified when vendors respond to your requests, new features arrive, and important updates about your wedding planning.',
                  textAlign: TextAlign.center,
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha:0.9),
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const Spacer(),
                // Enable notifications button
                _buildPrimaryButton(
                  text: 'Enable Notifications',
                  onPressed: () async {
                    await requestPermission(notificationsPermission);
                    await _finishOnboarding();
                  },
                  onDark: true,
                ),
                const SizedBox(height: 24),
                // Skip - very subtle text link
                TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    'Maybe later',
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha:0.5),
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // REUSABLE COMPONENTS
  // ============================================================

  /// Image header for profile/preferences pages
  Widget _buildImageHeader({
    required String imagePath,
    required int pageNumber,
  }) {
    return Stack(
      children: [
        ClipRRect(
          child: Image.asset(
            imagePath,
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
                  'LYNEWED',
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

  /// Progress indicator (page X of Y)
  Widget _buildProgressIndicator(int currentPage, {bool onDark = false}) {
    final progress = currentPage / _totalPages;
    final bgColor = onDark ? Colors.white.withValues(alpha:0.3) : LynewedColors.gray200;
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

  /// Avatar picker widget
  Widget _buildAvatarPicker() {
    return GestureDetector(
      onTap: _pickAvatar,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: LynewedColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: LynewedColors.gray200, width: 2),
            ),
            child: ClipOval(
              child: _model.localAvatarPath != null && _model.localAvatarPath!.isNotEmpty
                  ? Image.file(
                      File(_model.localAvatarPath!),
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                    )
                  : Image.network(
                      FFAppState().selfPublicProfile.avatarUrl.isNotEmpty
                          ? FFAppState().selfPublicProfile.avatarUrl
                          : 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/lynewed-alpha-du4al1/assets/egport4rt4rg/person_15429777_1.png',
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                    ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: LynewedColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  /// Text field with underline style
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      style: LynewedTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: LynewedTextStyles.bodyMedium.copyWith(
          color: LynewedColors.gray100,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: LynewedColors.gray200),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: LynewedColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  /// Country selector
  Widget _buildCountrySelector() {
    final country = _model.selectedCountry;
    final hasSelection = !country.isWorld;

    return GestureDetector(
      onTap: _showCountryPicker,
      child: Container(
        width: double.infinity,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: LynewedColors.gray200),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Text(
              _getCountryFlag(country.code),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasSelection ? country.displayName : 'Select your country',
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: hasSelection ? LynewedColors.primary : LynewedColors.gray100,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: LynewedColors.gray100,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom button container (fixed position)
  Widget _buildBottomButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
      decoration: BoxDecoration(
        color: LynewedColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: LynewedButton(
          text: text,
          onPressed: onPressed,
          type: LynewedButtonType.primary,
          width: double.infinity,
        ),
      ),
    );
  }

  /// Primary button (for dark backgrounds)
  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    bool onDark = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: LynewedSpacing.buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: onDark ? Colors.white : LynewedColors.primary,
          foregroundColor: onDark ? LynewedColors.primary : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        child: Text(
          text,
          style: LynewedTextStyles.bodyMedium.copyWith(
            color: onDark ? LynewedColors.primary : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  /// Navigate to specific page
  void _goToPage(int pageIndex) {
    _model.pageViewController?.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Pick avatar image
  Future<void> _pickAvatar() async {
    await requestPermission(photoLibraryPermission);
    await requestPermission(cameraPermission);

    final pickedPath = await actions.pickLocalImage();
    if (pickedPath != null && pickedPath.isNotEmpty) {
      safeSetState(() {
        _model.localAvatarPath = pickedPath;
      });
    }
  }

  /// Get country flag emoji
  String _getCountryFlag(String countryCode) {
    if (countryCode.isEmpty) return '🌍';
    return countryCode.toUpperCase().codeUnits
        .map((c) => String.fromCharCode(c + 127397))
        .join();
  }

  /// Show country picker bottom sheet
  void _showCountryPicker() {
    final searchController = TextEditingController();
    List<CountryFilter> filteredCountries = CountryFilter.values.toList()
      ..remove(CountryFilter.world);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    // Handle
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: LynewedColors.gray200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Title
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Select your country',
                        style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 18),
                      ),
                    ),
                    // Search
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search country...',
                          hintStyle: LynewedTextStyles.bodyMedium.copyWith(
                            color: LynewedColors.gray100,
                          ),
                          prefixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          fillColor: LynewedColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: LynewedTextStyles.bodyMedium,
                        onChanged: (query) {
                          setSheetState(() {
                            if (query.isEmpty) {
                              filteredCountries = CountryFilter.values.toList()
                                ..remove(CountryFilter.world);
                            } else {
                              filteredCountries = CountryFilter.search(query, excludeIndia: false)
                                ..remove(CountryFilter.world);
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    // List
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: filteredCountries.length,
                        itemBuilder: (context, index) {
                          final country = filteredCountries[index];
                          final isSelected = country == _model.selectedCountry;
                          return InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              safeSetState(() {
                                _model.selectedCountry = country;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              color: isSelected ? LynewedColors.surface : null,
                              child: Row(
                                children: [
                                  Text(
                                    _getCountryFlag(country.code),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      country.displayName,
                                      style: LynewedTextStyles.bodyMedium.copyWith(
                                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check, size: 20),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  /// Validate profile page and continue
  Future<void> _validateAndContinueProfile() async {
    // Validate avatar
    if (_model.localAvatarPath == null || _model.localAvatarPath!.isEmpty) {
      _showError('Please select a profile photo');
      return;
    }

    // Validate first name
    if (_model.firstNameTextController!.text.trim().isEmpty) {
      _showError('Please enter your first name');
      return;
    }

    // Validate last name
    if (_model.lastnameTextController!.text.trim().isEmpty) {
      _showError('Please enter your last name');
      return;
    }

    _goToPage(2);
  }

  /// Validate preferences and save
  Future<void> _validateAndSavePreferences() async {
    // Validate country
    if (_model.selectedCountry.isWorld) {
      _showError('Please select your country');
      return;
    }

    // Upload avatar
    _model.publicAvatarUrl = await actions.uploadAvatar(_model.localAvatarPath!);
    
    if (!mounted) return;
    
    // Get device locale
    _model.deviceLocale = await actions.getDeviceLocale(context);

    // Update preferences in app state
    FFAppState().updateCurrentUserPreferencesStruct(
      (e) => e
        ..currency = _model.dropDownCurrencyValue ?? 'USD'
        ..distanceUnit = _model.dropDownDistanceValue == 'miles'
            ? DistanceUnit.miles
            : DistanceUnit.km
        ..defaultLocale = _model.deviceLocale
        ..defaultCountry = _model.selectedCountry.code
        ..mapToggles = LayerTogglesStruct(
          showPros: true,
          showProRecent: true,
          showFixedLocations: true,
          showBridePrivatePoi: true,
          showWeddingPins: true,
          showProAlerts: false,
          showSearchTarget: true,
          showOnlyMyProfessionPins: false,
        )
        ..lastFiltersJson = functions.generateDefaultFiltersJson(),
    );

    // Save to database
    _model.updatedPreferences = await actions.saveUserPreferences(
      FFAppState().currentUserPreferences,
      '',
    );

    final fullName = '${_model.firstNameTextController!.text.trim()} ${_model.lastnameTextController!.text.trim()}';
    _model.updatedProfile = await actions.saveProfileFields(
      fullName,
      _model.publicAvatarUrl,
      country: _model.selectedCountry.code,
    );

    // Update app state
    if (_model.updatedPreferences != null) {
      FFAppState().currentUserPreferences = _model.updatedPreferences!;
      FFAppState().userPrefsLastSyncedAt = getCurrentTimestamp;
    }
    if (_model.updatedProfile != null) {
      FFAppState().selfPublicProfile = _model.updatedProfile!;
    }

    safeSetState(() {});
    _goToPage(3);
  }

  /// Finish onboarding
  Future<void> _finishOnboarding() async {
    // Check and accept TOS
    _model.tosAlreadyAccepted = await actions.checkTosAccepted();
    if (_model.tosAlreadyAccepted == false) {
      _model.insertLegalAcceptanceSucces = await actions.insertLegalAcceptance();
    }

    if (mounted) {
      context.goNamed(HomeBridesWidget.routeName);
    }
  }

  /// Show error snackbar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: LynewedTextStyles.bodyMedium.copyWith(
            color: LynewedColors.primary,
          ),
        ),
        backgroundColor: LynewedColors.warning,
        duration: const Duration(seconds: 2),
      ),
    );
  }

}
