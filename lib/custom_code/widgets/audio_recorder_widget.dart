// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/widgets/index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'dart:async';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioRecorderWidget extends StatefulWidget {
  const AudioRecorderWidget({
    super.key,
    this.width,
    this.height,
    this.maxDurationSeconds,
    this.onAudioReady,
    this.onCancel,
  });

  final double? width;
  final double? height;
  final int? maxDurationSeconds;
  final Future<dynamic> Function(FFUploadedFile audioFile)? onAudioReady;
  final Future<dynamic> Function()? onCancel;

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

enum _RecState { recording, stopped }

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  late final AudioRecorder _rec;
  _RecState _state = _RecState.recording;
  int _elapsedMs = 0;
  Timer? _ticker;
  String? _filePath;
  FFUploadedFile? _audioFile;

  int get _maxSec =>
      (widget.maxDurationSeconds == null || widget.maxDurationSeconds! <= 0)
          ? 120
          : widget.maxDurationSeconds!;

  @override
  void initState() {
    super.initState();
    _rec = AudioRecorder();
    // Démarre automatiquement l'enregistrement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startRecord();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _rec.dispose();
    super.dispose();
  }

  Future<bool> _ensureMicPermission() async {
    try {
      return await _rec.hasPermission();
    } catch (_) {
      return false;
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _elapsedMs = 0;
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (t) async {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _elapsedMs += 100;
      });
      if (_elapsedMs >= _maxSec * 1000) {
        await _stopRecord();
      }
    });
  }

  Future<void> _startRecord() async {
    final ok = await _ensureMicPermission();
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Permission microphone requise / Microphone permission required')),
        );
        if (widget.onCancel != null) await widget.onCancel!();
      }
      return;
    }

    try {
      final dir = await getTemporaryDirectory();
      final file =
          '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 64000,
        sampleRate: 44100,
      );
      await _rec.start(config, path: file);
      _filePath = file;
      _startTicker();
    } catch (e) {
      debugPrint('AudioRecorderWidget start error: $e');
      if (mounted && widget.onCancel != null) await widget.onCancel!();
    }
  }

  Future<void> _stopRecord() async {
    if (_state == _RecState.stopped) return; // Évite double-clic

    try {
      final path = await _rec.stop();
      _ticker?.cancel();

      if (path != null && File(path).existsSync()) {
        final bytes = await File(path).readAsBytes();
        _audioFile = FFUploadedFile(
          name: path.split('/').last,
          bytes: bytes,
        );

        setState(() {
          _state = _RecState.stopped;
        });

        // Notifie la page que l'audio est prêt
        if (widget.onAudioReady != null && _audioFile != null) {
          await widget.onAudioReady!(_audioFile!);
        }
      } else {
        // Échec
        if (widget.onCancel != null) await widget.onCancel!();
      }
    } catch (e) {
      debugPrint('AudioRecorderWidget stop error: $e');
      if (widget.onCancel != null) await widget.onCancel!();
    }
  }

  Future<void> _cancelAndDelete() async {
    try {
      if (await _rec.isRecording()) {
        await _rec.stop();
      }
    } catch (_) {}

    _ticker?.cancel();

    if (_filePath != null) {
      try {
        File(_filePath!).deleteSync();
      } catch (_) {}
    }

    if (widget.onCancel != null) {
      await widget.onCancel!();
    }
  }

  String _fmtMs(int ms) {
    final total = (ms / 1000).floor();
    final m = (total ~/ 60).toString();
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      width: widget.width,
      height: widget.height ?? 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Bouton Cancel (toujours visible)
          IconButton(
            icon: Icon(Icons.close, color: theme.error, size: 24),
            onPressed: _cancelAndDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),

          const SizedBox(width: 4),

          // Zone centrale : Chronomètre + Animation
          Expanded(
            child: _state == _RecState.recording
                ? _buildRecordingUI(theme)
                : _buildStoppedUI(theme),
          ),

          const SizedBox(width: 4),

          // Bouton Stop (visible seulement pendant l'enregistrement)
          if (_state == _RecState.recording)
            IconButton(
              icon: Icon(Icons.stop_circle, color: theme.primary, size: 32),
              onPressed: _stopRecord,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            )
          else
            const SizedBox(width: 40), // Espace pour garder l'alignement
        ],
      ),
    );
  }

  Widget _buildRecordingUI(FlutterFlowTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Point rouge pulsant
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        // Chronomètre
        Text(
          _fmtMs(_elapsedMs),
          style: theme.bodyMedium.override(
            fontFamily: 'Haas Grot Text Trial',
            color: Colors.red,
            letterSpacing: 0.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        // Animation de barres
        Expanded(child: _buildSoundWave(theme)),
      ],
    );
  }

  Widget _buildStoppedUI(FlutterFlowTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.mic, color: theme.primaryText, size: 20),
        const SizedBox(width: 8),
        Text(
          _fmtMs(_elapsedMs),
          style: theme.bodyMedium.override(
            fontFamily: 'Haas Grot Text Trial',
            letterSpacing: 0.0,
          ),
        ),
      ],
    );
  }

  Widget _buildSoundWave(FlutterFlowTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(15, (index) {
        final height = 4.0 + ((_elapsedMs ~/ 100 + index) % 5) * 3.0;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 2.5,
          height: height,
          decoration: BoxDecoration(
            color: theme.primary.withOpacity(0.6),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
