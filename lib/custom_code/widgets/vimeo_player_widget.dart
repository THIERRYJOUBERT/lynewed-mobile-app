// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '/core/utils/video_url_helpers.dart';

/// Vimeo Player Widget using InAppWebView (more performant)
/// 
/// Displays Vimeo videos with autoplay, muted, looped, no controls
class VimeoPlayerWidget extends StatefulWidget {
  const VimeoPlayerWidget({
    super.key,
    this.width,
    this.height,
    required this.vimeoUrl,
  });

  final double? width;
  final double? height;
  final String vimeoUrl;

  @override
  State<VimeoPlayerWidget> createState() => _VimeoPlayerWidgetState();
}

class _VimeoPlayerWidgetState extends State<VimeoPlayerWidget> {
  bool _isLoading = true;
  String? _videoId;

  @override
  void initState() {
    super.initState();
    _videoId = VideoUrlHelpers.extractVimeoId(widget.vimeoUrl);
  }

  @override
  Widget build(BuildContext context) {
    if (_videoId == null || _videoId!.isEmpty) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.black,
        child: const Center(
          child: Icon(Icons.error_outline, color: Colors.white54, size: 48),
        ),
      );
    }

    // Direct embed URL - simplest and fastest approach
    final embedUrl = 'https://player.vimeo.com/video/$_videoId'
        '?autoplay=1&muted=1&loop=1&autopause=0&controls=0'
        '&title=0&byline=0&portrait=0&playsinline=1';

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          IgnorePointer(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(embedUrl)),
              initialSettings: InAppWebViewSettings(
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                javaScriptEnabled: true,
                transparentBackground: true,
                disableContextMenu: true,
                supportZoom: false,
                disableHorizontalScroll: true,
                disableVerticalScroll: true,
              ),
              onLoadStop: (controller, url) {
                if (mounted) setState(() => _isLoading = false);
              },
              onReceivedError: (controller, request, error) {
                if (mounted) setState(() => _isLoading = false);
              },
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }
}
