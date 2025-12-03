/// Audio player widget - Clean Architecture
/// 
/// Complete audio player with playback controls, speed adjustment, and timeline.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '/core/design/design.dart';

/// Audio player widget with full controls
class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    this.isOwnMessage = false,
    this.compact = false,
    this.autoPlay = false,
  });

  /// URL of the audio file to play
  final String audioUrl;

  /// Whether this is the current user's message (for styling)
  final bool isOwnMessage;

  /// Compact mode (for chat bar preview)
  final bool compact;

  /// Auto-play when loaded (for preview)
  final bool autoPlay;

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late final AudioPlayer _audioPlayer;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  bool _isInitialized = false;
  bool _hasError = false;
  double _playbackSpeed = 1.0;
  
  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupPlayerStateListener();
    _initializePlayer();
  }

  /// Listen for playback completion to auto-reset
  void _setupPlayerStateListener() {
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      // When audio completes, auto-reset to beginning
      if (state.processingState == ProcessingState.completed) {
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
      }
    });
  }

  Future<void> _initializePlayer() async {
    try {
      debugPrint('AudioPlayer: Initializing with URL: ${widget.audioUrl}');
      await _audioPlayer.setUrl(widget.audioUrl);
      debugPrint('AudioPlayer: Duration: ${_audioPlayer.duration}');
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        // Autoplay in compact mode (preview before sending)
        if (widget.compact && widget.autoPlay) {
          await _audioPlayer.play();
        }
      }
    } catch (e) {
      debugPrint('AudioPlayer: Error initializing: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant AudioPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If URL changed, reinitialize player
    if (oldWidget.audioUrl != widget.audioUrl) {
      debugPrint('AudioPlayer: URL changed, reinitializing');
      _hasError = false;
      _isInitialized = false;
      _initializePlayer();
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      // If at the end, restart from beginning
      if (_audioPlayer.position >= (_audioPlayer.duration ?? Duration.zero)) {
        await _audioPlayer.seek(Duration.zero);
      }
      await _audioPlayer.play();
    }
  }

  void _changeSpeed() {
    setState(() {
      if (_playbackSpeed == 1.0) {
        _playbackSpeed = 1.5;
      } else if (_playbackSpeed == 1.5) {
        _playbackSpeed = 2.0;
      } else if (_playbackSpeed == 2.0) {
        _playbackSpeed = 0.5;
      } else {
        _playbackSpeed = 1.0;
      }
      _audioPlayer.setSpeed(_playbackSpeed);
    });
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '0:00';
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Color get _primaryColor {
    return widget.isOwnMessage
        ? LynewedColors.textOnPrimary
        : LynewedColors.primary;
  }

  Color get _secondaryColor {
    return widget.isOwnMessage
        ? LynewedColors.textOnPrimary.withValues(alpha: 0.7)
        : LynewedColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorState();
    }

    if (!_isInitialized) {
      return _buildLoadingState();
    }

    if (widget.compact) {
      return _buildCompactPlayer();
    }

    return _buildFullPlayer();
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            size: 20,
            color: LynewedColors.error,
          ),
          const SizedBox(width: 8),
          Text(
            'Audio error',
            style: LynewedTextStyles.labelSmall.copyWith(
              color: LynewedColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Loading...',
            style: LynewedTextStyles.labelSmall.copyWith(
              color: _secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Compact player for chatbar - Design System v3
  Widget _buildCompactPlayer() {
    return StreamBuilder<PlayerState>(
      stream: _audioPlayer.playerStateStream,
      builder: (context, stateSnapshot) {
        final playerState = stateSnapshot.data;
        final isPlaying = playerState?.playing ?? false;

        return StreamBuilder<Duration?>(
          stream: _audioPlayer.positionStream,
          builder: (context, positionSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            final duration = _audioPlayer.duration ?? Duration.zero;
            final progress = duration.inMilliseconds > 0
                ? position.inMilliseconds / duration.inMilliseconds
                : 0.0;

            return Row(
              children: [
                // Play/Pause button - 36px circle, Design System compliant
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: LynewedColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 20,
                        color: LynewedColors.textOnPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Timeline slider - minimal design
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: LynewedColors.primary,
                      inactiveTrackColor: LynewedColors.gray300,
                      thumbColor: LynewedColors.primary,
                      overlayColor: LynewedColors.primary.withValues(alpha: 0.1),
                      trackHeight: 3.0,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 5,
                        elevation: 0,
                      ),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                    ),
                    child: Slider(
                      value: progress.clamp(0.0, 1.0),
                      onChanged: (value) {
                        _audioPlayer.seek(duration * value);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Duration display - compact format
                Text(
                  '${_formatDuration(position)}/${_formatDuration(duration)}',
                  style: LynewedTextStyles.labelSmall.copyWith(
                    color: LynewedColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Full player for chat messages - Compact horizontal layout (FlutterFlow style)
  Widget _buildFullPlayer() {
    return StreamBuilder<PlayerState>(
      stream: _audioPlayer.playerStateStream,
      builder: (context, stateSnapshot) {
        final playerState = stateSnapshot.data;
        final isPlaying = playerState?.playing ?? false;

        return StreamBuilder<Duration?>(
          stream: _audioPlayer.positionStream,
          builder: (context, positionSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            final duration = _audioPlayer.duration ?? Duration.zero;
            final progress = duration.inMilliseconds > 0
                ? position.inMilliseconds / duration.inMilliseconds
                : 0.0;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Play/Pause button
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: Icon(
                    isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    size: 28,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(width: 4),

                // Timeline + Duration column
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Slider
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: _primaryColor,
                          inactiveTrackColor: _primaryColor.withValues(alpha: 0.3),
                          thumbColor: _primaryColor,
                          overlayColor: _primaryColor.withValues(alpha: 0.2),
                          trackHeight: 2.0,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                        ),
                        child: Slider(
                          value: progress.clamp(0.0, 1.0),
                          onChanged: (value) {
                            final newPosition = Duration(
                              milliseconds: (value * duration.inMilliseconds).round(),
                            );
                            _audioPlayer.seek(newPosition);
                          },
                        ),
                      ),

                      // Time labels
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(position),
                              style: LynewedTextStyles.labelSmall.copyWith(
                                color: _secondaryColor,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: LynewedTextStyles.labelSmall.copyWith(
                                color: _secondaryColor,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Speed button
                GestureDetector(
                  onTap: _changeSpeed,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '${_playbackSpeed.toStringAsFixed(1)}x',
                      style: LynewedTextStyles.labelSmall.copyWith(
                        color: _primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
