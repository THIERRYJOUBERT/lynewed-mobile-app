import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '/actions/actions.dart' as action_blocks;
import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/components/nav/nav_bar_pro/nav_bar_pro_widget.dart';
import '/core/design/design.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/features/chat/presentation/pages/messages_page.dart';
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
                        onTap: () => context.pushNamed(NotificationsPageWidget.routeName),
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
          // Simple header: icon + title
          const Row(
            children: [
              Icon(
                Icons.notifications_active,
                color: LynewedColors.error,
                size: 20.0,
              ),
              SizedBox(width: 8.0),
              Text(
                'ALERTS',
                style: LynewedTextStyles.sectionTitle,
              ),
            ],
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
    return FutureBuilder<List<ProfessionalAlertsRow>>(
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
          height: 120.0,
          child: PageView.builder(
            controller: _model.pageViewController,
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              final isOwn = alert.authorProfileId == currentUserUid;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _ProAlertTile(
                  key: Key('alert_${alert.id}'),
                  alertType: alert.alertType ?? '',
                  title: alert.title,
                  message: alert.message,
                  locationLabel: alert.locationLabel,
                  expiresAt: alert.expiresAt,
                  isOwn: isOwn,
                  onTap: isOwn 
                      ? () => _deleteAlert(alert.id)
                      : () => _contactAlertAuthor(alert),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Contact the alert author to offer help
  Future<void> _contactAlertAuthor(ProfessionalAlertsRow alert) async {
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

/// Alert Tile for Dashboard - Design System v3
/// 
/// Displays alert info in a compact card format:
/// - Alert type icon (adaptive) + title + location + time
/// - Message preview
/// - Tap to contact (or delete if own alert)
class _ProAlertTile extends StatelessWidget {
  final String alertType;
  final String title;
  final String? message;
  final String? locationLabel;
  final DateTime? expiresAt;
  final bool isOwn;
  final VoidCallback? onTap;

  const _ProAlertTile({
    super.key,
    required this.alertType,
    required this.title,
    this.message,
    this.locationLabel,
    this.expiresAt,
    this.isOwn = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.fromLTRB(12.0, 14.0, 10.0, 8.0),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: Icon + Title + Action (delete/contact)
            Row(
              children: [
                // Alert type icon
                Icon(
                  _getAlertIcon(),
                  color: LynewedColors.textSecondary,
                  size: 24.0,
                ),
                const SizedBox(width: 10.0),
                // Title
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LynewedTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                // Action icon: delete (own) or contact (other's)
                if (isOwn)
                  const Icon(
                    Icons.close,
                    color: LynewedColors.error,
                    size: 20.0,
                  )
                else
                  const Icon(
                    Icons.chat_bubble_outline,
                    color: LynewedColors.primary,
                    size: 20.0,
                  ),
              ],
            ),
            const SizedBox(height: 4.0),
            // Row 2: Location + Duration (always on same line)
            Row(
              children: [
                if (locationLabel != null && locationLabel!.isNotEmpty) ...[
                  const Icon(
                    Icons.location_on_outlined,
                    size: 12.0,
                    color: LynewedColors.textSecondary,
                  ),
                  const SizedBox(width: 2.0),
                  Flexible(
                    child: Text(
                      locationLabel!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LynewedTextStyles.bodySmall.copyWith(
                        color: LynewedColors.textSecondary,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ],
                if (expiresAt != null) ...[
                  if (locationLabel != null && locationLabel!.isNotEmpty)
                    const SizedBox(width: 6.0),
                  Text(
                    '· ${_formatTimeRemaining()}',
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: _isExpiringSoon() 
                          ? LynewedColors.error 
                          : LynewedColors.textSecondary,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ],
            ),
            // Row 3: Message (2 lines max)
            if (message != null && message!.isNotEmpty) ...[
              const SizedBox(height: 8.0),
              Text(
                message!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: LynewedColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getAlertIcon() {
    switch (alertType.toLowerCase()) {
      case 'backup_needed':
        return Icons.person_search_outlined;
      case 'gear_emergency':
        return Icons.camera_alt_outlined;
      case 'team_member':
        return Icons.groups_outlined;
      case 'emergency_help':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_none_outlined;
    }
  }


  String _formatTimeRemaining() {
    if (expiresAt == null) return '';
    final now = DateTime.now();
    final diff = expiresAt!.difference(now);
    
    if (diff.isNegative) return 'Expired';
    if (diff.inDays > 0) return '${diff.inDays}d left';
    if (diff.inHours > 0) return '${diff.inHours}h left';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m left';
    return 'Expiring soon';
  }

  bool _isExpiringSoon() {
    if (expiresAt == null) return false;
    final diff = expiresAt!.difference(DateTime.now());
    return diff.inHours < 2;
  }
}
