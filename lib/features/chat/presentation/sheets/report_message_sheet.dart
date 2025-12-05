/// Report message sheet - Clean Architecture
/// 
/// Bottom sheet for reporting a message.
/// Uses the same design as ReportUserSheet for UI consistency.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '/core/design/widgets/widgets.dart';
import '../../domain/entities/entities.dart';

/// Callback for report action
typedef ReportMessageCallback = Future<void> Function(ReportReason reason, String? details);

/// Bottom sheet for reporting a message
class ReportMessageSheet extends StatefulWidget {
  const ReportMessageSheet({
    super.key,
    required this.onReport,
  });

  /// Callback when report is submitted
  final ReportMessageCallback onReport;

  /// Show the report sheet as a modal bottom sheet
  static Future<void> show({
    required BuildContext context,
    required ReportMessageCallback onReport,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ReportMessageSheet(
        onReport: onReport,
      ),
    );
  }

  @override
  State<ReportMessageSheet> createState() => _ReportMessageSheetState();
}

class _ReportMessageSheetState extends State<ReportMessageSheet> {
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
      title: 'Report Message',
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
          // Info text
          _buildInfoText(),
          const SizedBox(height: 30), // Design System: 30px inter-section
          
          // Reason selection
          const LynewedSectionTitle('Reason for Report'),
          const SizedBox(height: 10), // Design System: 10px label→content
          ...ReportReason.values.map((reason) => _buildReasonOption(reason)),
          const SizedBox(height: 30), // Design System: 30px inter-section
          
          // Details input
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

  Widget _buildInfoText() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: LynewedColors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.flag_outlined,
            color: LynewedColors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Report this message',
                style: LynewedTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'This message will be reviewed by our team',
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
          color: Colors.transparent,
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

  String _getReasonDescription(ReportReason reason) {
    switch (reason) {
      case ReportReason.spam:
        return 'Unsolicited or promotional content';
      case ReportReason.harassment:
        return 'Abusive or threatening language';
      case ReportReason.inappropriateContent:
        return 'Offensive or inappropriate content';
      case ReportReason.other:
        return 'Other reason not listed';
    }
  }
}
