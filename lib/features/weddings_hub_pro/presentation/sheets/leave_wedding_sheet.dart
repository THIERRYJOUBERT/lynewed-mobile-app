import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../data/repositories/weddings_hub_repository_impl.dart';
import '../../domain/entities/wedding_client.dart';

/// Leave Wedding Sheet - Pro quits a wedding team
class LeaveWeddingSheet extends StatefulWidget {
  const LeaveWeddingSheet({
    super.key,
    required this.wedding,
    required this.onLeft,
  });

  final WeddingClient wedding;
  final VoidCallback onLeft;

  @override
  State<LeaveWeddingSheet> createState() => _LeaveWeddingSheetState();
}

class _LeaveWeddingSheetState extends State<LeaveWeddingSheet> {
  final _repository = WeddingsHubRepositoryImpl();
  final _reasonController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _leaveWedding() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      setState(() => _error = 'Please provide a reason');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _repository.leaveWedding(
      weddingId: widget.wedding.weddingId,
      reason: reason,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      widget.onLeft();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You have left the wedding team',
            style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: LynewedColors.textPrimary,
        ),
      );
    } else {
      setState(() => _error = result.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LynewedSheet(
      title: 'Leave Wedding',
      onClose: () => Navigator.pop(context),
      bottomAction: SizedBox(
        width: double.infinity,
        child: LynewedButton(
          text: 'Leave Wedding',
          onPressed: _isLoading ? null : _leaveWedding,
          isLoading: _isLoading,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You are about to leave ${widget.wedding.brideName}\'s wedding team.',
            style: LynewedTextStyles.bodyMedium.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This action cannot be undone. The bride will be notified of your departure.',
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Reason for leaving *',
            style: LynewedTextStyles.sectionTitle,
          ),
          const SizedBox(height: 10),
          LynewedTextField(
            controller: _reasonController,
            hint: 'e.g., Schedule conflict, personal reasons...',
            maxLines: 4,
            maxLength: 500,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
