# Story S25: Shared - Support Page

## Description

En tant que developpeur, je veux migrer la page Support vers Clean Architecture afin d'avoir une page d'aide coherente.

## Criteres d'Acceptance (Gherkin)

- [ ] Given `SupportWidget` When je la migre Then elle utilise le design system

- [ ] Given le formulaire de contact When je l'envoie Then le ticket est cree

- [ ] Given les FAQ When je les affiche Then elles sont accessibles

## Fichiers Concernes

### Pages Legacy a Migrer
- `lib/pages/shared/support/support_widget.dart`
- `lib/pages/shared/support/support_model.dart`

### A Creer
- `lib/features/support/support.dart` - Barrel
- `lib/features/support/presentation/pages/support_page.dart`
- `lib/features/support/presentation/widgets/faq_section.dart`
- `lib/features/support/presentation/widgets/contact_form.dart`

## Notes Techniques

### Support Page
```dart
class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  static const routeName = 'SupportPage';
  static const routePath = '/support';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'How can we help you?',
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            // Quick Actions
            _buildQuickActions(context),
            const SizedBox(height: 32),
            // FAQ Section
            Text(
              'Frequently Asked Questions',
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            const FAQSection(),
            const SizedBox(height: 32),
            // Contact Form
            Text(
              'Contact Us',
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            const ContactForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.email,
            title: 'Email Us',
            onTap: () => _sendEmail(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.chat,
            title: 'Live Chat',
            onTap: () => _openChat(context),
          ),
        ),
      ],
    );
  }

  void _sendEmail() {
    launchUrl(Uri.parse('mailto:support@lynewed.com'));
  }

  void _openChat(BuildContext context) {
    // Open support chat or external chat widget
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
```

### FAQ Section
```dart
class FAQSection extends StatelessWidget {
  const FAQSection({super.key});

  static const _faqs = [
    {
      'question': 'How do I contact a professional?',
      'answer': 'You can contact professionals by visiting their profile and clicking the "Contact" button.',
    },
    {
      'question': 'How do I update my wedding details?',
      'answer': 'Go to "My Wedding" section to update your wedding date, venue, and other details.',
    },
    // ... more FAQs
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _faqs.map((faq) => ExpansionTile(
        title: Text(faq['question']!),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(faq['answer']!),
          ),
        ],
      )).toList(),
    );
  }
}
```

### Contact Form
```dart
class ContactForm extends StatefulWidget {
  const ContactForm({super.key});

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // Submit support ticket to Supabase
      await Supabase.instance.client
          .from('support_tickets')
          .insert({
            'subject': _subjectController.text,
            'message': _messageController.text,
            'user_id': Supabase.instance.client.auth.currentUser?.id,
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent successfully')),
        );
        _subjectController.clear();
        _messageController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _subjectController,
            decoration: const InputDecoration(
              labelText: 'Subject',
              hintText: 'What is this about?',
            ),
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Message',
              hintText: 'Describe your issue or question...',
            ),
            maxLines: 5,
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 24),
          LynewedButton(
            text: 'Send Message',
            onPressed: _isSubmitting ? null : _submitForm,
            isLoading: _isSubmitting,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
```

## Definition of Done

- [ ] SupportPage migree et fonctionnelle
- [ ] FAQ section implementee
- [ ] Contact form fonctionnel
- [ ] Quick actions (email, chat)
- [ ] Tests
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 3
**Complexite** : Faible
**Risque** : Faible

## Dependances

- S03 : Design system
- S04 : Navigation

## Stories Dependantes

- Aucune
