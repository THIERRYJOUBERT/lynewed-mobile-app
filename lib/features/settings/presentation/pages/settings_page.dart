/// Settings page.
///
/// Displays app settings organized into sections:
/// - Account (Permissions)
/// - Notifications (Push Notifications)
/// - Privacy (Privacy Policy, Terms of Service)
/// - Support (Help & FAQ, Contact Support)
/// - Account Actions (Log Out, Delete Account)
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/design/design.dart';
import '/features/auth/presentation/bloc/auth_cubit.dart';
import '../widgets/settings_tile.dart';

/// The main settings page showing organized settings sections.
///
/// Provides access to:
/// - Device permissions management
/// - Notification preferences
/// - Legal documents (Privacy, Terms)
/// - Support options
/// - Account actions (logout, delete)
class SettingsPage extends StatelessWidget {
  /// Route name for navigation.
  static const String routeName = 'settings';

  /// Route path for navigation.
  static const String routePath = '/settings';

  /// Creates a settings page.
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            const Divider(height: 1.0, color: LynewedColors.gray200),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account Section
                    _buildSectionTitle('Account'),
                    const SizedBox(height: 8.0),
                    SettingsTile(
                      icon: Icons.security_outlined,
                      title: 'Permissions',
                      subtitle: 'Camera, microphone, location',
                      onTap: () => _navigateToPermissions(context),
                    ),

                    const SizedBox(height: 24.0),

                    // Notifications Section
                    _buildSectionTitle('Notifications'),
                    const SizedBox(height: 8.0),
                    SettingsTile(
                      icon: Icons.notifications_outlined,
                      title: 'Push Notifications',
                      subtitle: 'Manage notification preferences',
                      onTap: () => _openNotificationSettings(context),
                    ),

                    const SizedBox(height: 24.0),

                    // Privacy Section
                    _buildSectionTitle('Privacy'),
                    const SizedBox(height: 8.0),
                    SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'How we handle your data',
                      onTap: () => _openPrivacyPolicy(context),
                    ),
                    const SizedBox(height: 8.0),
                    SettingsTile(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      subtitle: 'Usage terms and conditions',
                      onTap: () => _openTermsOfService(context),
                    ),

                    const SizedBox(height: 24.0),

                    // Support Section
                    _buildSectionTitle('Support'),
                    const SizedBox(height: 8.0),
                    SettingsTile(
                      icon: Icons.help_outline,
                      title: 'Help & FAQ',
                      subtitle: 'Find answers to common questions',
                      onTap: () => _openHelpCenter(context),
                    ),
                    const SizedBox(height: 8.0),
                    SettingsTile(
                      icon: Icons.mail_outline,
                      title: 'Contact Support',
                      subtitle: 'Get help from our team',
                      onTap: () => _contactSupport(context),
                    ),

                    const SizedBox(height: 24.0),

                    // Account Actions Section
                    _buildSectionTitle('Account Actions'),
                    const SizedBox(height: 8.0),
                    SettingsTile(
                      icon: Icons.logout,
                      title: 'Log Out',
                      subtitle: 'Sign out of your account',
                      isDestructive: true,
                      onTap: () => _showLogoutDialog(context),
                    ),
                    const SizedBox(height: 8.0),
                    SettingsTile(
                      icon: Icons.delete_outline,
                      title: 'Delete Account',
                      subtitle: 'Permanently delete your account',
                      isDestructive: true,
                      onTap: () => _showDeleteAccountDialog(context),
                    ),

                    const SizedBox(height: 32.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 16.0, 16.0, 12.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            color: LynewedColors.textPrimary,
          ),
          const SizedBox(width: 4.0),
          Text(
            'Settings',
            style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20.0),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: LynewedTextStyles.sectionTitle,
      ),
    );
  }

  void _navigateToPermissions(BuildContext context) {
    // TODO: Navigate to permissions page
    // context.pushNamed('permissions');
  }

  void _openNotificationSettings(BuildContext context) {
    // TODO: Open system notification settings
  }

  void _openPrivacyPolicy(BuildContext context) {
    // TODO: Open privacy policy page or URL
  }

  void _openTermsOfService(BuildContext context) {
    // TODO: Open terms of service page or URL
  }

  void _openHelpCenter(BuildContext context) {
    // TODO: Open help center page or URL
  }

  void _contactSupport(BuildContext context) {
    // TODO: Open contact support page or email
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: LynewedColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(true);
              context.read<AuthCubit>().signOut();
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: LynewedColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This action is permanent and cannot be undone. '
          'All your data will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: LynewedColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(true);
              // TODO: Implement account deletion via edge function
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: LynewedColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
