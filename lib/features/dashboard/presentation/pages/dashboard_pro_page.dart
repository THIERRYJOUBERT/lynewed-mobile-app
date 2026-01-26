/// DashboardProPage - Clean Architecture
///
/// Professional dashboard with stats, alerts, and quick actions.
/// Uses DashboardCubit for state management via ChangeNotifier pattern.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '/core/design/design.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/components/nav/nav_bar_pro/nav_bar_pro_widget.dart';
import '/features/chat/presentation/pages/messages_page.dart';
import '/features/wishlist/presentation/pages/wishlist_pro_page.dart';
import '/features/map/presentation/widgets/lynewed_mini_map.dart';
import '/flutter_flow/custom_functions.dart' as functions;

import '../../domain/entities/pro_stats.dart';
import '../bloc/dashboard_cubit.dart';
import '../bloc/dashboard_state.dart';
import 'package:lynewed_beta/features/map/domain/entities/professional_alert.dart';
import 'package:lynewed_beta/features/map/domain/entities/alert_details.dart';
import '/actions/actions.dart' as action_blocks;

/// Professional dashboard page with Clean Architecture.
///
/// Displays:
/// - Header with title and action icons
/// - Interactive map section
/// - Community alerts carousel
/// - Quick action buttons
class DashboardProPage extends StatefulWidget {
  const DashboardProPage({super.key});

  static const String routeName = 'DashboardProPage';
  static const String routePath = '/dashboardProPage';

  @override
  State<DashboardProPage> createState() => _DashboardProPageState();
}

class _DashboardProPageState extends State<DashboardProPage>
    with WidgetsBindingObserver {
  late DashboardCubit _cubit;
  late NavBarProModel _navBarProModel;
  PageController? _pageViewController;
  LatLng? _currentUserLocation;
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    _cubit = DashboardCubit();
    _navBarProModel = NavBarProModel();
    _cubit.loadDashboard();

    getCurrentUserLocation(
      defaultLocation: const LatLng(0.0, 0.0),
      cached: true,
    ).then((loc) {
      if (mounted) {
        setState(() => _currentUserLocation = loc);
      }
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isFirstBuild) {
      _cubit.refresh();
    }
    _isFirstBuild = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _cubit.refresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cubit.dispose();
    _navBarProModel.dispose();
    _pageViewController?.dispose();
    super.dispose();
  }

  bool get _isUltimate =>
      FFAppState().selfProSubscription.subscriptionTier ==
      SubscriptionTierType.ultimateAccess;

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    if (_currentUserLocation == null) {
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

    return ChangeNotifierProvider.value(
      value: _cubit,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor: LynewedColors.background,
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                // Main content
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 110.0, 20.0, 84.0),
                  child: Consumer<DashboardCubit>(
                    builder: (context, cubit, _) {
                      final state = cubit.state;

                      if (state is DashboardLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              LynewedColors.primary,
                            ),
                          ),
                        );
                      }

                      if (state is DashboardError) {
                        return _buildError(state.message);
                      }

                      final stats = cubit.stats;
                      return SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            if (stats != null) _buildStatsSection(stats),
                            _buildMapSection(),
                            _buildAlertsSection(cubit.alerts),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Bottom Navigation
                Align(
                  alignment: Alignment.bottomCenter,
                  child: NavBarProWidget(
                    number: 1,
                  ),
                ),
                // Header
                _buildHeader(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48.0,
            color: LynewedColors.error,
          ),
          const SizedBox(height: 16.0),
          Text(
            message,
            style: LynewedTextStyles.bodyMedium.copyWith(
              color: LynewedColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          LynewedButton(
            text: 'Retry',
            onPressed: () => _cubit.loadDashboard(),
            type: LynewedButtonType.secondary,
          ),
        ],
      ),
    );
  }

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
                        style:
                            LynewedTextStyles.sheetTitle.copyWith(fontSize: 18.0),
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
                      if (_isUltimate) ...[
                        _buildHeaderIcon(
                          icon: Icons.favorite_border,
                          onTap: () =>
                              context.pushNamed(WishlistProPage.routeName),
                        ),
                        const SizedBox(width: 14.0),
                      ],
                      _buildBadgeIcon(
                        icon: Icons.notifications_outlined,
                        count: FFAppState().unreadNotificationsCount,
                        onTap: () =>
                            context.pushNamed(NotificationsPage.routeName),
                      ),
                      const SizedBox(width: 14.0),
                      _buildBadgeIcon(
                        icon: Icons.chat_bubble_outline_sharp,
                        count: FFAppState().unreadMessagesCount,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MessagesPage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14.0),
                      _buildHeaderIcon(
                        icon: Icons.settings_outlined,
                        onTap: () => context
                            .pushNamed(ProfileBridesAndProWidget.routeName),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14.0),
            const Divider(
              height: 1.0,
              thickness: 1.0,
              color: LynewedColors.gray200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
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
            Icon(icon, color: LynewedColors.textPrimary, size: 24.0),
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

  Widget _buildStatsSection(ProStats stats) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR STATS',
            style: LynewedTextStyles.sectionTitle,
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              _buildStatCard(
                icon: Icons.visibility_outlined,
                value: stats.profileViews.toString(),
                label: 'Views',
              ),
              const SizedBox(width: 12.0),
              _buildStatCard(
                icon: Icons.favorite_outline,
                value: stats.savedCount.toString(),
                label: 'Saved',
              ),
              const SizedBox(width: 12.0),
              _buildStatCard(
                icon: Icons.chat_bubble_outline,
                value: stats.messageCount.toString(),
                label: 'Messages',
              ),
              const SizedBox(width: 12.0),
              _buildStatCard(
                icon: Icons.notifications_active_outlined,
                value: stats.alertCount.toString(),
                label: 'Alerts',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20.0, color: LynewedColors.primary),
            const SizedBox(height: 4.0),
            Text(
              value,
              style: LynewedTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: LynewedColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: LynewedTextStyles.labelSmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'INTERACTIVE MAP',
            style: LynewedTextStyles.sectionTitle,
          ),
          const SizedBox(height: 4.0),
          Text(
            'Open the map for detailed searches',
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            width: double.infinity,
            height: 300.0,
            child: LynewedMiniMap(
              width: MediaQuery.sizeOf(context).width,
              height: 300.0,
              initialZoom: 14.0,
              borderRadius: 0.0,
              center: _currentUserLocation!,
              markerStyle: MarkerStyleInfoStruct(
                avatarUrl: FFAppState().selfPublicProfile.avatarUrl,
                borderColorHex: functions.professionToStyle(
                  FFAppState().selfProSubscription.profession,
                ),
                isOwn: false,
              ),
              useLiteMode: false,
              mapStyle: MapStyleType.normal,
              onTap: () async => _navigateToMap(),
            ),
          ),
          const SizedBox(height: 16.0),
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

  Widget _buildAlertsSection(List<ProfessionalAlert> alerts) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'COMMUNITY ALERTS',
            style: LynewedTextStyles.sectionTitle,
          ),
          const SizedBox(height: 4.0),
          Text(
            'Professionals nearby need your help',
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16.0),
          _buildAlertsCarousel(alerts),
        ],
      ),
    );
  }

  Widget _buildAlertsCarousel(List<ProfessionalAlert> alerts) {
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

    _pageViewController ??= PageController();

    return SizedBox(
      height: 165.0,
      child: PageView.builder(
        controller: _pageViewController,
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: _AlertCard(
              alert: alert,
              onContact: () => _contactAlertAuthor(alert),
            ),
          );
        },
      ),
    );
  }

  Future<void> _contactAlertAuthor(ProfessionalAlert alert) async {
    await action_blocks.contactChatRoom(
      context,
      targetProfileID: alert.professionalId,
    );
  }
}

/// Alert card widget for the carousel
class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.alert,
    required this.onContact,
  });

  final ProfessionalAlert alert;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: LynewedColors.primary,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 10.0),
          if (alert.description != null && alert.description!.isNotEmpty) ...[
            _buildDescription(),
            const SizedBox(height: 10.0),
          ],
          const Spacer(),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final timeInfo = _getTimeRemaining();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.professionalName ?? 'Unknown',
                      style: LynewedTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (alert.profession != null)
                      Text(
                        alert.profession!.toUpperCase(),
                        style: LynewedTextStyles.labelSmall.copyWith(
                          color: LynewedColors.gray300,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4.0),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getAlertIcon(alert.type),
                          size: 14.0,
                          color: _getAlertColor(alert.type),
                        ),
                        const SizedBox(width: 4.0),
                        Flexible(
                          child: Text(
                            _getAlertTypeName(alert.type),
                            style: LynewedTextStyles.labelLarge.copyWith(
                              color: _getAlertColor(alert.type),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (timeInfo.text.isNotEmpty)
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.topRight,
              child: Text(
                timeInfo.text,
                style: LynewedTextStyles.labelLarge.copyWith(
                  color: timeInfo.isExpiringSoon
                      ? LynewedColors.error
                      : LynewedColors.gray300,
                  fontWeight:
                      timeInfo.isExpiringSoon ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatar() {
    final hasAvatar =
        alert.professionalAvatarUrl != null &&
        alert.professionalAvatarUrl!.isNotEmpty;

    return Container(
      width: 48.0,
      height: 48.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: LynewedColors.gray200,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: hasAvatar
            ? CachedNetworkImage(
                imageUrl: alert.professionalAvatarUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => _buildInitials(),
                errorWidget: (_, __, ___) => _buildInitials(),
              )
            : _buildInitials(),
      ),
    );
  }

  Widget _buildInitials() {
    final initials = _getInitials(alert.professionalName ?? '');
    return Center(
      child: Text(
        initials,
        style: LynewedTextStyles.labelLarge.copyWith(
          color: LynewedColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      alert.description!,
      style: LynewedTextStyles.bodySmall.copyWith(
        color: Colors.white.withValues(alpha: 0.9),
        height: 1.3,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (alert.title != null && alert.title!.isNotEmpty)
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14.0,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4.0),
                Flexible(
                  child: Text(
                    alert.title!,
                    style: LynewedTextStyles.labelLarge.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )
        else
          const Spacer(),
        const SizedBox(width: 12.0),
        GestureDetector(
          onTap: onContact,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 40.0,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.handshake_outlined,
                  size: 18.0,
                  color: LynewedColors.primary,
                ),
                const SizedBox(width: 6.0),
                Text(
                  'I can help',
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: LynewedColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _TimeInfo _getTimeRemaining() {
    final expiresAt = alert.expiresAt;
    if (expiresAt == null) {
      return const _TimeInfo(text: '', isExpiringSoon: false);
    }

    final now = DateTime.now();
    final diff = expiresAt.difference(now);

    if (diff.isNegative) {
      return const _TimeInfo(text: 'Expired', isExpiringSoon: true);
    }

    final isExpiringSoon = diff.inHours < 2;

    String text;
    if (diff.inDays > 0) {
      text = '${diff.inDays}d left';
    } else if (diff.inHours > 0) {
      text = '${diff.inHours}h left';
    } else if (diff.inMinutes > 0) {
      text = '${diff.inMinutes}m left';
    } else {
      text = 'Expiring soon';
    }

    return _TimeInfo(text: text, isExpiringSoon: isExpiringSoon);
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.backupNeeded:
        return Icons.person_search_outlined;
      case AlertType.gearEmergency:
        return Icons.camera_alt_outlined;
      case AlertType.teamMember:
        return Icons.groups_outlined;
      case AlertType.emergencyHelp:
        return Icons.warning_amber_rounded;
      case AlertType.other:
        return Icons.notifications_none_outlined;
    }
  }

  Color _getAlertColor(AlertType type) {
    switch (type) {
      case AlertType.emergencyHelp:
        return LynewedColors.error;
      case AlertType.gearEmergency:
        return const Color(0xFFFF9500);
      case AlertType.backupNeeded:
        return const Color(0xFF007AFF);
      case AlertType.teamMember:
        return LynewedColors.success;
      case AlertType.other:
        return LynewedColors.textSecondary;
    }
  }

  String _getAlertTypeName(AlertType type) {
    switch (type) {
      case AlertType.backupNeeded:
        return 'Backup Needed';
      case AlertType.gearEmergency:
        return 'Gear Emergency';
      case AlertType.teamMember:
        return 'Team Member';
      case AlertType.emergencyHelp:
        return 'Emergency Help';
      case AlertType.other:
        return 'Alert';
    }
  }
}

class _TimeInfo {
  const _TimeInfo({
    required this.text,
    required this.isExpiringSoon,
  });

  final String text;
  final bool isExpiringSoon;
}
