import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../design.dart';

/// Standard Lynewed Details Bottom Sheet Container
///
/// Used for displaying entity details (Professional, Wedding, Alert).
/// Different from LynewedSheet which is for forms/actions.
///
/// Features:
/// - Handle bar
/// - Header with icon/avatar, title, subtitle, and optional badge
/// - Scrollable content
/// - Fixed action buttons at bottom
class LynewedDetailsSheet extends StatelessWidget {
  const LynewedDetailsSheet({
    super.key,
    required this.child,
    this.headerIcon,
    this.headerIconColor,
    this.headerAvatarUrl,
    this.headerAvatarInitials,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.badge,
    this.trailing,
    this.actions,
    this.maxHeightFraction = 0.85,
  });

  /// Icon to display in header (mutually exclusive with avatar)
  final IconData? headerIcon;
  
  /// Color for the header icon background
  final Color? headerIconColor;
  
  /// URL for avatar image (mutually exclusive with icon)
  final String? headerAvatarUrl;
  
  /// Initials to show when avatar fails to load
  final String? headerAvatarInitials;
  
  /// Title text (use titleWidget for custom styling)
  final String? title;
  
  /// Custom title widget (overrides title)
  final Widget? titleWidget;
  
  /// Subtitle widget
  final Widget? subtitle;
  
  /// Badge widget (shown after title)
  final Widget? badge;
  
  /// Trailing widget in header (e.g., favorite button)
  final Widget? trailing;
  
  /// Main scrollable content
  final Widget child;
  
  /// Action buttons at the bottom
  final Widget? actions;
  
  /// Maximum height as fraction of screen height
  final double maxHeightFraction;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * maxHeightFraction,
          ),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: LynewedColors.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                _buildHandleBar(),
                
                // Header (if any header content)
                if (_hasHeader) _buildHeader(),
                
                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: child,
                  ),
                ),
                
                // Action buttons (fixed at bottom)
                if (actions != null) _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get _hasHeader => 
      headerIcon != null || 
      headerAvatarUrl != null || 
      headerAvatarInitials != null ||
      title != null || 
      titleWidget != null;

  Widget _buildHandleBar() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: LynewedColors.gray200,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon or Avatar
          if (headerIcon != null) _buildIconHeader(),
          if (headerIcon == null && (headerAvatarUrl != null || headerAvatarInitials != null))
            _buildAvatarHeader(),
          
          // Title and subtitle
          if (_hasHeader) ...[
            if (headerIcon != null || headerAvatarUrl != null || headerAvatarInitials != null)
              const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row with badge
                  Row(
                    children: [
                      Expanded(
                        child: titleWidget ?? Text(
                          title ?? '',
                          style: LynewedTextStyles.sheetTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        badge!,
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    subtitle!,
                  ],
                ],
              ),
            ),
          ],
          
          // Trailing (12px spacing from text block)
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }

  Widget _buildIconHeader() {
    final color = headerIconColor ?? LynewedColors.primary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        headerIcon,
        color: color,
        size: 28,
      ),
    );
  }

  Widget _buildAvatarHeader() {
    return CircleAvatar(
      radius: 32,
      backgroundColor: LynewedColors.gray100,
      backgroundImage: headerAvatarUrl != null
          ? CachedNetworkImageProvider(headerAvatarUrl!)
          : null,
      child: headerAvatarUrl == null && headerAvatarInitials != null
          ? Text(
              headerAvatarInitials!,
              style: LynewedTextStyles.titleLarge.copyWith(
                color: LynewedColors.textSecondary,
              ),
            )
          : null,
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: LynewedColors.gray200, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: actions!,
      ),
    );
  }
}

// ============================================================
// REUSABLE DETAIL ROW WIDGETS
// ============================================================

/// Section with title and content
/// 
/// Design System v2 spacing (matching wedding_create_sheet):
/// - 10px between label and content
/// - 30px bottom margin between sections
class LynewedDetailsSection extends StatelessWidget {
  const LynewedDetailsSection({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: LynewedTextStyles.sectionTitle,
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// Status badge with color
class LynewedStatusBadge extends StatelessWidget {
  const LynewedStatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.isOutlined = false,
  });

  final String label;
  final Color color;
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(LynewedComponentStyles.chipBorderRadius),
        border: isOutlined ? Border.all(color: color, width: 1) : null,
      ),
      child: Text(
        label,
        style: LynewedTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Chip for profession, category, etc.
class LynewedDetailChip extends StatelessWidget {
  const LynewedDetailChip({
    super.key,
    required this.label,
    this.isPrimary = true,
  });

  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPrimary ? LynewedColors.primary : LynewedColors.gray200,
        borderRadius: BorderRadius.circular(LynewedComponentStyles.chipBorderRadius),
      ),
      child: Text(
        label,
        style: LynewedTextStyles.labelMedium.copyWith(
          color: isPrimary ? LynewedColors.textOnPrimary : LynewedColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Tappable author/user card
class LynewedAuthorCard extends StatelessWidget {
  const LynewedAuthorCard({
    super.key,
    required this.name,
    this.subtitle,
    this.avatarUrl,
    this.onTap,
    this.trailing,
  });

  final String name;
  final String? subtitle;
  final String? avatarUrl;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LynewedColors.background,
      borderRadius: BorderRadius.circular(LynewedComponentStyles.inputBorderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LynewedComponentStyles.inputBorderRadius),
            border: Border.all(color: LynewedColors.gray200),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: LynewedColors.gray100,
                backgroundImage: avatarUrl != null
                    ? CachedNetworkImageProvider(avatarUrl!)
                    : null,
                child: avatarUrl == null
                    ? Text(
                        _getInitials(name),
                        style: LynewedTextStyles.labelMedium.copyWith(
                          color: LynewedColors.textSecondary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: LynewedTextStyles.sectionTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: LynewedTextStyles.bodySmall.copyWith(
                          color: LynewedColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (trailing != null) 
                trailing!
              else if (onTap != null)
                const Icon(
                  Icons.chevron_right,
                  color: LynewedColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }
}
