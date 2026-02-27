// YouTube Player with Controls
// Used for replay player page where user needs to control playback
// 
// Note: This player is designed to work within the app's SafeArea.
// Fullscreen is handled by the parent page, not by YouTube's native fullscreen.
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerWithControls extends StatefulWidget {
  const YoutubePlayerWithControls({
    super.key,
    this.width,
    this.height,
    required this.youtubeUrl,
  });

  final double? width;
  final double? height;
  final String youtubeUrl;

  @override
  State<YoutubePlayerWithControls> createState() => _YoutubePlayerWithControlsState();
}

class _YoutubePlayerWithControlsState extends State<YoutubePlayerWithControls> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    final videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl);

    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        forceHD: true,
        showLiveFullscreenButton: false, // Disable native fullscreen button
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.black,
      child: Center(
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.white,
          progressColors: const ProgressBarColors(
            playedColor: Colors.white,
            handleColor: Colors.white,
            bufferedColor: Colors.white24,
            backgroundColor: Colors.white12,
          ),
          bottomActions: const [
            SizedBox(width: 14),
            CurrentPosition(),
            SizedBox(width: 8),
            ProgressBar(
              isExpanded: true,
              colors: ProgressBarColors(
                playedColor: Colors.white,
                handleColor: Colors.white,
                bufferedColor: Colors.white24,
                backgroundColor: Colors.white12,
              ),
            ),
            SizedBox(width: 8),
            RemainingDuration(),
            SizedBox(width: 14),
          ],
        ),
      ),
    );
  }
}
