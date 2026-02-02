/// Guest forgot password page.
///
/// Clone of ForgotPasswordPageWidget with guest-specific adaptations.
/// Uses FlutterFlow legacy style for visual consistency.
library;

import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';

/// Forgot password page for guests.
class GuestForgotPasswordPage extends StatefulWidget {
  const GuestForgotPasswordPage({super.key});

  static const routeName = 'GuestForgotPasswordPage';
  static const routePath = '/guestForgotPassword';

  @override
  State<GuestForgotPasswordPage> createState() =>
      _GuestForgotPasswordPageState();
}

class _GuestForgotPasswordPageState extends State<GuestForgotPasswordPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email required!'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    await authManager.resetPassword(
      email: _emailController.text.trim(),
      context: context,
      redirectTo: 'https://lynewed.com/reset-password-app',
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Password reset email sent!'),
        backgroundColor: FlutterFlowTheme.of(context).success,
      ),
    );

    context.goNamed(
      GuestSignInPage.routeName,
      extra: <String, dynamic>{
        kTransitionInfoKey: const TransitionInfo(
          hasTransition: true,
          transitionType: PageTransitionType.fade,
          duration: Duration(milliseconds: 0),
        ),
      },
    );
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
                          Align(
                            alignment: const AlignmentDirectional(0.0, 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Align(
                                  alignment:
                                      const AlignmentDirectional(0.0, 0.0),
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
                                  height: 30.0,
                                  decoration: const BoxDecoration(),
                                ),
                              ],
                            ),
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
            'RESET PASSWORD',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Haas Grot Text Trial',
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Text(
          'Enter your email address to receive a password reset link.',
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
              textInputAction: TextInputAction.done,
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
        ].divide(const SizedBox(height: 24.0)),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        FFButtonWidget(
          onPressed: _isLoading ? null : _handleResetPassword,
          text: 'Reset my password',
          options: FFButtonOptions(
            width: double.infinity,
            height: 48.0,
            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
            iconPadding:
                const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
            color: FlutterFlowTheme.of(context).primary,
            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                  fontFamily: 'Haas Grot Text Trial',
                  color: Colors.white,
                  fontSize: 14.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.normal,
                ),
            elevation: 0.0,
            borderRadius: BorderRadius.circular(0.0),
          ),
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
              'Remember your password? Log in',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Haas Grot Text Trial',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
        ),
      ].divide(const SizedBox(height: 12.0)),
    );
  }
}
