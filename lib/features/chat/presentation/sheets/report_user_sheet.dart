/// Report user sheet - Clean Architecture
/// 
/// Bottom sheet for reporting a user (professional) from profile views.
/// Can be used from ProfessionalDetailsSheet, ProDetailsPage, or any profile view.
/// Uses LynewedSheet for consistent design with other sheets.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../domain/entities/entities.dart';

/// Callback for report action
typedef ReportUserCallback = Future<void> Function(ReportReason reason, String? details);

/// Bottom sheet for reporting a user
class ReportUserSheet extends StatefulWidget {
  const ReportUserSheet({
    super.key,
    required this.userName,
    this.userAvatarUrl,
    required this.onReport,
  });

  /// Name of the user being reported
  final String userName;

  /// Avatar URL of the user (optional)
  final String? userAvatarUrl;

  /// Callback when report is submitted
  final ReportUserCallback onReport;

  /// Show the report sheet as a modal bottom sheet
  static Future<void> show({
    required BuildContext context,
    required String userName,
    String? userAvatarUrl,
    required ReportUserCallback onReport,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ReportUserSheet(
        userName: userName,
        userAvatarUrl: userAvatarUrl,
        onReport: onReport,
      ),
    );
  }

  @override
  State<ReportUserSheet> createState() => _ReportUserSheetState();
}

class _ReportUserSheetState extends State<ReportUserSheet> {
  ReportReason? _selectedReason;
  final TextEditingController _detailsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _selectedReason != null && !_isSubmitting;

  Future<void> _handleSubmit() async {
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);

    try {
      await widget.onReport(
        _selectedReason!,
        _detailsController.text.trim().isEmpty 
            ? null 
            : _detailsController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LynewedSheet(
      title: 'Report User',
      onClose: () => Navigator.pop(context),
      bottomAction: SizedBox(
        width: double.infinity,
        child: LynewedButton(
          text: 'Submit Report',
          onPressed: _canSubmit ? _handleSubmit : null,
          isLoading: _isSubmitting,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          _buildUserInfo(),
          const SizedBox(height: 30), // Design System: 30px inter-section
          
          // Reason selection
          const LynewedSectionTitle('Reason for Report'),
          const SizedBox(height: 10), // Design System: 10px label→content
          ...ReportReason.values.map((reason) => _buildReasonOption(reason)),
          const SizedBox(height: 30), // Design System: 30px inter-section
          
          // Details input (grey background for visual consistency)
          LynewedTextField(
            controller: _detailsController,
            label: 'Additional Details (optional)',
            hint: 'Describe the issue...',
            maxLines: 3,
            maxLength: 500,
            isValueInput: false, // Grey background for consistency
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 24,
          backgroundColor: LynewedColors.gray100,
          backgroundImage: widget.userAvatarUrl != null
              ? NetworkImage(widget.userAvatarUrl!)
              : null,
          child: widget.userAvatarUrl == null
              ? Text(
                  _getInitials(widget.userName),
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: LynewedColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 16),
        // Name and info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.userName,
                style: LynewedTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'You are about to report this profile',
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReasonOption(ReportReason reason) {
    final isSelected = _selectedReason == reason;

    return InkWell(
      onTap: () => setState(() => _selectedReason = reason),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.transparent, // Always transparent background
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? LynewedColors.primary : LynewedColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: isSelected ? LynewedColors.primary : LynewedColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reason.displayLabel,
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                  Text(
                    _getReasonDescription(reason),
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
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

  String _getReasonDescription(ReportReason reason) {
    switch (reason) {
      case ReportReason.spam:
        return 'Unsolicited messages or advertising';
      case ReportReason.harassment:
        return 'Abusive or intimidating behavior';
      case ReportReason.inappropriateContent:
        return 'Offensive or inappropriate content';
      case ReportReason.other:
        return 'Other reason not listed';
    }
  }
}
