/// Contact request avatar widget - Clean Architecture
/// 
/// Displays a contact request as an avatar in the horizontal list.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../domain/entities/entities.dart';

/// Avatar widget for pending contact requests
class ContactRequestAvatar extends StatelessWidget {
  const ContactRequestAvatar({
    super.key,
    required this.request,
    required this.currentUserId,
    required this.onTap,
  });

  final ContactRequest request;
  final String currentUserId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isWaiting = request.initiatorId == currentUserId;
    
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isWaiting ? LynewedColors.gray200 : LynewedColors.primary,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: request.otherAvatarUrl != null && request.otherAvatarUrl!.isNotEmpty
                    ? Image.network(
                        request.otherAvatarUrl!,
                        width: 46,
                        height: 46,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            
            const SizedBox(height: 6),
            
            // Status label
            Text(
              isWaiting ? 'En attente' : 'Nouveau',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LynewedTextStyles.labelSmall.copyWith(
                color: isWaiting ? LynewedColors.textSecondary : LynewedColors.primary,
                fontWeight: isWaiting ? FontWeight.normal : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 46,
      height: 46,
      color: LynewedColors.gray200,
      child: const Icon(
        Icons.person,
        color: LynewedColors.gray300,
        size: 24,
      ),
    );
  }
}
