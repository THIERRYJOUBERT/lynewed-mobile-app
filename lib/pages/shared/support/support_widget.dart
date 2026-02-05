/// Support/Contact page - Clean Architecture
/// 
/// Unified contact support page for both Brides and Professionals.
/// Allows users to send support tickets with subject and message.
/// Tickets are stored in support_tickets table with status 'pending'.
/// 
/// DESIGN SYSTEM v3 APPLIED:
/// - Header: Back button (LynewedComponentStyles.backButton) + Title
/// - Divider under header (LynewedColors.gray200)
/// - Typography: LynewedTextStyles.sectionTitle for section headers
/// - Spacing: 30px inter-section, 10px label→content
/// - TextField: LynewedTextField with grey background (like wedding_create_sheet)
/// - Button: LynewedButton primary style
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '/backend/supabase/supabase.dart';
import '/backend/schema/enums/enums.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SupportWidget extends StatefulWidget {
  const SupportWidget({
    super.key,
    this.prefilledSubject,
    this.prefilledMessage,
  });

  /// Optional pre-filled subject for the support ticket
  /// Used when navigating from specific contexts (e.g., "Delete Account" for Pro)
  final String? prefilledSubject;

  /// Optional pre-filled message body for the support ticket.
  /// Used when navigating from specific contexts (e.g., magazine order details).
  final String? prefilledMessage;

  static String routeName = 'Support';
  static String routePath = '/support';

  @override
  State<SupportWidget> createState() => _SupportWidgetState();
}

class _SupportWidgetState extends State<SupportWidget> {
  late TextEditingController _otherSubjectController;
  late TextEditingController _messageController;
  
  String? _selectedSubject;
  bool _isLoading = false;

  // Subject visible only for Pro users requesting account deletion
  static const String _deleteAccountSubject = 'Request account deletion';

  static const List<String> _subjectOptions = [
    'Question about my account',
    'Report a bug',
    'Feature request',
    _deleteAccountSubject, // Pro-only, will be filtered in UI
    'Magazine order issue',
    'Other...'
  ];

  @override
  void initState() {
    super.initState();
    _otherSubjectController = TextEditingController();
    _messageController = TextEditingController();
    
    // Handle pre-filled subject from navigation
    if (widget.prefilledSubject != null) {
      _selectedSubject = widget.prefilledSubject;
    }
    if (widget.prefilledMessage != null) {
      _messageController.text = widget.prefilledMessage!;
    }
  }

  @override
  void dispose() {
    _otherSubjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _onSendPressed() async {
    // Validation du sujet
    String? finalSubject;
    if (_selectedSubject == null || _selectedSubject!.isEmpty) {
      _showSnackBar('Please select a subject', LynewedColors.warning);
      return;
    }

    if (_selectedSubject == 'Other...') {
      if (_otherSubjectController.text.trim().isEmpty) {
        _showSnackBar('Please describe your subject', LynewedColors.warning);
        return;
      }
      finalSubject = _otherSubjectController.text.trim();
    } else {
      finalSubject = _selectedSubject!;
    }

    // Validation du message
    if (_messageController.text.trim().isEmpty) {
      _showSnackBar('Please describe your request', LynewedColors.warning);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await SupportTicketsTable().insert({
        'profile_id': currentUserUid,
        'subject': finalSubject,
        'message': _messageController.text.trim(),
        'status': 'pending',
      });

      if (mounted) {
        _showSnackBar(
          'Your message has been sent. We will respond as soon as possible.',
          LynewedColors.success,
        );
        
        // Pop after short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'An error occurred. Please try again.',
          LynewedColors.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: LynewedColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header - Same style as MessagesPage
              _buildHeader(),
              
              // Divider - Same as LynewedSheet
              const Divider(height: 1, color: LynewedColors.gray200),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subject Section
                      const Text('Subject', style: LynewedTextStyles.sectionTitle),
                      const SizedBox(height: 12),
                      _buildSubjectDropdown(),
                      
                      // Other subject field (conditional)
                      if (_selectedSubject == 'Other...') ...[
                        const SizedBox(height: 20),
                        LynewedTextField(
                          controller: _otherSubjectController,
                          label: 'Describe your subject',
                          hint: 'Please describe...',
                          maxLines: 2,
                        ),
                      ],
                      
                      // Message Section
                      const SizedBox(height: 30),
                      LynewedTextField(
                        controller: _messageController,
                        label: 'Message',
                        hint: 'Describe your request in detail...',
                        maxLines: 8,
                      ),
                      
                      const SizedBox(height: 12),
                      Text(
                        'Or contact us directly at support@lynewed.com',
                        style: LynewedTextStyles.labelMedium.copyWith(
                          color: LynewedColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bottom Action - Same pattern as wedding_create_sheet
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: LynewedColors.gray200, width: 1),
                  ),
                ),
                child: LynewedButton(
                  text: 'Send',
                  onPressed: _isLoading ? null : _onSendPressed,
                  isLoading: _isLoading,
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Header with back button and title - Same style as MessagesPage
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      child: Row(
        children: [
          // Back button - Standard 44px tap target with 28px icon
          LynewedComponentStyles.backButton(context),
          
          const SizedBox(width: 4),
          
          // Title - Same style as LynewedSheet/MessagesPage
          Expanded(
            child: Text(
              'Contact Support',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  /// Subject dropdown with grey background - Same style as LynewedTextField
  Widget _buildSubjectDropdown() {
    // Filter options based on user role
    // "Delete account" option only visible for Pro users
    final isPro = FFAppState().currentUserRole == UserRole.professional;
    final filteredOptions = _subjectOptions.where((subject) {
      if (subject == _deleteAccountSubject) {
        return isPro; // Only show for Pro
      }
      return true;
    }).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2), // Same as LynewedTextField fillColor
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSubject,
          hint: Text(
            'Select a subject',
            style: LynewedTextStyles.inputHint,
          ),
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: LynewedColors.gray300,
          ),
          style: LynewedTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w300,
          ),
          dropdownColor: LynewedColors.background,
          items: filteredOptions.map((subject) {
            return DropdownMenuItem<String>(
              value: subject,
              child: Text(subject),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSubject = value;
              if (value != 'Other...') {
                _otherSubjectController.clear();
              }
            });
          },
        ),
      ),
    );
  }
}
