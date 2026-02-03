import 'package:flutter/material.dart';
import '/core/design/design.dart';

/// A reusable widget for caption input with character counter.
///
/// Features:
/// - Character counter showing current/max (e.g., "45/500")
/// - Max length enforcement (500 characters)
/// - Warning color at 450+ characters (orange)
/// - Error color at 500 characters (red)
/// - Optional caption (empty allowed)
/// - Uses LynewedTextField from Design System
class CaptionInputWidget extends StatefulWidget {
  const CaptionInputWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.label,
  });

  /// Controller for the text field
  final TextEditingController controller;

  /// Callback when text changes
  final ValueChanged<String>? onChanged;

  /// Optional label above the text field
  final String? label;

  /// Maximum character limit for captions
  static const int maxLength = 500;

  /// Character count threshold to show warning color
  static const int warningThreshold = 450;

  @override
  State<CaptionInputWidget> createState() => _CaptionInputWidgetState();
}

class _CaptionInputWidgetState extends State<CaptionInputWidget> {
  int _currentLength = 0;
  bool _isEnforcingLimit = false;

  @override
  void initState() {
    super.initState();
    _currentLength = widget.controller.text.length;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant CaptionInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      _currentLength = widget.controller.text.length;
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (_isEnforcingLimit) return;

    final text = widget.controller.text;
    if (text.length > CaptionInputWidget.maxLength) {
      // Enforce max length
      _isEnforcingLimit = true;
      final truncated = text.substring(0, CaptionInputWidget.maxLength);
      widget.controller.text = truncated;
      widget.controller.selection = TextSelection.fromPosition(
        TextPosition(offset: truncated.length),
      );
      _isEnforcingLimit = false;
    }

    setState(() {
      _currentLength = widget.controller.text.length;
    });
  }

  void _handleTextChange(String value) {
    // The listener handles truncation, so just forward the callback
    // with the potentially truncated value
    widget.onChanged?.call(widget.controller.text);
  }

  Color _getCounterColor() {
    if (_currentLength >= CaptionInputWidget.maxLength) {
      return LynewedColors.error;
    } else if (_currentLength >= CaptionInputWidget.warningThreshold) {
      return Colors.orange;
    }
    return LynewedColors.textSecondary;
  }

  FontWeight _getCounterFontWeight() {
    if (_currentLength >= CaptionInputWidget.warningThreshold) {
      return FontWeight.w600;
    }
    return FontWeight.normal;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LynewedTextField(
          controller: widget.controller,
          label: widget.label,
          hint: 'Add a caption...',
          maxLines: 3,
          // Note: We don't pass maxLength to avoid the default counter
          // Max length is enforced via the controller listener
          onChanged: _handleTextChange,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$_currentLength/${CaptionInputWidget.maxLength}',
            style: LynewedTextStyles.labelLarge.copyWith(
              color: _getCounterColor(),
              fontWeight: _getCounterFontWeight(),
            ),
          ),
        ),
      ],
    );
  }
}
