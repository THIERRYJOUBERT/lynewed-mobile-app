import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/components/nav/nav_bar_brides/nav_bar_brides_widget.dart';
import '/components/ui_system/empty_state/empty_state_widget.dart';
import '/core/design/design.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/features/chat/presentation/pages/chat_details_page.dart';
import '/features/chat/presentation/pages/messages_page.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'home_brides_model.dart';

export 'home_brides_model.dart';

class HomeBridesWidget extends StatefulWidget {
  const HomeBridesWidget({super.key});

  static String routeName = 'HomeBrides';
  static String routePath = '/homeBrides';

  @override
  State<HomeBridesWidget> createState() => _HomeBridesWidgetState();
}

class _HomeBridesWidgetState extends State<HomeBridesWidget> {
  late HomeBridesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng? currentUserLocationValue;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeBridesModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await Future.wait([
        Future(() async {
          _model.publicRoomsResult =
              await actions.getPublicChatRoomsForBridesAction();
        }),
        Future(() async {
          await actions.refreshUnreadCounts();
        }),
      ]);
      if (!mounted) return;
      _model.psPublicRooms = _model.publicRoomsResult!.items
          .toList()
          .cast<PublicChatRoomItemStruct>();
      if (mounted) {
        safeSetState(() {});
      }
    });

    getCurrentUserLocation(defaultLocation: const LatLng(0.0, 0.0), cached: true)
        .then((loc) => safeSetState(() => currentUserLocationValue = loc));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  // Note: Pour rafraîchir les compteurs quand on revient sur cette page,
  // utiliser un RouteObserver ou didChangeDependencies si nécessaire

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
                      const SizedBox(height: 14.0),
                      const Divider(height: 1.0, thickness: 1.0, color: LynewedColors.gray200),
                      // Chat Rooms Section
                      _buildChatRoomsSection(),
                    ],
                  ),
                ),
              ),
              // Bottom Navigation
              Align(
                alignment: Alignment.bottomCenter,
                child: wrapWithModel(
                  model: _model.navBarBridesModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const NavBarBridesWidget(number: 1),
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
                  Text(
                    'HOME',
                    style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 18.0),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Favorites
                      _buildHeaderIcon(
                        icon: Icons.favorite_border,
                        onTap: () => context.pushNamed(FavProListWidget.routeName),
                      ),
                      const SizedBox(width: 14.0),
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
              initialZoom: 12.0,
              borderRadius: 0.0,
              center: currentUserLocationValue!,
              markerStyle: MarkerStyleInfoStruct(
                avatarUrl: FFAppState().selfPublicProfile.avatarUrl,
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
            text: 'Find vendors or Pin my wedding',
            onPressed: _navigateToMap,
            width: double.infinity,
          ),
          const SizedBox(height: 14.0),
        ],
      ),
    );
  }

  void _navigateToMap() {
    context.pushNamed(
      MapBridesLargeWidget.routeName,
      extra: <String, dynamic>{
        kTransitionInfoKey: const TransitionInfo(
          hasTransition: true,
          transitionType: PageTransitionType.fade,
          duration: Duration(milliseconds: 0),
        ),
      },
    );
  }

  /// Chat Rooms section
  Widget _buildChatRoomsSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: LynewedColors.background),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14.0),
          // Section header
          const Text(
            'CHAT ROOMS',
            style: LynewedTextStyles.sectionTitle,
          ),
          const SizedBox(height: 4.0),
          Text(
            'Ask the community for advice',
            style: LynewedTextStyles.bodySmall.copyWith(color: LynewedColors.textSecondary),
          ),
          const SizedBox(height: 14.0),
          // Chat rooms list
          _buildChatRoomsList(),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }

  Widget _buildChatRoomsList() {
    final rooms = _model.psPublicRooms;
    
    if (rooms.isEmpty) {
      return const Center(
        child: SizedBox(
          height: 80.0,
          child: EmptyStateWidget(message: 'No chat rooms available...'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _model.refreshedPublicRooms = await actions.getPublicChatRoomsForBridesAction();
        if (_model.refreshedPublicRooms != null) {
          _model.psPublicRooms = _model.refreshedPublicRooms!.items
              .toList()
              .cast<PublicChatRoomItemStruct>();
          safeSetState(() {});
        }
      },
      child: ListView.separated(
        padding: EdgeInsets.zero,
        primary: false,
        shrinkWrap: true,
        itemCount: rooms.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10.0),
        itemBuilder: (context, index) {
          final room = rooms[index];
          return _PublicChatRoomTile(
            room: room,
            onTap: () => _joinChatRoom(room),
          );
        },
      ),
    );
  }

  Future<void> _joinChatRoom(PublicChatRoomItemStruct room) async {
    _model.joinSuccess = await actions.joinPublicRoomIfNeededAction(room.roomId);
    
    if (_model.joinSuccess == true) {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatDetailsPage(
            roomId: room.roomId,
            isPublicRoom: true,
            publicRoomTitle: room.title,
            publicRoomCoverUrl: room.coverImageUrl,
          ),
        ),
      ).then((_) async {
        if (mounted) {
          final refreshed = await actions.getPublicChatRoomsForBridesAction();
          if (refreshed != null && mounted) {
            _model.psPublicRooms = refreshed.items.toList().cast<PublicChatRoomItemStruct>();
            safeSetState(() {});
          }
        }
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to join the chat room. Please try again.',
            style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          duration: const Duration(milliseconds: 2000),
          backgroundColor: LynewedColors.error,
        ),
      );
    }
    safeSetState(() {});
  }
}

/// Public Chat Room Tile - Design System v3
class _PublicChatRoomTile extends StatelessWidget {
  final PublicChatRoomItemStruct room;
  final VoidCallback onTap;

  const _PublicChatRoomTile({
    required this.room,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: LynewedColors.textPrimary, // Black background
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
          children: [
            // Cover image
            ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: CachedNetworkImage(
                imageUrl: room.coverImageUrl.isNotEmpty
                    ? room.coverImageUrl
                    : 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/lynewed-alpha-du4al1/assets/vq6j64n8aqw5/SCR-20250923-knqk.png',
                width: 48.0,
                height: 48.0,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 48.0,
                  height: 48.0,
                  color: LynewedColors.gray200,
                ),
                errorWidget: (context, url, error) => Container(
                  width: 48.0,
                  height: 48.0,
                  color: LynewedColors.gray200,
                  child: const Icon(Icons.image, color: LynewedColors.textSecondary),
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            // Room info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.title.isNotEmpty ? room.title : 'Chat Room',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.white, // White text for title
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      const Icon(
                        Icons.people_alt_outlined,
                        color: LynewedColors.gray300, // Light gray for icon
                        size: 14.0,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        '${room.activeUsersCount} participants',
                        style: LynewedTextStyles.labelLarge.copyWith(
                          color: LynewedColors.gray300, // Light gray for secondary text
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow
            const Icon(
              Icons.arrow_forward_ios,
              color: LynewedColors.gray300, // Light gray for arrow
              size: 16.0,
            ),
          ],
        ),
      ),
    );
  }
}
