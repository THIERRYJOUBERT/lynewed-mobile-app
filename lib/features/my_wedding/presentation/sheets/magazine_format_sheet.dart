/// Magazine Format Selection Sheet.
///
/// Bottom sheet for selecting a magazine format using the standard
/// LynewedSheet pattern.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../domain/entities/magazine_format.dart';
import '../widgets/magazine_format_selector.dart';

/// Bottom sheet for selecting a magazine format.
class MagazineFormatSheet extends StatefulWidget {
  /// Creates a magazine format sheet.
  const MagazineFormatSheet({
    super.key,
    required this.photoCount,
    required this.currentFormat,
  });

  /// Number of photos selected.
  final int photoCount;

  /// Currently selected format.
  final MagazineFormat? currentFormat;

  /// Shows the format selection sheet and returns the selected format.
  static Future<MagazineFormat?> show(
    BuildContext context, {
    required int photoCount,
    required MagazineFormat? currentFormat,
  }) {
    return showModalBottomSheet<MagazineFormat>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MagazineFormatSheet(
        photoCount: photoCount,
        currentFormat: currentFormat,
      ),
    );
  }

  @override
  State<MagazineFormatSheet> createState() => _MagazineFormatSheetState();
}

class _MagazineFormatSheetState extends State<MagazineFormatSheet> {
  late MagazineFormat? _selectedFormat;

  @override
  void initState() {
    super.initState();
    _selectedFormat = widget.currentFormat;
  }

  @override
  Widget build(BuildContext context) {
    return LynewedSheet(
      title: 'Select Format',
      onClose: () => Navigator.pop(context),
      bottomAction: LynewedButton(
        text: 'Apply',
        onPressed: _selectedFormat != null
            ? () => Navigator.pop(context, _selectedFormat)
            : null,
        width: double.infinity,
      ),
      child: MagazineFormatSelector(
        photoCount: widget.photoCount,
        selectedFormat: _selectedFormat,
        onFormatSelected: (format) {
          setState(() => _selectedFormat = format);
        },
      ),
    );
  }
}
