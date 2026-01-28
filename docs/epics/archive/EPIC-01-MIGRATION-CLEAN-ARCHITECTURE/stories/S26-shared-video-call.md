# Story S26: Shared - Video Call Page

## Description

En tant que developpeur, je veux migrer la page Video Call vers Clean Architecture afin d'avoir une integration Agora propre et testable.

## Criteres d'Acceptance (Gherkin)

- [ ] Given `VideoCallPageWidget` When je la migre Then elle utilise un module video dedie

- [ ] Given un appel video When je le demarre Then la connexion Agora est etablie

- [ ] Given les controles video When je les utilise Then mute/camera switch fonctionnent

- [ ] Given la fin d'appel When je raccroche Then la session est terminee proprement

## Fichiers Concernes

### Pages Legacy a Migrer
- `lib/pages/shared/video_call_page/video_call_page_widget.dart`
- `lib/pages/shared/video_call_page/video_call_page_model.dart`

### Actions Custom Code a Integrer
- `lib/custom_code/actions/get_agora_token_action.dart`
- `lib/custom_code/actions/agora_toggle_camera.dart`
- `lib/custom_code/actions/agora_toggle_mute.dart`
- `lib/custom_code/actions/agora_switch_camera.dart`
- `lib/custom_code/actions/agora_end_call.dart`
- `lib/custom_code/actions/start_video_session_action.dart`
- `lib/custom_code/actions/update_video_session_status_action.dart`
- `lib/custom_code/actions/handle_video_session_timeout.dart`

### Widgets Custom Code
- `lib/custom_code/widgets/agora_video_view.dart`

### A Creer
- `lib/features/video_call/video_call.dart` - Barrel
- `lib/features/video_call/domain/entities/video_session.dart`
- `lib/features/video_call/domain/repositories/video_call_repository.dart`
- `lib/features/video_call/data/repositories/video_call_repository_impl.dart`
- `lib/features/video_call/presentation/pages/video_call_page.dart`
- `lib/features/video_call/presentation/bloc/video_call_cubit.dart`
- `lib/features/video_call/presentation/widgets/video_controls.dart`

## Notes Techniques

### Video Session Entity
```dart
class VideoSession {
  final String id;
  final String channelName;
  final String token;
  final int uid;
  final String callerProfileId;
  final String receiverProfileId;
  final VideoSessionStatus status;
  final DateTime createdAt;
  final DateTime? endedAt;

  const VideoSession({
    required this.id,
    required this.channelName,
    required this.token,
    required this.uid,
    required this.callerProfileId,
    required this.receiverProfileId,
    required this.status,
    required this.createdAt,
    this.endedAt,
  });
}

enum VideoSessionStatus {
  pending,
  ringing,
  connected,
  ended,
  missed,
  declined,
}
```

### Video Call Cubit
```dart
class VideoCallCubit extends Cubit<VideoCallState> {
  final VideoCallRepository _repository;
  RtcEngine? _engine;

  VideoCallCubit({required VideoCallRepository repository})
      : _repository = repository,
        super(const VideoCallState.initial());

  Future<void> startCall({
    required String receiverProfileId,
    required String roomId,
  }) async {
    emit(state.copyWith(status: CallStatus.connecting));

    try {
      // Get Agora token
      final session = await _repository.createSession(
        receiverProfileId: receiverProfileId,
        roomId: roomId,
      );

      // Initialize Agora
      await _initializeAgora(session);

      emit(state.copyWith(
        status: CallStatus.ringing,
        session: session,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CallStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _initializeAgora(VideoSession session) async {
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(const RtcEngineContext(
      appId: 'YOUR_AGORA_APP_ID',
    ));

    _engine!.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        emit(state.copyWith(status: CallStatus.connected));
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        emit(state.copyWith(remoteUid: remoteUid));
      },
      onUserOffline: (connection, remoteUid, reason) {
        emit(state.copyWith(remoteUid: null));
        endCall();
      },
    ));

    await _engine!.enableVideo();
    await _engine!.startPreview();
    await _engine!.joinChannel(
      token: session.token,
      channelId: session.channelName,
      uid: session.uid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
  }

  void toggleMute() {
    final newMuted = !state.isMuted;
    _engine?.muteLocalAudioStream(newMuted);
    emit(state.copyWith(isMuted: newMuted));
  }

  void toggleCamera() {
    final newEnabled = !state.isCameraOn;
    _engine?.enableLocalVideo(newEnabled);
    emit(state.copyWith(isCameraOn: newEnabled));
  }

  void switchCamera() {
    _engine?.switchCamera();
  }

  Future<void> endCall() async {
    await _engine?.leaveChannel();
    await _engine?.release();
    _engine = null;

    if (state.session != null) {
      await _repository.endSession(state.session!.id);
    }

    emit(state.copyWith(status: CallStatus.ended));
  }

  @override
  Future<void> close() async {
    await endCall();
    return super.close();
  }
}

class VideoCallState {
  final CallStatus status;
  final VideoSession? session;
  final int? remoteUid;
  final bool isMuted;
  final bool isCameraOn;
  final String? error;

  const VideoCallState({
    this.status = CallStatus.initial,
    this.session,
    this.remoteUid,
    this.isMuted = false,
    this.isCameraOn = true,
    this.error,
  });

  const VideoCallState.initial() : this();

  VideoCallState copyWith({...});
}

enum CallStatus {
  initial,
  connecting,
  ringing,
  connected,
  ended,
  error,
}
```

### Video Call Page
```dart
class VideoCallPage extends StatelessWidget {
  final String receiverProfileId;
  final String roomId;

  const VideoCallPage({
    required this.receiverProfileId,
    required this.roomId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VideoCallCubit(
        repository: getIt<VideoCallRepository>(),
      )..startCall(
        receiverProfileId: receiverProfileId,
        roomId: roomId,
      ),
      child: const _VideoCallView(),
    );
  }
}

class _VideoCallView extends StatelessWidget {
  const _VideoCallView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VideoCallCubit, VideoCallState>(
      listener: (context, state) {
        if (state.status == CallStatus.ended) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Remote video (full screen)
              if (state.remoteUid != null)
                AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: context.read<VideoCallCubit>()._engine!,
                    canvas: VideoCanvas(uid: state.remoteUid),
                    connection: const RtcConnection(channelId: ''),
                  ),
                )
              else
                const Center(
                  child: Text(
                    'Waiting for other participant...',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              // Local video (picture-in-picture)
              Positioned(
                top: 50,
                right: 16,
                width: 120,
                height: 160,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: context.read<VideoCallCubit>()._engine!,
                      canvas: const VideoCanvas(uid: 0),
                    ),
                  ),
                ),
              ),
              // Controls
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: VideoControls(
                  isMuted: state.isMuted,
                  isCameraOn: state.isCameraOn,
                  onToggleMute: () => context.read<VideoCallCubit>().toggleMute(),
                  onToggleCamera: () => context.read<VideoCallCubit>().toggleCamera(),
                  onSwitchCamera: () => context.read<VideoCallCubit>().switchCamera(),
                  onEndCall: () => context.read<VideoCallCubit>().endCall(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

## Definition of Done

- [ ] Module video_call cree
- [ ] VideoCallCubit implemente
- [ ] Integration Agora
- [ ] Controls (mute, camera, end)
- [ ] Session management
- [ ] Tests
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 8
**Complexite** : Elevee
**Risque** : Eleve (integration tiers)

## Dependances

- S03 : Design system
- S04 : Navigation

## Stories Dependantes

- S40 : Custom Code - Video/Media actions
