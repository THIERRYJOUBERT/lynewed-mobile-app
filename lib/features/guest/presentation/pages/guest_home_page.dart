/// Home page for guest users.
///
/// Main container with 3 tabs: Album, Chat, Profil.
/// Uses IndexedStack for tab content preservation.
library;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../auth/supabase_auth/auth_util.dart';
import '../../../../core/design/design.dart';
import '../../../../core/services/unread_counter_service.dart';
import '../../../../flutter_flow/flutter_flow_util.dart';
import '../../../auth/domain/usecases/upgrade_to_bride.dart';
import '../widgets/guest_nav_bar_v2.dart';
import '../widgets/upgrade_confirmation_dialog.dart';
import 'guest_album_page.dart';
import 'guest_messages_page.dart';
import 'guest_settings_page.dart';

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
  String? _guestName;
  String? _guestEmail;
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

      // Get user profile
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('first_name, email')
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null && mounted) {
        setState(() {
          _guestName = profile['first_name'] as String?;
          _guestEmail = profile['email'] as String? ?? user.email;
        });
      }

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
        body: Center(
          child: CircularProgressIndicator(
            color: LynewedColors.primary,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${_brideName ?? '...'}'s Wedding",
          style: LynewedTextStyles.titleMedium.copyWith(
            color: LynewedColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: LynewedColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const GuestAlbumPage(),
          const GuestMessagesPage(),
          GuestSettingsPage(
            guestName: _guestName,
            email: _guestEmail,
            onUpgradeToBride: _handleUpgradeToBride,
            onLogout: _handleLogout,
          ),
        ],
      ),
      bottomNavigationBar: GuestNavBarV2(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        unreadCount: _unreadCount,
      ),
    );
  }
}
