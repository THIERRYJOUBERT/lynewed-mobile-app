/// Chat input bar for marketplace messages.
///
/// Text field with send button for composing and sending messages.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';

/// Input bar for typing and sending chat messages.
///
/// Contains a [LynewedTextField] and a send [LynewedIconButton].
/// The send button is disabled when the input is empty.
class ChatInputBar extends StatefulWidget {
  /// Creates a chat input bar.
  const ChatInputBar({
    required this.controller,
    required this.onSend,
    super.key,
  });

  /// Text editing controller for the message input.
  final TextEditingController controller;

  /// Callback when the send button is pressed.
  final VoidCallback onSend;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _hasText = widget.controller.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _handleSend() {
    if (!_hasText) return;
    widget.onSend();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(LynewedSpacing.md),
      decoration: const BoxDecoration(
        color: LynewedColors.background,
        border: Border(
          top: BorderSide(color: LynewedColors.gray200),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: LynewedTextField(
                controller: widget.controller,
                hint: 'Type a message...',
                maxLines: 3,
                textInputAction: TextInputAction.send,
                onEditingComplete: _handleSend,
              ),
            ),
            SizedBox(width: LynewedSpacing.sm),
            LynewedIconButton(
              icon: Icon(
                Icons.send,
                color: _hasText
                    ? LynewedColors.primary
                    : LynewedColors.gray300,
                size: 22,
              ),
              onPressed: _hasText ? _handleSend : null,
            ),
          ],
        ),
      ),
    );
  }
}
