import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../domain/entities/wedding_client.dart';

class WeddingActionsSheet extends StatelessWidget {
  const WeddingActionsSheet({
    super.key,
    required this.wedding,
    required this.onViewDetails,
    required this.onToggleMute,
    required this.onLeaveWedding,
  });

  final WeddingClient wedding;
  final VoidCallback onViewDetails;
  final VoidCallback onToggleMute;
  final VoidCallback onLeaveWedding;

  static Future<void> show({
    required BuildContext context,
    required WeddingClient wedding,
    required VoidCallback onViewDetails,
    required VoidCallback onToggleMute,
    required VoidCallback onLeaveWedding,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => WeddingActionsSheet(
        wedding: wedding,
        onViewDetails: onViewDetails,
        onToggleMute: onToggleMute,
        onLeaveWedding: onLeaveWedding,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final muteLabel = wedding.isMuted ? 'Unmute Notifications' : 'Mute Notifications';

    return Container(
      decoration: LynewedComponentStyles.bottomSheetDecoration(),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: LynewedColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      wedding.brideName,
                      style: LynewedTextStyles.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    iconSize: 24,
                    color: LynewedColors.textSecondary,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: LynewedColors.gray200),
            _buildActionTile(
              icon: Icons.visibility_outlined,
              label: 'View Details',
              onTap: () {
                Navigator.of(context).pop();
                onViewDetails();
              },
            ),
            _buildActionTile(
              icon: wedding.isMuted
                  ? Icons.notifications_outlined
                  : Icons.notifications_off_outlined,
              label: muteLabel,
              onTap: () {
                Navigator.of(context).pop();
                onToggleMute();
              },
            ),
            _buildActionTile(
              icon: Icons.logout_outlined,
              label: 'Leave Wedding',
              color: LynewedColors.error,
              onTap: () {
                Navigator.of(context).pop();
                onLeaveWedding();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final avatarUrl = wedding.brideAvatarUrl;

    return ClipOval(
      child: avatarUrl != null && avatarUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: avatarUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              placeholder: (_, __) => _buildPlaceholder(),
              errorWidget: (_, __, ___) => _buildPlaceholder(),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 40,
      height: 40,
      color: LynewedColors.gray200,
      child: const Icon(
        Icons.person,
        color: LynewedColors.gray300,
        size: 24,
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: color ?? LynewedColors.textPrimary,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: color ?? LynewedColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
