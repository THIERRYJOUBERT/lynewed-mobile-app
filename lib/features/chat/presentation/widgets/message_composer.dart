/// Message composer widget - Clean Architecture
/// 
/// Input field for composing and sending messages (text, image, audio).
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/core/design/design.dart';

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
    this.isEnabled = true,
    this.isSending = false,
    this.firstMessageTextOnly = false,
    this.placeholder = 'Écrire un message...',
    this.maxLength = 1000,
  });

  /// Callback to send text message
  final SendTextCallback onSendText;

  /// Callback to send image message
  final SendImageCallback? onSendImage;

  /// Callback to send audio message
  final SendAudioCallback? onSendAudio;

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
  bool _isRecording = false;

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _canSend {
    if (!widget.isEnabled || widget.isSending) return false;
    return _textController.text.trim().isNotEmpty || _selectedImages.isNotEmpty;
  }

  bool get _canAddMedia {
    return widget.isEnabled &&
        !widget.isSending &&
        !widget.firstMessageTextOnly;
  }

  Future<void> _handleSend() async {
    if (!_canSend) return;

    // Send images first if any
    if (_selectedImages.isNotEmpty && widget.onSendImage != null) {
      for (final image in _selectedImages) {
        await widget.onSendImage!(
          filePath: image.path,
          fileName: image.path.split('/').last,
        );
      }
      setState(() {
        _selectedImages = [];
      });
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

  Widget _buildInputRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LynewedSpacing.md,
        vertical: LynewedSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Image picker button
          if (!widget.firstMessageTextOnly) ...[
            _buildActionButton(
              icon: Icons.image_outlined,
              onTap: _canAddMedia ? _pickImages : null,
              enabled: _canAddMedia,
            ),
            const SizedBox(width: LynewedSpacing.sm),
          ],

          // Audio button (placeholder - needs audio recording implementation)
          if (!widget.firstMessageTextOnly && widget.onSendAudio != null) ...[
            _buildActionButton(
              icon: _isRecording ? Icons.stop : Icons.mic_outlined,
              onTap: _canAddMedia ? _toggleRecording : null,
              enabled: _canAddMedia,
              isActive: _isRecording,
            ),
            const SizedBox(width: LynewedSpacing.sm),
          ],

          // Text input
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: LynewedColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
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

          // Send button
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onTap,
    bool enabled = true,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
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
    return GestureDetector(
      onTap: _canSend ? _handleSend : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _canSend ? LynewedColors.primary : LynewedColors.surface,
          shape: BoxShape.circle,
        ),
        child: widget.isSending
            ? const Padding(
                padding: EdgeInsets.all(10),
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

  void _toggleRecording() {
    // TODO: Implement audio recording
    // This would require audio_recorder package
    setState(() {
      _isRecording = !_isRecording;
    });

    if (!_isRecording) {
      // Recording stopped - would send audio here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enregistrement audio non implémenté'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
