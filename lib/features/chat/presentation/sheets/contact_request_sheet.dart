/// Contact Request Sheet - Clean Architecture
/// 
/// Sheet displayed when Pro wants to contact a Bride.
/// Requires a message before creating the contact request.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '/core/design/widgets/widgets.dart';
import '../../domain/entities/entities.dart';
import '../../data/repositories/contact_repository_impl.dart';

/// Sheet for creating a contact request (Pro → Bride)
class ContactRequestSheet extends StatefulWidget {
  const ContactRequestSheet({
    super.key,
    required this.targetProfileId,
    required this.targetName,
    required this.source,
    this.targetAvatarUrl,
    this.onSuccess,
  });

  /// Target bride's profile ID
  final String targetProfileId;

  /// Target bride's name (for display)
  final String targetName;

  /// Source of the contact request
  final ContactRequestSource source;

  /// Target bride's avatar URL (optional)
  final String? targetAvatarUrl;

  /// Callback when request is successfully created
  final VoidCallback? onSuccess;

  /// Show the sheet
  static Future<void> show({
    required BuildContext context,
    required String targetProfileId,
    required String targetName,
    required ContactRequestSource source,
    String? targetAvatarUrl,
    VoidCallback? onSuccess,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ContactRequestSheet(
        targetProfileId: targetProfileId,
        targetName: targetName,
        source: source,
        targetAvatarUrl: targetAvatarUrl,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  State<ContactRequestSheet> createState() => _ContactRequestSheetState();
}

class _ContactRequestSheetState extends State<ContactRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _repository = ContactRepositoryImpl();
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _repository.createContactRequest(
      targetId: widget.targetProfileId,
      source: widget.source,
      message: _messageController.text.trim(),
    );

    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.of(context).pop();
      
      // Show success toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request sent to ${widget.targetName}'),
          backgroundColor: LynewedColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      widget.onSuccess?.call();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = _getErrorMessage(result.error);
      });
    }
  }

  String _getErrorMessage(String? error) {
    if (error == null) return 'An error occurred';
    
    if (error.contains('INSUFFICIENT_TIER')) {
      return 'Your subscription does not allow contacting this person';
    }
    if (error.contains('REQUEST_ALREADY_PENDING')) {
      return 'A request is already pending';
    }
    if (error.contains('ALREADY_CONNECTED')) {
      return 'You are already connected';
    }
    if (error.contains('BLOCKED')) {
      return 'Contact not possible';
    }
    if (error.contains('MESSAGE_REQUIRED')) {
      return 'Message is required';
    }
    
    return 'An error occurred';
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return LynewedDetailsSheet(
      headerAvatarUrl: widget.targetAvatarUrl,
      headerAvatarInitials: _getInitials(widget.targetName),
      title: 'Contact ${widget.targetName}',
      subtitle: Text(
        widget.source.displayLabel,
        style: LynewedTextStyles.bodySmall.copyWith(
          color: LynewedColors.textSecondary,
        ),
      ),
      trailing: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.close),
        iconSize: 24,
        color: LynewedColors.gray300,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
      actions: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Submit button
          LynewedButton(
            text: 'Send Request',
            onPressed: _isLoading ? null : _submitRequest,
            isLoading: _isLoading,
            width: double.infinity,
          ),
          const SizedBox(height: 8),
          // Cancel button
          LynewedButton(
            text: 'Cancel',
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            type: LynewedButtonType.ghost,
            width: double.infinity,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: LynewedComponentStyles.errorBannerDecoration(),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: LynewedColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: LynewedTextStyles.bodySmall.copyWith(
                          color: LynewedColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LynewedSpacing.lg),
            ],
            
            // Message field with LynewedTextField (grey background)
            LynewedTextField(
              controller: _messageController,
              label: 'Message',
              hint: 'Introduce yourself and explain why you want to get in touch...',
              maxLines: 5,
              maxLength: 1000,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Message is required';
                }
                if (value.trim().length < 10) {
                  return 'Message must be at least 10 characters';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
