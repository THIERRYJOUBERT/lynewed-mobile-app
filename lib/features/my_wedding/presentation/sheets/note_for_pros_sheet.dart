import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../domain/entities/wedding_overview.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';

/// Note for Pros Sheet - Edit the note visible to all professionals
class NoteForProsSheet extends StatefulWidget {
  const NoteForProsSheet({
    super.key,
    required this.wedding,
    required this.onSaved,
  });

  final WeddingOverview wedding;
  final VoidCallback onSaved;

  @override
  State<NoteForProsSheet> createState() => _NoteForProsSheetState();
}

class _NoteForProsSheetState extends State<NoteForProsSheet> {
  final _repository = MyWeddingRepositoryImpl();
  late TextEditingController _noteController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.wedding.noteForPros ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    final result = await _repository.updateWedding(
      weddingId: widget.wedding.id,
      noteForPros: _noteController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (result.isSuccess) {
      widget.onSaved();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Note saved',
            style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: LynewedColors.textPrimary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.error ?? 'Failed to save note',
            style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: LynewedColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LynewedSheet(
      title: 'Note for Professionals',
      onClose: () => Navigator.pop(context),
      bottomAction: SizedBox(
        width: double.infinity,
        child: LynewedButton(
          text: 'Save Note',
          onPressed: _isSaving ? null : _save,
          isLoading: _isSaving,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtitle (outside header)
          Text(
            'This note will be visible to all professionals in your wedding team',
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          // Text field with 12 lines max for comfortable editing
          LynewedTextField(
            controller: _noteController,
            hint: 'e.g., Our theme is bohemian chic with pastel colors. We want a relaxed and romantic atmosphere...',
            maxLines: 12,
            maxLength: 1000,
          ),
          const SizedBox(height: 16),
          Text(
            'Tips for a good note:',
            style: LynewedTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildTip('Describe your wedding theme and style'),
          _buildTip('Mention any specific requirements or preferences'),
          _buildTip('Share your vision for the big day'),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: LynewedTextStyles.bodySmall),
          Expanded(
            child: Text(
              text,
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
