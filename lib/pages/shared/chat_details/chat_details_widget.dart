import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/conversation_sheet/my_message_actions_sheet/my_message_actions_sheet_widget.dart';
import '/conversation_sheet/other_message_actions_sheet/other_message_actions_sheet_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'chat_details_model.dart';
export 'chat_details_model.dart';

class ChatDetailsWidget extends StatefulWidget {
  const ChatDetailsWidget({
    super.key,
    this.roomId,
    bool? isPublic,
    this.requestId,
    this.otherProfileId,
    bool? isRoomEmpty,
    bool? firstMessageTextOnly,
    bool? viewerIsReviewer,
  })  : isPublic = isPublic ?? false,
        isRoomEmpty = isRoomEmpty ?? false,
        firstMessageTextOnly = firstMessageTextOnly ?? false,
        viewerIsReviewer = viewerIsReviewer ?? false;

  final String? roomId;
  final bool isPublic;
  final String? requestId;
  final String? otherProfileId;
  final bool isRoomEmpty;
  final bool firstMessageTextOnly;
  final bool viewerIsReviewer;

  static String routeName = 'ChatDetails';
  static String routePath = '/chatDetails';

  @override
  State<ChatDetailsWidget> createState() => _ChatDetailsWidgetState();
}

class _ChatDetailsWidgetState extends State<ChatDetailsWidget> {
  late ChatDetailsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatDetailsModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _model.validateParameters = await actions.validateChatDetailsParams(
        context,
        widget.roomId,
        FFAppState().currentUserRole,
      );
      if (!mounted) return;
      if (_model.validateParameters == true) {
        _model.psRoomId = widget.roomId;
        _model.psIsPublic = valueOrDefault<bool>(
          widget.isPublic,
          false,
        );
        _model.psRequestId = widget.requestId;
        _model.psOtherProfileId = widget.otherProfileId;
        _model.psReviewMode = valueOrDefault<bool>(
          widget.viewerIsReviewer,
          false,
        );
        _model.psIsRoomEmpty = valueOrDefault<bool>(
          widget.isRoomEmpty,
          false,
        );
        _model.psFirstMessageTextOnly = valueOrDefault<bool>(
          widget.firstMessageTextOnly,
          false,
        );
        if (mounted) {
          safeSetState(() {});
        }
        if (_model.psIsPublic == true) {
          _model.joinSuccess = await actions.joinPublicRoomIfNeededAction(
            _model.psRoomId!,
          );
          if (!mounted) return;
          _model.publicRoomHeader = await actions.getRoomHeaderAction(
            _model.psRoomId!,
          );
          if (!mounted) return;
          _model.psRoomHeader = _model.publicRoomHeader;
          await ChatRoomParticipantsTable().update(
            data: {
              'last_read_at': supaSerialize<DateTime>(getCurrentTimestamp),
            },
            matchingRows: (rows) => rows
                .eqOrNull(
                  'room_id',
                  _model.psRoomId,
                )
                .eqOrNull(
                  'profile_id',
                  currentUserUid,
                ),
          );
          if (mounted) {
            safeSetState(() {});
          }
        } else {
          _model.roomHeaderResult = await actions.getRoomHeaderAction(
            _model.psRoomId!,
          );
          if (!mounted) return;
          _model.psRoomHeader = _model.roomHeaderResult;
          await ChatRoomParticipantsTable().update(
            data: {
              'last_read_at': supaSerialize<DateTime>(getCurrentTimestamp),
            },
            matchingRows: (rows) => rows
                .eqOrNull(
                  'room_id',
                  _model.psRoomId,
                )
                .eqOrNull(
                  'profile_id',
                  currentUserUid,
                ),
          );
          if (mounted) {
            safeSetState(() {});
          }
        }
      }
    });
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
        body: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: const AlignmentDirectional(0.0, -1.0),
                  child: Container(
                    width: double.infinity,
                    height: 110.0,
                    decoration: BoxDecoration(
                      color: _model.psIsPublic == false
                          ? FlutterFlowTheme.of(context).primaryBackground
                          : const Color(0xFF040404),
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Stack(
                            children: [
                              if (_model.psIsPublic == false)
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      20.0, 0.0, 20.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          context.safePop();
                                        },
                                        child: Icon(
                                          Icons.arrow_back_ios_new,
                                          color: widget.isPublic == false
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : Colors.white,
                                          size: 24.0,
                                        ),
                                      ),
                                      Flexible(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100.0),
                                              child: Image.network(
                                                valueOrDefault<String>(
                                                  _model.psRoomHeader
                                                      ?.otherAvatarUrl,
                                                  'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/lynewed-alpha-du4al1/assets/egport4rt4rg/person_15429777_1.png',
                                                ),
                                                width: 40.0,
                                                height: 40.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  valueOrDefault<String>(
                                                    _model.psRoomHeader
                                                        ?.otherFullName,
                                                    'Name...',
                                                  ),
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                'Haas Grot Text Trial',
                                                            color: widget
                                                                        .isPublic ==
                                                                    false
                                                                ? FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary
                                                                : Colors.white,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                ),
                                                Text(
                                                  valueOrDefault<String>(
                                                    _model.psRoomHeader
                                                        ?.otherRole?.name,
                                                    'profesionnal',
                                                  ),
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                'Haas Grot Text Trial',
                                                            color: widget
                                                                        .isPublic ==
                                                                    false
                                                                ? FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText
                                                                : FlutterFlowTheme.of(
                                                                        context)
                                                                    .tertiary,
                                                            letterSpacing: 0.0,
                                                          ),
                                                ),
                                              ].divide(const SizedBox(height: 1.0)),
                                            ),
                                          ].divide(const SizedBox(width: 14.0)),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          if (_model.psIsPublic == false)
                                            Align(
                                              alignment: const AlignmentDirectional(
                                                  1.0, 0.0),
                                              child: Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        4.0, 0.0, 4.0, 0.0),
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    // Étape 1: Vérifier les permissions Camera et Microphone
                                                    _model.cameraPermissionResult =
                                                        await actions
                                                            .checkAndRequestPermission(
                                                      PermissionType.CAMERA,
                                                    );
                                                    _model.micPermissionResult =
                                                        await actions
                                                            .checkAndRequestPermission(
                                                      PermissionType.MICROPHONE,
                                                    );

                                                    // Si les permissions ne sont pas accordées, arrêter
                                                    if (_model
                                                                .cameraPermissionResult !=
                                                            'granted' ||
                                                        _model.micPermissionResult !=
                                                            'granted') {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: const Text(
                                                            'Les permissions caméra et microphone sont nécessaires pour passer un appel vidéo.',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          duration: const Duration(
                                                              milliseconds:
                                                                  4000),
                                                          backgroundColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .error,
                                                        ),
                                                      );
                                                      safeSetState(() {});
                                                      return;
                                                    }

                                                    // Étape 2: Créer la session vidéo
                                                    _model.createdVideoSession =
                                                        await actions
                                                            .startVideoSessionAction(
                                                      _model.psRoomHeader!
                                                          .otherProfileId,
                                                    );

                                                    // Étape 3: Vérifier que la session a été créée
                                                    if (_model
                                                            .createdVideoSession ==
                                                        null) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: const Text(
                                                            'Impossible de créer la session vidéo. Vérifiez votre connexion.',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          duration: const Duration(
                                                              milliseconds:
                                                                  4000),
                                                          backgroundColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .error,
                                                        ),
                                                      );
                                                      safeSetState(() {});
                                                      return;
                                                    }

                                                    // Étape 4: Valider les données de la session
                                                    if (_model.createdVideoSession!
                                                            .id.isEmpty ||
                                                        _model
                                                            .createdVideoSession!
                                                            .agoraChannelName
                                                            .isEmpty) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: const Text(
                                                            'Session vidéo invalide. Veuillez réessayer.',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          duration: const Duration(
                                                              milliseconds:
                                                                  4000),
                                                          backgroundColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .error,
                                                        ),
                                                      );
                                                      safeSetState(() {});
                                                      return;
                                                    }

                                                    // Étape 5: Obtenir le token Agora
                                                    _model.agoraToken =
                                                        await actions
                                                            .getAgoraTokenAction(
                                                      _model
                                                          .createdVideoSession!
                                                          .agoraChannelName,
                                                      currentUserUid, // Passer le UUID directement
                                                    );

                                                    // Étape 6: Vérifier le token
                                                    if (_model.agoraToken ==
                                                            null ||
                                                        _model.agoraToken ==
                                                            '') {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: const Text(
                                                            'Impossible d\'obtenir le token Agora. Veuillez réessayer.',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          duration: const Duration(
                                                              milliseconds:
                                                                  4000),
                                                          backgroundColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .error,
                                                        ),
                                                      );
                                                      safeSetState(() {});
                                                      return;
                                                    }

                                                    // Étape 7: Tout est OK, naviguer vers la page d'appel
                                                    context.goNamed(
                                                      VideoCallPageWidget
                                                          .routeName,
                                                      queryParameters: {
                                                        'videoSessionId':
                                                            serializeParam(
                                                          _model
                                                              .createdVideoSession!
                                                              .id,
                                                          ParamType.String,
                                                        ),
                                                        'channelName':
                                                            serializeParam(
                                                          _model
                                                              .createdVideoSession!
                                                              .agoraChannelName,
                                                          ParamType.String,
                                                        ),
                                                        'agoraToken':
                                                            serializeParam(
                                                          _model.agoraToken,
                                                          ParamType.String,
                                                        ),
                                                        'isInitiator':
                                                            serializeParam(
                                                          true,
                                                          ParamType.bool,
                                                        ),
                                                      }.withoutNulls,
                                                    );

                                                    safeSetState(() {});
                                                  },
                                                  child: Icon(
                                                    Icons.videocam,
                                                    color: widget.isPublic ==
                                                            false
                                                        ? FlutterFlowTheme.of(
                                                                context)
                                                            .primary
                                                        : Colors.white,
                                                    size: 24.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ].divide(const SizedBox(width: 4.0)),
                                      ),
                                    ].divide(const SizedBox(width: 14.0)),
                                  ),
                                ),
                              if (_model.psIsPublic == true)
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      20.0, 0.0, 20.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          context.safePop();
                                        },
                                        child: const Icon(
                                          Icons.arrow_back_ios_new,
                                          color: Colors.white,
                                          size: 24.0,
                                        ),
                                      ),
                                      Flexible(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100.0),
                                              child: Image.network(
                                                valueOrDefault<String>(
                                                  _model.psRoomHeader
                                                      ?.publicCoverUrl,
                                                  'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/lynewed-alpha-du4al1/assets/egport4rt4rg/person_15429777_1.png',
                                                ),
                                                width: 40.0,
                                                height: 40.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  valueOrDefault<String>(
                                                    _model.psRoomHeader
                                                        ?.publicTitle,
                                                    'Room...',
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            'Haas Grot Text Trial',
                                                        color: Colors.white,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                ),
                                                Text(
                                                  'Public',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            'Haas Grot Text Trial',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .alternate,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                              ].divide(const SizedBox(height: 1.0)),
                                            ),
                                          ].divide(const SizedBox(width: 14.0)),
                                        ),
                                      ),
                                    ].divide(const SizedBox(width: 14.0)),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 100.0),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 1.0,
                      height: MediaQuery.sizeOf(context).height * 1.0,
                      decoration: const BoxDecoration(),
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: MediaQuery.sizeOf(context).height * 1.0,
                        child: custom_widgets.ChatMessageList(
                          width: MediaQuery.sizeOf(context).width * 1.0,
                          height: MediaQuery.sizeOf(context).height * 1.0,
                          roomId: _model.psRoomId!,
                          currentUserId: currentUserUid,
                          isPublic: _model.psIsPublic,
                          pageSize: 20,
                          otherAvatarUrl: functions.imagePathToString(
                              _model.psRoomHeader?.otherAvatarUrl),
                          otherFullName: _model.psRoomHeader?.otherFullName,
                          pendingRequestId: _model.psRequestId,
                          isReviewer: _model.psReviewMode,
                          onMessageLongPress: (data) async {
                            if (data.isMine == true) {
                              await showModalBottomSheet(
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                enableDrag: false,
                                context: context,
                                builder: (context) {
                                  return GestureDetector(
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                    child: Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: MyMessageActionsSheetWidget(
                                        messageLongPressData: data,
                                        onActionCompleted: () async {
                                          safeSetState(() {});
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ).then((value) => safeSetState(() {}));
                            } else {
                              await showModalBottomSheet(
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                enableDrag: false,
                                context: context,
                                builder: (context) {
                                  return GestureDetector(
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                    child: Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: OtherMessageActionsSheetWidget(
                                        messageLongPressData: data,
                                        onActionCompleted: () async {
                                          safeSetState(() {});
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ).then((value) => safeSetState(() {}));
                            }
                          },
                          onNewMessageArrived: () async {
                            await ChatRoomParticipantsTable().update(
                              data: {
                                'last_read_at': supaSerialize<DateTime>(
                                    getCurrentTimestamp),
                              },
                              matchingRows: (rows) => rows
                                  .eqOrNull(
                                    'room_id',
                                    _model.psRoomId,
                                  )
                                  .eqOrNull(
                                    'profile_id',
                                    currentUserUid,
                                  ),
                            );

                            safeSetState(() {});
                          },
                          onTopReached: () async {},
                          onRequestAccepted: (newRoomId) async {
                            _model.psRoomId = newRoomId;
                            _model.psReviewMode = false;
                            _model.psRequestId = null;
                            safeSetState(() {});
                            _model.acceptedRoomHeader =
                                await actions.getRoomHeaderAction(
                              _model.psRoomId!,
                            );
                            safeSetState(() {});

                            safeSetState(() {});
                          },
                          onRequestDeclined: () async {
                            context.safePop();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: const AlignmentDirectional(0.0, 1.0),
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width * 1.0,
                height: 280.0,
                child: custom_widgets.ChatComposerWidget(
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  height: 280.0,
                  isPublic: _model.psIsPublic,
                  pendingRequestId: _model.psRequestId,
                  roomId: _model.psRoomId,
                  targetProfileId: _model.psOtherProfileId,
                  viewerRole: FFAppState().currentUserRole,
                  isRoomEmpty: _model.psIsRoomEmpty,
                  firstMessageTextOnly: _model.psFirstMessageTextOnly,
                  onRoomCreated: (newRoomId, newRequestId) async {
                    _model.psRoomId = newRoomId;
                    _model.psRequestId = newRoomId;
                    safeSetState(() {});
                    safeSetState(() {});
                  },
                  onError: (message) async {
                    await showDialog(
                      context: context,
                      builder: (alertDialogContext) {
                        return AlertDialog(
                          title: const Text('Error...'),
                          content: const Text(
                              'An error has occurred. Please try again by refreshing the page or contacting support. '),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(alertDialogContext),
                              child: const Text('Ok'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
