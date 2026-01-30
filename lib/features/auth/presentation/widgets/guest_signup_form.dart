/// Signup form widget for guest accounts.
///
/// Includes fields for first name, email, and password
/// with validation and error display.
library;

import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';

/// Callback when form is submitted.
typedef GuestSignupCallback = void Function(
  String firstName,
  String email,
  String password,
);

/// Form for guest signup with validation.
class GuestSignupForm extends StatefulWidget {
  /// Initial email to pre-fill (from invitation).
  final String? initialEmail;

  /// Whether the form is in loading state.
  final bool isLoading;

  /// Error message to display.
  final String? errorMessage;

  /// Callback when form is submitted.
  final GuestSignupCallback onSubmit;

  /// Creates a guest signup form.
  const GuestSignupForm({
    required this.onSubmit,
    this.initialEmail,
    this.isLoading = false,
    this.errorMessage,
    super.key,
  });

  @override
  State<GuestSignupForm> createState() => _GuestSignupFormState();
}

class _GuestSignupFormState extends State<GuestSignupForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _emailController = TextEditingController(text: widget.initialEmail);
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _firstNameController.text.isNotEmpty &&
      _emailController.text.isNotEmpty &&
      _passwordController.text.length >= 6 &&
      _termsAccepted;

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_termsAccepted) {
        return;
      }
      widget.onSubmit(
        _firstNameController.text.trim(),
        _emailController.text.trim().toLowerCase(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // First name field
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              labelText: 'Prénom',
              hintText: 'Entrez votre prénom',
              prefixIcon: Icon(Icons.person_outline),
            ),
            textCapitalization: TextCapitalization.words,
            enabled: !widget.isLoading,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le prénom est requis';
              }
              return null;
            },
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: LynewedSpacing.md),

          // Email field
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'votre@email.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            enabled: !widget.isLoading,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "L'email est requis";
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
                return 'Email invalide';
              }
              return null;
            },
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: LynewedSpacing.md),

          // Password field
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              hintText: 'Au moins 6 caractères',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            obscureText: _obscurePassword,
            enabled: !widget.isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le mot de passe est requis';
              }
              if (value.length < 6) {
                return 'Au moins 6 caractères requis';
              }
              return null;
            },
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: LynewedSpacing.md),

          // Terms checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _termsAccepted,
                onChanged: widget.isLoading
                    ? null
                    : (value) {
                        setState(() => _termsAccepted = value ?? false);
                      },
              ),
              Expanded(
                child: GestureDetector(
                  onTap: widget.isLoading
                      ? null
                      : () {
                          setState(() => _termsAccepted = !_termsAccepted);
                        },
                  child: Padding(
                    padding: EdgeInsets.only(top: LynewedSpacing.sm),
                    child: Text.rich(
                      TextSpan(
                        text: "J'accepte les ",
                        children: [
                          TextSpan(
                            text: "conditions d'utilisation",
                            style: TextStyle(
                              color: LynewedColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' et la '),
                          TextSpan(
                            text: 'politique de confidentialité',
                            style: TextStyle(
                              color: LynewedColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                      style: LynewedTextStyles.bodySmall,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Error message
          if (widget.errorMessage != null) ...[
            SizedBox(height: LynewedSpacing.sm),
            Container(
              padding: EdgeInsets.all(LynewedSpacing.sm),
              decoration: BoxDecoration(
                color: LynewedColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(LynewedSpacing.sm),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: LynewedColors.error, size: 20),
                  SizedBox(width: LynewedSpacing.sm),
                  Expanded(
                    child: Text(
                      widget.errorMessage!,
                      style: LynewedTextStyles.bodySmall.copyWith(
                        color: LynewedColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Terms warning if not accepted
          if (!_termsAccepted &&
              _firstNameController.text.isNotEmpty &&
              _emailController.text.isNotEmpty &&
              _passwordController.text.length >= 6) ...[
            SizedBox(height: LynewedSpacing.sm),
            Text(
              'Veuillez accepter les conditions',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.error,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          SizedBox(height: LynewedSpacing.lg),

          // Submit button
          ElevatedButton(
            onPressed: widget.isLoading || !_isFormValid ? null : _submit,
            child: widget.isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: LynewedColors.textOnDark,
                    ),
                  )
                : const Text('Créer mon compte invité'),
          ),
        ],
      ),
    );
  }
}
