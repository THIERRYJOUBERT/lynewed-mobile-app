/// Settings page for guest users.
///
/// Structure copiée de ProfileBridesAndProWidget et adaptée pour Guest role.
/// Uses FlutterFlowTheme for consistency with Bride/Pro interface.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';

/// Settings page for guest users.
///
/// Shows:
/// - Header "PROFIL" (110px) - identical to ProfileBridesAndProWidget
/// - Preferences section (Preference, Notifications, Settings & Permissions)
/// - Upgrade section (prominent CTA "Become a Bride")
/// - Support section (Rate, Contact, Terms, Log out)
/// - Version
///
/// Pattern copied from ProfileBridesAndProWidget for consistency.
class GuestSettingsPage extends StatefulWidget {
  /// Callback when upgrade button is tapped.
  final VoidCallback? onUpgradeToBride;

  /// Callback when logout button is tapped.
  final VoidCallback? onLogout;

  /// Creates a guest settings page.
  const GuestSettingsPage({
    this.onUpgradeToBride,
    this.onLogout,
    super.key,
  });

  @override
  State<GuestSettingsPage> createState() => _GuestSettingsPageState();
}

class _GuestSettingsPageState extends State<GuestSettingsPage> {
  String? _brideName;
  DateTime? _weddingDate;
  String? _inviteCode;
  bool _isLoadingWeddingInfo = true;

  @override
  void initState() {
    super.initState();
    _loadWeddingInfo();
  }

  Future<void> _loadWeddingInfo() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() => _isLoadingWeddingInfo = false);
        return;
      }

      // Step 1: Get wedding_id from wedding_guests
      final guestData = await Supabase.instance.client
          .from('wedding_guests')
          .select('wedding_id')
          .eq('user_id', user.id)
          .eq('status', 'joined')
          .order('joined_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (guestData == null) {
        setState(() => _isLoadingWeddingInfo = false);
        return;
      }

      final weddingId = guestData['wedding_id'] as String;

      // Step 2: Get wedding details
      final weddingData = await Supabase.instance.client
          .from('weddings')
          .select('id, event_date, invite_code, bride_profile_id')
          .eq('id', weddingId)
          .maybeSingle();

      if (weddingData == null) {
        setState(() => _isLoadingWeddingInfo = false);
        return;
      }

      // Step 3: Get bride profile
      final brideProfileId = weddingData['bride_profile_id'] as String?;
      String? brideName;
      if (brideProfileId != null) {
        final brideData = await Supabase.instance.client
            .from('profiles')
            .select('full_name')
            .eq('id', brideProfileId)
            .maybeSingle();
        brideName = brideData?['full_name'] as String?;
      }

      final eventDateStr = weddingData['event_date'] as String?;
      final inviteCode = weddingData['invite_code'] as String?;

      if (mounted) {
        setState(() {
          _brideName = brideName;
          _inviteCode = inviteCode;
          if (eventDateStr != null) {
            _weddingDate = DateTime.tryParse(eventDateStr);
          }
          _isLoadingWeddingInfo = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingWeddingInfo = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Structure Stack comme ProfileBridesAndProWidget
    // Pas de Scaffold car embeddé dans GuestHomePage
    return Stack(
      children: [
        // === HEADER 110px (copié de ProfileBridesAndProWidget) ===
        Align(
          alignment: const AlignmentDirectional(0.0, -1.0),
          child: Container(
            width: double.infinity,
            height: 110.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PROFIL',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Haas Grot Text Trial',
                              fontSize: 18.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: const AlignmentDirectional(0.0, 1.0),
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(0.0, 14.0, 0.0, 0.0),
                    child: Container(
                      width: double.infinity,
                      height: 1.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondary,
                      ),
                      alignment: const AlignmentDirectional(0.0, 1.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // === CONTENT avec padding (copié de ProfileBridesAndProWidget) ===
        Padding(
          padding:
              const EdgeInsetsDirectional.fromSTEB(20.0, 110.0, 20.0, 0.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Spacing after header
                const SizedBox(height: 16.0),

                // === WEDDING INFO BANNER ===
                _buildWeddingInfoBanner(),

                // === SECTION PREFERENCE ===
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Section title
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Preference',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Haas Grot Text Trial',
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                    // Menu items with exact InkWell pattern from ProfileBridesAndProWidget
                    _buildMenuItem(
                      'Preference',
                      () => context.pushNamed(PreferenceWidget.routeName),
                    ),
                    _buildMenuItem(
                      'Notifications',
                      () =>
                          context.pushNamed(NotificationSettingsPage.routeName),
                    ),
                    _buildMenuItem(
                      'Settings and Permissions',
                      () =>
                          context.pushNamed(SettingsPermissionsWidget.routeName),
                    ),
                  ].divide(const SizedBox(height: 14.0)),
                ),

                // === SECTION UPGRADE (NEW for Guest) ===
                _buildUpgradeSection(),

                // === SECTION SUPPORT AND LEGAL ===
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Support and Legal',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Haas Grot Text Trial',
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                    _buildMenuItem(
                      'Rate Lynewed on the App Store',
                      () async => actions.requestAppReview(),
                    ),
                    _buildMenuItem(
                      'Contact us / Feedback',
                      () => context.pushNamed(SupportWidget.routeName),
                    ),
                    _buildMenuItemExternal(
                      'Terms and Conditions of Sale and Use',
                      'https://www.lynewed.com/terms-of-service',
                    ),
                    _buildLogoutItem(),
                  ].divide(const SizedBox(height: 14.0)),
                ),

                // === VERSION ===
                Align(
                  alignment: const AlignmentDirectional(0.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Align(
                        alignment: const AlignmentDirectional(0.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Application version',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Haas Grot Text Trial',
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            Text(
                              'v1.3.2',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Haas Grot Text Trial',
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ].divide(const SizedBox(width: 12.0)),
                        ),
                      ),
                    ].divide(const SizedBox(height: 24.0)),
                  ),
                ),
              ].divide(const SizedBox(height: 24.0)),
            ),
          ),
        ),
      ],
    );
  }

  /// Wedding info banner showing which wedding the guest is attending
  Widget _buildWeddingInfoBanner() {
    // Loading state
    if (_isLoadingWeddingInfo) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 1.5),
          ),
        ),
      );
    }

    // No wedding linked - hide banner
    if (_brideName == null) {
      return const SizedBox.shrink();
    }

    final dateFormat = DateFormat('MMMM d, yyyy');
    final dateText =
        _weddingDate != null ? dateFormat.format(_weddingDate!) : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            "You're attending",
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: 'Haas Grot Text Trial',
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontSize: 12.0,
                  letterSpacing: 0.0,
                ),
          ),
          const SizedBox(height: 6),
          // Wedding name
          Text(
            "$_brideName's Wedding",
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Haas Grot Text Trial',
                  fontWeight: FontWeight.w500,
                  fontSize: 15.0,
                  letterSpacing: 0.0,
                ),
          ),
          const SizedBox(height: 10),
          // Date and code row
          Row(
            children: [
              if (dateText != null) ...[
                Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
                const SizedBox(width: 5),
                Text(
                  dateText,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: 'Haas Grot Text Trial',
                        color: FlutterFlowTheme.of(context).secondaryText,
                        fontSize: 12.0,
                        letterSpacing: 0.0,
                      ),
                ),
              ],
              if (dateText != null && _inviteCode != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    width: 1,
                    height: 12,
                    color: FlutterFlowTheme.of(context).secondary,
                  ),
                ),
              if (_inviteCode != null)
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _inviteCode!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Code $_inviteCode copied!'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _inviteCode!,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Haas Grot Text Trial',
                              color: FlutterFlowTheme.of(context).secondaryText,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.copy_outlined,
                        size: 12,
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Menu item with EXACT pattern from ProfileBridesAndProWidget
  Widget _buildMenuItem(String title, VoidCallback onTap) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Haas Grot Text Trial',
                          letterSpacing: 0.0,
                        ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: FlutterFlowTheme.of(context).primaryText,
                    size: 18.0,
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 1.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Menu item for external links (opens in browser)
  Widget _buildMenuItemExternal(String title, String url) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        await launchURL(url);
      },
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Haas Grot Text Trial',
                          letterSpacing: 0.0,
                        ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: FlutterFlowTheme.of(context).primaryText,
                    size: 18.0,
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 1.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Upgrade section - prominent CTA for guest to become a bride
  Widget _buildUpgradeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(
            Icons.celebration,
            size: 32,
            color: FlutterFlowTheme.of(context).primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Planning your own wedding?',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Haas Grot Text Trial',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.0,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upgrade to access all features: find vendors, organize your wedding, and more.',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: 'Haas Grot Text Trial',
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onUpgradeToBride,
              style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                'Become a Bride',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Haas Grot Text Trial',
                      color: Colors.white,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This action is irreversible',
            style: FlutterFlowTheme.of(context).labelSmall.override(
                  fontFamily: 'Haas Grot Text Trial',
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                ),
          ),
        ],
      ),
    );
  }

  /// Logout menu item with different icon
  Widget _buildLogoutItem() {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: widget.onLogout,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Log out',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Haas Grot Text Trial',
                          letterSpacing: 0.0,
                        ),
                  ),
                  Icon(
                    Icons.login_rounded,
                    color: FlutterFlowTheme.of(context).primaryText,
                    size: 18.0,
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 1.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
