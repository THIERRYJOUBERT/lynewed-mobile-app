/// MapPage - Unified map page for bride and professional users
/// 
/// Replaces duplicated map_brides_large_widget.dart and map_pro_large_widget.dart
/// with a single, clean implementation.
library;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:provider/provider.dart';

import '../../domain/entities/entities.dart';
import '../../domain/repositories/map_repository.dart';
import '../../domain/usecases/get_marker_details.dart';
import '../../data/repositories/supabase_map_repository.dart';
import '../state/map_state.dart';
import '../widgets/lynewed_map_widget.dart';
import '../widgets/filter_sheet.dart';
import '../sheets/sheets.dart';

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
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;

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
    _searchController.dispose();
    _mapState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _mapState,
      child: Scaffold(
        body: Stack(
          children: [
            // Map widget
            LynewedMapWidget(
              userRole: widget.userRole,
              config: LynewedMapConfig(
                initialCenter: widget.config.initialCenter,
                initialZoom: widget.config.initialZoom,
                padding: EdgeInsets.only(
                  top: widget.config.showAppBar ? 100 : 0,
                  bottom: 80,
                ),
              ),
              onMarkerTap: _onMarkerTap,
              repository: widget.repository,
            ),

            // Top bar with search
            if (widget.config.showAppBar || widget.config.showSearchBar)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildTopBar(context),
              ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomControls(context),
            ),

            // My location button
            if (widget.config.showMyLocationButton)
              Positioned(
                right: 16,
                bottom: 100,
                child: _buildMyLocationButton(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main bar
            Row(
              children: [
                // Back button
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),

                // Search field
                if (widget.config.showSearchBar)
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: _getSearchHint(),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onTap: () {
                        setState(() => _isSearchExpanded = true);
                      },
                      onSubmitted: _onSearch,
                    ),
                  )
                else
                  Expanded(
                    child: Text(
                      widget.config.title ?? _getDefaultTitle(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),

                // Filter button
                if (widget.config.showFilterButton)
                  Consumer<MapState>(
                    builder: (context, state, _) {
                      final hasActiveFilters = state.filter.hasProfessionFilter ||
                          state.filter.hasBudgetFilter;
                      return IconButton(
                        icon: Badge(
                          isLabelVisible: hasActiveFilters,
                          child: const Icon(Icons.tune),
                        ),
                        onPressed: () => _showFilterSheet(context),
                      );
                    },
                  ),
              ],
            ),

            // Search suggestions (expanded)
            if (_isSearchExpanded)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: _buildSearchSuggestions(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    // TODO: Intégrer avec AddressSearchWidget existant
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'Search for a location',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          TextButton(
            onPressed: () => setState(() => _isSearchExpanded = false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Layer toggles
            if (widget.config.showLayerToggle)
              Expanded(
                child: _buildLayerToggles(context),
              )
            else
              const Spacer(),

            // Markers count
            Consumer<MapState>(
              builder: (context, state, _) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    '${state.visibleMarkersCount} results',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayerToggles(BuildContext context) {
    return Consumer<MapState>(
      builder: (context, state, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildToggleChip(
                label: 'Pros',
                isActive: state.filter.toggles.showPros,
                onTap: () => state.updateToggles(
                  state.filter.toggles.copyWith(
                    showPros: !state.filter.toggles.showPros,
                  ),
                ),
              ),
              _buildToggleChip(
                label: 'Alerts',
                isActive: state.filter.toggles.showAlerts,
                onTap: () => state.updateToggles(
                  state.filter.toggles.copyWith(
                    showAlerts: !state.filter.toggles.showAlerts,
                  ),
                ),
              ),
              if (widget.userRole == 'professional')
                _buildToggleChip(
                  label: 'Weddings',
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

  Widget _buildToggleChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMyLocationButton(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: 'myLocation',
      backgroundColor: Colors.white,
      foregroundColor: Theme.of(context).primaryColor,
      onPressed: _goToMyLocation,
      child: const Icon(Icons.my_location),
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
    setState(() => _isSearchExpanded = false);
    // TODO: Implement search with AddressSearchWidget
  }

  void _onMarkerTap(MapMarker marker) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MarkerDetailsLoader(
        marker: marker,
        userRole: widget.userRole,
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterSheet(
        currentFilter: _mapState.filter,
        userRole: widget.userRole,
        onApply: (filter) {
          _mapState.updateFilter(filter);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _goToMyLocation() {
    // TODO: Implement with Geolocator
  }
}

/// Widget qui charge les détails d'un marker et affiche le sheet approprié
class _MarkerDetailsLoader extends StatefulWidget {
  const _MarkerDetailsLoader({
    required this.marker,
    required this.userRole,
  });

  final MapMarker marker;
  final String userRole;

  @override
  State<_MarkerDetailsLoader> createState() => _MarkerDetailsLoaderState();
}

class _MarkerDetailsLoaderState extends State<_MarkerDetailsLoader> {
  final _detailsService = MarkerDetailsServiceProvider.instance;
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(40),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null || _details == null) {
      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to load details',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      );
    }

    // Afficher le sheet approprié selon le type de marker
    switch (widget.marker.type) {
      case MapMarkerType.proFixedLocation:
        return ProfessionalDetailsSheet(
          details: _details as ProfessionalDetails,
          onContact: () => _handleContact(context),
          onFavoriteToggle: () => _handleFavoriteToggle(context),
          onViewProfile: () => _handleViewProfile(context),
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
        );

      case MapMarkerType.poiPrivate:
        // POI deprecated, show error
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(40),
          child: const Center(
            child: Text('POI feature has been deprecated'),
          ),
        );
    }
  }

  // Action handlers - à connecter avec la navigation et les services
  void _handleContact(BuildContext context) {
    Navigator.pop(context);
    // TODO: Navigate to chat or contact flow
    debugPrint('Contact professional: ${widget.marker.id}');
  }

  void _handleFavoriteToggle(BuildContext context) {
    // TODO: Toggle favorite via Supabase
    debugPrint('Toggle favorite: ${widget.marker.id}');
  }

  void _handleViewProfile(BuildContext context) {
    Navigator.pop(context);
    // TODO: Navigate to professional profile page
    debugPrint('View profile: ${widget.marker.id}');
  }

  void _handleHelp(BuildContext context) {
    Navigator.pop(context);
    // TODO: Navigate to chat with alert author
    debugPrint('Help with alert: ${widget.marker.id}');
  }

  void _handleViewAuthorProfile(BuildContext context) {
    Navigator.pop(context);
    // TODO: Navigate to author profile
    debugPrint('View author profile: ${(_details as AlertDetails).authorId}');
  }

  void _handleDeleteAlert(BuildContext context) {
    Navigator.pop(context);
    // TODO: Delete alert via Supabase
    debugPrint('Delete alert: ${widget.marker.id}');
  }

  void _handleContactBride(BuildContext context) {
    Navigator.pop(context);
    // TODO: Navigate to contact bride flow
    debugPrint('Contact bride: ${(_details as WeddingDetails).brideId}');
  }

  void _handleViewBrideProfile(BuildContext context) {
    Navigator.pop(context);
    // TODO: Navigate to bride profile
    debugPrint('View bride profile: ${(_details as WeddingDetails).brideId}');
  }
}
