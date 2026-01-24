import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/components/nav/nav_bar_brides/nav_bar_brides_widget.dart';
import '/components/nav/nav_bar_pro/nav_bar_pro_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'profile_brides_and_pro_model.dart';
export 'profile_brides_and_pro_model.dart';

class ProfileBridesAndProWidget extends StatefulWidget {
  const ProfileBridesAndProWidget({super.key});

  static String routeName = 'ProfileBridesAndPro';
  static String routePath = '/profileBridesAndPro';

  @override
  State<ProfileBridesAndProWidget> createState() =>
      _ProfileBridesAndProWidgetState();
}

class _ProfileBridesAndProWidgetState extends State<ProfileBridesAndProWidget> {
  late ProfileBridesAndProModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfileBridesAndProModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Align(
                alignment: const AlignmentDirectional(0.0, -1.0),
                child: Container(
                  width: double.infinity,
                  height: 110.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20.0, 0.0, 20.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PROFIL',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Haas Grot Text Trial',
                                    fontSize: 18.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(0.0, 1.0),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 14.0, 0.0, 0.0),
                          child: Container(
                            width: double.infinity,
                            height: 1.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondary,
                            ),
                            alignment: const AlignmentDirectional(0.0, 1.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(20.0, 110.0, 20.0, 100.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Align(
                              alignment: const AlignmentDirectional(0.0, 0.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(99.0),
                                    child: Image.network(
                                      valueOrDefault<String>(
                                        FFAppState()
                                            .selfPublicProfile
                                            .avatarUrl,
                                        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/lynewed-alpha-du4al1/assets/egport4rt4rg/person_15429777_1.png',
                                      ),
                                      width: 80.0,
                                      height: 80.0,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            valueOrDefault<String>(
                                              FFAppState()
                                                  .selfPublicProfile
                                                  .fullName,
                                              'Name',
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      'Haas Grot Text Trial',
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ].divide(const SizedBox(height: 4.0)),
                                  ),
                                ].divide(const SizedBox(height: 14.0)),
                              ),
                            ),
                          ].divide(const SizedBox(height: 14.0)),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Preference',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Haas Grot Text Trial',
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              if (FFAppState().currentUserRole ==
                                  UserRole.bride) {
                                context.pushNamed(
                                    EditProfileBridesWidget.routeName);
                              } else {
                                await launchURL('https://www.lynewed.com');
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 12.0, 0.0, 12.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Edit my profil',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    'Haas Grot Text Trial',
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                        Stack(
                                          children: [
                                            if (FFAppState().currentUserRole ==
                                                UserRole.bride)
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                size: 18.0,
                                              ),
                                            if (FFAppState().currentUserRole ==
                                                UserRole.professional)
                                              FaIcon(
                                                FontAwesomeIcons
                                                    .upRightFromSquare,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                size: 16.0,
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 1.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // My Profile - Pro only
                          if (FFAppState().currentUserRole == UserRole.professional)
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                // Fetch own profile details and navigate to ProDetails
                                final proDetails = await actions.getProItemDetailsAction(
                                  currentUserUid,
                                );
                                if (proDetails != null && context.mounted) {
                                  context.pushNamed(
                                    ProDetailsWidget.routeName,
                                    queryParameters: {
                                      'profileId': serializeParam(
                                        currentUserUid,
                                        ParamType.String,
                                      ),
                                    }.withoutNulls,
                                    extra: <String, dynamic>{
                                      'proDetails': proDetails,
                                    },
                                  );
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 12.0, 0.0, 12.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'My Profile',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      'Haas Grot Text Trial',
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            size: 18.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: 1.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.pushNamed(PreferenceWidget.routeName);
                            },
                            child: Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 12.0, 0.0, 12.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Preference',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    'Haas Grot Text Trial',
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 18.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 1.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.pushNamed(
                                  NotificationSettingsPage.routeName);
                            },
                            child: Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 12.0, 0.0, 12.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Notifications',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    'Haas Grot Text Trial',
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 18.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 1.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.pushNamed(
                                  SettingsPermissionsWidget.routeName);
                            },
                            child: Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 12.0, 0.0, 12.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Settings and Permissions',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    'Haas Grot Text Trial',
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 18.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 1.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ].divide(const SizedBox(height: 14.0)),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Support and Legal',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Haas Grot Text Trial',
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              // Request app review - opens native iOS/Android review dialog
                              await actions.requestAppReview();
                            },
                            child: Container(
                              decoration: const BoxDecoration(),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 12.0, 0.0, 12.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Rate Lynewed on the App Store',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    'Haas Grot Text Trial',
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 18.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 1.0,
                                    decoration: BoxDecoration(
                                      color:
                                          FlutterFlowTheme.of(context).secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.pushNamed(SupportWidget.routeName);
                            },
                            child: Container(
                              decoration: const BoxDecoration(),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 12.0, 0.0, 12.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Contact us / Feedback',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    'Haas Grot Text Trial',
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 18.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 1.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              await launchURL(
                                  'https://www.lynewed.com/terms-of-service');
                            },
                            child: Container(
                              decoration: const BoxDecoration(),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 12.0, 0.0, 12.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Terms and Conditions of Sale and Use',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    'Haas Grot Text Trial',
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 18.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 1.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              GoRouter.of(context).prepareAuthEvent();
                              await authManager.signOut();
                              if (!context.mounted) return;
                              GoRouter.of(context).clearRedirectLocation();

                              context.goNamedAuth(
                                  AuthWelcomePageWidget.routeName,
                                  context.mounted);
                            },
                            child: Container(
                              decoration: const BoxDecoration(),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 12.0, 0.0, 12.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Log out',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    'Haas Grot Text Trial',
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                        Icon(
                                          Icons.login_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 18.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 1.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ].divide(const SizedBox(height: 14.0)),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(0.0, 0.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Align(
                              alignment: const AlignmentDirectional(0.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Application version',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Haas Grot Text Trial',
                                          fontSize: 12.0,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  Text(
                                    'v1.2.4',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Haas Grot Text Trial',
                                          fontSize: 12.0,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ].divide(const SizedBox(width: 12.0)),
                              ),
                            ),
                          ].divide(const SizedBox(height: 24.0)),
                        ),
                      ),
                    ].divide(const SizedBox(height: 24.0)),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 1.0),
                child: Stack(
                  alignment: const AlignmentDirectional(0.0, 1.0),
                  children: [
                    if (FFAppState().currentUserRole == UserRole.bride)
                      Align(
                        alignment: const AlignmentDirectional(0.0, 1.0),
                        child: wrapWithModel(
                          model: _model.navBarBridesModel,
                          updateCallback: () => safeSetState(() {}),
                          child: const NavBarBridesWidget(
                            number: 5,
                          ),
                        ),
                      ),
                    if (FFAppState().currentUserRole == UserRole.professional)
                      wrapWithModel(
                        model: _model.navBarProModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const NavBarProWidget(
                          number: 5,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
