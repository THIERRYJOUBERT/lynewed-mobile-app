import 'package:flutter/material.dart';
import '../design.dart';

/// Standard Lynewed Bottom Sheet Container
///
/// Includes:
/// - Top handle bar
/// - Header with Title (left) and Actions (right)
/// - Divider
/// - Scrollable content with bottom action inside scroll
class LynewedSheet extends StatelessWidget {
  const LynewedSheet({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.onClose,
    this.action,
    this.padding = LynewedSpacing.sheetContent,
    this.bottomAction,
  });

  final String title;
  final Widget? subtitle;
  final Widget child;
  final VoidCallback? onClose;
  final Widget? action;
  final EdgeInsetsGeometry padding;
  final Widget? bottomAction;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: LynewedColors.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle Bar
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: LynewedColors.gray200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: LynewedTextStyles.sheetTitle,
                            ),
                          ),
                          if (action != null) ...[
                            action!,
                            const SizedBox(width: 16),
                          ],
                          if (onClose != null)
                            InkWell(
                              onTap: onClose,
                              child: const Icon(
                                Icons.close,
                                size: 24,
                                color: LynewedColors.gray300,
                              ),
                            ),
                        ],
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 8),
                        subtitle!,
                      ],
                    ],
                  ),
                ),
                
                const Divider(height: 1, color: LynewedColors.gray200),

                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    padding: padding,
                    child: child,
                  ),
                ),

                // Bottom Action - fixed at bottom, outside scroll
                if (bottomAction != null)
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    decoration: const BoxDecoration(
                      color: LynewedColors.background,
                      border: Border(
                        top: BorderSide(color: LynewedColors.gray100),
                      ),
                    ),
                    child: bottomAction,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
