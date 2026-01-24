import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/core/design/design.dart';
import '/core/design/widgets/lynewed_slider.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/compo_finaux/address_search/address_search_widget.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/features/map/domain/entities/wedding_details.dart' show WeddingVisibility;
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/repositories/my_wedding_repository.dart';

/// Wedding Onboarding Widget - In-page wizard for creating a wedding
/// 
/// This widget is displayed INSIDE MyWeddingPage with navbar visible.
/// Different from register onboarding - this is a form-style wizard.
/// 
/// Steps:
/// 1. Date - Wedding date (required)
/// 2. Location - Venue location (required)  
/// 3. Professionals - Which pros are needed (optional)
/// 4. Guest Count - Estimated guests (optional)
/// 5. Budget - Budget range (optional)
/// 6. Visibility - Map visibility (optional)
/// 7. Done - Confirmation
class WeddingOnboardingWidget extends StatefulWidget {
  const WeddingOnboardingWidget({
    super.key,
    this.resumeAtStep,
    this.weddingId,
    required this.onComplete,
  });

  final int? resumeAtStep;
  final String? weddingId;
  final VoidCallback onComplete;

  @override
  State<WeddingOnboardingWidget> createState() => _WeddingOnboardingWidgetState();
}

class _WeddingOnboardingWidgetState extends State<WeddingOnboardingWidget> {
  late MyWeddingRepository _repository;

  // Total steps (reduced from 9 to 7 - more focused)
  static const int _totalSteps = 7;

  // Current step (1-indexed)
  int _currentStep = 1;

  // Wedding ID (set after step 2)
  String? _weddingId;

  // Loading state
  bool _isLoading = false;

  // Form data
  DateTime? _eventDate;
  String? _venueAddress;
  double? _lat;
  double? _lng;
  String? _countryCode;
  final List<String> _professionsNeeded = [];
  int? _guestCount;
  int? _budgetMin;
  int? _budgetMax;
  WeddingVisibility _visibility = WeddingVisibility.private;
  int _searchRadius = 50; // km, only used when visible_to_pros
  bool _useSearchRadius = false; // checkbox for search radius
  String? _coverImageUrl;

  // Options
  final List<int> _guestCountOptions = [50, 100, 150, 200, 300, 500];
  // Budget ranges: [min, max] pairs
  final List<List<int>> _budgetRanges = [
    [0, 10000],
    [10000, 25000],
    [25000, 50000],
    [50000, 100000],
    [100000, 200000],
  ];
  final List<int> _searchRadiusOptions = [10, 20, 50, 100, 200, 300, 500];

  @override
  void initState() {
    super.initState();
    _repository = MyWeddingRepositoryImpl();
    _weddingId = widget.weddingId;
    _currentStep = widget.resumeAtStep ?? 1;
    
    // Load existing wedding data if resuming
    if (_weddingId != null) {
      _loadExistingData();
    }
  }

  Future<void> _loadExistingData() async {
    final result = await _repository.getMyWedding();
    if (result.isSuccess && result.data != null && mounted) {
      final wedding = result.data!;
      setState(() {
        _eventDate = wedding.eventDate;
        _venueAddress = wedding.venueAddress;
        if (wedding.position != null) {
          _lat = wedding.position!.latitude;
          _lng = wedding.position!.longitude;
        }
        _countryCode = wedding.countryCode;
        _professionsNeeded.clear();
        _professionsNeeded.addAll(wedding.professionsNeeded);
        _guestCount = wedding.guestCount;
        _budgetMin = wedding.budgetMin?.toInt();
        _budgetMax = wedding.budgetMax?.toInt();
        _searchRadius = wedding.searchRadius ?? 50;
        _useSearchRadius = wedding.searchRadius != null && wedding.searchRadius! > 0;
        _coverImageUrl = wedding.coverImageUrl;
        if (wedding.visibility == WeddingVisibility.visibleToPros) {
          _visibility = WeddingVisibility.visibleToPros;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Progress header with back arrow
          _buildProgressHeader(),
          
          // Step content - no scroll, content must fit
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildCurrentStep(),
            ),
          ),
          
          // Bottom buttons (24px above navbar)
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    final canGoBack = _currentStep > 1;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: LynewedColors.background,
        border: Border(
          bottom: BorderSide(color: LynewedColors.gray200, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back arrow + Title row
          Row(
            children: [
              if (canGoBack)
                GestureDetector(
                  onTap: _goBack,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.arrow_back_ios, size: 20, color: LynewedColors.textPrimary),
                  ),
                ),
              Expanded(
                child: Text(
                  _getStepTitle(),
                  style: LynewedTextStyles.sheetTitle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _getStepSubtitle(),
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: _currentStep / _totalSteps,
                    minHeight: 4,
                    backgroundColor: LynewedColors.gray200,
                    valueColor: const AlwaysStoppedAnimation<Color>(LynewedColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$_currentStep/$_totalSteps',
                style: LynewedTextStyles.labelSmall.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 1: return 'When is your wedding?';
      case 2: return 'Where is your wedding?';
      case 3: return 'Which professionals do you need?';
      case 4: return 'How many guests?';
      case 5: return 'What\'s your budget?';
      case 6: return 'Visibility on the map';
      case 7: return 'You\'re all set!';
      default: return '';
    }
  }

  String _getStepSubtitle() {
    switch (_currentStep) {
      case 1: return 'You can modify this later';
      case 2: return 'This helps pros find you';
      case 3: return 'Optional - skip if unsure';
      case 4: return 'Optional - helps with recommendations';
      case 5: return 'Optional - helps filter pros';
      case 6: return 'Choose who can see your wedding';
      case 7: return 'Your wedding space is ready';
      default: return '';
    }
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1: return _buildDateStep();
      case 2: return _buildLocationStep();
      case 3: return _buildProfessionalsStep();
      case 4: return _buildGuestCountStep();
      case 5: return _buildBudgetStep();
      case 6: return _buildVisibilityStep();
      case 7: return _buildDoneStep();
      default: return const SizedBox.shrink();
    }
  }

  // ============================================================
  // STEP 1: DATE
  // ============================================================
  Widget _buildDateStep() {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Illustration/Icon - unified size
          _buildStepIcon(Icons.calendar_month_outlined),
          const SizedBox(height: 16),
        // Marketing text
        Center(
          child: Text(
            'The countdown begins!',
            style: LynewedTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Set your wedding date to start planning\nyour perfect day.',
            textAlign: TextAlign.center,
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Date picker button
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _eventDate != null ? LynewedColors.primary.withValues(alpha: 0.05) : LynewedColors.surface,
              border: Border.all(
                color: _eventDate != null ? LynewedColors.primary : LynewedColors.gray200,
                width: _eventDate != null ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 24,
                  color: _eventDate != null ? LynewedColors.primary : LynewedColors.textSecondary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _eventDate != null 
                        ? dateFormat.format(_eventDate!)
                        : 'Tap to select date',
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      color: _eventDate != null 
                          ? LynewedColors.textPrimary 
                          : LynewedColors.textSecondary,
                    ),
                  ),
                ),
                if (_eventDate != null)
                  const Icon(Icons.check_circle, color: LynewedColors.primary, size: 20),
              ],
            ),
          ),
        ),
        // Countdown preview
        if (_eventDate != null) ...[
          const SizedBox(height: 20),
          _buildCountdownPreview(),
        ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCountdownPreview() {
    final daysUntil = _eventDate!.difference(DateTime.now()).inDays;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LynewedColors.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                'J-$daysUntil',
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$daysUntil days to go',
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Let\'s make them count!',
                  style: LynewedTextStyles.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

  // ============================================================
  // STEP 2: LOCATION
  // ============================================================
  Widget _buildLocationStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildStepIcon(Icons.location_on_outlined),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Find your dream venue',
              style: LynewedTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'This helps local professionals\ndiscover and connect with you.',
              textAlign: TextAlign.center,
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          AddressSearchWidget(
            initialValue: _venueAddress,
            borderRadius: 4.0,
            onAddressSelected: (PlaceDetailsDataStruct details) {
              setState(() {
                _venueAddress = details.formattedAddress;
                _lat = details.coords?.latitude;
                _lng = details.coords?.longitude;
                _countryCode = details.countryCode.isNotEmpty ? details.countryCode : null;
              });
            },
          ),
          const SizedBox(height: 12),
          if (_lat != null && _lng != null)
            _buildStatusRow(Icons.check_circle, 'Location confirmed', LynewedColors.success)
          else if (_venueAddress != null && _venueAddress!.isNotEmpty)
            _buildStatusRow(Icons.warning_amber_rounded, 'Select from suggestions', LynewedColors.warning),
          if (_lat != null && _lng != null) ...[
            const SizedBox(height: 20),
            _buildBenefitsList([
              'Pros near you will see your wedding',
              'Get personalized recommendations',
            ]),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBenefitsList(List<String> benefits) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LynewedColors.surface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: benefits.map((benefit) => Padding(
          padding: EdgeInsets.only(bottom: benefit != benefits.last ? 12 : 0),
          child: Row(
            children: [
              const Icon(Icons.check, size: 16, color: LynewedColors.success),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  benefit,
                  style: LynewedTextStyles.bodySmall,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildStatusRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          text,
          style: LynewedTextStyles.labelSmall.copyWith(color: color),
        ),
      ],
    );
  }

  // ============================================================
  // STEP 3: PROFESSIONALS
  // ============================================================
  Widget _buildProfessionalsStep() {
    final professions = Profession.values
        .where((p) => p != Profession.OTHER)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Illustration/Icon - smaller
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: LynewedColors.surface,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.people_outline,
              size: 28,
              color: LynewedColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Marketing text
        Center(
          child: Text(
            'Build your dream team',
            style: LynewedTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'Select the professionals you need.',
            textAlign: TextAlign.center,
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Selection count
        if (_professionsNeeded.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${_professionsNeeded.length} selected',
              style: LynewedTextStyles.labelSmall.copyWith(
                color: LynewedColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        // Profession chips in scrollable area
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: professions.map((profession) {
                final isSelected = _professionsNeeded.contains(profession.name);
                return _buildSelectableChip(
                  label: _formatProfessionName(profession.name),
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _professionsNeeded.remove(profession.name);
                      } else {
                        _professionsNeeded.add(profession.name);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  String _formatProfessionName(String name) {
    return name.toLowerCase().replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  // ============================================================
  // STEP 4: GUEST COUNT
  // ============================================================
  Widget _buildGuestCountStep() {
    // Default to 100 if not set
    final currentCount = _guestCount ?? 100;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        // Illustration/Icon
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: LynewedColors.surface,
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.groups_outlined,
              size: 32,
              color: LynewedColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Marketing text
        Center(
          child: Text(
            'How big is your celebration?',
            style: LynewedTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'This helps us recommend venues\nand vendors suited to your size.',
            textAlign: TextAlign.center,
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
        const Spacer(),
        // Current value display
        Center(
          child: Column(
            children: [
              Text(
                currentCount >= 500 ? '500+' : '$currentCount',
                style: LynewedTextStyles.displaySmall.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'guests',
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getGuestCountDescription(currentCount),
                style: LynewedTextStyles.labelSmall.copyWith(
                  color: LynewedColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Slider
        LynewedSlider(
          value: currentCount,
          steps: _guestCountOptions,
          onChanged: (value) => setState(() => _guestCount = value),
          formatValue: (v) => v >= 500 ? '500+' : '$v',
        ),
        const Spacer(),
      ],
    );
  }

  String _getGuestCountDescription(int count) {
    if (count <= 50) return 'Intimate gathering';
    if (count <= 100) return 'Classic celebration';
    if (count <= 150) return 'Medium-sized wedding';
    if (count <= 200) return 'Large celebration';
    if (count <= 300) return 'Grand affair';
    return 'Spectacular event';
  }

  Widget _buildOptionCard({
    required String label,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? LynewedColors.primary.withValues(alpha: 0.05) : LynewedColors.surface,
          border: Border.all(
            color: isSelected ? LynewedColors.primary : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
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
            if (isSelected)
              const Icon(Icons.check_circle, color: LynewedColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STEP 5: BUDGET
  // ============================================================
  Widget _buildBudgetStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildStepIcon(Icons.account_balance_wallet_outlined),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'Plan your budget',
            style: LynewedTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'Select your budget range.',
            textAlign: TextAlign.center,
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Budget range options in scrollable list
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: _budgetRanges.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final range = _budgetRanges[index];
              final min = range[0];
              final max = range[1];
              final isSelected = _budgetMin == min && _budgetMax == max;
              return _buildOptionCard(
                label: _getBudgetRangeLabel(min, max),
                description: _getBudgetDescription(max),
                isSelected: isSelected,
                onTap: () => setState(() {
                  _budgetMin = min;
                  _budgetMax = max;
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getBudgetRangeLabel(int min, int max) {
    if (min == 0) return 'Up to €${_formatBudget(max)}';
    if (max >= 200000) return '€${_formatBudget(min)}+';
    return '€${_formatBudget(min)} - €${_formatBudget(max)}';
  }

  String _formatBudget(int value) {
    if (value >= 1000) return '${value ~/ 1000}k';
    return value.toString();
  }

  String _getBudgetDescription(int max) {
    if (max <= 10000) return 'Intimate & budget-friendly';
    if (max <= 25000) return 'Classic wedding';
    if (max <= 50000) return 'Premium experience';
    if (max <= 100000) return 'Luxury celebration';
    return 'Ultimate luxury';
  }

  // ============================================================
  // STEP 6: VISIBILITY
  // ============================================================
  Widget _buildVisibilityStep() {
    final isPublic = _visibility == WeddingVisibility.visibleToPros;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildStepIcon(Icons.visibility_outlined),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Control your visibility',
              style: LynewedTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Choose who can see your wedding.',
              textAlign: TextAlign.center,
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildVisibilityOption(
            WeddingVisibility.private,
            Icons.lock_outline,
            'Private',
            'Only you can see your wedding.',
          ),
          const SizedBox(height: 8),
          _buildVisibilityOption(
            WeddingVisibility.visibleToPros,
            Icons.explore_outlined,
            'Visible to Pros',
            'Professionals can discover you on the map.',
          ),
          // Search radius checkbox + slider - only shown when visible to pros
          if (isPublic) ...[
            const SizedBox(height: 16),
            _buildSearchRadiusCheckbox(),
            if (_useSearchRadius) ...[
              const SizedBox(height: 12),
              LynewedSlider(
                value: _searchRadius,
                steps: _searchRadiusOptions,
                suffix: ' km',
                onChanged: (value) => setState(() => _searchRadius = value),
              ),
            ],
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: LynewedColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, size: 18, color: LynewedColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You can change this anytime in settings.',
                    style: LynewedTextStyles.labelSmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSearchRadiusCheckbox() {
    return InkWell(
      onTap: () => setState(() => _useSearchRadius = !_useSearchRadius),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: LynewedColors.gray200),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _useSearchRadius ? Colors.black : Colors.transparent,
                border: Border.all(
                  color: _useSearchRadius ? Colors.black : LynewedColors.gray200,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _useSearchRadius
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search professionals around my location',
                style: LynewedTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
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
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? LynewedColors.primary : LynewedColors.gray200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: isSelected ? LynewedColors.primary : LynewedColors.textSecondary),
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
                    subtitle,
                    style: LynewedTextStyles.labelSmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: LynewedColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STEP 7: DONE
  // ============================================================
  Widget _buildDoneStep() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Cover image picker - tap to change
          GestureDetector(
            onTap: _pickCoverImage,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: LynewedColors.surface,
                    shape: BoxShape.circle,
                    image: _coverImageUrl != null || _localCoverImagePath != null
                        ? DecorationImage(
                            image: _localCoverImagePath != null
                                ? FileImage(File(_localCoverImagePath!))
                                : NetworkImage(_coverImageUrl!) as ImageProvider,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _coverImageUrl == null && _localCoverImagePath == null
                      ? const Icon(
                          Icons.favorite,
                          color: LynewedColors.primary,
                          size: 36,
                        )
                      : null,
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: LynewedColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to add cover photo',
            style: LynewedTextStyles.labelSmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Congratulations!',
            textAlign: TextAlign.center,
            style: LynewedTextStyles.sheetTitle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your wedding space is ready.',
            textAlign: TextAlign.center,
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          // What's next section
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'WHAT\'S NEXT',
              style: LynewedTextStyles.sectionTitle,
            ),
          ),
          const SizedBox(height: 12),
          _buildNextStepItem(1, Icons.people_outline, 'Build your team', 'Invite your pros'),
          const SizedBox(height: 8),
          _buildNextStepItem(2, Icons.photo_library_outlined, 'Create moodboards', 'Save inspiration'),
          const SizedBox(height: 8),
          _buildNextStepItem(3, Icons.chat_bubble_outline, 'Start chatting', 'Coordinate in one place'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String? _localCoverImagePath;

  Future<void> _pickCoverImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (image != null) {
      setState(() => _localCoverImagePath = image.path);
    }
  }

  Widget _buildNextStepItem(int number, IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: LynewedColors.surface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: LynewedColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$number',
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
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
                  subtitle,
                  style: LynewedTextStyles.labelSmall.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, size: 24, color: LynewedColors.gray300),
        ],
      ),
    );
  }

  // ============================================================
  // REUSABLE WIDGETS
  // ============================================================
  
  /// Unified step icon - 56x56 with 28px icon
  Widget _buildStepIcon(IconData icon) {
    return Center(
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Icon(
          icon,
          size: 28,
          color: LynewedColors.primary,
        ),
      ),
    );
  }

  Widget _buildSelectableChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? LynewedColors.primary : LynewedColors.surface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: LynewedTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : LynewedColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    final isLastStep = _currentStep == _totalSteps;
    final canContinue = _canContinue();
    final isOptionalStep = _currentStep >= 3 && _currentStep <= 6;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: LynewedColors.background,
      ),
      child: Row(
        children: [
          // Skip button for optional steps (replaces Back)
          if (isOptionalStep && !isLastStep)
            Expanded(
              child: LynewedButton(
                text: 'Skip',
                onPressed: _isLoading ? null : _skip,
                type: LynewedButtonType.secondary,
              ),
            ),
          if (isOptionalStep && !isLastStep) const SizedBox(width: 12),
          // Continue button
          Expanded(
            flex: (isOptionalStep && !isLastStep) ? 2 : 1,
            child: LynewedButton(
              text: isLastStep ? 'Start Planning' : 'Continue',
              onPressed: canContinue && !_isLoading ? _continue : null,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }

  bool _canContinue() {
    switch (_currentStep) {
      case 1: return _eventDate != null;
      case 2: return _lat != null && _lng != null;
      default: return true;
    }
  }

  void _goBack() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  void _skip() {
    _continue(skip: true);
  }

  Future<void> _continue({bool skip = false}) async {
    // Step 2: Create wedding after location is set
    if (_currentStep == 2 && _weddingId == null) {
      await _createWedding();
      if (_weddingId == null) return; // Failed
    }
    
    // Save data for current step
    if (!skip && _weddingId != null && _currentStep >= 3 && _currentStep < _totalSteps) {
      await _saveCurrentStepData();
    }

    // Last step: complete onboarding
    if (_currentStep == _totalSteps) {
      await _completeOnboarding();
      return;
    }

    // Go to next step
    setState(() => _currentStep++);
  }

  Future<void> _createWedding() async {
    if (_eventDate == null || _lat == null || _lng == null) return;

    setState(() => _isLoading = true);

    try {
      final result = await _repository.createWedding(
        eventDate: _eventDate!,
        lat: _lat!,
        lng: _lng!,
        venueName: null,
        venueAddress: _venueAddress,
        countryCode: _countryCode,
      );

      if (result.isSuccess && result.data != null) {
        _weddingId = result.data;
      } else {
        _showError(result.error ?? 'Failed to create wedding');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCurrentStepData() async {
    if (_weddingId == null) return;

    OnboardingData? data;
    
    switch (_currentStep) {
      case 3:
        if (_professionsNeeded.isNotEmpty) {
          data = OnboardingData(
            professionsNeeded: _professionsNeeded,
            onboardingStep: 3,
          );
        }
        break;
      case 4:
        // Use displayed value (default 100 if not set)
        final guestValue = _guestCount ?? 100;
        data = OnboardingData(
          guestCount: guestValue,
          onboardingStep: 4,
        );
        // Update state with saved value
        _guestCount = guestValue;
        break;
      case 5:
        // Save budget range (both min and max) - values stored in selected currency
        if (_budgetMin != null && _budgetMax != null) {
          debugPrint('Saving budget: min=$_budgetMin, max=$_budgetMax');
          data = OnboardingData(
            budgetMin: _budgetMin!.toDouble(),
            budgetMax: _budgetMax!.toDouble(),
            onboardingStep: 5,
          );
        } else {
          debugPrint('Budget not set, skipping');
          data = const OnboardingData(onboardingStep: 5);
        }
        break;
      case 6:
        // Convert enum to snake_case for DB (private or visible_to_pros)
        final visibilityValue = _visibility == WeddingVisibility.visibleToPros 
            ? 'visible_to_pros' 
            : 'private';
        // Include search radius only if visible to pros AND checkbox is checked
        final radius = (_visibility == WeddingVisibility.visibleToPros && _useSearchRadius)
            ? _searchRadius 
            : null;
        data = OnboardingData(
          visibility: visibilityValue,
          searchRadius: radius,
          onboardingStep: 6,
        );
        break;
    }

    if (data != null) {
      setState(() => _isLoading = true);
      try {
        await _repository.updateOnboardingData(
          weddingId: _weddingId!,
          data: data,
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _completeOnboarding() async {
    if (_weddingId == null) return;

    setState(() => _isLoading = true);

    try {
      // Upload cover image if selected
      String? uploadedCoverUrl;
      if (_localCoverImagePath != null) {
        uploadedCoverUrl = await _uploadCoverImage(_localCoverImagePath!);
        if (uploadedCoverUrl != null) {
          // Save cover URL to wedding
          await _repository.updateOnboardingData(
            weddingId: _weddingId!,
            data: OnboardingData(coverImageUrl: uploadedCoverUrl),
          );
        }
      }

      final result = await _repository.completeOnboarding(weddingId: _weddingId!);

      if (result.isSuccess) {
        widget.onComplete();
      } else {
        _showError(result.error ?? 'Failed to complete setup');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _uploadCoverImage(String localPath) async {
    try {
      final file = File(localPath);
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('Failed to upload cover image: user not authenticated');
        return null;
      }
      // Path format: userId/weddingId_timestamp.jpg (required for DELETE policy)
      final filePath = '$userId/${_weddingId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      await supabase.storage.from('wedding-covers').upload(
        filePath,
        file,
        fileOptions: const FileOptions(contentType: 'image/jpeg'),
      );
      
      final publicUrl = supabase.storage.from('wedding-covers').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      debugPrint('Failed to upload cover image: $e');
      return null;
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: LynewedColors.error,
      ),
    );
  }
}
