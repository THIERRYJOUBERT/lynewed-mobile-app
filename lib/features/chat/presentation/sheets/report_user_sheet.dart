/// Report user sheet - Clean Architecture
/// 
/// Bottom sheet for reporting a user (professional) from profile views.
/// Can be used from ProfessionalDetailsSheet, ProDetailsPage, or any profile view.
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
    return Container(
      decoration: LynewedComponentStyles.bottomSheetDecoration(),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const Divider(color: LynewedColors.border, height: 1),
              _buildUserInfo(),
              const Divider(color: LynewedColors.border, height: 1),
              _buildReasonSelection(),
              _buildDetailsInput(),
              _buildSubmitButton(),
              const SizedBox(height: LynewedSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
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
        // Title with close button
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LynewedSpacing.md,
            vertical: LynewedSpacing.sm,
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: LynewedSpacing.sm),
              Expanded(
                child: Text(
                  'Signaler un utilisateur',
                  style: LynewedTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.all(LynewedSpacing.md),
      child: Row(
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
          const SizedBox(width: LynewedSpacing.md),
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
                  'Vous êtes sur le point de signaler ce profil',
                  style: LynewedTextStyles.bodySmall.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonSelection() {
    return Padding(
      padding: const EdgeInsets.all(LynewedSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Raison du signalement',
            style: LynewedTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: LynewedSpacing.sm),
          ...ReportReason.values.map((reason) => _buildReasonOption(reason)),
        ],
      ),
    );
  }

  Widget _buildReasonOption(ReportReason reason) {
    final isSelected = _selectedReason == reason;

    return InkWell(
      onTap: () => setState(() => _selectedReason = reason),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: LynewedSpacing.md,
          vertical: LynewedSpacing.sm,
        ),
        margin: const EdgeInsets.only(bottom: LynewedSpacing.xs),
        decoration: BoxDecoration(
          color: isSelected ? LynewedColors.gray100 : Colors.transparent,
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
            const SizedBox(width: LynewedSpacing.sm),
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

  Widget _buildDetailsInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LynewedSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détails supplémentaires (optionnel)',
            style: LynewedTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: LynewedSpacing.sm),
          TextField(
            controller: _detailsController,
            maxLines: 3,
            maxLength: 500,
            decoration: LynewedComponentStyles.inputDecoration(
              hintText: 'Décrivez le problème...',
            ),
            style: LynewedTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LynewedSpacing.md),
      child: ElevatedButton(
        onPressed: _canSubmit ? _handleSubmit : null,
        style: LynewedComponentStyles.primaryButton(),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: LynewedColors.textOnPrimary,
                ),
              )
            : const Text('Envoyer le signalement'),
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
        return 'Messages non sollicités ou publicité';
      case ReportReason.harassment:
        return 'Comportement abusif ou intimidant';
      case ReportReason.inappropriateContent:
        return 'Contenu offensant ou inapproprié';
      case ReportReason.other:
        return 'Autre raison non listée';
    }
  }
}
