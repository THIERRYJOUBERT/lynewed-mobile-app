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
import '../sheets/sheets.dart';
import '../services/map_actions_service.dart';

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
                  child: _buildLocationButton(),
                ),
              ),

              // 3. Zoom+ button - top right (padding: 0, 160, 20, 0)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 160.0, right: 20.0),
                  child: _buildZoomButton(
                    icon: Icons.add,
                    onPressed: _zoomIn,
                  ),
                ),
              ),

              // 4. Zoom- button - top right (padding: 0, 210, 20, 0)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 210.0, right: 20.0),
                  child: _buildZoomButton(
                    icon: Icons.remove,
                    onPressed: _zoomOut,
                  ),
                ),
              ),

              // 5. Back button - top left (padding: 20, 70, 0, 0)
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 70.0, left: 20.0),
                  child: _buildBackButton(),
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
  // LEGACY LAYOUT BUTTONS (exact positions from map_pro_large)
  // ============================================================

  /// Back button - top left, 40x40, circular, primary fill, white icon
  Widget _buildBackButton() {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: LynewedColors.primary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () {
          if (_mounted && Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        },
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.white,
          size: 17.0,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  /// Location button - 40x40, rounded 4px, primary fill, white icon
  Widget _buildLocationButton() {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: LynewedColors.primary,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: IconButton(
        onPressed: _goToMyLocation,
        icon: const Icon(
          Icons.near_me,  // FontAwesome locationArrow equivalent
          color: Colors.white,
          size: 24.0,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  /// Zoom button - 40x40, rounded 8px, no fill, primary icon
  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: LynewedColors.background,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: LynewedColors.border, width: 1),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: LynewedColors.primary,
          size: 24.0,
        ),
        padding: EdgeInsets.zero,
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
      decoration: BoxDecoration(
        color: LynewedColors.primary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () => _showCreateSheet(context),
        icon: Icon(
          widget.userRole == 'bride' ? Icons.favorite : Icons.crisis_alert_rounded,
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
                decoration: BoxDecoration(
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
              debugPrint('Address cleared');
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
                child: Icon(Icons.tune, color: LynewedColors.primary),
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

  /// Filter chips row (layer toggles)
  /// - Bride: Professionals + My Wedding (no alerts - pro-only feature)
  /// - Pro: Professionals + Alerts + Weddings
  /// Note: Professionals + Fixed Locations merged into single chip (proFixedLocation fusion)
  Widget _buildFilterChipsRow() {
    return Consumer<MapState>(
      builder: (context, state, _) {
        // Merged toggle: showPros controls both professionals and fixed locations
        final showPros = state.filter.toggles.showPros;
        final isBride = widget.userRole == 'bride';
        
        return SingleChildScrollView(
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
        Icon(Icons.search, size: 48, color: LynewedColors.gray300),
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

  String _getDefaultTitle() {
    return widget.userRole == 'bride' ? 'Find Vendors' : 'Explore Map';
  }

  void _onSearch(String query) {
    if (!_mounted) return;
    setState(() => _isSearchExpanded = false);
    // TODO: Implement search with AddressSearchWidget
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
        onEditWedding: () => _showCreateSheet(context),
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
    
    try {
      // Check permissions
      final hasPermission = await _ensureLocationPermission();
      if (!hasPermission || !_mounted) return;
      
      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
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
      debugPrint('Error getting location: $e');
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

  void _showMapStyleMenu() {
    if (!_mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: LynewedColors.transparent,
      builder: (sheetContext) => _MapStyleSheet(
        currentStyle: _mapState.mapType,
        onStyleSelected: (style) {
          _mapState.setMapType(style);
          Navigator.pop(sheetContext);
        },
      ),
    );
  }

  void _showCreateSheet(BuildContext ctx) async {
    if (!_mounted) return;
    final isBride = widget.userRole == 'bride';
    
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
        Navigator.of(ctx).pop(); // Hide loader

        // Show create/edit sheet
        showModalBottomSheet(
          context: ctx,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (c) => WeddingCreateSheet(
            existingWedding: existingWedding,
            onSaved: () {
              // Invalidate cache to show updated data
              MarkerDetailsServiceProvider.instance.clearCache();
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text(
                    existingWedding != null 
                      ? 'Wedding updated successfully' 
                      : 'Wedding created successfully'
                  ),
                  backgroundColor: LynewedColors.success,
                ),
              );
              _mapState.refresh(); // Refresh map
            },
            onDeleted: () {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                  content: Text('Wedding deleted successfully'),
                  backgroundColor: LynewedColors.success,
                ),
              );
              _mapState.refresh(); // Refresh map
            },
          ),
        );
      } catch (e) {
        if (!_mounted) return;
        Navigator.of(ctx).pop(); // Hide loader on error
        
        ScaffoldMessenger.of(ctx).showSnackBar(
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
            ScaffoldMessenger.of(ctx).showSnackBar(
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

/// Map style selection sheet
class _MapStyleSheet extends StatelessWidget {
  const _MapStyleSheet({
    required this.currentStyle,
    required this.onStyleSelected,
  });

  final gmaps.MapType currentStyle;
  final ValueChanged<gmaps.MapType> onStyleSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LynewedColors.background,
        borderRadius: LynewedBorders.sheetBorderRadius,
      ),
      padding: LynewedSpacing.allLg,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: EdgeInsets.only(bottom: LynewedSpacing.lg),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: LynewedColors.gray200,
                  borderRadius: LynewedBorders.borderRadiusSm,
                ),
              ),
            ),
            // Title
            Text(
              'Map Style',
              style: LynewedTextStyles.titleLarge,
            ),
            LynewedGap.verticalLg,
            // Options
            _buildStyleOption(
              context,
              title: 'Normal',
              icon: Icons.map_outlined,
              style: gmaps.MapType.normal,
            ),
            _buildStyleOption(
              context,
              title: 'Satellite',
              icon: Icons.satellite_alt,
              style: gmaps.MapType.satellite,
            ),
            _buildStyleOption(
              context,
              title: 'Terrain',
              icon: Icons.terrain,
              style: gmaps.MapType.terrain,
            ),
            _buildStyleOption(
              context,
              title: 'Hybrid',
              icon: Icons.layers,
              style: gmaps.MapType.hybrid,
            ),
            LynewedGap.verticalMd,
          ],
        ),
      ),
    );
  }

  Widget _buildStyleOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required gmaps.MapType style,
  }) {
    final isSelected = currentStyle == style;
    
    return InkWell(
      onTap: () => onStyleSelected(style),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: LynewedSpacing.lg,
          vertical: LynewedSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected ? LynewedColors.surface : LynewedColors.transparent,
          borderRadius: LynewedBorders.borderRadiusMd,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? LynewedColors.primary : LynewedColors.textSecondary,
              size: 24,
            ),
            LynewedGap.horizontalMd,
            Expanded(
              child: Text(
                title,
                style: LynewedTextStyles.bodyLarge.copyWith(
                  color: isSelected ? LynewedColors.primary : LynewedColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: LynewedColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

/// Widget qui charge les détails d'un marker et affiche le sheet approprié
class _MarkerDetailsLoader extends StatefulWidget {
  const _MarkerDetailsLoader({
    required this.marker,
    required this.userRole,
    this.onEditWedding,
  });

  final MapMarker marker;
  final String userRole;
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

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final details = await _detailsService.getDetailsForMarker(widget.marker);
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
        decoration: BoxDecoration(
          color: LynewedColors.background,
          borderRadius: LynewedBorders.sheetBorderRadius,
        ),
        padding: EdgeInsets.all(LynewedSpacing.xxxl + LynewedSpacing.sm),
        child: Center(
          child: CircularProgressIndicator(
            color: LynewedColors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_error != null || _details == null) {
      return Container(
        decoration: BoxDecoration(
          color: LynewedColors.background,
          borderRadius: LynewedBorders.sheetBorderRadius,
        ),
        padding: EdgeInsets.all(LynewedSpacing.xxxl + LynewedSpacing.sm),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
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
        return ProfessionalDetailsSheet(
          // Key ensures widget rebuilds when favorite status changes
          key: ValueKey('pro_${proDetails.id}_fav_${proDetails.isFavorited}'),
          details: proDetails,
          onContact: () => _handleContact(context),
          onFavoriteToggle: () => _handleFavoriteToggle(context),
          onViewProfile: () => _handleViewProfile(context),
          // Only show favorite button for brides (adds to wishlist)
          showFavoriteButton: widget.userRole == 'bride',
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
    
    // EXACT same logic as ItemAllAlertWidget (lines 222-256)
    // This is the code that WORKS in dashboard_pro
    final proDetails = await actions.getProItemDetailsAction(
      alertDetails.authorId,
    );
    
    if (!mounted) return;
    
    if (proDetails?.proProfileId != null && proDetails!.proProfileId.isNotEmpty) {
      // Close the sheet first
      Navigator.of(context).pop();
      
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
      ScaffoldMessenger.of(context).showSnackBar(
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Alert deleted' : 'Failed to delete alert'),
        ),
      );
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
}
