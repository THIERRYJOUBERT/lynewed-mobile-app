import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// LynewedIconButton - Clean Architecture equivalent of FlutterFlowIconButton
///
/// A customizable icon button that supports:
/// - Loading states with circular progress indicator
/// - Custom fill colors and border styling
/// - Hover and disabled states
/// - Font Awesome and Material icons
///
/// Example:
/// ```dart
/// LynewedIconButton(
///   icon: const Icon(Icons.add),
///   onPressed: () => print('pressed'),
///   buttonSize: 48.0,
///   fillColor: Colors.black,
/// )
/// ```
class LynewedIconButton extends StatefulWidget {
  const LynewedIconButton({
    super.key,
    required this.icon,
    this.borderColor,
    this.borderRadius,
    this.borderWidth,
    this.buttonSize,
    this.fillColor,
    this.disabledColor,
    this.disabledIconColor,
    this.hoverColor,
    this.hoverIconColor,
    this.hoverBorderColor,
    this.onPressed,
    this.showLoadingIndicator = false,
  });

  /// The icon widget to display. Can be Icon, FaIcon, or any Widget.
  final Widget icon;

  /// The border radius of the button.
  final double? borderRadius;

  /// The size of the button (width and height).
  final double? buttonSize;

  /// The background fill color of the button.
  final Color? fillColor;

  /// The background color when the button is disabled.
  final Color? disabledColor;

  /// The icon color when the button is disabled.
  final Color? disabledIconColor;

  /// The background color when hovering over the button.
  final Color? hoverColor;

  /// The icon color when hovering over the button.
  final Color? hoverIconColor;

  /// The border color when hovering over the button.
  final Color? hoverBorderColor;

  /// The border color of the button.
  final Color? borderColor;

  /// The border width of the button.
  final double? borderWidth;

  /// Whether to show a loading indicator during async operations.
  final bool showLoadingIndicator;

  /// The callback when the button is pressed. If null, the button is disabled.
  final VoidCallback? onPressed;

  @override
  State<LynewedIconButton> createState() => _LynewedIconButtonState();
}

class _LynewedIconButtonState extends State<LynewedIconButton> {
  bool _loading = false;
  late double? _iconSize;
  late Color? _iconColor;
  late Widget _effectiveIcon;

  @override
  void initState() {
    super.initState();
    _updateIcon();
  }

  @override
  void didUpdateWidget(LynewedIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateIcon();
  }

  void _updateIcon() {
    final isFontAwesome = widget.icon is FaIcon;
    if (isFontAwesome) {
      final icon = widget.icon as FaIcon;
      _effectiveIcon = FaIcon(
        icon.icon,
        size: icon.size,
      );
      _iconSize = icon.size;
      _iconColor = icon.color;
    } else if (widget.icon is Icon) {
      final icon = widget.icon as Icon;
      _effectiveIcon = Icon(
        icon.icon,
        size: icon.size,
      );
      _iconSize = icon.size;
      _iconColor = icon.color;
    } else {
      // Custom widget, use as-is
      _effectiveIcon = widget.icon;
      _iconSize = 24.0;
      _iconColor = null;
    }
  }

  Future<void> _handlePressed() async {
    if (_loading || widget.onPressed == null) {
      return;
    }

    if (widget.showLoadingIndicator) {
      setState(() => _loading = true);
      try {
        await Future.sync(widget.onPressed!);
      } finally {
        if (mounted) {
          setState(() => _loading = false);
        }
      }
    } else {
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      shape: WidgetStateProperty.resolveWith<OutlinedBorder>(
        (states) {
          if (states.contains(WidgetState.hovered)) {
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 0),
              side: BorderSide(
                color: widget.hoverBorderColor ??
                    widget.borderColor ??
                    Colors.transparent,
                width: widget.borderWidth ?? 0,
              ),
            );
          }
          return RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 0),
            side: BorderSide(
              color: widget.borderColor ?? Colors.transparent,
              width: widget.borderWidth ?? 0,
            ),
          );
        },
      ),
      iconColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.disabled) &&
              widget.disabledIconColor != null) {
            return widget.disabledIconColor;
          }
          if (states.contains(WidgetState.hovered) &&
              widget.hoverIconColor != null) {
            return widget.hoverIconColor;
          }
          return _iconColor;
        },
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.disabled) &&
              widget.disabledColor != null) {
            return widget.disabledColor;
          }
          if (states.contains(WidgetState.hovered) &&
              widget.hoverColor != null) {
            return widget.hoverColor;
          }
          return widget.fillColor;
        },
      ),
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.pressed)) {
          return null;
        }
        return widget.hoverColor == null ? null : Colors.transparent;
      }),
    );

    return SizedBox(
      width: widget.buttonSize,
      height: widget.buttonSize,
      child: Theme(
        data: ThemeData.from(
          colorScheme: Theme.of(context).colorScheme,
          useMaterial3: true,
        ),
        child: IgnorePointer(
          ignoring: widget.showLoadingIndicator && _loading,
          child: IconButton(
            icon: (widget.showLoadingIndicator && _loading)
                ? SizedBox(
                    width: _iconSize,
                    height: _iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _iconColor ?? Colors.white,
                      ),
                    ),
                  )
                : _effectiveIcon,
            onPressed: widget.onPressed == null ? null : _handlePressed,
            splashRadius: widget.buttonSize,
            style: style,
          ),
        ),
      ),
    );
  }
}
