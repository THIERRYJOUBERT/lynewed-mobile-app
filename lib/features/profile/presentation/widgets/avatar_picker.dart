/// Avatar picker widget for profile editing.
///
/// A reusable widget that displays an avatar image with an edit overlay.
/// Supports both network images and local file images.
library;

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '/core/design/design.dart';

/// A widget that displays an avatar with an edit button overlay.
///
/// Features:
/// - Display network avatar from URL
/// - Display local file image when picked
/// - Show placeholder when no image
/// - Edit icon overlay
/// - Optional helper text
/// - Loading state
class AvatarPicker extends StatelessWidget {
  /// The current avatar URL from the server.
  final String? currentAvatarUrl;

  /// Path to a locally picked image (takes precedence over URL).
  final String? localImagePath;

  /// Callback when the avatar is tapped.
  final VoidCallback? onTap;

  /// Optional helper text displayed below the avatar.
  final String? helperText;

  /// Size of the avatar in pixels.
  final double size;

  /// Whether the avatar is currently being uploaded/loading.
  final bool isLoading;

  /// Creates an avatar picker widget.
  const AvatarPicker({
    super.key,
    this.currentAvatarUrl,
    this.localImagePath,
    this.onTap,
    this.helperText,
    this.size = 80,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: size + 2,
            height: size + 2,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                if (isLoading)
                  _buildLoadingAvatar()
                else
                  _buildAvatar(),
                // Edit icon overlay
                if (!isLoading)
                  const Icon(
                    Icons.edit,
                    color: LynewedColors.textSecondary,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 14),
          Text(
            helperText!,
            style: LynewedTextStyles.labelLarge.copyWith(
              color: LynewedColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: LynewedColors.gray200,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    // Priority: local file > network URL > placeholder
    if (localImagePath != null && localImagePath!.isNotEmpty) {
      return _buildFileAvatar();
    } else if (currentAvatarUrl != null && currentAvatarUrl!.isNotEmpty) {
      return _buildNetworkAvatar();
    } else {
      return _buildPlaceholderAvatar();
    }
  }

  Widget _buildFileAvatar() {
    final file = File(localImagePath!);
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: Image.file(
        file,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholderAvatar(),
      ),
    );
  }

  Widget _buildNetworkAvatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: CachedNetworkImage(
        imageUrl: currentAvatarUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) => _buildPlaceholderAvatar(),
        errorWidget: (_, __, ___) => _buildPlaceholderAvatar(),
      ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: LynewedColors.gray200,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(
        Icons.person,
        size: size / 2,
        color: LynewedColors.gray300,
      ),
    );
  }
}
