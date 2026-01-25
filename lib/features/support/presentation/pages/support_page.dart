/// Support page.
///
/// Displays help and support options for users including:
/// - Quick actions (Email, Chat)
/// - Frequently asked questions
/// - Contact form for direct support requests
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '/core/design/design.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/faq_section.dart';
import '../widgets/contact_form.dart';

/// The main support page with help and contact options.
///
/// Provides users with multiple ways to get help:
/// - Quick access to email support
/// - Live chat option
/// - FAQ section with common questions
/// - Contact form for detailed inquiries
class SupportPage extends StatelessWidget {
  /// Route name for navigation.
  static const String routeName = 'support';

  /// Route path for navigation.
  static const String routePath = '/support';

  /// Support email address.
  static const String supportEmail = 'support@lynewed.com';

  /// Creates a support page.
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            const Divider(height: 1.0, color: LynewedColors.gray200),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Actions Section
                    _buildSectionTitle('Quick Actions'),
                    const SizedBox(height: 12.0),
                    _buildQuickActions(context),

                    const SizedBox(height: 32.0),

                    // FAQ Section
                    const FaqSection(),

                    const SizedBox(height: 32.0),

                    // Contact Form Section
                    ContactForm(
                      onSubmit: (subject, message) =>
                          _handleContactSubmit(context, subject, message),
                    ),

                    const SizedBox(height: 32.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 16.0, 16.0, 12.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            color: LynewedColors.textPrimary,
          ),
          const SizedBox(width: 4.0),
          Text(
            'Help & Support',
            style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20.0),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: LynewedTextStyles.sectionTitle,
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: QuickActionCard(
            icon: Icons.email_outlined,
            title: 'Email Us',
            subtitle: supportEmail,
            onTap: () => _launchEmail(context),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: QuickActionCard(
            icon: Icons.chat_outlined,
            title: 'Live Chat',
            subtitle: 'Chat with us',
            onTap: () => _openLiveChat(context),
          ),
        ),
      ],
    );
  }

  Future<void> _launchEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: {
        'subject': 'Lynewed App Support Request',
      },
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          _showErrorSnackBar(context, 'Could not open email app');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Error opening email app');
      }
    }
  }

  void _openLiveChat(BuildContext context) {
    // TODO: Implement live chat functionality
    // For now, show a snackbar indicating feature coming soon
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Live chat coming soon!'),
        backgroundColor: LynewedColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  void _handleContactSubmit(
    BuildContext context,
    String subject,
    String message,
  ) {
    // TODO: Implement form submission to Supabase
    // For now, show a success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Message sent! We\'ll get back to you soon.'),
        backgroundColor: LynewedColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: LynewedColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
