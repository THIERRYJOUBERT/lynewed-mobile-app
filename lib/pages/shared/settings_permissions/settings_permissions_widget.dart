/// Settings & Permissions page - Clean Architecture
/// 
/// Unified settings page for both Brides and Professionals.
/// Handles device permissions, visibility preferences (Pro only), and account deletion.
/// 
/// DESIGN SYSTEM v3 APPLIED:
/// - Header: Back button (LynewedComponentStyles.backButton) + Title
/// - Divider under header (LynewedColors.gray200)
/// - Typography: LynewedTextStyles.sectionTitle for section headers
/// - Spacing: 30px inter-section
/// - List items with descriptions
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core/design/design.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/permissions_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';

class SettingsPermissionsWidget extends StatefulWidget {
  const SettingsPermissionsWidget({super.key});

  static String routeName = 'SettingsPermissions';
  static String routePath = '/settingsPermissions';

  @override
  State<SettingsPermissionsWidget> createState() =>
      _SettingsPermissionsWidgetState();
}

class _SettingsPermissionsWidgetState extends State<SettingsPermissionsWidget> {
  bool _isLoading = true;
  bool _proRecentVisibility = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadProRecentStatus();
  }

  Future<void> _loadProRecentStatus() async {
    if (FFAppState().currentUserRole == UserRole.professional) {
      try {
        final rows = await ProRecentLocationsTable().queryRows(
          queryFn: (q) => q.eqOrNull('profile_id', currentUserUid),
        );
        if (rows.isNotEmpty) {
          _proRecentVisibility = rows.first.isOptIn;
        }
      } catch (e) {
        // Silently fail - default to false
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onPermissionTap(PermissionType type, String successMsg, String errorMsg) async {
    final result = await actions.checkAndRequestPermission(type);
    if (!mounted) return;
    
    if (result == 'granted') {
      _showSnackBar(successMsg, LynewedColors.success);
    } else {
      _showSnackBar(errorMsg, LynewedColors.primary);
    }
  }

  Future<void> _onToggleProRecent(bool value) async {
    setState(() => _proRecentVisibility = value);
    await actions.upsertProRecentOptIn(value);
  }

  Future<void> _onDeleteAccountTap() async {
    final isPro = FFAppState().currentUserRole == UserRole.professional;
    
    if (isPro) {
      // Pro: Navigate to support page with pre-filled subject
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SupportWidget(
            prefilledSubject: 'Request account deletion',
          ),
        ),
      );
    } else {
      // Bride: Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete my account?'),
          content: const Text(
            'Please note that you are about to delete your account. '
            'This action is permanent. Are you sure you want to proceed?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'Delete my account',
                style: TextStyle(color: LynewedColors.error),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true && mounted) {
        setState(() => _isDeleting = true);
        
        final success = await actions.callDeleteAccountEdgeFunction();
        
        if (success && mounted) {
          GoRouter.of(context).prepareAuthEvent();
          await authManager.signOut();
          GoRouter.of(context).clearRedirectLocation();
          context.goNamedAuth(AuthWelcomePageWidget.routeName, context.mounted);
        } else if (mounted) {
          setState(() => _isDeleting = false);
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('An error has occurred'),
              content: const Text(
                'We are unable to delete your account. '
                'Please try again later or contact support.'
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Ok'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final isPro = FFAppState().currentUserRole == UserRole.professional;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: LynewedColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Divider
              const Divider(height: 1, color: LynewedColors.gray200),
              
              // Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: LynewedColors.primary))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Device Permissions Section
                            Text('Device Permissions', style: LynewedTextStyles.sectionTitle),
                            const SizedBox(height: 16),
                            _buildPermissionItem(
                              title: 'Location Access',
                              description: 'Enables the map, nearby searches, and distance calculations.',
                              onTap: () => _onPermissionTap(
                                PermissionType.LOCATION,
                                'Location access is enabled',
                                'Enable location in settings',
                              ),
                            ),
                            _buildPermissionItem(
                              title: 'Push Notifications',
                              description: 'Receive alerts for messages and important activities.',
                              onTap: () => _onPermissionTap(
                                PermissionType.NOTIFICATIONS,
                                'Notifications are enabled',
                                'Enable notifications in settings',
                              ),
                            ),
                            _buildPermissionItem(
                              title: 'Camera Access',
                              description: 'To take photos for your profile, portfolio, or chat.',
                              onTap: () => _onPermissionTap(
                                PermissionType.CAMERA,
                                'Camera access is enabled',
                                'Allow camera access in settings',
                              ),
                            ),
                            _buildPermissionItem(
                              title: 'Photo Library Access',
                              description: 'To select images for your profile, portfolio, or chat.',
                              onTap: () => _onPermissionTap(
                                PermissionType.PHOTOS,
                                'Photo access is enabled',
                                'Allow photo access in settings',
                              ),
                            ),
                            _buildPermissionItem(
                              title: 'Microphone Access',
                              description: 'Needed to record audio messages in the chat.',
                              onTap: () => _onPermissionTap(
                                PermissionType.MICROPHONE,
                                'Microphone access is enabled',
                                'Allow microphone access in settings',
                              ),
                              showDivider: !isPro, // No divider if Pro section follows
                            ),
                            
                            // Visibility Preferences Section (Pro only)
                            if (isPro) ...[
                              const SizedBox(height: 30),
                              Text('Visibility Preferences', style: LynewedTextStyles.sectionTitle),
                              const SizedBox(height: 16),
                              _buildToggleItem(
                                title: 'Share my recent location',
                                description: 'Allows other users to see your approximate location on the map when you are active.',
                                value: _proRecentVisibility,
                                onChanged: _onToggleProRecent,
                              ),
                            ],
                            
                            // Account Section
                            const SizedBox(height: 30),
                            Text('Account', style: LynewedTextStyles.sectionTitle),
                            const SizedBox(height: 16),
                            _buildDeleteAccountItem(isPro),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      child: Row(
        children: [
          LynewedComponentStyles.backButton(context),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Settings',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem({
    required String title,
    required String description,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: LynewedTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: LynewedTextStyles.bodySmall.copyWith(
                          color: LynewedColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.chevron_right,
                  color: LynewedColors.textPrimary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (showDivider) const Divider(height: 1, color: LynewedColors.gray200),
      ],
    );
  }

  Widget _buildToggleItem({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: LynewedTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: LynewedTextStyles.bodySmall.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: LynewedColors.primary,
                activeTrackColor: LynewedColors.primary,
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: LynewedColors.gray200),
      ],
    );
  }

  Widget _buildDeleteAccountItem(bool isPro) {
    return InkWell(
      onTap: _isDeleting ? null : _onDeleteAccountTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPro ? 'Request account deletion' : 'Delete my account',
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: LynewedColors.error,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPro 
                        ? 'Professional accounts are managed through our support team.'
                        : 'Permanently delete your account and all associated data.',
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (_isDeleting)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: LynewedColors.error,
                ),
              )
            else
              Icon(
                isPro ? Icons.chevron_right : Icons.delete_outline,
                color: LynewedColors.error,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
