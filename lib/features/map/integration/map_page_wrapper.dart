/// Map Page Wrapper - Replaces FlutterFlow map pages
/// 
/// This wrapper provides the same routes and functionality as the
/// old FlutterFlow pages while using the new Clean Architecture module.
/// 
/// Features:
/// - Same routes (/mapBridesLarge, /mapProLarge)
/// - Reuses existing FlutterFlow sheet widgets
/// - Integrates with FFAppState for user preferences
/// - Maintains callback compatibility
library;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:provider/provider.dart';

// FlutterFlow imports (reuse existing sheets and actions)
import '/backend/schema/enums/enums.dart' as ff_enums;
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/custom_code/actions/index.dart' as actions;

// Existing FlutterFlow sheet widgets (reused)
import '/compo_finaux/info_pro_item_sheet/info_pro_item_sheet_widget.dart';
import '/compo_finaux/info_poi_sheet/info_poi_sheet_widget.dart';
import '/compo_finaux/info_wedding_pin_sheet/info_wedding_pin_sheet_widget.dart';
import '/compo_finaux/info_alert_item_sheet/info_alert_item_sheet_widget.dart';

// New map module
import '../domain/entities/entities.dart';
import '../presentation/widgets/lynewed_map_widget.dart';
import '../presentation/widgets/filter_sheet.dart';

/// Unified Map Page that replaces both MapBridesLarge and MapProLarge
/// 
/// Routes:
/// - /mapBridesLarge → MapPageWrapper(userRole: 'bride')
/// - /mapProLarge → MapPageWrapper(userRole: 'professional')
class MapPageWrapper extends StatefulWidget {
  const MapPageWrapper({
    super.key,
    required this.userRole,
    this.initialCenter,
  });

  final String userRole;
  final LatLng? initialCenter;

  // Route configuration for bride
  static const String brideRouteName = 'MapBridesLarge';
  static const String brideRoutePath = '/mapBridesLarge';

  // Route configuration for pro
  static const String proRouteName = 'MapProLarge';
  static const String proRoutePath = '/mapProLarge';

  @override
  State<MapPageWrapper> createState() => _MapPageWrapperState();
}

class _MapPageWrapperState extends State<MapPageWrapper> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng? currentUserLocationValue;
  
  // Filter state (from FFAppState preferences)
  late MapFilter _currentFilter;
  
  // Loading state
  bool _isLoadingDetails = false;
  
  // User market region for profession filtering
  String _userMarket = 'GLOBAL';

  @override
  void initState() {
    super.initState();
    _initializeFromFFAppState();
    _getCurrentLocation();
    _loadUserMarket();
  }
  
  /// Load user's market region for profession filtering
  Future<void> _loadUserMarket() async {
    final market = await actions.getUserMarketRegion();
    if (mounted && market != null) {
      setState(() => _userMarket = market);
    }
  }

  /// Initialize filters from FFAppState preferences
  void _initializeFromFFAppState() {
    final appState = FFAppState();
    final prefs = appState.currentUserPreferences;
    
    _currentFilter = MapFilter(
      currency: prefs.currency.isNotEmpty ? prefs.currency : 'EUR',
      radiusKm: prefs.defaultRadiusKm.toDouble(),
      toggles: const LayerToggles(
        showPros: true,
        showFixedLocations: true,
        showAlerts: true,
        showWeddings: true,
        showOnlyMyProfession: false,
      ),
    );
  }

  /// Get current user location
  void _getCurrentLocation() {
    getCurrentUserLocation(defaultLocation: const LatLng(0.0, 0.0), cached: true)
        .then((loc) {
      if (mounted) {
        setState(() => currentUserLocationValue = loc);
      }
    });
  }

  /// Convert FlutterFlow LatLng to Google Maps LatLng
  gmaps.LatLng? _convertCenter() {
    final center = widget.initialCenter ?? currentUserLocationValue;
    if (center == null) return null;
    return gmaps.LatLng(center.latitude, center.longitude);
  }

  /// Handle marker tap - show appropriate FlutterFlow sheet
  Future<void> _handleMarkerTap(MapMarker marker) async {
    if (_isLoadingDetails) return;
    
    setState(() => _isLoadingDetails = true);
    
    try {
      switch (marker.type) {
        case MapMarkerType.proFixedLocation:
          await _showProDetailsSheet(marker.id);
          break;
        case MapMarkerType.professionalAlert:
          await _showAlertDetailsSheet(marker.id);
          break;
        case MapMarkerType.wedding:
          await _showWeddingDetailsSheet(marker.id);
          break;
      }
    } catch (e) {
      _showErrorDialog('Unable to load details. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoadingDetails = false);
      }
    }
  }

  /// Show professional details sheet (reuses FlutterFlow widget)
  Future<void> _showProDetailsSheet(String proId) async {
    final proDetails = await actions.getProItemDetailsAction(proId);
    if (proDetails == null || !mounted) return;

    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: MediaQuery.viewInsetsOf(context),
          child: InfoProItemSheetWidget(proDetails: proDetails),
        ),
      ),
    );
  }

  /// Show alert details sheet (reuses FlutterFlow widget)
  Future<void> _showAlertDetailsSheet(String alertId) async {
    final alertDetails = await actions.getAlertItemDetailsRpc(alertId);
    if (alertDetails == null || !mounted) return;

    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: MediaQuery.viewInsetsOf(context),
          child: InfoAlertItemSheetWidget(alertDetails: alertDetails),
        ),
      ),
    );
  }

  /// Show wedding details sheet (reuses FlutterFlow widget)
  Future<void> _showWeddingDetailsSheet(String weddingId) async {
    final weddingDetails = await actions.getWeddingPinItemDetailsRpc(weddingId);
    if (weddingDetails == null || !mounted) return;

    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: MediaQuery.viewInsetsOf(context),
          child: InfoWeddingPinSheetWidget(weddingPinData: weddingDetails),
        ),
      ),
    );
  }

  /// Show POI details sheet (reuses FlutterFlow widget)
  Future<void> _showPoiDetailsSheet(String poiId) async {
    final poiDetails = await actions.getPoiItemDetails(poiId);
    if (poiDetails == null || !mounted) return;

    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: MediaQuery.viewInsetsOf(context),
          child: InfoPoiSheetWidget(poiData: poiDetails),
        ),
      ),
    );
  }

  /// Show filter sheet (uses new FilterSheet)
  Future<void> _showFilterSheet() async {
    final result = await showModalBottomSheet<MapFilter>(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => FilterSheet(
        currentFilter: _currentFilter,
        userRole: widget.userRole,
        userMarket: _userMarket,
        onApply: (filter) => Navigator.pop(context, filter),
      ),
    );

    if (result != null && mounted) {
      setState(() => _currentFilter = result);
    }
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    // Show loading while getting location
    if (currentUserLocationValue == null) {
      return Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              FlutterFlowTheme.of(context).primary,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Stack(
          children: [
            // Map widget
            LynewedMapWidget(
              userRole: widget.userRole,
              config: LynewedMapConfig(
                initialCenter: _convertCenter(),
                initialZoom: 12.0,
                enableMyLocation: true,
                enableZoomControls: true,
              ),
              initialFilter: _currentFilter,
              onMarkerTap: _handleMarkerTap,
            ),

            // Top bar with back button and search
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  // Back button
                  Container(
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: FlutterFlowIconButton(
                      borderRadius: 20,
                      buttonSize: 40,
                      icon: Icon(
                        Icons.arrow_back,
                        color: FlutterFlowTheme.of(context).primaryText,
                        size: 24,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Search bar (placeholder - integrate AddressSearchWidget)
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(
                            Icons.search,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Search location...',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Filter button
                  Container(
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: FlutterFlowIconButton(
                      borderRadius: 20,
                      buttonSize: 40,
                      icon: Icon(
                        Icons.filter_list,
                        color: FlutterFlowTheme.of(context).primaryText,
                        size: 24,
                      ),
                      onPressed: _showFilterSheet,
                    ),
                  ),
                ],
              ),
            ),

            // Loading indicator for details
            if (_isLoadingDetails)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Convenience constructors for specific roles
class MapBridesLargeWrapper extends MapPageWrapper {
  const MapBridesLargeWrapper({
    super.key,
    super.initialCenter,
  }) : super(userRole: 'bride');

  static String routeName = MapPageWrapper.brideRouteName;
  static String routePath = MapPageWrapper.brideRoutePath;
}

class MapProLargeWrapper extends MapPageWrapper {
  const MapProLargeWrapper({
    super.key,
    super.initialCenter,
  }) : super(userRole: 'professional');

  static String routeName = MapPageWrapper.proRouteName;
  static String routePath = MapPageWrapper.proRoutePath;
}
