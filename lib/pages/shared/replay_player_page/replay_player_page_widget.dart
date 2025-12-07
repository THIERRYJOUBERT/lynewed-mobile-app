import '/flutter_flow/flutter_flow_util.dart';
import '/core/design/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'replay_player_page_model.dart';
export 'replay_player_page_model.dart';

/// Replay Player Page - Design System v3
/// 
/// Full-screen video player with controls for watching podcast replays.
/// - Portrait: Shows header with back button and title
/// - Landscape: Fullscreen video without header
class ReplayPlayerPageWidget extends StatefulWidget {
  const ReplayPlayerPageWidget({
    super.key,
    required this.videoUrl,
  });

  final String? videoUrl;

  static String routeName = 'ReplayPlayerPage';
  static String routePath = '/replayPlayerPage';

  @override
  State<ReplayPlayerPageWidget> createState() => _ReplayPlayerPageWidgetState();
}

class _ReplayPlayerPageWidgetState extends State<ReplayPlayerPageWidget> {
  late ReplayPlayerPageModel _model;
  YoutubePlayerController? _youtubeController;
  bool _isFullScreen = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReplayPlayerPageModel());
    _initYoutubePlayer();
  }

  void _initYoutubePlayer() {
    if (widget.videoUrl == null || widget.videoUrl!.isEmpty) return;
    
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl!);
    if (videoId == null) return;

    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        forceHD: true,
        loop: false,
        hideControls: false,
        controlsVisibleAtStart: true,
        disableDragSeek: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    // Restore portrait orientation when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _model.dispose();
    super.dispose();
  }

  void _onEnterFullScreen() {
    setState(() => _isFullScreen = true);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _onExitFullScreen() {
    setState(() => _isFullScreen = false);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    if (_youtubeController == null) {
      return Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const Divider(height: 1, color: LynewedColors.gray200),
              const Expanded(
                child: Center(
                  child: Text(
                    'No video available',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return YoutubePlayerBuilder(
      onEnterFullScreen: _onEnterFullScreen,
      onExitFullScreen: _onExitFullScreen,
      player: YoutubePlayer(
        controller: _youtubeController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.white,
        progressColors: const ProgressBarColors(
          playedColor: Colors.white,
          handleColor: Colors.white,
          bufferedColor: Colors.white24,
          backgroundColor: Colors.white12,
        ),
      ),
      builder: (context, player) {
        // In fullscreen (landscape), show only the player
        if (_isFullScreen) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: player,
          );
        }

        // In portrait, show header + player
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Column(
                children: [
                  // Header - Design System v3
                  _buildHeader(),
                  
                  // Divider
                  const Divider(height: 1, color: LynewedColors.gray200),
                  
                  // Video Player
                  Expanded(child: player),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Header with back button and title - Design System v3
  Widget _buildHeader() {
    return Container(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 20, 12),
        child: Row(
          children: [
            // Back button
            GestureDetector(
              onTap: () => context.safePop(),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: Icon(
                    Icons.chevron_left,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 4),
            
            // Title - same style as Replay page (18px, w500)
            Expanded(
              child: Text(
                'REPLAY',
                style: LynewedTextStyles.headlineSmall.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
