// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import '/utils/secure_logger.dart';
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
import 'package:just_audio/just_audio.dart';
import 'dart:async';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({
    super.key,
    this.width,
    this.height,
    required this.audioUrl,
    this.bubbleColor,
    this.textColor,
  });

  final double? width;
  final double? height;
  final String audioUrl;
  final Color? bubbleColor;
  final Color? textColor;

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late final AudioPlayer _player;
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _init();
  }

  Future<void> _init() async {
    try {
      final source = AudioSource.uri(
        Uri.parse(widget.audioUrl),
        headers: {'Accept': 'audio/*, application/octet-stream'},
      );
      await _player.setAudioSource(source);
      await _player.setSpeed(_speed);
    } catch (e) {
      SecureLogger.error('Audio player URL loading failed', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load audio.')),
        );
      }
    }
  }

  @override
  void didUpdateWidget(covariant AudioPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioUrl != widget.audioUrl) {
      _init();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration? d) {
    final duration = d ?? Duration.zero;
    final minutes = (duration.inSeconds ~/ 60).toString();
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final textColor = widget.textColor ?? theme.primaryText;

    return Container(
      width: widget.width,
      height: widget.height,
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 300),
      child: StreamBuilder<PlayerState>(
        stream: _player.playerStateStream,
        builder: (context, snapshot) {
          final state = snapshot.data;
          final playing = state?.playing ?? false;

          return Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 28,
                icon: Icon(
                  playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  color: textColor,
                ),
                onPressed: () async {
                  try {
                    if (playing) {
                      await _player.pause();
                    } else {
                      if (_player.processingState ==
                          ProcessingState.completed) {
                        await _player.seek(Duration.zero);
                      }
                      await _player.play();
                    }
                  } catch (e) {
                    SecureLogger.error('Audio player action failed', error: e);
                  }
                },
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    StreamBuilder<Duration>(
                      stream: _player.positionStream,
                      builder: (context, posSnap) {
                        final position = posSnap.data ?? Duration.zero;
                        final duration = _player.duration ?? Duration.zero;
                        final value = duration.inMilliseconds == 0
                            ? 0.0
                            : position.inMilliseconds / duration.inMilliseconds;
                        return SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6.0),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 12.0),
                            trackHeight: 2.0,
                          ),
                          child: Slider(
                            value: value.clamp(0.0, 1.0),
                            onChanged: (newValue) async {
                              final newPosition = Duration(
                                milliseconds:
                                    (newValue * duration.inMilliseconds)
                                        .round(),
                              );
                              await _player.seek(newPosition);
                            },
                            activeColor: textColor,
                            inactiveColor: textColor.withValues(alpha: 0.3),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StreamBuilder<Duration>(
                            stream: _player.positionStream,
                            builder: (context, snap) => Text(
                              _formatDuration(snap.data),
                              style:
                                  theme.labelSmall.copyWith(color: textColor),
                            ),
                          ),
                          Text(
                            _formatDuration(_player.duration),
                            style: theme.labelSmall.copyWith(color: textColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  final speeds = [1.0, 1.5, 2.0];
                  final currentIndex = speeds.indexOf(_speed);
                  final nextSpeed = speeds[(currentIndex + 1) % speeds.length];
                  setState(() => _speed = nextSpeed);
                  try {
                    await _player.setSpeed(nextSpeed);
                  } catch (_) {}
                },
                child: Text(
                  '${_speed.toStringAsFixed(1)}x',
                  style: theme.labelMedium.copyWith(color: textColor),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
