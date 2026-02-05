/// Widget for generating a FedEx shipping label.
///
/// Shows a generate button that triggers the [GenerateShippingLabelUseCase],
/// displays loading and error states, and calls [onSuccess] when complete.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '/core/di/injection_container.dart';
import '../../domain/entities/shipping_label.dart';
import '../../domain/usecases/generate_shipping_label_use_case.dart';

/// Button widget to generate a FedEx shipping label for a transaction.
///
/// Handles loading, error with retry, and success states.
class GenerateLabelButton extends StatefulWidget {
  /// The transaction ID to generate a label for.
  final String transactionId;

  /// Callback invoked when label generation succeeds.
  final void Function(ShippingLabel label) onSuccess;

  /// Use case for generating labels. Injectable for testing.
  final GenerateShippingLabelUseCase? generateLabelUseCase;

  const GenerateLabelButton({
    required this.transactionId,
    required this.onSuccess,
    this.generateLabelUseCase,
    super.key,
  });

  @override
  State<GenerateLabelButton> createState() => _GenerateLabelButtonState();
}

class _GenerateLabelButtonState extends State<GenerateLabelButton> {
  late final GenerateShippingLabelUseCase _useCase;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _useCase =
        widget.generateLabelUseCase ?? sl<GenerateShippingLabelUseCase>();
  }

  Future<void> _generateLabel() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final label = await _useCase(
        transactionId: widget.transactionId,
        serviceType: 'FEDEX_GROUND',
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        widget.onSuccess(label);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.local_shipping_outlined,
              color: LynewedColors.textPrimary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Generate a FedEx shipping label to send your item.',
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: LynewedColors.primary),
            ),
          )
        else if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: LynewedComponentStyles.errorBannerDecoration(),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: LynewedColors.error,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: LynewedColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          LynewedButton(
            text: 'Retry',
            type: LynewedButtonType.secondary,
            icon: Icons.refresh,
            onPressed: _generateLabel,
          ),
        ] else
          LynewedButton(
            text: 'Generate Shipping Label',
            onPressed: _generateLabel,
            icon: Icons.label_outline,
          ),
      ],
    );
  }
}
