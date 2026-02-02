/// Settings page for guest users.
///
/// Complete settings page with preferences, notifications,
/// upgrade option, and support sections.
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '/core/design/design.dart';
import '/features/settings/presentation/widgets/settings_tile.dart';
import '/index.dart';

/// Settings page for guest users.
///
/// Shows:
/// - Profile header (avatar, name, email, guest badge)
/// - Preferences section (settings tiles)
/// - Upgrade section (prominent CTA)
/// - Support section (rate, contact, terms)
/// - Logout
/// - Version
class GuestSettingsPage extends StatefulWidget {
  /// Guest's display name.
  final String? guestName;

  /// Guest's email.
  final String? email;

  /// Callback when upgrade button is tapped.
  final VoidCallback? onUpgradeToBride;

  /// Callback when logout button is tapped.
  final VoidCallback? onLogout;

  /// Creates a guest settings page.
  const GuestSettingsPage({
    this.guestName,
    this.email,
    this.onUpgradeToBride,
    this.onLogout,
    super.key,
  });

  @override
  State<GuestSettingsPage> createState() => _GuestSettingsPageState();
}

class _GuestSettingsPageState extends State<GuestSettingsPage> {
  // Version is set statically since package_info_plus is not available
  static const String _version = 'Version 1.0.0';

  void _openPreferences() {
    Navigator.pushNamed(context, PreferenceWidget.routeName);
  }

  void _openNotifications() {
    Navigator.pushNamed(context, NotificationSettingsPage.routeName);
  }

  void _openSettings() {
    Navigator.pushNamed(context, SettingsPermissionsWidget.routeName);
  }

  Future<void> _rateApp() async {
    // TODO: Replace with actual App Store / Play Store URL
    final url = Uri.parse('https://apps.apple.com/app/lynewed');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _contactSupport() async {
    final url = Uri.parse('mailto:support@lynewed.com');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _openTerms() async {
    final url = Uri.parse('https://lynewed.com/terms');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: LynewedSpacing.xl),

          // Profile header
          _buildProfileHeader(),

          SizedBox(height: LynewedSpacing.xxxl),

          // Preferences section
          _buildSection(
            title: 'PREFERENCES',
            children: [
              SettingsTile(
                icon: Icons.tune,
                title: 'Preferences',
                subtitle: 'Currency, distance, country',
                onTap: _openPreferences,
              ),
              const SizedBox(height: 8),
              SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Chat, updates',
                onTap: _openNotifications,
              ),
              const SizedBox(height: 8),
              SettingsTile(
                icon: Icons.security,
                title: 'Settings & Permissions',
                onTap: _openSettings,
              ),
            ],
          ),

          SizedBox(height: LynewedSpacing.lg),

          // Upgrade section
          _buildUpgradeSection(),

          SizedBox(height: LynewedSpacing.lg),

          // Support section
          _buildSection(
            title: 'SUPPORT & LEGAL',
            children: [
              SettingsTile(
                icon: Icons.star_border,
                title: 'Rate Lynewed',
                onTap: _rateApp,
              ),
              const SizedBox(height: 8),
              SettingsTile(
                icon: Icons.help_outline,
                title: 'Contact Support',
                onTap: _contactSupport,
              ),
              const SizedBox(height: 8),
              SettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                onTap: _openTerms,
              ),
              const SizedBox(height: 8),
              SettingsTile(
                icon: Icons.logout,
                title: 'Log Out',
                isDestructive: true,
                onTap: widget.onLogout,
                trailing: const SizedBox.shrink(),
              ),
            ],
          ),

          SizedBox(height: LynewedSpacing.xxxl),

          // Version
          Text(
            _version,
            style: LynewedTextStyles.labelSmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),

          SizedBox(height: LynewedSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Avatar placeholder
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: LynewedColors.gray200,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            size: 40,
            color: LynewedColors.textSecondary,
          ),
        ),
        SizedBox(height: LynewedSpacing.md),

        // Name
        Text(
          widget.guestName ?? 'Guest',
          style: LynewedTextStyles.titleMedium.copyWith(
            color: LynewedColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),

        // Email
        Text(
          widget.email ?? '',
          style: LynewedTextStyles.bodySmall.copyWith(
            color: LynewedColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),

        // Guest badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: LynewedColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Guest',
            style: LynewedTextStyles.labelMedium.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: LynewedTextStyles.labelMedium.copyWith(
              color: LynewedColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildUpgradeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(LynewedSpacing.lg),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Icon(
              Icons.celebration,
              size: 32,
              color: LynewedColors.primary,
            ),
            SizedBox(height: LynewedSpacing.md),
            Text(
              'Planning your own wedding?',
              style: LynewedTextStyles.titleSmall.copyWith(
                color: LynewedColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: LynewedSpacing.sm),
            Text(
              'Upgrade to access all features: find vendors, organize your wedding, and more.',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: LynewedSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onUpgradeToBride,
                style: LynewedComponentStyles.primaryButton(),
                child: const Text('Become a Bride'),
              ),
            ),
            SizedBox(height: LynewedSpacing.sm),
            Text(
              'This action is irreversible',
              style: LynewedTextStyles.labelSmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
