/// Bottom sheet for scanning QR codes.
///
/// Provides a camera view with QR code detection for
/// scanning wedding invitation QR codes.
library;

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/design/design.dart';

/// Shows a bottom sheet with QR scanner.
///
/// Returns the extracted invitation code (8 characters) if a valid
/// Lynewed invitation QR code is scanned, or null if cancelled.
Future<String?> showQrScannerSheet(BuildContext context) async {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: LynewedColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _QrScannerContent(),
  );
}

/// Content of the QR scanner bottom sheet.
class _QrScannerContent extends StatefulWidget {
  const _QrScannerContent();

  @override
  State<_QrScannerContent> createState() => _QrScannerContentState();
}

class _QrScannerContentState extends State<_QrScannerContent> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return; // Prevent multiple scans

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue == null) continue;

      // Extract code from Lynewed URL format
      final code = _extractCodeFromUrl(rawValue);
      if (code != null) {
        _hasScanned = true;
        Navigator.of(context).pop(code);
        return;
      }

      // Also accept plain 8-character codes
      if (_isValidCode(rawValue)) {
        _hasScanned = true;
        Navigator.of(context).pop(rawValue.toUpperCase());
        return;
      }
    }
  }

  /// Extracts the invitation code from a Lynewed URL.
  ///
  /// Expected format: https://lynewed.app/join/ABCD1234
  String? _extractCodeFromUrl(String url) {
    // Pattern to match lynewed.app/join/{code}
    final regex = RegExp(r'lynewed\.app/join/([A-Za-z0-9]{8})');
    final match = regex.firstMatch(url);

    if (match != null && match.groupCount >= 1) {
      return match.group(1)?.toUpperCase();
    }

    return null;
  }

  /// Checks if a string is a valid 8-character alphanumeric code.
  bool _isValidCode(String value) {
    return RegExp(r'^[A-Za-z0-9]{8}$').hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          // Handle
          Padding(
            padding: EdgeInsets.only(top: LynewedSpacing.md),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: LynewedColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(LynewedSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Scanner QR Code',
                  style: LynewedTextStyles.sheetTitle,
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: LynewedColors.textPrimary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Instructions
          Padding(
            padding: EdgeInsets.symmetric(horizontal: LynewedSpacing.lg),
            child: Text(
              "Placez le QR code de votre invitation dans le cadre",
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: LynewedSpacing.lg),

          // Scanner
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(LynewedSpacing.md),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: LynewedSpacing.lg),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(LynewedSpacing.md),
                  child: Stack(
                    children: [
                      // Camera
                      MobileScanner(
                        controller: _controller,
                        onDetect: _onDetect,
                      ),
                      // Overlay with scan area
                      CustomPaint(
                        size: Size.infinite,
                        painter: _ScanOverlayPainter(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: LynewedSpacing.lg),

          // Flash toggle
          Padding(
            padding: EdgeInsets.only(bottom: LynewedSpacing.xxxl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FlashButton(controller: _controller),
                SizedBox(width: LynewedSpacing.xxl),
                _SwitchCameraButton(controller: _controller),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Button to toggle flash.
class _FlashButton extends StatefulWidget {
  const _FlashButton({required this.controller});

  final MobileScannerController controller;

  @override
  State<_FlashButton> createState() => _FlashButtonState();
}

class _FlashButtonState extends State<_FlashButton> {
  bool _isOn = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isOn ? Icons.flash_on : Icons.flash_off,
        color: LynewedColors.textPrimary,
        size: 28,
      ),
      onPressed: () {
        widget.controller.toggleTorch();
        setState(() => _isOn = !_isOn);
      },
    );
  }
}

/// Button to switch camera.
class _SwitchCameraButton extends StatelessWidget {
  const _SwitchCameraButton({required this.controller});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.cameraswitch_outlined,
        color: LynewedColors.textPrimary,
        size: 28,
      ),
      onPressed: () => controller.switchCamera(),
    );
  }
}

/// Custom painter for the scan overlay.
class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    // Scan area dimensions
    final scanAreaSize = size.width * 0.7;
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;
    final right = left + scanAreaSize;
    final bottom = top + scanAreaSize;

    // Draw overlay (everything except scan area)
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTRB(left, top, right, bottom),
        const Radius.circular(16),
      ))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw corner brackets
    final bracketPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const bracketLength = 24.0;
    const radius = 16.0;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(left, top + bracketLength)
        ..lineTo(left, top + radius)
        ..arcToPoint(
          Offset(left + radius, top),
          radius: const Radius.circular(radius),
        )
        ..lineTo(left + bracketLength, top),
      bracketPaint,
    );

    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(right - bracketLength, top)
        ..lineTo(right - radius, top)
        ..arcToPoint(
          Offset(right, top + radius),
          radius: const Radius.circular(radius),
        )
        ..lineTo(right, top + bracketLength),
      bracketPaint,
    );

    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(left, bottom - bracketLength)
        ..lineTo(left, bottom - radius)
        ..arcToPoint(
          Offset(left + radius, bottom),
          radius: const Radius.circular(radius),
        )
        ..lineTo(left + bracketLength, bottom),
      bracketPaint,
    );

    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(right - bracketLength, bottom)
        ..lineTo(right - radius, bottom)
        ..arcToPoint(
          Offset(right, bottom - radius),
          radius: const Radius.circular(radius),
        )
        ..lineTo(right, bottom - bracketLength),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
