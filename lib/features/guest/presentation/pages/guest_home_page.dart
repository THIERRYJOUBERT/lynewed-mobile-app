/// Home page for guest users.
///
/// Main container with 3 tabs: Album, Chat, Profil.
/// Uses IndexedStack for tab content preservation.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../auth/supabase_auth/auth_util.dart';
import '../../../../core/design/design.dart';
import '../../../../core/services/unread_counter_service.dart';
import '../../../../features/notifications/presentation/bloc/notifications_cubit.dart';
import '../../../../flutter_flow/flutter_flow_util.dart';
import '../../../../index.dart';
import '../../../auth/domain/usecases/upgrade_to_bride.dart';
import '../widgets/guest_nav_bar_v2.dart';
import '../widgets/upgrade_confirmation_dialog.dart';

/// Main home page for guest users.
///
/// Displays a bottom navigation with 3 tabs:
/// - Album: Guest's photos and videos
/// - Chat: Wedding team group chat
/// - Profil: Guest profile and settings
class GuestHomePage extends StatefulWidget {
  /// Route name for navigation.
  static const routeName = 'GuestHomePage';

  /// Route path for navigation.
  static const routePath = '/guestHome';

  /// Bride's name to display in app bar.
  final String? brideName;

  /// Chat room ID for the wedding team.
  final String? chatRoomId;

  /// Creates a guest home page.
  const GuestHomePage({
    this.brideName,
    this.chatRoomId,
    super.key,
  });

  @override
  State<GuestHomePage> createState() => _GuestHomePageState();
}

class _GuestHomePageState extends State<GuestHomePage> {
  int _currentIndex = 0;
  String? _brideName;
  bool _isLoading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _brideName = widget.brideName;
    _loadGuestInfo();
    _initializeUnreadCounter();
  }

  void _initializeUnreadCounter() {
    // Initialize unread counter service
    UnreadCounterService.instance.initialize();

    // Listen to FFAppState changes for unread count
    FFAppState().addListener(_onUnreadCountChanged);
    _unreadCount = FFAppState().unreadMessagesCount;
  }

  void _onUnreadCountChanged() {
    if (mounted) {
      setState(() {
        _unreadCount = FFAppState().unreadMessagesCount;
      });
    }
  }

  @override
  void dispose() {
    FFAppState().removeListener(_onUnreadCountChanged);
    super.dispose();
  }

  Future<void> _loadGuestInfo() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Get wedding info if not provided
      if (_brideName == null) {
        final guestInfo = await Supabase.instance.client
            .from('wedding_guests')
            .select('''
              wedding_id,
              weddings!inner (
                id,
                bride_profile_id,
                profiles!weddings_bride_profile_id_fkey (
                  first_name
                )
              )
            ''')
            .eq('user_id', user.id)
            .eq('status', 'joined')
            .maybeSingle();

        if (guestInfo != null && mounted) {
          final wedding = guestInfo['weddings'] as Map<String, dynamic>;
          final brideProfile = wedding['profiles'] as Map<String, dynamic>?;

          setState(() {
            _brideName = brideProfile?['first_name'] as String? ?? 'The bride';
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  void _handleUpgradeToBride() {
    showDialog(
      context: context,
      builder: (context) => UpgradeConfirmationDialog(
        onConfirm: () {
          Navigator.of(context).pop();
          _performUpgrade();
        },
      ),
    );
  }

  Future<void> _performUpgrade() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: LynewedColors.primary,
        ),
      ),
    );

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final useCase = UpgradeToBride();
    final result = await useCase(userId);

    if (!mounted) return;

    Navigator.of(context).pop(); // Remove loading

    switch (result) {
      case UpgradeSuccessful():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome! You can now create your wedding.'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to bride home
        context.go('/home');
      case NotAGuest():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('You are not a guest.'),
            backgroundColor: LynewedColors.error,
          ),
        );
      case UpgradeError(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: LynewedColors.error,
          ),
        );
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Log out',
              style: TextStyle(color: LynewedColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await authManager.signOut();
      if (mounted) {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: LynewedColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: LynewedColors.primary,
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
        backgroundColor: LynewedColors.background,
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // Main content with padding for header and navbar
              // Note: Profile tab (index 2) has its own header, so no padding top
              Padding(
                padding: EdgeInsets.fromLTRB(
                  _currentIndex == 2 ? 0.0 : 20.0, // Profile manages its own horizontal padding
                  _currentIndex == 2 ? 0.0 : 110.0, // Profile has its own header
                  _currentIndex == 2 ? 0.0 : 20.0,
                  84.0, // Always need navbar padding
                ),
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    GuestAlbumPage(brideName: _brideName),
                    const GuestMessagesPage(),
                    GuestSettingsPage(
                      onUpgradeToBride: _handleUpgradeToBride,
                      onLogout: _handleLogout,
                    ),
                  ],
                ),
              ),
              // Bottom Navigation
              Align(
                alignment: Alignment.bottomCenter,
                child: GuestNavBarV2(
                  currentIndex: _currentIndex,
                  onTap: _onTabTapped,
                  unreadCount: _unreadCount,
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

  /// Get header title based on current tab
  String _getHeaderTitle() {
    switch (_currentIndex) {
      case 0:
        return 'ALBUM';
      case 1:
        return 'MESSAGES';
      case 2:
        return 'SETTINGS';
      default:
        return 'ALBUM';
    }
  }

  /// Header with title only (simple header without icons for Messages tab)
  /// Returns empty widget for Profile tab (index 2) since it has its own header
  Widget _buildHeader() {
    // Profile tab has its own header "PROFIL" like ProfileBridesAndProWidget
    if (_currentIndex == 2) {
      return const SizedBox.shrink();
    }

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
                  // Dynamic title based on current tab
                  Text(
                    _getHeaderTitle(),
                    style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 18.0),
                  ),
                  // Icons only for Album tab (index 0)
                  if (_currentIndex == 0)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Transactions (placeholder for future purchases)
                        _buildHeaderIcon(
                          icon: Icons.receipt_outlined,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Purchase history coming soon!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 14.0),
                        // Notifications with badge - same style as HomeBridesPage
                        GestureDetector(
                          onTap: () => context.pushNamed(NotificationsPage.routeName),
                          behavior: HitTestBehavior.opaque,
                          child: Consumer<NotificationsNotifier>(
                            builder: (context, notifier, _) {
                              final count = notifier.unreadCount;
                              return SizedBox(
                                width: 32.0,
                                height: 32.0,
                                child: Badge(
                                  isLabelVisible: count > 0,
                                  label: Text(
                                    count > 99 ? '99+' : count.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: LynewedColors.primary,
                                  child: const Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.notifications_outlined,
                                      color: LynewedColors.textPrimary,
                                      size: 24.0,
                                    ),
                                  ),
                                ),
                              );
                            },
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

  /// Header icon without badge - fixed 32x32 for uniform alignment
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
}
