/// Contact Request Sheet - Clean Architecture
/// 
/// Sheet displayed when Pro wants to contact a Bride.
/// Requires a message before creating the contact request.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
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
          content: Text('Demande envoyée à ${widget.targetName}'),
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
    if (error == null) return 'Une erreur est survenue';
    
    if (error.contains('INSUFFICIENT_TIER')) {
      return 'Votre abonnement ne permet pas de contacter cette personne';
    }
    if (error.contains('REQUEST_ALREADY_PENDING')) {
      return 'Une demande est déjà en attente';
    }
    if (error.contains('ALREADY_CONNECTED')) {
      return 'Vous êtes déjà en contact';
    }
    if (error.contains('BLOCKED')) {
      return 'Contact impossible';
    }
    if (error.contains('MESSAGE_REQUIRED')) {
      return 'Le message est obligatoire';
    }
    
    return 'Une erreur est survenue';
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      decoration: LynewedComponentStyles.bottomSheetDecoration(),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
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
            
            // Header
            Container(
              padding: LynewedComponentStyles.sheetHeaderPadding,
              decoration: LynewedComponentStyles.sheetHeaderDecoration(),
              child: Row(
                children: [
                  // Avatar
                  if (widget.targetAvatarUrl != null)
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(widget.targetAvatarUrl!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: LynewedColors.gray200,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: LynewedColors.gray300,
                        size: 24,
                      ),
                    ),
                  
                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contacter ${widget.targetName}',
                          style: LynewedTextStyles.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.source.displayLabel,
                          style: LynewedTextStyles.labelSmall.copyWith(
                            color: LynewedColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Close button
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    iconSize: 24,
                    color: LynewedColors.textSecondary,
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: LynewedComponentStyles.sheetContentPadding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info text
                    Text(
                      'Présentez-vous et expliquez pourquoi vous souhaitez entrer en contact.',
                      style: LynewedTextStyles.bodySmall.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Message field
                    TextFormField(
                      controller: _messageController,
                      decoration: LynewedComponentStyles.formInputDecoration(
                        hintText: 'Votre message...',
                        labelText: 'Message',
                      ),
                      maxLines: 4,
                      maxLength: 1000,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le message est obligatoire';
                        }
                        if (value.trim().length < 10) {
                          return 'Le message doit contenir au moins 10 caractères';
                        }
                        return null;
                      },
                    ),
                    
                    // Error message
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
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
                    ],
                    
                    const SizedBox(height: 20),
                    
                    // Submit button
                    SizedBox(
                      height: LynewedSpacing.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitRequest,
                        style: LynewedComponentStyles.primaryButton(),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: LynewedColors.textOnPrimary,
                                ),
                              )
                            : const Text('Envoyer la demande'),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Cancel button
                    SizedBox(
                      height: LynewedSpacing.buttonHeight,
                      child: TextButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                        style: LynewedComponentStyles.textButton(),
                        child: const Text('Annuler'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
