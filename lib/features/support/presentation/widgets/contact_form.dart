/// Contact form widget.
///
/// A form for users to submit support requests with subject and message.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';

/// Callback type for form submission.
typedef ContactFormSubmitCallback = void Function(String subject, String message);

/// A widget that displays a contact form.
///
/// Used in the support page for users to send messages to the support team.
/// Includes validation for subject and message fields.
///
/// Example:
/// ```dart
/// ContactForm(
///   onSubmit: (subject, message) {
///     // Handle submission
///   },
/// )
/// ```
class ContactForm extends StatefulWidget {
  /// Callback when form is submitted with valid data.
  final ContactFormSubmitCallback? onSubmit;

  /// Whether the form is currently submitting.
  /// When true, shows a loading indicator and disables the submit button.
  final bool isLoading;

  /// Creates a contact form widget.
  const ContactForm({
    this.onSubmit,
    this.isLoading = false,
    super.key,
  });

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit?.call(
        _subjectController.text.trim(),
        _messageController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 16.0),
            child: Text(
              'Contact Us',
              style: LynewedTextStyles.sectionTitle,
            ),
          ),
          // Subject field label
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              'Subject',
              style: LynewedTextStyles.labelLarge.copyWith(
                color: LynewedColors.textPrimary,
              ),
            ),
          ),
          // Subject field
          TextFormField(
            controller: _subjectController,
            enabled: !widget.isLoading,
            decoration: InputDecoration(
              hintText: 'What is this about?',
              hintStyle: LynewedTextStyles.inputHint,
              filled: true,
              fillColor: LynewedColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: LynewedColors.border,
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: LynewedColors.border,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: LynewedColors.primary,
                  width: 1.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: LynewedColors.error,
                  width: 1.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: LynewedColors.error,
                  width: 1.0,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 14.0,
              ),
            ),
            style: LynewedTextStyles.bodyMedium,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a subject';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          // Message field label
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              'Message',
              style: LynewedTextStyles.labelLarge.copyWith(
                color: LynewedColors.textPrimary,
              ),
            ),
          ),
          // Message field
          TextFormField(
            controller: _messageController,
            enabled: !widget.isLoading,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Describe your issue or question...',
              hintStyle: LynewedTextStyles.inputHint,
              filled: true,
              fillColor: LynewedColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: LynewedColors.border,
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: LynewedColors.border,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: LynewedColors.primary,
                  width: 1.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: LynewedColors.error,
                  width: 1.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: LynewedColors.error,
                  width: 1.0,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 14.0,
              ),
              alignLabelWithHint: true,
            ),
            style: LynewedTextStyles.bodyMedium,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a message';
              }
              if (value.trim().length < 10) {
                return 'Message must be at least 10 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 24.0),
          // Submit button
          SizedBox(
            width: double.infinity,
            height: 48.0,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: LynewedColors.primary,
                foregroundColor: LynewedColors.textOnPrimary,
                disabledBackgroundColor: LynewedColors.gray200,
                disabledForegroundColor: LynewedColors.textSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 0,
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24.0,
                      height: 24.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          LynewedColors.textOnPrimary,
                        ),
                      ),
                    )
                  : Text(
                      'Send Message',
                      style: LynewedTextStyles.buttonPrimary,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
