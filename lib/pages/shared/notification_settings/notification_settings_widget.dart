import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/components/nav/header_bar/header_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'notification_settings_model.dart';
export 'notification_settings_model.dart';

class NotificationSettingsWidget extends StatefulWidget {
  const NotificationSettingsWidget({super.key});

  static String routeName = 'NotificationSettings';
  static String routePath = '/notificationSettings';

  @override
  State<NotificationSettingsWidget> createState() =>
      _NotificationSettingsWidgetState();
}

class _NotificationSettingsWidgetState
    extends State<NotificationSettingsWidget> {
  late NotificationSettingsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NotificationSettingsModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.userNotificationsSettings =
          await NotificationSettingsTable().queryRows(
        queryFn: (q) => q.eqOrNull(
          'profile_id',
          currentUserUid,
        ),
      );
      await Future.wait([
        Future(() async {
          _model.chatMessageBool = _model.userNotificationsSettings
                      ?.where((e) => e.notificationType == 'chatMessage')
                      .toList()
                      .firstOrNull
                      ?.inAppEnabled ==
                  true
              ? true
              : false;
          safeSetState(() {});
          safeSetState(() {
            _model.switchMsgValue = _model.chatMessageBool;
          });
        }),
        Future(() async {
          _model.connectionRequestBool = _model.userNotificationsSettings
                      ?.where((e) => e.notificationType == 'connectionRequest')
                      .toList()
                      .firstOrNull
                      ?.inAppEnabled ==
                  true
              ? true
              : false;
          safeSetState(() {});
          safeSetState(() {
            _model.switchContactRequestValue = _model.connectionRequestBool;
          });
        }),
        Future(() async {
          _model.wishlistAddBool = _model.userNotificationsSettings
                      ?.where((e) => e.notificationType == 'wishlistAdd')
                      .toList()
                      .firstOrNull
                      ?.inAppEnabled ==
                  true
              ? true
              : false;
          safeSetState(() {});
          safeSetState(() {
            _model.switchWishlistValue = _model.wishlistAddBool;
          });
        }),
        Future(() async {
          _model.professionalAlertReminder24hBool = _model
                      .userNotificationsSettings
                      ?.where((e) =>
                          e.notificationType == 'professionalAlertReminder24h')
                      .toList()
                      .firstOrNull
                      ?.inAppEnabled ==
                  true
              ? true
              : false;
          safeSetState(() {});
          safeSetState(() {
            _model.switchAlertExpirationValue =
                _model.professionalAlertReminder24hBool;
          });
        }),
      ]);
    });

    _model.switchMsgValue = _model.chatMessageBool;
    _model.switchContactRequestValue = _model.connectionRequestBool;
    _model.switchWishlistValue = _model.wishlistAddBool;
    _model.switchAlertExpirationValue = _model.professionalAlertReminder24hBool;
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
        body: Align(
          alignment: const AlignmentDirectional(0.0, -1.0),
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width * 1.0,
            height: MediaQuery.sizeOf(context).height * 1.0,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 130.0, 0.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (FFAppState().currentUserRole == UserRole.bride)
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 0.0, 20.0, 0.0),
                          child: Container(
                            decoration: const BoxDecoration(),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Private messages',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      'Haas Grot Text Trial',
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          Text(
                                            'Receive an alert for each new message in a private conversation.',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      'Haas Grot Text Trial',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ].divide(const SizedBox(height: 10.0)),
                                      ),
                                    ),
                                    Switch.adaptive(
                                      value: _model.switchMsgValue!,
                                      onChanged: (newValue) async {
                                        safeSetState(() =>
                                            _model.switchMsgValue = newValue);
                                        if (newValue) {
                                          _model.chatMessageOn = await actions
                                              .upsertNotificationSetting(
                                            'chatMessage',
                                            true,
                                            true,
                                          );

                                          safeSetState(() {});
                                        } else {
                                          _model.chatMessageOff = await actions
                                              .upsertNotificationSetting(
                                            'chatMessage',
                                            false,
                                            false,
                                          );

                                          safeSetState(() {});
                                        }
                                      },
                                      activeColor:
                                          FlutterFlowTheme.of(context).primary,
                                      activeTrackColor:
                                          FlutterFlowTheme.of(context).primary,
                                      inactiveTrackColor:
                                          FlutterFlowTheme.of(context)
                                              .alternate,
                                      inactiveThumbColor:
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                    ),
                                  ].divide(const SizedBox(width: 14.0)),
                                ),
                                Divider(
                                  thickness: 1.0,
                                  color: FlutterFlowTheme.of(context).secondary,
                                ),
                              ].divide(const SizedBox(height: 14.0)),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20.0, 14.0, 20.0, 14.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Contact requests',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Haas Grot Text Trial',
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  Text(
                                    FFAppState().currentUserRole ==
                                            UserRole.bride
                                        ? 'Receive notifications when a professional sends you a request, and when you accept or decline a request.'
                                        : 'Get notified when a Bride accepts or declines your request, or when another Pro contacts you.',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Haas Grot Text Trial',
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          fontSize: 12.0,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ].divide(const SizedBox(height: 10.0)),
                              ),
                            ),
                            Switch.adaptive(
                              value: _model.switchContactRequestValue!,
                              onChanged: (newValue) async {
                                safeSetState(() => _model
                                    .switchContactRequestValue = newValue);
                                if (newValue) {
                                  _model.connectionRequestOn = await actions
                                      .upsertNotificationSettingsBatch(
                                    ([
                                      'connectionRequest',
                                      'connectionRequestAccepted',
                                      'connectionRequestDeclined'
                                    ]).toList(),
                                    true,
                                    true,
                                  );

                                  safeSetState(() {});
                                } else {
                                  _model.connectionRequestOff = await actions
                                      .upsertNotificationSettingsBatch(
                                    ([
                                      'connectionRequest',
                                      'connectionRequestAccepted',
                                      'connectionRequestDeclined'
                                    ]).toList(),
                                    false,
                                    false,
                                  );

                                  safeSetState(() {});
                                }
                              },
                              activeColor: FlutterFlowTheme.of(context).primary,
                              activeTrackColor:
                                  FlutterFlowTheme.of(context).primary,
                              inactiveTrackColor:
                                  FlutterFlowTheme.of(context).alternate,
                              inactiveThumbColor: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                            ),
                          ].divide(const SizedBox(width: 14.0)),
                        ),
                      ),
                      if (FFAppState().currentUserRole == UserRole.professional)
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 0.0, 20.0, 0.0),
                          child: Container(
                            decoration: const BoxDecoration(),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (FFAppState()
                                        .selfProSubscription
                                        .subscriptionTier ==
                                    SubscriptionTierType.ultimateAccess)
                                  Divider(
                                    thickness: 1.0,
                                    color:
                                        FlutterFlowTheme.of(context).secondary,
                                  ),
                                if (FFAppState()
                                        .selfProSubscription
                                        .subscriptionTier ==
                                    SubscriptionTierType.ultimateAccess)
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Add to wishlist',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            'Haas Grot Text Trial',
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                            ),
                                            Text(
                                              'Receive a personalized notification when a Bride adds you to her wishlist.',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            'Haas Grot Text Trial',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
                                                        fontSize: 12.0,
                                                        letterSpacing: 0.0,
                                                      ),
                                            ),
                                          ].divide(const SizedBox(height: 10.0)),
                                        ),
                                      ),
                                      Switch.adaptive(
                                        value: _model.switchWishlistValue!,
                                        onChanged: (newValue) async {
                                          safeSetState(() => _model
                                              .switchWishlistValue = newValue);
                                          if (newValue) {
                                            _model.wishlistAddOn = await actions
                                                .upsertNotificationSetting(
                                              'wishlistAdd',
                                              true,
                                              true,
                                            );

                                            safeSetState(() {});
                                          } else {
                                            _model.wishlistAddOff =
                                                await actions
                                                    .upsertNotificationSetting(
                                              'wishlistAdd',
                                              false,
                                              false,
                                            );

                                            safeSetState(() {});
                                          }
                                        },
                                        activeColor:
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                        activeTrackColor:
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                        inactiveTrackColor:
                                            FlutterFlowTheme.of(context)
                                                .alternate,
                                        inactiveThumbColor:
                                            FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                      ),
                                    ].divide(const SizedBox(width: 14.0)),
                                  ),
                                Divider(
                                  thickness: 1.0,
                                  color: FlutterFlowTheme.of(context).secondary,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Alert expiration reminder',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      'Haas Grot Text Trial',
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          Text(
                                            'Receive a reminder 24 hours before one of your active alerts expires.',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      'Haas Grot Text Trial',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ].divide(const SizedBox(height: 10.0)),
                                      ),
                                    ),
                                    Switch.adaptive(
                                      value: _model.switchAlertExpirationValue!,
                                      onChanged: (newValue) async {
                                        safeSetState(() =>
                                            _model.switchAlertExpirationValue =
                                                newValue);
                                        if (newValue) {
                                          _model.professionalAlertReminder24hOn =
                                              await actions
                                                  .upsertNotificationSetting(
                                            'professionalAlertReminder24h',
                                            true,
                                            true,
                                          );

                                          safeSetState(() {});
                                        } else {
                                          _model.professionalAlertReminder24hOff =
                                              await actions
                                                  .upsertNotificationSetting(
                                            'professionalAlertReminder24h',
                                            false,
                                            false,
                                          );

                                          safeSetState(() {});
                                        }
                                      },
                                      activeColor:
                                          FlutterFlowTheme.of(context).primary,
                                      activeTrackColor:
                                          FlutterFlowTheme.of(context).primary,
                                      inactiveTrackColor:
                                          FlutterFlowTheme.of(context)
                                              .alternate,
                                      inactiveThumbColor:
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                    ),
                                  ].divide(const SizedBox(width: 14.0)),
                                ),
                              ].divide(const SizedBox(height: 14.0)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                wrapWithModel(
                  model: _model.headerBarModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const HeaderBarWidget(
                    title: 'NOTIFICATIONS',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
