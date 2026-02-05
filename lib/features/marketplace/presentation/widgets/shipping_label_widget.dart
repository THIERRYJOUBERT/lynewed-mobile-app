/// Widget for displaying a shipping label with view and download options.
///
/// Shows a success card with tracking number, copy button,
/// view/download buttons, and instructions for the seller.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '/core/design/design.dart';

/// Displays a shipping label with tracking number and action buttons.
///
/// Shows:
/// - Green checkmark icon and "Shipping Label Ready" title
/// - Tracking number with copy button
/// - View Label button (opens PDF in browser)
/// - Download Label button (opens PDF for download)
/// - Instructions for the seller
class ShippingLabelWidget extends StatelessWidget {
  /// FedEx tracking number.
  final String trackingNumber;

  /// URL to download/view the label PDF.
  final String labelUrl;

  const ShippingLabelWidget({
    required this.trackingNumber,
    required this.labelUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: LynewedColors.success.withValues(alpha: 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: LynewedColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: LynewedColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Shipping Label Ready',
                    style: LynewedTextStyles.titleSmall.copyWith(
                      color: LynewedColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Tracking Number',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: SelectableText(
                    trackingNumber,
                    style: LynewedTextStyles.titleSmall.copyWith(
                      color: LynewedColors.textPrimary,
                      fontFamily: 'monospace',
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: trackingNumber));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tracking number copied'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  tooltip: 'Copy tracking number',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: LynewedButton(
                    text: 'View Label',
                    type: LynewedButtonType.secondary,
                    icon: Icons.visibility_outlined,
                    onPressed: () => _openUrl(labelUrl),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LynewedButton(
                    text: 'Download Label',
                    icon: Icons.download_outlined,
                    onPressed: () => _openUrl(labelUrl),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Print this label and attach it to your package.',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Opens the given URL in an external browser.
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
