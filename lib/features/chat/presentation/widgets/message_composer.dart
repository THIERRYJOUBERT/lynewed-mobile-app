/// Message composer widget - Clean Architecture
/// 
/// Input field for composing and sending messages (text, image, audio).
library;

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '/core/design/design.dart';
import 'audio_player_widget.dart';

/// Callback types for message sending
typedef SendTextCallback = Future<bool> Function(String content);
typedef SendImageCallback = Future<bool> Function({
  required String filePath,
  required String fileName,
});
typedef SendAudioCallback = Future<bool> Function({
  required String filePath,
  required String fileName,
});

/// Widget for composing and sending messages
class MessageComposer extends StatefulWidget {
  const MessageComposer({
    super.key,
    required this.onSendText,
    this.onSendImage,
    this.onSendAudio,
    this.onSendingComplete,
    this.isEnabled = true,
    this.isSending = false,
    this.firstMessageTextOnly = false,
    this.placeholder = 'Write a message...',
    this.maxLength = 1000,
  });

  /// Callback to send text message
  final SendTextCallback onSendText;

  /// Callback to send image message
  final SendImageCallback? onSendImage;

  /// Callback to send audio message
  final SendAudioCallback? onSendAudio;

  /// Callback when all sending is complete (for multiple images)
  final VoidCallback? onSendingComplete;

  /// Whether the composer is enabled
  final bool isEnabled;

  /// Whether a message is currently being sent
  final bool isSending;

  /// Whether only text is allowed (first message Pro→Bride)
  final bool firstMessageTextOnly;

  /// Placeholder text
  final String placeholder;

  /// Maximum text length
  final int maxLength;

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();

  List<XFile> _selectedImages = [];
  
  // Audio recording state
  late final AudioRecorder _audioRecorder;
  bool _isRecording = false;
  String? _recordingPath;
  String? _audioFilePath;
  String? _audioFileName;
  int _recordingDurationMs = 0;
  Timer? _recordingTimer;
  static const int _maxRecordingDurationSec = 120;

  // Waveform data
  final List<double> _amplitudes = List.filled(30, 0.0); // Keep last 30 values

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  bool get _hasAudioReady => _audioFilePath != null && _audioFileName != null;

  bool get _canSend {
    if (!widget.isEnabled || widget.isSending) return false;
    return _textController.text.trim().isNotEmpty || 
           _selectedImages.isNotEmpty || 
           _hasAudioReady;
  }

  bool get _canAddMedia {
    return widget.isEnabled &&
        !widget.isSending &&
        !widget.firstMessageTextOnly &&
        !_hasAudioReady;
  }

  Future<void> _handleSend() async {
    if (!_canSend) return;

    // Send audio if ready (audio is exclusive - no images/text with it)
    if (_hasAudioReady && widget.onSendAudio != null) {
      final success = await widget.onSendAudio!(
        filePath: _audioFilePath!,
        fileName: _audioFileName!,
      );
      if (success) {
        _clearAudio();
      }
      return;
    }

    // Send images first if any
    if (_selectedImages.isNotEmpty && widget.onSendImage != null) {
      final imagesToSend = List<XFile>.from(_selectedImages);
      setState(() {
        _selectedImages = [];
      });
      
      for (final image in imagesToSend) {
        await widget.onSendImage!(
          filePath: image.path,
          fileName: image.path.split('/').last,
        );
      }
      
      // Notify that all images have been sent
      widget.onSendingComplete?.call();
    }

    // Then send text if any
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      final success = await widget.onSendText(text);
      if (success) {
        _textController.clear();
      }
    }
  }

  void _clearAudio() {
    // Delete the temp file
    if (_audioFilePath != null) {
      try {
        File(_audioFilePath!).deleteSync();
      } catch (_) {}
    }
    setState(() {
      _audioFilePath = null;
      _audioFileName = null;
      _recordingDurationMs = 0;
    });
  }

  Future<void> _pickImages() async {
    if (!_canAddMedia) return;

    try {
      final images = await _imagePicker.pickMultiImage(
        maxWidth: 1440,
        imageQuality: 80,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages = [..._selectedImages, ...images];
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: LynewedColors.background,
        border: Border(
          top: BorderSide(color: LynewedColors.border),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selected images preview
            if (_selectedImages.isNotEmpty) _buildImagePreview(),

            // Input row
            _buildInputRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(
        horizontal: LynewedSpacing.md,
        vertical: LynewedSpacing.sm,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: LynewedSpacing.sm),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_selectedImages[index].path),
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: LynewedColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: LynewedColors.textOnPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Determines if mic button should be shown (no text, no images, no audio ready)
  bool get _showMicButton {
    return !widget.firstMessageTextOnly &&
        widget.onSendAudio != null &&
        !_isRecording &&
        !_hasAudioReady &&
        _textController.text.trim().isEmpty &&
        _selectedImages.isEmpty;
  }

  Widget _buildInputRow() {
    // Fixed height for buttons to match text field min height
    const double buttonSize = 44.0;
    const double minInputHeight = 44.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LynewedSpacing.md,
        vertical: LynewedSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image picker button (left side) - only show if not recording and no audio ready
          if (!widget.firstMessageTextOnly && !_isRecording && !_hasAudioReady) ...[
            _buildActionButton(
              icon: Icons.add,
              onTap: _canAddMedia ? _pickImages : null,
              enabled: _canAddMedia,
              size: buttonSize,
            ),
            const SizedBox(width: LynewedSpacing.sm),
          ],

          // Text input (expanded)
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                minHeight: minInputHeight,
                maxHeight: 120,
              ),
              decoration: BoxDecoration(
                color: LynewedColors.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: _isRecording
                  ? _buildRecordingIndicator()
                  : _hasAudioReady
                      ? _buildAudioPreviewChip()
                      : TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          enabled: widget.isEnabled && !widget.isSending,
                          maxLength: widget.maxLength,
                          maxLines: null,
                          textInputAction: TextInputAction.newline,
                          style: LynewedTextStyles.bodyMedium,
                          decoration: InputDecoration(
                            hintText: widget.placeholder,
                            hintStyle: LynewedTextStyles.bodyMedium.copyWith(
                              color: LynewedColors.textSecondary,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            counterText: '', // Hide character counter
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
            ),
          ),

          const SizedBox(width: LynewedSpacing.sm),

          // Right button: Mic OR Send (stacked at same position)
          _buildRightActionButton(),
        ],
      ),
    );
  }

  /// Recording indicator - Instagram style layout
  Widget _buildRecordingIndicator() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Cancel button (Left) - Unified with player delete button
          GestureDetector(
            onTap: _cancelRecording,
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: const Icon(
                Icons.close,
                size: 20, // Same as player delete button
                color: LynewedColors.error,
              ),
            ),
          ),
          const SizedBox(width: 10), // Reduced from 12px
          
          // Waveform (Middle, Expanded)
          Expanded(child: _buildSoundWave()),
          
          const SizedBox(width: 10), // Reduced from 12px

          // Red Dot + Timer (Right)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Recording indicator dot
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: LynewedColors.error,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              // Timer - Unified with player (w400, same as duration display)
              Text(
                _formatDuration(_recordingDurationMs),
                style: LynewedTextStyles.labelSmall.copyWith(
                  color: LynewedColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Animated sound wave bars - Real-time amplitude (slower, uniform color)
  Widget _buildSoundWave() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(_amplitudes.length, (index) {
        final amplitude = _amplitudes[index];
        
        // More aggressive curve: cube to reduce silence amplitude
        final emphasizedAmp = amplitude * amplitude * amplitude;
        
        // Height: min 2px (silence), max 20px (loud)
        final height = (2.0 + (emphasizedAmp * 18.0)).clamp(2.0, 20.0);
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80), // Slower animation
            width: 3,
            height: height,
            decoration: BoxDecoration(
              color: LynewedColors.textSecondary, // Uniform color, no gradient
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        );
      }),
    );
  }

  /// Audio preview with playback controls - Design System v3
  Widget _buildAudioPreviewChip() {
    if (_audioFilePath == null) return const SizedBox.shrink();

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Audio player - takes most space
          Expanded(
            child: AudioPlayerWidget(
              audioUrl: 'file://$_audioFilePath',
              compact: true,
              autoPlay: false,
            ),
          ),
          
          const SizedBox(width: 6),
          
          // Delete button - Design System v3 compliant
          GestureDetector(
            onTap: _clearAudio,
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: const Icon(
                Icons.close,
                color: LynewedColors.error,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Right action button: shows Mic when empty, Send when has content
  Widget _buildRightActionButton() {
    const double buttonSize = 44.0;
    
    // If recording, show stop button
    if (_isRecording) {
      return GestureDetector(
        onTap: _stopRecording,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: const BoxDecoration(
            color: LynewedColors.error,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.stop,
            size: 20,
            color: LynewedColors.textOnPrimary,
          ),
        ),
      );
    }

    // Show mic button when no content
    if (_showMicButton) {
      return GestureDetector(
        onTap: _canAddMedia ? _startRecording : null,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: const BoxDecoration(
            color: LynewedColors.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mic_none,
            size: 22,
            color: _canAddMedia
                ? LynewedColors.textPrimary
                : LynewedColors.textSecondary,
          ),
        ),
      );
    }

    // Show send button when has content
    return _buildSendButton();
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onTap,
    bool enabled = true,
    bool isActive = false,
    double size = 44.0,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isActive ? LynewedColors.primary : LynewedColors.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 22,
          color: isActive
              ? LynewedColors.textOnPrimary
              : (enabled
                  ? LynewedColors.textPrimary
                  : LynewedColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    const double buttonSize = 44.0;
    return GestureDetector(
      onTap: _canSend ? _handleSend : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: _canSend ? LynewedColors.primary : LynewedColors.surface,
          shape: BoxShape.circle,
        ),
        child: widget.isSending
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: LynewedColors.textOnPrimary,
                ),
              )
            : Icon(
                Icons.send,
                size: 20,
                color: _canSend
                    ? LynewedColors.textOnPrimary
                    : LynewedColors.textSecondary,
              ),
      ),
    );
  }

  /// Poll amplitude without blocking timer
  Future<void> _pollAmplitude() async {
    if (!_isRecording) return;
    
    try {
      final amplitude = await _audioRecorder.getAmplitude();
      // Normalize: -160dB (silence) to 0dB (max) → 0.0 to 1.0
      final currentAmp = ((amplitude.current + 160) / 160).clamp(0.0, 1.0);
      
      if (mounted && _isRecording) {
        // Shift left and add new value
        for (int i = 0; i < _amplitudes.length - 1; i++) {
          _amplitudes[i] = _amplitudes[i + 1];
        }
        _amplitudes[_amplitudes.length - 1] = currentAmp;
      }
    } catch (e) {
      // Ignore amplitude errors, just use 0
    }
  }

  Future<void> _startRecording() async {
    // Check microphone permission
    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission required'),
            backgroundColor: LynewedColors.error,
          ),
        );
      }
      return;
    }

    try {
      // Get temp directory and create file path
      final dir = await getTemporaryDirectory();
      final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final filePath = '${dir.path}/$fileName';

      // Configure and start recording
      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 64000,
        sampleRate: 44100,
      );
      
      await _audioRecorder.start(config, path: filePath);
      _recordingPath = filePath;
      
      // Start timer (100ms - slower for smoother waveform)
      _recordingDurationMs = 0;
      for (int i = 0; i < _amplitudes.length; i++) {
        _amplitudes[i] = 0.0;
      }
      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!mounted || !_isRecording) {
          timer.cancel();
          return;
        }
        
        // Update duration
        _recordingDurationMs += 100;
        
        // Poll amplitude asynchronously without blocking timer
        _pollAmplitude();

        // Auto-stop at max duration
        if (_recordingDurationMs >= _maxRecordingDurationSec * 1000) {
          _stopRecording();
        }
        
        // Force rebuild for timer display
        setState(() {});
      });

      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      debugPrint('Audio recording start failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to start recording'),
            backgroundColor: LynewedColors.error,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    _recordingTimer?.cancel();

    try {
      final path = await _audioRecorder.stop();
      
      if (path != null && File(path).existsSync()) {
        setState(() {
          _isRecording = false;
          _audioFilePath = path;
          _audioFileName = path.split('/').last;
        });
      } else {
        setState(() {
          _isRecording = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recording failed - no file saved'),
              backgroundColor: LynewedColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Audio recording stop failed: $e');
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<void> _cancelRecording() async {
    _recordingTimer?.cancel();
    
    try {
      if (await _audioRecorder.isRecording()) {
        await _audioRecorder.stop();
      }
    } catch (_) {}

    // Delete temp file if exists
    if (_recordingPath != null) {
      try {
        File(_recordingPath!).deleteSync();
      } catch (_) {}
    }

    setState(() {
      _isRecording = false;
      _recordingPath = null;
      _recordingDurationMs = 0;
    });
  }

  String _formatDuration(int ms) {
    final totalSeconds = (ms / 1000).floor();
    final minutes = totalSeconds ~/ 60;
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
