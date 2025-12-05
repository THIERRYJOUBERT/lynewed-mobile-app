import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/core/design/design.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'auth_welcome_page_model.dart';
export 'auth_welcome_page_model.dart';

class AuthWelcomePageWidget extends StatefulWidget {
  const AuthWelcomePageWidget({super.key});

  static String routeName = 'AuthWelcomePage';
  static String routePath = '/authWelcomePage';

  @override
  State<AuthWelcomePageWidget> createState() => _AuthWelcomePageWidgetState();
}

class _AuthWelcomePageWidgetState extends State<AuthWelcomePageWidget> {
  late AuthWelcomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AuthWelcomePageModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SizedBox(
          width: MediaQuery.sizeOf(context).width * 1.0,
          height: MediaQuery.sizeOf(context).height * 1.0,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(0.0),
                child: Image.asset(
                  'assets/images/DSC_0004-2_(1).png',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: const AlignmentDirectional(0.0, -1.0),
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 60.0, 0.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
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
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                            ],
                          ),
                        ].divide(const SizedBox(height: 12.0)),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(32.0, 0.0, 32.0, 80.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Main CTA - I'm a Bride (white background, black text)
                        SizedBox(
                          width: double.infinity,
                          height: LynewedSpacing.buttonHeight,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to Bride auth choice (login or register)
                              _showBrideAuthChoice();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: LynewedColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                            ),
                            child: Text(
                              'I\'m a Bride',
                              style: LynewedTextStyles.bodyMedium.copyWith(
                                color: LynewedColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        // Secondary CTA - I'm a Professional (text link)
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              // Pro can only login, no registration in app
                              context.pushNamed(SignInEmailPageProWidget.routeName);
                            },
                            child: Text(
                              'I\'m a Professional',
                              style: LynewedTextStyles.bodyMedium.copyWith(
                                color: Colors.white,
                                fontSize: 15.0,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show bottom sheet for Bride auth choice (Login or Register)
  void _showBrideAuthChoice() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title
                Text(
                  'Welcome to Lynewed',
                  style: LynewedTextStyles.sheetTitle.copyWith(
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find the perfect wedding professionals for your special day',
                  textAlign: TextAlign.center,
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: LynewedColors.gray100,
                  ),
                ),
                const SizedBox(height: 32),
                // Login button
                SizedBox(
                  width: double.infinity,
                  height: LynewedSpacing.buttonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.pushNamed(SignInEmailPageWidget.routeName);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LynewedColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    child: Text(
                      'Log in',
                      style: LynewedTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Register button
                SizedBox(
                  width: double.infinity,
                  height: LynewedSpacing.buttonHeight,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.pushNamed(SignUpEmailPageWidget.routeName);
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: LynewedColors.primary,
                      side: const BorderSide(color: LynewedColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    child: Text(
                      'Create an account',
                      style: LynewedTextStyles.bodyMedium.copyWith(
                        color: LynewedColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
