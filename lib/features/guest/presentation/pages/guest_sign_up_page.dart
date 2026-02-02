/// Guest sign-up page.
///
/// Clone of SignUpEmailPageWidget with guest-specific adaptations.
/// Includes first name field and invitation code handling.
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/core/design/design.dart';
import '/index.dart';
import '../../../auth/data/repositories/guest_repository_impl.dart';
import '../../../auth/domain/repositories/guest_repository.dart';
import '../../../auth/domain/usecases/create_guest_account.dart';

/// Sign-up page for guests.
class GuestSignUpPage extends StatefulWidget {
  const GuestSignUpPage({
    required this.inviteCode,
    required this.brideName,
    this.prefilledEmail,
    this.guestRepository,
    this.createGuestAccountUseCase,
    super.key,
  });

  /// Route name for navigation.
  static const routeName = 'GuestSignUpPage';

  /// Route path for navigation.
  static const routePath = '/guestSignUp';

  /// The validated invite code.
  final String inviteCode;

  /// Name of the bride (from code validation).
  final String brideName;

  /// Pre-filled email (if guest was invited by email).
  final String? prefilledEmail;

  /// Optional repository for testing.
  final GuestRepository? guestRepository;

  /// Optional use case for testing.
  final CreateGuestAccount? createGuestAccountUseCase;

  @override
  State<GuestSignUpPage> createState() => _GuestSignUpPageState();
}

class _GuestSignUpPageState extends State<GuestSignUpPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  bool _passwordVisibility = false;
  bool _confirmPasswordVisibility = false;
  bool _checkboxCGUValue = false;
  bool _isLoading = false;
  late final CreateGuestAccount _createGuestAccount;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledEmail != null) {
      _emailController.text = widget.prefilledEmail!;
    }
    final repository =
        widget.guestRepository ?? GuestRepositoryImpl.withDefaults();
    _createGuestAccount =
        widget.createGuestAccountUseCase ?? CreateGuestAccount(repository);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    // Validate checkbox
    if (!_checkboxCGUValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You must accept the terms and conditions'),
          backgroundColor: FlutterFlowTheme.of(context).warning,
        ),
      );
      return;
    }

    // Validate passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('The two passwords are different'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      return;
    }

    // Validate all fields filled
    if (_firstNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _createGuestAccount(CreateGuestAccountParams(
      firstName: _firstNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      inviteCode: widget.inviteCode,
    ));

    if (!mounted) return;
    setState(() => _isLoading = false);

    switch (result) {
      case GuestAccountCreated():
        context.goNamed(GuestHomePage.routeName);
      case EmailAlreadyExists():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'This email is already in use. Would you like to sign in?'),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      case InvalidEmailFormat():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Invalid email format'),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      case WeakPassword():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password must be at least 6 characters'),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      case InvalidInviteCodeError():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Invalid or expired invitation code'),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      case CreateGuestAccountError(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Header with photo
              _buildHeader(context),

              // Form content
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(32.0, 0.0, 32.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title section
                    _buildTitleSection(context),

                    // Form fields
                    _buildFormFields(context),

                    // Buttons
                    _buildButtons(context),

                    // Bottom padding
                    const SizedBox(height: 32.0),
                  ].divide(const SizedBox(height: 32.0)),
                ),
              ),
            ].divide(const SizedBox(height: 32.0)),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            child: Align(
              alignment: const AlignmentDirectional(0.0, 0.0),
              child: Stack(
                alignment: const AlignmentDirectional(0.0, -1.0),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(0.0),
                    child: Image.asset(
                      'assets/images/20240504_DOSMASENLAMESA_HT_AMALFI-438-BW.jpg',
                      width: MediaQuery.sizeOf(context).width * 1.0,
                      height: 170.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(0.0, -1.0),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          32.0, 70.0, 32.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Align(
                                alignment: const AlignmentDirectional(0.0, 0.0),
                                child: FlutterFlowIconButton(
                                  borderRadius: 100.0,
                                  borderWidth: 0.0,
                                  buttonSize: 40.0,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .backgroundIcons,
                                  icon: const Icon(
                                    Icons.arrow_back_ios_rounded,
                                    color: Colors.white,
                                    size: 17.0,
                                  ),
                                  onPressed: () async {
                                    context.safePop();
                                  },
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'LYNEWED',
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Haas Grot Text Trial',
                                        color: Colors.white,
                                        fontSize: 32.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                              Container(
                                width: 40.0,
                                height: 40.0,
                                decoration: const BoxDecoration(),
                              ),
                            ],
                          ),
                          Text(
                            'THE WORLD WEDDING INDUSTRY\nIN YOUR POCKET',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Haas Grot Text Trial',
                                  color: Colors.white,
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ].divide(const SizedBox(height: 12.0)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: const AlignmentDirectional(-1.0, -1.0),
          child: Text(
            'JOIN THE WEDDING',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Haas Grot Text Trial',
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Text(
          'Create your guest account to access photos, chat and more',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Haas Grot Text Trial',
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
              ),
        ),
        Align(
          alignment: const AlignmentDirectional(1.0, 1.0),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
            child: Text(
              'Required fields*',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Haas Grot Text Trial',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
        ),
      ].divide(const SizedBox(height: 14.0)),
    );
  }

  Widget _buildFormFields(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First name field (guest specific)
          SizedBox(
            width: double.infinity,
            child: TextFormField(
              controller: _firstNameController,
              focusNode: _firstNameFocusNode,
              autofocus: false,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              obscureText: false,
              decoration: InputDecoration(
                isDense: true,
                labelText: 'First name*',
                labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                      fontFamily: 'Haas Grot Text Trial',
                      letterSpacing: 0.0,
                    ),
                hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                      fontFamily: 'Haas Grot Text Trial',
                      letterSpacing: 0.0,
                    ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).accent1,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(0.0),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).tertiary,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(0.0),
                ),
                errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).error,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(0.0),
                ),
                focusedErrorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).error,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(0.0),
                ),
                contentPadding:
                    const EdgeInsetsDirectional.fromSTEB(4.0, 12.0, 0.0, 12.0),
              ),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Haas Grot Text Trial',
                    letterSpacing: 0.0,
                  ),
              cursorColor: FlutterFlowTheme.of(context).primaryText,
              enableInteractiveSelection: true,
            ),
          ),

          // Email field
          SizedBox(
            width: double.infinity,
            child: TextFormField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              autofocus: false,
              textInputAction: TextInputAction.next,
              obscureText: false,
              decoration: InputDecoration(
                isDense: true,
                labelText: 'Email address*',
                labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                      fontFamily: 'Haas Grot Text Trial',
                      letterSpacing: 0.0,
                    ),
                hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                      fontFamily: 'Haas Grot Text Trial',
                      letterSpacing: 0.0,
                    ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).accent1,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(0.0),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).tertiary,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(0.0),
                ),
                errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).error,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(0.0),
                ),
                focusedErrorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).error,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(0.0),
                ),
                contentPadding:
                    const EdgeInsetsDirectional.fromSTEB(4.0, 12.0, 0.0, 12.0),
              ),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Haas Grot Text Trial',
                    letterSpacing: 0.0,
                  ),
              keyboardType: TextInputType.emailAddress,
              cursorColor: FlutterFlowTheme.of(context).primaryText,
              enableInteractiveSelection: true,
            ),
          ),

          // Password field
          SizedBox(
            width: double.infinity,
            child: TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              autofocus: false,
              textInputAction: TextInputAction.next,
              obscureText: !_passwordVisibility,
              decoration: InputDecoration(
                isDense: true,
                labelText: 'Password*',
                labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                      fontFamily: 'Haas Grot Text Trial',
                      letterSpacing: 0.0,
                    ),
                hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                      fontFamily: 'Haas Grot Text Trial',
                      letterSpacing: 0.0,
                    ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).accent1,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(0.0),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).tertiary,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(0.0),
                ),
                errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).error,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(0.0),
                ),
                focusedErrorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).error,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(0.0),
                ),
                contentPadding:
                    const EdgeInsetsDirectional.fromSTEB(4.0, 12.0, 0.0, 12.0),
                suffixIcon: InkWell(
                  onTap: () => setState(
                    () => _passwordVisibility = !_passwordVisibility,
                  ),
                  focusNode: FocusNode(skipTraversal: true),
                  child: Icon(
                    _passwordVisibility
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    size: 22,
                  ),
                ),
              ),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Haas Grot Text Trial',
                    letterSpacing: 0.0,
                  ),
              cursorColor: FlutterFlowTheme.of(context).primaryText,
              enableInteractiveSelection: true,
            ),
          ),

          // Confirm password field
          SizedBox(
            width: double.infinity,
            child: TextFormField(
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocusNode,
              autofocus: false,
              textInputAction: TextInputAction.done,
              obscureText: !_confirmPasswordVisibility,
              decoration: InputDecoration(
                isDense: true,
                labelText: 'Confirm password*',
                labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                      fontFamily: 'Haas Grot Text Trial',
                      letterSpacing: 0.0,
                    ),
                hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                      fontFamily: 'Haas Grot Text Trial',
                      letterSpacing: 0.0,
                    ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).accent1,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(0.0),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).tertiary,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(0.0),
                ),
                errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).error,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(0.0),
                ),
                focusedErrorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).error,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(0.0),
                ),
                contentPadding:
                    const EdgeInsetsDirectional.fromSTEB(4.0, 12.0, 0.0, 12.0),
                suffixIcon: InkWell(
                  onTap: () => setState(
                    () =>
                        _confirmPasswordVisibility = !_confirmPasswordVisibility,
                  ),
                  focusNode: FocusNode(skipTraversal: true),
                  child: Icon(
                    _confirmPasswordVisibility
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    size: 22,
                  ),
                ),
              ),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Haas Grot Text Trial',
                    letterSpacing: 0.0,
                  ),
              cursorColor: FlutterFlowTheme.of(context).primaryText,
              enableInteractiveSelection: true,
            ),
          ),

          // Terms checkbox
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Theme(
                data: ThemeData(
                  checkboxTheme: CheckboxThemeData(
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                  unselectedWidgetColor:
                      FlutterFlowTheme.of(context).secondaryText,
                ),
                child: Checkbox(
                  value: _checkboxCGUValue,
                  onChanged: (newValue) async {
                    setState(() => _checkboxCGUValue = newValue!);
                  },
                  side: BorderSide(
                    width: 2,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                  activeColor: FlutterFlowTheme.of(context).primary,
                  checkColor: FlutterFlowTheme.of(context).info,
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      child: RichText(
                        textScaler: MediaQuery.of(context).textScaler,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'I agree to ',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Haas Grot Text Trial',
                                    fontSize: 13.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            TextSpan(
                              text: 'Terms and Conditions of Sale and Use',
                              style: const TextStyle(
                                fontSize: 13.0,
                                decoration: TextDecoration.underline,
                              ),
                              mouseCursor: SystemMouseCursors.click,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  await launchURL(
                                      'https://www.lynewed.com/terms-of-service');
                                },
                            )
                          ],
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Haas Grot Text Trial',
                                    fontSize: 13.0,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ].divide(const SizedBox(height: 24.0)),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          LynewedButton(
            text: 'Create my guest account',
            onPressed: _isLoading ? null : _handleSignUp,
            type: LynewedButtonType.primary,
            width: double.infinity,
            isLoading: _isLoading,
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
            child: InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                context.goNamed(GuestSignInPage.routeName);
              },
              child: Text(
                'Already registered? Log in here',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Haas Grot Text Trial',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
          ),
        ].divide(const SizedBox(height: 12.0)),
      ),
    );
  }
}
