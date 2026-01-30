/// Profile page for guests.
///
/// Displays the guest's profile information and settings.
/// Includes option to upgrade to bride account.
library;

import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';

/// Profile page for guest users.
///
/// Shows:
/// - Guest name and email
/// - Wedding info
/// - Upgrade to bride option
/// - Logout button
class GuestProfilePage extends StatelessWidget {
  /// Guest's display name.
  final String? guestName;

  /// Guest's email.
  final String? email;

  /// Callback when upgrade button is tapped.
  final VoidCallback? onUpgradeToBride;

  /// Callback when logout button is tapped.
  final VoidCallback? onLogout;

  /// Creates a guest profile page.
  const GuestProfilePage({
    this.guestName,
    this.email,
    this.onUpgradeToBride,
    this.onLogout,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(LynewedSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: LynewedSpacing.xl),

          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: LynewedColors.surface,
            child: Icon(
              Icons.person,
              size: 50,
              color: LynewedColors.textSecondary,
            ),
          ),

          SizedBox(height: LynewedSpacing.lg),

          // Name
          Text(
            guestName ?? 'Invité',
            style: LynewedTextStyles.headlineMedium.copyWith(
              color: LynewedColors.textPrimary,
            ),
          ),

          SizedBox(height: LynewedSpacing.xs),

          // Email
          Text(
            email ?? '',
            style: LynewedTextStyles.bodyMedium.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),

          SizedBox(height: LynewedSpacing.sm),

          // Role badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: LynewedSpacing.md,
              vertical: LynewedSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: LynewedColors.surface,
              borderRadius: BorderRadius.circular(LynewedSpacing.md),
            ),
            child: Text(
              'Invité',
              style: LynewedTextStyles.labelMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ),

          SizedBox(height: LynewedSpacing.xxxl),

          // Upgrade section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(LynewedSpacing.lg),
            decoration: BoxDecoration(
              color: LynewedColors.surface,
              borderRadius: BorderRadius.circular(LynewedSpacing.md),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.celebration,
                  size: 40,
                  color: LynewedColors.primary,
                ),
                SizedBox(height: LynewedSpacing.md),
                Text(
                  'Vous organisez un mariage ?',
                  style: LynewedTextStyles.titleMedium.copyWith(
                    color: LynewedColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: LynewedSpacing.sm),
                Text(
                  'Passez en compte Mariée pour accéder à toutes les fonctionnalités : '
                  'recherche de prestataires, organisation, planning...',
                  style: LynewedTextStyles.bodySmall.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: LynewedSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onUpgradeToBride,
                    child: const Text('Passer en compte Mariée'),
                  ),
                ),
                SizedBox(height: LynewedSpacing.sm),
                Text(
                  'Cette action est irréversible',
                  style: LynewedTextStyles.labelSmall.copyWith(
                    color: Colors.orange.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: LynewedSpacing.xxl),

          // Logout button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onLogout,
              style: OutlinedButton.styleFrom(
                foregroundColor: LynewedColors.error,
              ),
              child: const Text('Se déconnecter'),
            ),
          ),

          SizedBox(height: LynewedSpacing.xl),
        ],
      ),
    );
  }
}
