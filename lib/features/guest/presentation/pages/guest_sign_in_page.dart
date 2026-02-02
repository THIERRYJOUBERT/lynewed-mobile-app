/// Guest sign-in page.
///
/// Clone of SignInEmailPageWidget with guest-specific adaptations.
/// Uses FlutterFlow legacy style for visual consistency.
library;

import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/core/design/design.dart';
import '/index.dart';
import 'package:flutter/material.dart';

/// Sign-in page for guests.
class GuestSignInPage extends StatefulWidget {
  const GuestSignInPage({super.key});

  static const routeName = 'GuestSignInPage';
  static const routePath = '/guestSignIn';

  @override
  State<GuestSignInPage> createState() => _GuestSignInPageState();
}

class _GuestSignInPageState extends State<GuestSignInPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _passwordVisibility = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    GoRouter.of(context).prepareAuthEvent();

    final user = await authManager.signInWithEmail(
      context,
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid email or password'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      return;
    }

    if (context.mounted) {
      context.goNamedAuth(StartupGateWidget.routeName, context.mounted);
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
                  ].divide(const SizedBox(height: 48.0)),
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
                                    context.goNamed(JoinWeddingPage.routeName);
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
                                height: 30.0,
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
            'WELCOME BACK, GUEST',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Haas Grot Text Trial',
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Text(
          'Log in to access the wedding',
          textAlign: TextAlign.start,
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
                labelText: 'Email address',
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

          // Forgot password link
          InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              context.pushNamed(GuestForgotPasswordPage.routeName);
            },
            child: Text(
              'Forgot your password?',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Haas Grot Text Trial',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                    decoration: TextDecoration.underline,
                  ),
            ),
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
            text: 'Log in',
            onPressed: _isLoading ? null : _handleSignIn,
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
                // Navigate to guest signup - need invite code first
                context.goNamed(JoinWeddingPage.routeName);
              },
              child: Text(
                "Don't have an account? Create your guest account",
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
