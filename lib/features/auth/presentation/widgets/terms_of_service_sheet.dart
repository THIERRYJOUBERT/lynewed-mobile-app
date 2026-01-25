/// Terms of Service bottom sheet widget.
///
/// A modal bottom sheet that displays the Terms of Service and Privacy Policy,
/// requiring users to accept before continuing to use the app.
library;

import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../core/design/design.dart';
import '../../domain/repositories/auth_repository.dart';

/// A bottom sheet widget for displaying and accepting Terms of Service.
///
/// Displays:
/// - Terms of Service content
/// - Checkbox for acceptance
/// - Continue button (disabled until accepted)
///
/// Usage:
/// ```dart
/// final accepted = await TermsOfServiceSheet.show(context);
/// if (accepted) {
///   // User accepted terms
/// }
/// ```
class TermsOfServiceSheet extends StatefulWidget {
  /// Creates a Terms of Service sheet.
  const TermsOfServiceSheet({super.key});

  /// Shows the Terms of Service sheet and returns true if accepted.
  ///
  /// Returns false if the sheet is dismissed without accepting.
  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => const TermsOfServiceSheet(),
    );
    return result ?? false;
  }

  @override
  State<TermsOfServiceSheet> createState() => _TermsOfServiceSheetState();
}

class _TermsOfServiceSheetState extends State<TermsOfServiceSheet> {
  bool _accepted = false;
  bool _isLoading = false;

  Future<void> _handleAccept() async {
    setState(() => _isLoading = true);

    final authRepo = sl<AuthRepository>();
    final result = await authRepo.acceptTerms();

    if (!mounted) return;

    switch (result) {
      case Success():
        Navigator.of(context).pop(true);
      case Failure(:final failure):
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.9,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: LynewedColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Terms of Service',
                  style: LynewedTextStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: const _TermsContent(),
                ),
              ),
              // Footer
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        value: _accepted,
                        onChanged: (value) =>
                            setState(() => _accepted = value ?? false),
                        title: const Text(
                          'I accept the Terms of Service and Privacy Policy',
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 16),
                      LynewedButton(
                        text: 'Continue',
                        onPressed:
                            _accepted && !_isLoading ? _handleAccept : null,
                        isLoading: _isLoading,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The Terms of Service and Privacy Policy content.
class _TermsContent extends StatelessWidget {
  const _TermsContent();

  @override
  Widget build(BuildContext context) {
    return Text(
      '''By using LYNEWED, you agree to our Terms of Service and Privacy Policy.

1. Terms of Use
These terms govern your use of the LYNEWED application. By accessing or using our services, you agree to be bound by these terms.

2. Privacy Policy
We take your privacy seriously. Your personal data is collected and processed in accordance with applicable data protection laws.

3. User Responsibilities
You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.

4. Service Availability
While we strive to provide uninterrupted service, we cannot guarantee that the service will be available at all times.

5. Content Guidelines
Users must not post content that is offensive, illegal, or violates the rights of others.

6. Intellectual Property
All content and materials available on LYNEWED are the property of LYNEWED or its licensors.

7. Limitation of Liability
LYNEWED shall not be liable for any indirect, incidental, or consequential damages arising from your use of the service.

8. Changes to Terms
We reserve the right to modify these terms at any time. Continued use of the service constitutes acceptance of any changes.

9. Contact
For questions about these terms, please contact our support team.

Last updated: January 2025''',
      style: LynewedTextStyles.bodyMedium,
    );
  }
}
