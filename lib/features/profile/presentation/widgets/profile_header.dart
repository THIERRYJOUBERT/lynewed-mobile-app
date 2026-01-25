/// Profile header widget.
///
/// Displays the user's avatar, name, profession (for professionals),
/// and bio in a centered layout.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '/features/auth/domain/entities/entities.dart';

/// A widget that displays the profile header with avatar and info.
///
/// Shows different information based on user role:
/// - Bride: name and bio
/// - Professional: name, profession, company, and bio
class ProfileHeader extends StatelessWidget {
  /// The user profile to display.
  final UserProfile profile;

  /// Creates a profile header widget.
  const ProfileHeader({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          _buildAvatar(),
          const SizedBox(height: 16.0),
          // Name
          Text(
            profile.displayName ?? 'User',
            style: LynewedTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          // Professional info
          if (profile.isProfessional) ...[
            if (profile.profession != null) ...[
              const SizedBox(height: 4.0),
              Text(
                profile.profession!,
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: LynewedColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (profile.companyName != null) ...[
              const SizedBox(height: 2.0),
              Text(
                profile.companyName!,
                style: LynewedTextStyles.labelMedium.copyWith(
                  color: LynewedColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
          // Bio
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 12.0),
            Text(
              profile.bio!,
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    const double size = 80.0;

    if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: CachedNetworkImage(
          imageUrl: profile.avatarUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => _buildAvatarPlaceholder(size),
          errorWidget: (_, __, ___) => _buildAvatarPlaceholder(size),
        ),
      );
    }

    return _buildAvatarPlaceholder(size);
  }

  Widget _buildAvatarPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: LynewedColors.gray200,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: const Icon(
        Icons.person,
        size: 40.0,
        color: LynewedColors.gray300,
      ),
    );
  }
}
