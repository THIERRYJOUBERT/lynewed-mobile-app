import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '/actions/actions.dart' as action_blocks;
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/components/nav/nav_bar_pro/nav_bar_pro_widget.dart';
import '/core/design/design.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/features/chat/presentation/pages/messages_page.dart';
import '/features/dashboard/presentation/widgets/alert_item_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'dashboard_pro_model.dart';

export 'dashboard_pro_model.dart';

class DashboardProWidget extends StatefulWidget {
  const DashboardProWidget({super.key});

  static String routeName = 'DashboardPro';
  static String routePath = '/dashboardPro';

  @override
  State<DashboardProWidget> createState() => _DashboardProWidgetState();
}

class _DashboardProWidgetState extends State<DashboardProWidget> with WidgetsBindingObserver {
  late DashboardProModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng? currentUserLocationValue;
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DashboardProModel());
    
    // Initialize alerts future
    _model.refreshAlerts();

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await actions.refreshUnreadCounts();
      if (mounted) {
        safeSetState(() {});
      }
    });

    getCurrentUserLocation(defaultLocation: const LatLng(0.0, 0.0), cached: true)
        .then((loc) => safeSetState(() => currentUserLocationValue = loc));
    
    // Register for app lifecycle events
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh alerts when returning to page (skip first build)
    if (!_isFirstBuild && _model.alertsFuture != null) {
      _refreshAlerts();
    }
    _isFirstBuild = false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _model.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _refreshAlerts();
    }
  }
  
  /// Refresh alerts list (called after alert deletion or creation)
  void _refreshAlerts() {
    _model.refreshAlerts();
    safeSetState(() {});
  }

  /// Check if current user has Ultimate subscription (for wishlist icon)
  bool get _isUltimate => 
      FFAppState().selfProSubscription.subscriptionTier == SubscriptionTierType.ultimateAccess;

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    if (currentUserLocationValue == null) {
      return Container(
        color: LynewedColors.background,
        child: const Center(
          child: SizedBox(
            width: 50.0,
            height: 50.0,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: LynewedColors.background,
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 110.0, 20.0, 84.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Map Section
                      _buildMapSection(),
                      // Alerts Section
                      _buildAlertsSection(),
                    ],
                  ),
                ),
              ),
              // Bottom Navigation
              Align(
                alignment: Alignment.bottomCenter,
                child: wrapWithModel(
                  model: _model.navBarProModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const NavBarProWidget(number: 1),
                ),
              ),
              // Header
              _buildHeader(),
            ],
          ),
        ),
      ),
    );
  }

  /// Header with title and action icons
  Widget _buildHeader() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        height: 110.0,
        decoration: const BoxDecoration(color: LynewedColors.background),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Title with "Pro" badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'HOME',
                        style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 18.0),
                      ),
                      const SizedBox(width: 8.0),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 2.0),
                        child: Text(
                          'Pro',
                          style: LynewedTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  // Action icons
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Favorites (only for Ultimate)
                      if (_isUltimate) ...[
                        _buildHeaderIcon(
                          icon: Icons.favorite_border,
                          onTap: () => context.pushNamed(WishlistProWidget.routeName),
                        ),
                        const SizedBox(width: 14.0),
                      ],
                      // Notifications
                      _buildBadgeIcon(
                        icon: Icons.notifications_outlined,
                        count: FFAppState().unreadNotificationsCount,
                        onTap: () => context.pushNamed(NotificationsPage.routeName),
                      ),
                      const SizedBox(width: 14.0),
                      // Messages
                      _buildBadgeIcon(
                        icon: Icons.chat_bubble_outline_sharp,
                        count: FFAppState().unreadMessagesCount,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MessagesPage()),
                        ),
                      ),
                      const SizedBox(width: 14.0),
                      // Settings / Profile
                      _buildHeaderIcon(
                        icon: Icons.settings_outlined,
                        onTap: () => context.pushNamed(ProfileBridesAndProWidget.routeName),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14.0),
            const Divider(height: 1.0, thickness: 1.0, color: LynewedColors.gray200),
          ],
        ),
      ),
    );
  }

  /// Header icon without badge - taille fixe 32x32 pour alignement uniforme
  Widget _buildHeaderIcon({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 32.0,
        height: 32.0,
        child: Center(
          child: Icon(icon, color: LynewedColors.textPrimary, size: 24.0),
        ),
      ),
    );
  }

  /// Header icon with badge count - taille fixe 32x32 pour alignement uniforme
  Widget _buildBadgeIcon({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 32.0,
        height: 32.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Icône centrée
            Icon(icon, color: LynewedColors.textPrimary, size: 24.0),
            // Badge en haut à droite (si count > 0)
            if (count > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 16.0,
                  height: 16.0,
                  decoration: BoxDecoration(
                    color: LynewedColors.primary,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Text(
                      count > 99 ? '99+' : count.toString(),
                      style: LynewedTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontSize: 9.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Map section with mini map and CTA button
  Widget _buildMapSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          const Text(
            'INTERACTIVE MAP',
            style: LynewedTextStyles.sectionTitle,
          ),
          const SizedBox(height: 4.0),
          Text(
            'Open the map for detailed searches',
            style: LynewedTextStyles.bodySmall.copyWith(color: LynewedColors.textSecondary),
          ),
          const SizedBox(height: 16.0),
          // Mini Map
          SizedBox(
            width: double.infinity,
            height: 300.0,
            child: custom_widgets.LynewedMiniMap(
              width: MediaQuery.sizeOf(context).width,
              height: 300.0,
              initialZoom: 14.0,
              borderRadius: 0.0,
              center: currentUserLocationValue!,
              markerStyle: MarkerStyleInfoStruct(
                avatarUrl: FFAppState().selfPublicProfile.avatarUrl,
                borderColorHex: functions.professionToStyle(
                    FFAppState().selfProSubscription.profession),
                isOwn: false,
              ),
              useLiteMode: false,
              mapStyle: MapStyleType.normal,
              onTap: () async {
                _navigateToMap();
              },
            ),
          ),
          const SizedBox(height: 16.0),
          // CTA Button - Design System v3
          LynewedButton(
            text: 'Find events or create alerts',
            onPressed: _navigateToMap,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  void _navigateToMap() {
    context.pushNamed(
      MapProLargeWidget.routeName,
      extra: <String, dynamic>{
        kTransitionInfoKey: const TransitionInfo(
          hasTransition: true,
          transitionType: PageTransitionType.fade,
          duration: Duration(milliseconds: 0),
        ),
      },
    );
  }

  /// Alerts section - Design System v3
  Widget _buildAlertsSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          const Text(
            'COMMUNITY ALERTS',
            style: LynewedTextStyles.sectionTitle,
          ),
          const SizedBox(height: 4.0),
          Text(
            'Professionals nearby need your help',
            style: LynewedTextStyles.bodySmall.copyWith(color: LynewedColors.textSecondary),
          ),
          const SizedBox(height: 16.0),
          // Paged alerts carousel
          _buildAlertsCarousel(),
        ],
      ),
    );
  }

  /// Paged alerts carousel with snap and navigation chevrons
  Widget _buildAlertsCarousel() {
    return FutureBuilder<List<AlertItemDataStruct>>(
      future: _model.alertsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: SizedBox(
                width: 24.0,
                height: 24.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
                ),
              ),
            ),
          );
        }

        final alerts = snapshot.data!;
        if (alerts.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: LynewedColors.surface,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.notifications_none,
                  color: LynewedColors.gray300,
                  size: 32.0,
                ),
                const SizedBox(height: 8.0),
                Text(
                  'No alerts nearby',
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'When professionals need help, their alerts will appear here',
                  textAlign: TextAlign.center,
                  style: LynewedTextStyles.bodySmall.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        // Initialize page controller if needed
        _model.pageViewController ??= PageController();

        return SizedBox(
          height: 165.0,
          child: PageView.builder(
            controller: _model.pageViewController,
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: AlertItemWidget(
                  key: Key('alert_${alert.alertId}'),
                  alert: alert,
                  onContact: () => _contactAlertAuthor(alert),
                  onDelete: alert.isOwn ? () => _deleteAlert(alert.alertId) : null,
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Contact the alert author to offer help
  Future<void> _contactAlertAuthor(AlertItemDataStruct alert) async {
    await action_blocks.contactChatRoom(
      context,
      targetProfileID: alert.authorProfileId,
    );
  }

  /// Delete an alert
  Future<void> _deleteAlert(String alertId) async {
    try {
      await ProfessionalAlertsTable().delete(
        matchingRows: (row) => row.eq('id', alertId),
      );
      _refreshAlerts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Alert deleted',
              style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: LynewedColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete alert',
              style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: LynewedColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

}
