/// FAQ section widget.
///
/// Displays frequently asked questions in expandable tiles.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';

/// Data class representing a single FAQ item.
class FaqItem {
  /// The question text.
  final String question;

  /// The answer text.
  final String answer;

  /// Creates a FAQ item.
  const FaqItem({
    required this.question,
    required this.answer,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FaqItem &&
          runtimeType == other.runtimeType &&
          question == other.question &&
          answer == other.answer;

  @override
  int get hashCode => question.hashCode ^ answer.hashCode;
}

/// Default FAQ items for the Lynewed app.
const List<FaqItem> _defaultFaqItems = [
  FaqItem(
    question: 'How do I create a wedding?',
    answer:
        'Go to the "My Wedding" section and tap "Create Wedding". Fill in your wedding details including date, location, and budget to get started.',
  ),
  FaqItem(
    question: 'How do I contact a professional?',
    answer:
        'Browse professionals in the Discover tab, view their profile, and use the "Contact" button to start a conversation or book a video call.',
  ),
  FaqItem(
    question: 'How do I manage my team?',
    answer:
        'In your wedding details, you can add professionals to your team. Once added, you can chat with them directly and coordinate your wedding planning.',
  ),
  FaqItem(
    question: 'How do I update my profile?',
    answer:
        'Tap on your profile picture in the navigation, then select "Edit Profile" to update your information, photos, and preferences.',
  ),
  FaqItem(
    question: 'How do I cancel a booking?',
    answer:
        'Go to your wedding team, find the professional, and tap on their profile. You can manage or cancel bookings from there. Note that cancellation policies may apply.',
  ),
];

/// A widget that displays the FAQ section with expandable tiles.
///
/// Used in the support page to show frequently asked questions.
/// Each FAQ item is displayed as an ExpansionTile that can be
/// expanded to reveal the answer.
///
/// By default, shows common Lynewed FAQs. Custom items can be
/// provided via the [items] parameter.
class FaqSection extends StatelessWidget {
  /// The FAQ items to display.
  /// If null, displays default Lynewed FAQs.
  final List<FaqItem>? items;

  /// Creates a FAQ section widget.
  const FaqSection({
    this.items,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final faqItems = items ?? _defaultFaqItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
          child: Text(
            'Frequently Asked Questions',
            style: LynewedTextStyles.sectionTitle,
          ),
        ),
        // FAQ items
        Container(
          decoration: BoxDecoration(
            color: LynewedColors.surface,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: LynewedColors.border,
              width: 1.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Column(
              children: [
                for (int i = 0; i < faqItems.length; i++) ...[
                  _buildFaqTile(faqItems[i]),
                  if (i < faqItems.length - 1)
                    const Divider(
                      height: 1.0,
                      color: LynewedColors.border,
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFaqTile(FaqItem item) {
    return Theme(
      data: ThemeData(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 4.0,
        ),
        childrenPadding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          bottom: 16.0,
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        title: Text(
          item.question,
          style: LynewedTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        iconColor: LynewedColors.textSecondary,
        collapsedIconColor: LynewedColors.textSecondary,
        backgroundColor: LynewedColors.surface,
        collapsedBackgroundColor: LynewedColors.surface,
        children: [
          Text(
            item.answer,
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
