import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'video_call_page_model.dart';
export 'video_call_page_model.dart';

class VideoCallPageWidget extends StatefulWidget {
  const VideoCallPageWidget({
    super.key,
    required this.videoSessionId,
    required this.channelName,
    required this.agoraToken,
    required this.isInitiator,
  });

  final String? videoSessionId;
  final String? channelName;
  final String? agoraToken;
  final bool? isInitiator;

  static String routeName = 'VideoCallPage';
  static String routePath = '/videoCallPage';

  @override
  State<VideoCallPageWidget> createState() => _VideoCallPageWidgetState();
}

class _VideoCallPageWidgetState extends State<VideoCallPageWidget> {
  late VideoCallPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Listener Realtime pour détecter quand l'autre raccroche
  RealtimeChannel? _sessionChannel;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VideoCallPageModel());
    _setupRealtimeListener();
  }
  
  void _setupRealtimeListener() {
    _sessionChannel = Supabase.instance.client.channel('video_session_${widget.videoSessionId}')
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'video_sessions',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id',
          value: widget.videoSessionId,
        ),
        callback: (payload) {
          final newStatus = payload.newRecord['status'] as String?;
          
          if (newStatus == 'completed' && mounted) {
            // Navigation vers la home page en fonction du rôle
            final userRole = FFAppState().currentUserRole;
            if (userRole == UserRole.professional) {
              context.goNamed('DashboardPro');
            } else {
              context.goNamed('HomeBrides');
            }
          }
        },
      )
      ..subscribe();
  }

  @override
  void dispose() {
    _sessionChannel?.unsubscribe();
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
        backgroundColor: FlutterFlowTheme.of(context).primaryText,
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: custom_widgets.AgoraVideoViewWidget(
                  width: double.infinity,
                  height: double.infinity,
                  appId: FFAppConstants.agoraAppId,
                  channelName: widget.channelName!,
                  token: widget.agoraToken!,
                  userId: currentUserUid,
                  onCallEnd: () async {
                    _model.updateVideoSessionStatusActionEndCall =
                        await actions.updateVideoSessionStatusAction(
                      widget.videoSessionId!,
                      VideoSessionStatus.completed,
                    );
                    
                    // Navigation vers la home page en fonction du rôle
                    final userRole = FFAppState().currentUserRole;
                    if (userRole == UserRole.professional) {
                      context.goNamed('DashboardPro');
                    } else {
                      context.goNamed('HomeBrides');
                    }

                    safeSetState(() {});
                  },
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 1.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            _model.isMuted = !_model.isMuted;
                            safeSetState(() {});
                            await actions.agoraToggleMute(
                              _model.isMuted,
                            );
                          },
                          child: Container(
                            width: 72.0,
                            height: 72.0,
                            decoration: BoxDecoration(
                              color: const Color(0xCC4B4B4B),
                              borderRadius: BorderRadius.circular(99.0),
                            ),
                            child: Stack(
                              children: [
                                if (_model.isMuted == true)
                                  const Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Icon(
                                      Icons.mic_off_rounded,
                                      color: Colors.white,
                                      size: 36.0,
                                    ),
                                  ),
                                if (_model.isMuted == false)
                                  const Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Icon(
                                      Icons.mic,
                                      color: Colors.white,
                                      size: 36.0,
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
                            _model.isCameraOff = !_model.isCameraOff;
                            safeSetState(() {});
                            await actions.agoraToggleCamera(
                              _model.isCameraOff,
                            );
                          },
                          child: Container(
                            width: 72.0,
                            height: 72.0,
                            decoration: BoxDecoration(
                              color: const Color(0xCC4B4B4B),
                              borderRadius: BorderRadius.circular(99.0),
                            ),
                            child: Stack(
                              children: [
                                if (_model.isCameraOff == true)
                                  const Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Icon(
                                      Icons.videocam_off,
                                      color: Colors.white,
                                      size: 36.0,
                                    ),
                                  ),
                                if (_model.isCameraOff == false)
                                  const Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Icon(
                                      Icons.videocam_sharp,
                                      color: Colors.white,
                                      size: 36.0,
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
                            await actions.agoraSwitchCamera();
                          },
                          child: Container(
                            width: 72.0,
                            height: 72.0,
                            decoration: BoxDecoration(
                              color: const Color(0xCC4B4B4B),
                              borderRadius: BorderRadius.circular(99.0),
                            ),
                            child: const Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Icon(
                                Icons.flip_camera_ios,
                                color: Colors.white,
                                size: 36.0,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            // 1. Naviguer vers home IMMÉDIATEMENT
                            if (mounted) {
                              final userRole = FFAppState().currentUserRole;
                              if (userRole == UserRole.professional) {
                                context.goNamed('DashboardPro');
                              } else {
                                context.goNamed('HomeBrides');
                              }
                            }
                            
                            // 2. Nettoyer Agora en arrière-plan (non bloquant)
                            actions.agoraEndCall().catchError((_) => false);
                            
                            // 3. Mettre à jour le status en arrière-plan (non bloquant)
                            actions.updateVideoSessionStatusAction(
                              widget.videoSessionId!,
                              VideoSessionStatus.completed,
                            ).catchError((_) => false);
                          },
                          child: Container(
                            width: 72.0,
                            height: 72.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).accent2,
                              borderRadius: BorderRadius.circular(99.0),
                            ),
                            child: const Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Icon(
                                Icons.call_end,
                                color: Colors.white,
                                size: 36.0,
                              ),
                            ),
                          ),
                        ),
                      ]
                          .addToStart(const SizedBox(width: 10.0))
                          .addToEnd(const SizedBox(width: 10.0)),
                    ),
                  ].addToEnd(const SizedBox(height: 60.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
