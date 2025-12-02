/// Message actions sheet - Clean Architecture
/// 
/// Bottom sheet for message actions (delete, report, block).
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../domain/entities/entities.dart';

/// Callback for report action
typedef ReportCallback = Future<void> Function(ReportReason reason, String? details);

/// Bottom sheet for message actions
class MessageActionsSheet extends StatefulWidget {
  const MessageActionsSheet({
    super.key,
    required this.message,
    required this.isOwnMessage,
    this.onDelete,
    this.onReport,
    this.onBlock,
  });

  /// The message to act on
  final ChatMessage message;

  /// Whether this is the current user's message
  final bool isOwnMessage;

  /// Callback to delete message (own messages only)
  final VoidCallback? onDelete;

  /// Callback to report message (other's messages only)
  final ReportCallback? onReport;

  /// Callback to block user (other's messages only)
  final VoidCallback? onBlock;

  @override
  State<MessageActionsSheet> createState() => _MessageActionsSheetState();
}

class _MessageActionsSheetState extends State<MessageActionsSheet> {
  bool _showReportOptions = false;
  ReportReason? _selectedReason;
  final TextEditingController _detailsController = TextEditingController();

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LynewedComponentStyles.bottomSheetDecoration(),
      child: SafeArea(
        top: false,
        child: _showReportOptions ? _buildReportOptions() : _buildMainOptions(),
      ),
    );
  }

  Widget _buildMainOptions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle bar
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          decoration: BoxDecoration(
            color: LynewedColors.gray200,
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Title
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LynewedSpacing.md,
            vertical: LynewedSpacing.sm,
          ),
          child: Text(
            'Actions',
            style: LynewedTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const Divider(color: LynewedColors.border, height: 1),

        // Options
        if (widget.isOwnMessage) ...[
          // Delete option (own messages)
          _buildOptionTile(
            icon: Icons.delete_outline,
            label: 'Supprimer le message',
            onTap: widget.onDelete,
            isDestructive: true,
          ),
        ] else ...[
          // Report option (other's messages)
          _buildOptionTile(
            icon: Icons.flag_outlined,
            label: 'Signaler ce message',
            onTap: () {
              setState(() {
                _showReportOptions = true;
              });
            },
          ),

          // Block option (other's messages)
          _buildOptionTile(
            icon: Icons.block,
            label: 'Bloquer cet utilisateur',
            onTap: widget.onBlock,
            isDestructive: true,
          ),
        ],

        // Cancel
        _buildOptionTile(
          icon: Icons.close,
          label: 'Annuler',
          onTap: () => Navigator.pop(context),
        ),

        const SizedBox(height: LynewedSpacing.md),
      ],
    );
  }

  Widget _buildReportOptions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle bar
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          decoration: BoxDecoration(
            color: LynewedColors.gray200,
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Header with back button
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LynewedSpacing.md,
            vertical: LynewedSpacing.sm,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showReportOptions = false;
                    _selectedReason = null;
                    _detailsController.clear();
                  });
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: LynewedColors.primary,
                ),
              ),
              const SizedBox(width: LynewedSpacing.sm),
              Text(
                'Signaler le message',
                style: LynewedTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const Divider(color: LynewedColors.border, height: 1),

        // Report reasons
        Padding(
          padding: const EdgeInsets.all(LynewedSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Raison du signalement',
                style: LynewedTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: LynewedSpacing.sm),

              // Reason options
              ...ReportReason.values.map((reason) => _buildReasonOption(reason)),

              const SizedBox(height: LynewedSpacing.md),

              // Details field (optional)
              Text(
                'Détails (optionnel)',
                style: LynewedTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: LynewedSpacing.sm),
              TextField(
                controller: _detailsController,
                maxLines: 3,
                maxLength: 500,
                decoration: LynewedComponentStyles.formInputDecoration(
                  hintText: 'Décrivez le problème...',
                ),
                style: LynewedTextStyles.bodyMedium,
              ),

              const SizedBox(height: LynewedSpacing.md),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedReason != null
                      ? () {
                          widget.onReport?.call(
                            _selectedReason!,
                            _detailsController.text.isNotEmpty
                                ? _detailsController.text
                                : null,
                          );
                        }
                      : null,
                  style: LynewedComponentStyles.primaryButton(),
                  child: const Text('Envoyer le signalement'),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: LynewedSpacing.md),
      ],
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? LynewedColors.error : LynewedColors.textPrimary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: LynewedSpacing.md,
          vertical: LynewedSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: LynewedSpacing.md),
            Text(
              label,
              style: LynewedTextStyles.bodyMedium.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonOption(ReportReason reason) {
    final isSelected = _selectedReason == reason;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedReason = reason;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: LynewedSpacing.md,
          vertical: LynewedSpacing.sm,
        ),
        margin: const EdgeInsets.only(bottom: LynewedSpacing.xs),
        decoration: BoxDecoration(
          color: isSelected ? LynewedColors.primary : LynewedColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? LynewedColors.primary : LynewedColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: isSelected
                  ? LynewedColors.textOnPrimary
                  : LynewedColors.textSecondary,
            ),
            const SizedBox(width: LynewedSpacing.sm),
            Text(
              reason.displayLabel,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: isSelected
                    ? LynewedColors.textOnPrimary
                    : LynewedColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
