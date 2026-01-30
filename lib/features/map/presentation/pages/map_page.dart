/// MapPage - Unified map page for bride and professional users
/// 
/// Replaces duplicated map_brides_large_widget.dart and map_pro_large_widget.dart
/// with a single, clean implementation.
library;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '/core/design/design.dart';
import '/compo_finaux/address_search/address_search_widget.dart';
import '/backend/schema/structs/index.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/map_repository.dart';
import '../../domain/usecases/get_marker_details.dart';
import '../../data/repositories/supabase_map_repository.dart';
import '../../data/datasources/supabase_map_datasource.dart';
import '../state/map_state.dart';
import '../widgets/lynewed_map_widget.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/map_controls.dart';
import '../sheets/sheets.dart';
import '../services/map_actions_service.dart';
import '/core/di/injection_container.dart';
import '/features/reviews/domain/repositories/review_repository.dart';
import '/features/reviews/presentation/sheets/review_submit_sheet.dart';

/// Configuration de la page map
class MapPageConfig {
  const MapPageConfig({
    this.title,
    this.showAppBar = true,
    this.showSearchBar = true,
    this.showFilterButton = true,
    this.showMyLocationButton = true,
    this.showLayerToggle = false,
    this.initialCenter,
    this.initialZoom = 12.0,
  });

  final String? title;
  final bool showAppBar;
  final bool showSearchBar;
  final bool showFilterButton;
  final bool showMyLocationButton;
  final bool showLayerToggle;
  final gmaps.LatLng? initialCenter;
  final double initialZoom;
}

/// Page map unifiée bride/pro
class MapPage extends StatefulWidget {
  const MapPage({
    super.key,
    required this.userRole,
    this.config = const MapPageConfig(),
    this.repository,
  });

  /// Rôle utilisateur: 'bride' ou 'professional'
  final String userRole;

  /// Configuration de la page
  final MapPageConfig config;

  /// Repository custom (pour tests)
  final MapRepository? repository;

  /// Route name pour navigation
  static const routeName = 'MapPage';
  static const routePath = '/map';

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapState _mapState;
  gmaps.GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  final _datasource = SupabaseMapDatasource();
  bool _isSearchExpanded = false;
  bool _showMapStyleOptions = false;
  bool _isLocating = false;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _mapState = MapState(
      repository: widget.repository ?? SupabaseMapRepository(),
      userRole: widget.userRole,
      initialCenter: widget.config.initialCenter,
      initialZoom: widget.config.initialZoom,
    );
    _loadUserMarket();
  }
  
  /// Load user's market region for profession filtering
  Future<void> _loadUserMarket() async {
    final market = await actions.getUserMarketRegion();
    if (_mounted) {
      _mapState.updateUserMarket(market);
    }
  }

  @override
  void dispose() {
    _mounted = false;
    _searchController.dispose();
    _mapState.dispose();
    _mapController = null;
    super.dispose();
  }

  /// Callback when map controller is ready
  void _onMapControllerReady(gmaps.GoogleMapController controller) {
    _mapController = controller;
    // Auto-center on user's location when map is ready (if no initial center provided)
    if (widget.config.initialCenter == null) {
      _goToMyLocationOnInit();
    }
  }

  /// Go to user's location on map initialization (silent, no loading indicator)
  Future<void> _goToMyLocationOnInit() async {
    if (_mapController == null) return;
    
    try {
      final hasPermission = await _ensureLocationPermission();
      if (!hasPermission || !_mounted) return;
      
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      
      if (!_mounted || _mapController == null) return;
      
      await _mapController!.animateCamera(
        gmaps.CameraUpdate.newLatLngZoom(
          gmaps.LatLng(position.latitude, position.longitude),
          _mapState.zoom,
        ),
      );
    } catch (e) {
      // Silent fail - keep default Paris location if geolocation fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _mapState,
      child: Scaffold(
        backgroundColor: LynewedColors.background,
        body: SizedBox(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          child: Stack(
            children: [
              // 1. Map avec padding bottom 150px (comme legacy)
              Container(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height,
                decoration: const BoxDecoration(),
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 150.0),
                    child: LynewedMapWidget(
                      userRole: widget.userRole,
                      config: LynewedMapConfig(
                        initialCenter: widget.config.initialCenter,
                        initialZoom: widget.config.initialZoom,
                      ),
                      externalMapState: _mapState,
                      onMapControllerReady: _onMapControllerReady,
                      onMarkerTap: _onMarkerTap,
                      repository: widget.repository,
                    ),
                  ),
                ),
              ),

              // 2. Location button - top right (padding: 0, 80, 20, 0)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 80.0, right: 20.0),
                  child: MapLocationButton(
                    onPressed: _goToMyLocation,
                    isLoading: _isLocating,
                  ),
                ),
              ),

              // 3. Zoom controls - top right (padding: 0, 160, 20, 0)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 160.0, right: 20.0),
                  child: MapZoomControls(
                    onZoomIn: _zoomIn,
                    onZoomOut: _zoomOut,
                  ),
                ),
              ),

              // 5. Back button - top left (padding: 20, 70, 0, 0)
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 70.0, left: 20.0),
                  child: MapBackButton(
                    onPressed: () {
                      if (_mounted && Navigator.canPop(context)) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
              ),

              // 6. Zoom label - top right (padding: 0, 136, 25, 0)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 136.0, right: 25.0),
                  child: Text(
                    'Zoom',
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ),

              // 7. Bottom section - FABs + Search bar
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row with FABs (Map Style right, Create left)
                    _buildBottomFABsRow(context),
                    // Search bar / filters
                    _buildBottomSearchBar(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM SECTION (FABs + Search Bar)
  // ============================================================

  /// Bottom FABs row: Create (left) + Map Style (right)
  /// Raised by 60px to avoid overlap with filter chips
  Widget _buildBottomFABsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Map style menu - right side
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildMapStyleToggle(),
              ),
            ),
            // Create FAB - left side
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildCreateFAB(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Create FAB - 40x40, circular, primary fill
  Widget _buildCreateFAB() {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: const BoxDecoration(
        color: LynewedColors.primary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () => _showCreateSheet(context),
        icon: Icon(
          widget.userRole == 'bride' ? Icons.diamond_outlined : Icons.crisis_alert_rounded,
          color: Colors.white,
          size: 24.0,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  /// Map style toggle - expandable menu (40x90 when expanded)
  Widget _buildMapStyleToggle() {
    return SizedBox(
      width: 40.0,
      height: 90.0,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Expanded options (when _showMapStyleOptions is true)
          if (_showMapStyleOptions)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMapStyleOption(
                  assetPath: 'assets/images/SCR-20251017-jqhr.png',
                  style: gmaps.MapType.satellite,
                  isSelected: _mapState.mapType == gmaps.MapType.satellite,
                ),
                const SizedBox(height: 8.0),
                _buildMapStyleOption(
                  assetPath: 'assets/images/SCR-20251017-jpwd.png',
                  style: gmaps.MapType.normal,
                  isSelected: _mapState.mapType == gmaps.MapType.normal,
                ),
              ],
            ),
          // Collapsed button (when _showMapStyleOptions is false)
          if (!_showMapStyleOptions)
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: 40.0,
                height: 40.0,
                decoration: const BoxDecoration(
                  color: LynewedColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() => _showMapStyleOptions = true);
                  },
                  icon: const Icon(
                    Icons.map,
                    color: Colors.white,
                    size: 24.0,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Map style option button
  Widget _buildMapStyleOption({
    required String assetPath,
    required gmaps.MapType style,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        _mapState.setMapType(style);
        setState(() => _showMapStyleOptions = false);
      },
      child: Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          color: isSelected ? LynewedColors.success : LynewedColors.gray200,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Image.asset(
              assetPath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                style == gmaps.MapType.satellite ? Icons.satellite_alt : Icons.map_outlined,
                color: LynewedColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Bottom search bar with filters - rounded top corners 24px
  Widget _buildBottomSearchBar(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: MediaQuery.sizeOf(context).width,
      constraints: BoxConstraints(
        minHeight: _isSearchExpanded ? 450.0 : 150.0,
      ),
      decoration: BoxDecoration(
        color: LynewedColors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        boxShadow: [
          BoxShadow(
            color: LynewedColors.primary.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: LynewedColors.gray200,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // Filter chips row (above search field)
              _buildFilterChipsRow(),
              const SizedBox(height: 12.0),
              // Search field
              _buildSearchField(),
              // Expanded search suggestions
              if (_isSearchExpanded) ...[
                const SizedBox(height: 16.0),
                Expanded(child: _buildSearchSuggestions()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Search text field with AddressSearchWidget
  Widget _buildSearchField() {
    return Row(
      children: [
        // Address search widget
        Expanded(
          child: AddressSearchWidget(
            height: 48.0,
            hintText: _getSearchHint(),
            locale: 'fr',
            useOverlay: true,
            suggestionsPosition: SuggestionsPosition.below,
            onAddressSelected: _onAddressSelected,
            onAddressCleared: () {
              // Clear any selected address
            },
            onSuggestionsVisibilityChanged: (visible) {
              if (_mounted) {
                setState(() => _isSearchExpanded = visible);
              }
            },
          ),
        ),
        // Filter button
        Consumer<MapState>(
          builder: (context, state, _) {
            final hasActiveFilters = state.filter.hasProfessionFilter ||
                state.filter.hasBudgetFilter;
            return IconButton(
              icon: Badge(
                isLabelVisible: hasActiveFilters,
                child: const Icon(Icons.tune, color: LynewedColors.primary),
              ),
              onPressed: () => _showFilterSheet(context),
            );
          },
        ),
      ],
    );
  }

  /// Handle address selection from search
  void _onAddressSelected(PlaceDetailsDataStruct details) {
    if (!_mounted || _mapController == null) return;
    
    // coords is a LatLng from FlutterFlow
    final coords = details.coords;
    
    if (coords != null) {
      _mapController!.animateCamera(
        gmaps.CameraUpdate.newLatLngZoom(
          gmaps.LatLng(coords.latitude, coords.longitude),
          14.0,
        ),
      );
    }
    
    // Collapse search
    setState(() => _isSearchExpanded = false);
  }

  /// Filter chips row - shows toggles for marker types + count
  /// - Bride: Professionals + My Wedding (no alerts - pro-only feature)
  /// - Pro: Professionals + Alerts + Weddings
  /// Note: Professionals + Fixed Locations merged into single chip (proFixedLocation fusion)
  Widget _buildFilterChipsRow() {
    return Consumer<MapState>(
      builder: (context, state, _) {
        // Merged toggle: showPros controls both professionals and fixed locations
        final showPros = state.filter.toggles.showPros;
        final isBride = widget.userRole == 'bride';
        final markerCount = state.visibleMarkersCount;
        
        return Row(
          children: [
            // Filter chips (left side)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Professionals (merged with Fixed Locations → proFixedLocation)
                    _buildFilterChip(
                      label: 'Professionals',
                      isActive: showPros,
                      onTap: () => state.updateToggles(
                        state.filter.toggles.copyWith(
                          showPros: !showPros,
                          showFixedLocations: !showPros, // Keep in sync
                        ),
                      ),
                    ),
                    // Alerts - PRO ONLY (not for brides)
                    if (!isBride) ...[
                      const SizedBox(width: 8.0),
                      _buildFilterChip(
                        label: 'Alerts',
                        isActive: state.filter.toggles.showAlerts,
                        onTap: () => state.updateToggles(
                          state.filter.toggles.copyWith(
                            showAlerts: !state.filter.toggles.showAlerts,
                          ),
                        ),
                      ),
                    ],
                    // Weddings - different label for bride vs pro
                    const SizedBox(width: 8.0),
                    _buildFilterChip(
                      label: isBride ? 'My Wedding' : 'Weddings',
                      isActive: state.filter.toggles.showWeddings,
                      onTap: () => state.updateToggles(
                        state.filter.toggles.copyWith(
                          showWeddings: !state.filter.toggles.showWeddings,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Marker count (right side)
            if (markerCount > 0) ...[
              const SizedBox(width: 12.0),
              Text(
                '$markerCount',
                style: LynewedTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w300,
                  color: LynewedColors.textSecondary,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  /// Filter chip widget
  Widget _buildFilterChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isActive ? LynewedColors.primary : LynewedColors.surface,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isActive ? LynewedColors.primary : LynewedColors.border,
          ),
        ),
        child: Text(
          label,
          style: LynewedTextStyles.labelMedium.copyWith(
            color: isActive ? LynewedColors.textOnPrimary : LynewedColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Search suggestions panel
  Widget _buildSearchSuggestions() {
    // TODO: Intégrer avec AddressSearchWidget
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.search, size: 48, color: LynewedColors.gray300),
        const SizedBox(height: 12.0),
        Text(
          'Search for a location',
          style: LynewedTextStyles.bodyMedium.copyWith(
            color: LynewedColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16.0),
        TextButton(
          onPressed: () => setState(() => _isSearchExpanded = false),
          child: Text(
            'Cancel',
            style: LynewedTextStyles.bodyMedium.copyWith(
              color: LynewedColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  String _getSearchHint() {
    return widget.userRole == 'bride'
        ? 'Search for vendors...'
        : 'Search location...';
  }

  void _onMarkerTap(MapMarker marker) {
    if (!_mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => _MarkerDetailsLoader(
        marker: marker,
        userRole: widget.userRole,
        mapState: _mapState,
        onEditWedding: () => _openMyWeddingPage(context),
      ),
    );
  }

  void _openMyWeddingPage(BuildContext ctx) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (context) => const MyWeddingPage(),
      ),
    );
  }

  void _showFilterSheet(BuildContext ctx) {
    if (!_mounted) return;
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => FilterSheet(
        currentFilter: _mapState.filter,
        userRole: widget.userRole,
        userMarket: _mapState.userMarket,
        onApply: (filter) {
          _mapState.updateFilter(filter);
          Navigator.pop(sheetContext);
        },
      ),
    );
  }

  /// Go to user's current location
  Future<void> _goToMyLocation() async {
    if (_mapController == null) return;
    
    setState(() => _isLocating = true);

    try {
      // Check permissions
      final hasPermission = await _ensureLocationPermission();
      if (!hasPermission || !_mounted) return;
      
      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      
      if (!_mounted || _mapController == null) return;
      
      // Animate to user location
      await _mapController!.animateCamera(
        gmaps.CameraUpdate.newLatLngZoom(
          gmaps.LatLng(position.latitude, position.longitude),
          _mapState.zoom + 2,
        ),
      );
    } catch (e) {
      debugPrint('[MapPage._goToCurrentLocation] Error: $e');
    } finally {
      if (_mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  /// Check and request location permission
  Future<bool> _ensureLocationPermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;
    
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return permission != LocationPermission.denied &&
           permission != LocationPermission.deniedForever;
  }

  /// Zoom in on map
  Future<void> _zoomIn() async {
    if (_mapController == null) return;
    await _mapController!.animateCamera(gmaps.CameraUpdate.zoomIn());
  }

  /// Zoom out on map
  Future<void> _zoomOut() async {
    if (_mapController == null) return;
    await _mapController!.animateCamera(gmaps.CameraUpdate.zoomOut());
  }

  /// Handle wedding icon tap for brides:
  /// - If wedding exists with coordinates → Navigate to wedding location on map
  /// - If no wedding or no coordinates → Navigate to MyWeddingPage (onboarding)
  void _showCreateSheet(BuildContext ctx) async {
    if (!_mounted) return;
    final isBride = widget.userRole == 'bride';
    
    // Capture references before async gaps
    final navigator = Navigator.of(ctx);
    final scaffoldMessenger = ScaffoldMessenger.of(ctx);
    
    if (isBride) {
      // Show loader while fetching existing wedding
      showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Fetch existing wedding
        final existingWedding = await _datasource.getMyWedding();
        
        if (!_mounted) return;
        navigator.pop(); // Hide loader

        if (!ctx.mounted) return;
        
        // Check if wedding exists with valid coordinates
        final exists = existingWedding?['exists'] == true;
        final venueLat = (existingWedding?['venueLat'] as num?)?.toDouble() ??
            (existingWedding?['venue_lat'] as num?)?.toDouble();
        final venueLng = (existingWedding?['venueLng'] as num?)?.toDouble() ??
            (existingWedding?['venue_lng'] as num?)?.toDouble();

        if (exists && venueLat != null && venueLng != null) {
          // Wedding exists → Navigate to wedding location on map
          final weddingPosition = gmaps.LatLng(venueLat, venueLng);
          
          if (_mapController != null) {
            await _mapController!.animateCamera(
              gmaps.CameraUpdate.newLatLngZoom(weddingPosition, 14.0),
            );
          }
        } else {
          // No wedding or incomplete → Navigate to MyWeddingPage (onboarding)
          navigator.push(
            MaterialPageRoute(
              builder: (context) => const MyWeddingPage(),
            ),
          );
        }
      } catch (e) {
        if (!_mounted) return;
        navigator.pop(); // Hide loader on error
        
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error loading wedding: $e'),
            backgroundColor: LynewedColors.error,
          ),
        );
      }
    } else {
      // Show AlertCreateSheet for professionals
      showModalBottomSheet(
        context: ctx,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (c) => AlertCreateSheet(
          onSaved: () {
            // Invalidate cache to show new alert
            MarkerDetailsServiceProvider.instance.clearCache();
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text('Alert created successfully'),
                backgroundColor: LynewedColors.success,
              ),
            );
            _mapState.refresh(); // Refresh map to show new alert
          },
        ),
      );
    }
  }
}

/// Widget qui charge les détails d'un marker et affiche le sheet approprié
class _MarkerDetailsLoader extends StatefulWidget {
  const _MarkerDetailsLoader({
    required this.marker,
    required this.userRole,
    required this.mapState,
    this.onEditWedding,
  });

  final MapMarker marker;
  final String userRole;
  final MapState mapState;
  final VoidCallback? onEditWedding;

  @override
  State<_MarkerDetailsLoader> createState() => _MarkerDetailsLoaderState();
}

class _MarkerDetailsLoaderState extends State<_MarkerDetailsLoader> {
  final _detailsService = MarkerDetailsServiceProvider.instance;
  final _actionsService = MapActionsService.instance;
  bool _isLoading = true;
  String? _error;
  dynamic _details;

  // Rating data for professionals
  double? _averageRating;
  int? _reviewCount;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      // For professionals, invalidate cache to ensure fresh favorite status
      // This ensures the favorite icon is always in sync with the database
      if (widget.marker.type == MapMarkerType.proFixedLocation) {
        final profileId = widget.marker.style.profileId ?? widget.marker.id;
        _detailsService.invalidateCache(profileId);
      }

      final details = await _detailsService.getDetailsForMarker(widget.marker);

      // Fetch ratings for professionals
      if (widget.marker.type == MapMarkerType.proFixedLocation &&
          sl.isRegistered<ReviewRepository>()) {
        final profileId = widget.marker.style.profileId ?? widget.marker.id;
        try {
          final rating = await sl<ReviewRepository>().getRatingForPro(profileId);
          if (rating != null) {
            _averageRating = rating.averageRating;
            _reviewCount = rating.reviewCount;
          }
        } catch (_) {
          // Ignore rating fetch errors - not critical
        }
      }

      if (mounted) {
        setState(() {
          _details = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration: const BoxDecoration(
          color: LynewedColors.background,
          borderRadius: LynewedBorders.sheetBorderRadius,
        ),
        padding: const EdgeInsets.all(LynewedSpacing.xxxl + LynewedSpacing.sm),
        child: const Center(
          child: CircularProgressIndicator(
            color: LynewedColors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_error != null || _details == null) {
      return Container(
        decoration: const BoxDecoration(
          color: LynewedColors.background,
          borderRadius: LynewedBorders.sheetBorderRadius,
        ),
        padding: const EdgeInsets.all(LynewedSpacing.xxxl + LynewedSpacing.sm),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: LynewedColors.error,
              ),
              LynewedGap.verticalLg,
              Text(
                _error ?? 'Unable to load details',
                style: LynewedTextStyles.titleMedium,
                textAlign: TextAlign.center,
              ),
              LynewedGap.verticalSm,
              TextButton(
                style: LynewedComponentStyles.textButton(),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: LynewedColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Afficher le sheet approprié selon le type de marker
    switch (widget.marker.type) {
      case MapMarkerType.proFixedLocation:
        final proDetails = _details as ProfessionalDetails;
        // Extract city from fixed location label (e.g., "15 Rue de Rivoli, 75001 Paris" -> "Paris")
        final locationLabel = widget.marker.metadata['locationLabel'] as String?;
        final fixedLocationCity = _extractCityFromAddress(locationLabel);
        
        return ProfessionalDetailsSheet(
          // Key ensures widget rebuilds when favorite status OR marker changes
          key: ValueKey('pro_${widget.marker.id}_${proDetails.isFavorited}'),
          details: proDetails,
          fixedLocation: fixedLocationCity,
          onContact: () => _handleContact(context),
          onFavoriteToggle: () => _handleFavoriteToggle(context),
          onViewProfile: () => _handleViewProfile(context),
          onReport: () => _handleReportPro(context),
          // Only show favorite button for brides (adds to wishlist)
          showFavoriteButton: widget.userRole == 'bride',
          // Rating data
          averageRating: _averageRating,
          reviewCount: _reviewCount,
          // Only brides can write reviews
          onWriteReview: widget.userRole == 'bride'
              ? () => _handleWriteReview(context, proDetails)
              : null,
        );

      case MapMarkerType.professionalAlert:
        return AlertDetailsSheet(
          details: _details as AlertDetails,
          onHelp: () => _handleHelp(context),
          onViewAuthorProfile: () => _handleViewAuthorProfile(context),
          onDelete: (_details as AlertDetails).isOwn
              ? () => _handleDeleteAlert(context)
              : null,
        );

      case MapMarkerType.wedding:
        return WeddingDetailsSheet(
          details: _details as WeddingDetails,
          userRole: widget.userRole,
          onContact: () => _handleContactBride(context),
          onViewBrideProfile: () => _handleViewBrideProfile(context),
          onEdit: () => _handleEditWedding(context),
        );
    }
  }

  // ============================================================
  // ACTION HANDLERS - Connected to MapActionsService
  // ============================================================

  /// Handle edit wedding action
  void _handleEditWedding(BuildContext context) {
    Navigator.pop(context); // Close details sheet
    // Wait a bit for the sheet to close before opening the new one
    Future.delayed(const Duration(milliseconds: 200), () {
      widget.onEditWedding?.call();
    });
  }

  /// Handle contact professional action
  void _handleContact(BuildContext context) {
    Navigator.pop(context);
    final details = _details as ProfessionalDetails;
    _actionsService.navigateToChat(context, details.id);
  }

  /// Handle favorite toggle action
  Future<void> _handleFavoriteToggle(BuildContext context) async {
    final details = _details as ProfessionalDetails;
    final oldValue = details.isFavorited;
    final optimisticValue = !oldValue;
    
    // Invalidate cache to ensure fresh data on next load
    _detailsService.invalidateCache(details.id);
    
    // 1. Optimistic update - Update UI immediately
    if (mounted) {
      setState(() {
        _details = ProfessionalDetails(
          id: details.id,
          fullName: details.fullName,
          avatarUrl: details.avatarUrl,
          businessName: details.businessName,
          profession: details.profession,
          budgetMin: details.budgetMin,
          budgetMax: details.budgetMax,
          currency: details.currency,
          subscriptionTier: details.subscriptionTier,
          distanceKm: details.distanceKm,
          locationLabel: details.locationLabel,
          coverImageUrl: details.coverImageUrl,
          isFavorited: optimisticValue, // Optimistic value
          isLive: details.isLive,
          description: details.description,
          portfolioImages: details.portfolioImages,
          slideshowImages: details.slideshowImages,
          fixedLocations: details.fixedLocations,
          instagramUrl: details.instagramUrl,
          websiteUrl: details.websiteUrl,
          profileVideoUrl: details.profileVideoUrl,
          canBeContactedByBride: details.canBeContactedByBride,
          canContactBride: details.canContactBride,
        );
      });
    }

    // 2. Call server
    final serverValue = await _actionsService.toggleFavorite(
      details.id,
      currentValue: oldValue,
    );
    
    // 3. Reconcile with server response if needed
    // If server returns the same value as before, operation failed - revert
    if (mounted && serverValue == oldValue) {
      setState(() {
        _details = ProfessionalDetails(
          id: details.id,
          fullName: details.fullName,
          avatarUrl: details.avatarUrl,
          businessName: details.businessName,
          profession: details.profession,
          budgetMin: details.budgetMin,
          budgetMax: details.budgetMax,
          currency: details.currency,
          subscriptionTier: details.subscriptionTier,
          distanceKm: details.distanceKm,
          locationLabel: details.locationLabel,
          coverImageUrl: details.coverImageUrl,
          isFavorited: oldValue, // Revert to original value
          isLive: details.isLive,
          description: details.description,
          portfolioImages: details.portfolioImages,
          slideshowImages: details.slideshowImages,
          fixedLocations: details.fixedLocations,
          instagramUrl: details.instagramUrl,
          websiteUrl: details.websiteUrl,
          profileVideoUrl: details.profileVideoUrl,
          canBeContactedByBride: details.canBeContactedByBride,
          canContactBride: details.canContactBride,
        );
      });
    }
  }

  /// Handle view professional profile action
  void _handleViewProfile(BuildContext context) {
    Navigator.pop(context);
    final details = _details as ProfessionalDetails;
    _actionsService.navigateToProProfile(context, details);
  }

  /// Handle write review action (brides only)
  Future<void> _handleWriteReview(BuildContext sheetContext, ProfessionalDetails proDetails) async {
    Navigator.pop(sheetContext);

    // Capture references before async gap
    final messenger = ScaffoldMessenger.of(context);
    final reviewRepo = sl<ReviewRepository>();

    // Check if user already has a review for this pro
    final existingReview = await reviewRepo.getMyReviewForPro(proDetails.id);

    if (!mounted) return;

    // Open review submit sheet
    // ignore: use_build_context_synchronously
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReviewSubmitSheet(
        proId: proDetails.id,
        proName: proDetails.fullName,
        existingReview: existingReview,
        onSubmit: (rating, comment) async {
          if (existingReview != null) {
            // Update existing review
            await reviewRepo.updateReview(
              reviewId: existingReview.id,
              rating: rating,
              comment: comment,
            );
          } else {
            // Create new review
            await reviewRepo.createReview(
              proId: proDetails.id,
              rating: rating,
              comment: comment,
            );
          }
          // Sheet closes automatically after successful submission
          if (mounted) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(existingReview != null
                    ? 'Review updated successfully!'
                    : 'Review submitted successfully!'),
                backgroundColor: LynewedColors.success,
              ),
            );
            // Refresh the details to show new rating
            _loadDetails();
          }
        },
      ),
    );
  }

  /// Handle help with alert action
  void _handleHelp(BuildContext context) {
    Navigator.pop(context);
    final details = _details as AlertDetails;
    _actionsService.navigateToHelpAlert(context, details);
  }

  /// Handle view alert author profile action
  /// Uses the SAME logic as ItemAllAlertWidget in dashboard (which works)
  Future<void> _handleViewAuthorProfile(BuildContext context) async {
    final alertDetails = _details as AlertDetails;
    
    // Capture navigator and scaffoldMessenger before async gap
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // EXACT same logic as ItemAllAlertWidget (lines 222-256)
    // This is the code that WORKS in dashboard_pro
    final proDetails = await actions.getProItemDetailsAction(
      alertDetails.authorId,
    );
    
    if (!mounted) return;
    
    if (proDetails?.proProfileId != null && proDetails!.proProfileId.isNotEmpty) {
      // Close the sheet first
      navigator.pop();
      
      // Then navigate using the PARENT context (widget.context is MapPage context)
      // We need a small delay to let the sheet close
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (!mounted) return;
      
      // Use the widget's context (MapPage) which is still valid
      this.context.pushNamed(
        ProDetailsWidget.routeName,
        queryParameters: {
          'proDetails': serializeParam(
            proDetails,
            ParamType.DataStruct,
          ),
        }.withoutNulls,
      );
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Unable to load author profile'),
          duration: Duration(milliseconds: 2000),
        ),
      );
    }
  }

  /// Handle delete alert action
  Future<void> _handleDeleteAlert(BuildContext context) async {
    final details = _details as AlertDetails;
    
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Alert'),
        content: const Text('Are you sure you want to delete this alert?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: LynewedColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm != true || !context.mounted) return;
    
    final success = await _actionsService.deleteAlert(details.id);
    
    if (context.mounted) {
      Navigator.pop(context);
      
      if (success) {
        // Refresh map data to remove deleted alert marker
        widget.mapState.refresh();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alert deleted'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete alert'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handle contact bride action
  void _handleContactBride(BuildContext context) {
    Navigator.pop(context);
    final details = _details as WeddingDetails;
    _actionsService.navigateToContactBride(context, details);
  }

  /// Handle view bride profile action
  void _handleViewBrideProfile(BuildContext context) {
    Navigator.pop(context);
    final details = _details as WeddingDetails;
    _actionsService.navigateToBrideProfile(context, details);
  }

  /// Handle report professional action
  void _handleReportPro(BuildContext context) {
    final details = _details as ProfessionalDetails;
    Navigator.pop(context);
    _actionsService.showReportUserSheet(
      context,
      profileId: details.id,
      userName: details.displayName,
      userAvatarUrl: details.avatarUrl,
    );
  }

  /// Extract city name from full address
  /// 
  /// Examples:
  /// - "15 Rue de Rivoli, 75001 Paris" -> "Paris"
  /// - "42 Avenue des Champs-Élysées, 75008 Paris" -> "Paris"
  /// - "10 Downing Street, London SW1A 2AA" -> "London"
  /// - null -> null
  String? _extractCityFromAddress(String? fullAddress) {
    if (fullAddress == null || fullAddress.isEmpty) return null;
    
    // Split by comma and take the last part (usually contains city)
    final parts = fullAddress.split(',').map((p) => p.trim()).toList();
    if (parts.isEmpty) return fullAddress;
    
    // Last part usually contains postal code + city
    final lastPart = parts.last;
    
    // Try to extract city from "75001 Paris" format (French)
    final frenchMatch = RegExp(r'\d{5}\s+(.+)$').firstMatch(lastPart);
    if (frenchMatch != null) {
      return frenchMatch.group(1)?.trim();
    }
    
    // Try to extract city from "London SW1A 2AA" format (UK)
    final ukMatch = RegExp(r'^([A-Za-z\s]+)\s+[A-Z]{1,2}\d').firstMatch(lastPart);
    if (ukMatch != null) {
      return ukMatch.group(1)?.trim();
    }
    
    // Fallback: return last part as-is (might be just city name)
    return lastPart;
  }
}
