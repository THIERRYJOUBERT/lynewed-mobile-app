import 'package:flutter/material.dart';
import '../design.dart';

class LynewedChip extends StatelessWidget {
  const LynewedChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.count,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(!selected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? LynewedColors.primary : const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: LynewedTextStyles.chipText.copyWith(
                color: selected ? LynewedColors.textOnPrimary : LynewedColors.textPrimary,
                fontWeight: FontWeight.w300,
              ),
            ),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : LynewedColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: LynewedTextStyles.labelSmall.copyWith(
                    color: selected ? LynewedColors.primary : Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
