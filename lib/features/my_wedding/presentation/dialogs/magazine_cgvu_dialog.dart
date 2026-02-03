/// Magazine CGVU Dialog - Terms acceptance with scroll requirement.
///
/// Displays the magazine purchase terms with a scroll-to-unlock checkbox.
/// User must scroll to the bottom before the checkbox becomes enabled.
/// Logs acceptance to cgvu_acceptances table for audit.
library;

import 'package:flutter/material.dart';
import '/core/constants/cgvu_texts.dart';
import '/core/design/design.dart';
import '../../domain/usecases/accept_cgvu_use_case.dart';

/// Dialog for accepting magazine CGVU (Terms of Purchase).
///
/// Features:
/// - Scrollable terms text
/// - Checkbox disabled until user scrolls to bottom
/// - Logs acceptance to database for audit
/// - Prevents acceptance without reading
class MagazineCgvuDialog extends StatefulWidget {
  /// Creates a magazine CGVU dialog.
  const MagazineCgvuDialog({
    super.key,
    required this.onAccepted,
    this.acceptCgvuUseCase,
  });

  /// Callback when user accepts the terms.
  final VoidCallback onAccepted;

  /// Optional use case for testing injection.
  final AcceptCgvuUseCase? acceptCgvuUseCase;

  @override
  State<MagazineCgvuDialog> createState() => _MagazineCgvuDialogState();
}

class _MagazineCgvuDialogState extends State<MagazineCgvuDialog> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;
  bool _isChecked = false;
  bool _isLoading = false;

  late final AcceptCgvuUseCase _acceptCgvuUseCase;

  @override
  void initState() {
    super.initState();
    _acceptCgvuUseCase = widget.acceptCgvuUseCase ?? const AcceptCgvuUseCase();
    _scrollController.addListener(_onScroll);
    // Check if content is already fully visible (short content)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialScrollPosition();
    });
  }

  void _checkInitialScrollPosition() {
    if (!_scrollController.hasClients) return;
    // If content doesn't need scrolling, enable checkbox immediately
    if (_scrollController.position.maxScrollExtent <= 0) {
      setState(() => _hasScrolledToBottom = true);
    }
  }

  void _onScroll() {
    if (_hasScrolledToBottom) return;

    final position = _scrollController.position;
    // Consider "at bottom" when within 20 pixels of the end
    final isAtBottom = position.pixels >= position.maxScrollExtent - 20;

    if (isAtBottom) {
      setState(() => _hasScrolledToBottom = true);
    }
  }

  Future<void> _onAccept() async {
    if (!_isChecked || _isLoading) return;

    setState(() => _isLoading = true);

    final result = await _acceptCgvuUseCase(
      cgvuType: magazineCgvuType,
      cgvuVersion: magazineCgvuVersion,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      widget.onAccepted();
      Navigator.of(context).pop(true);
    } else {
      // Show error but still allow proceeding (acceptance logging is non-blocking)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to record acceptance'),
          backgroundColor: LynewedColors.warning,
        ),
      );
      // Still call onAccepted even if logging failed
      widget.onAccepted();
      Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: LynewedColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const Divider(height: 1, color: LynewedColors.gray200),
            Flexible(
              child: _buildScrollableContent(),
            ),
            const Divider(height: 1, color: LynewedColors.gray200),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Terms of Purchase',
              style: LynewedTextStyles.sheetTitle,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(false),
            icon: const Icon(
              Icons.close,
              size: 24,
              color: LynewedColors.gray300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableContent() {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        child: Text(
          magazineCgvuText,
          style: LynewedTextStyles.bodyMedium.copyWith(
            height: 1.6,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Scroll hint when not yet scrolled
          if (!_hasScrolledToBottom) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: LynewedColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_downward,
                    size: 16,
                    color: LynewedColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Scroll to read all terms',
                    style: LynewedTextStyles.labelLarge.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Checkbox
          InkWell(
            onTap: _hasScrolledToBottom
                ? () => setState(() => _isChecked = !_isChecked)
                : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _isChecked,
                      onChanged: _hasScrolledToBottom
                          ? (value) =>
                              setState(() => _isChecked = value ?? false)
                          : null,
                      activeColor: LynewedColors.primary,
                      checkColor: LynewedColors.textOnPrimary,
                      side: BorderSide(
                        color: _hasScrolledToBottom
                            ? LynewedColors.primary
                            : LynewedColors.gray200,
                        width: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'I have read and accept the terms',
                      style: LynewedTextStyles.bodyMedium.copyWith(
                        color: _hasScrolledToBottom
                            ? LynewedColors.textPrimary
                            : LynewedColors.gray300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Accept button
          SizedBox(
            width: double.infinity,
            child: LynewedButton(
              text: 'Accept',
              onPressed: _isChecked && !_isLoading ? _onAccept : null,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows the magazine CGVU dialog.
///
/// Returns true if user accepted, false if dismissed.
Future<bool> showMagazineCgvuDialog({
  required BuildContext context,
  required VoidCallback onAccepted,
  AcceptCgvuUseCase? acceptCgvuUseCase,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => MagazineCgvuDialog(
      onAccepted: onAccepted,
      acceptCgvuUseCase: acceptCgvuUseCase,
    ),
  );

  return result ?? false;
}
