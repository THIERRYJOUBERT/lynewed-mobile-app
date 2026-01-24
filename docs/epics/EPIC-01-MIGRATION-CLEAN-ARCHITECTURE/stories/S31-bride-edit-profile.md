# Story S31: Bride - Edit Profile

## Description

En tant que developpeur, je veux migrer la page Edit Profile Bride vers Clean Architecture afin d'avoir une edition de profil coherente.

## Criteres d'Acceptance (Gherkin)

- [ ] Given `EditProfileBridesWidget` When je la migre Then elle utilise AuthCubit

- [ ] Given les champs du profil When je les modifie Then ils sont sauvegardes

- [ ] Given l'avatar When je le change Then il est uploade et mis a jour

## Fichiers Concernes

### Pages Legacy a Migrer
- `lib/pages/bride/edit_profile_brides/edit_profile_brides_widget.dart`
- `lib/pages/bride/edit_profile_brides/edit_profile_brides_model.dart`

### A Creer
- `lib/features/profile/presentation/pages/edit_profile_brides_page.dart`
- `lib/features/profile/presentation/widgets/avatar_picker.dart`

## Notes Techniques

### Edit Profile Page
```dart
class EditProfileBridesPage extends StatefulWidget {
  const EditProfileBridesPage({super.key});

  static const routeName = 'EditProfileBrides';
  static const routePath = '/editProfileBrides';

  @override
  State<EditProfileBridesPage> createState() => _EditProfileBridesPageState();
}

class _EditProfileBridesPageState extends State<EditProfileBridesPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  String? _avatarUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthCubit>().state;
    if (state is Authenticated) {
      _nameController = TextEditingController(text: state.profile?.displayName);
      _bioController = TextEditingController(text: state.profile?.bio);
      _avatarUrl = state.profile?.avatarUrl;
    } else {
      _nameController = TextEditingController();
      _bioController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );

    if (image == null) return;

    setState(() => _isLoading = true);

    try {
      final bytes = await image.readAsBytes();
      final authRepo = getIt<AuthRepository>();
      final result = await authRepo.uploadAvatar(bytes, image.name);

      result.when(
        success: (url) {
          setState(() {
            _avatarUrl = url;
            _isLoading = false;
          });
        },
        failure: (error) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authRepo = getIt<AuthRepository>();
    final result = await authRepo.updateProfile(UpdateProfileParams(
      displayName: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      avatarUrl: _avatarUrl,
    ));

    result.when(
      success: (_) {
        // Refresh auth state
        context.read<AuthCubit>().checkAuthStatus();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
      },
      failure: (error) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar
              AvatarPicker(
                avatarUrl: _avatarUrl,
                onPick: _pickAvatar,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 32),
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  hintText: 'How should we call you?',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Bio
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Tell us about yourself...',
                ),
                maxLines: 3,
                maxLength: 150,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Avatar Picker Widget
```dart
class AvatarPicker extends StatelessWidget {
  final String? avatarUrl;
  final VoidCallback onPick;
  final bool isLoading;

  const AvatarPicker({
    this.avatarUrl,
    required this.onPick,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPick,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: avatarUrl != null
                ? NetworkImage(avatarUrl!)
                : null,
            child: avatarUrl == null
                ? const Icon(Icons.person, size: 48)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.primary,
                shape: BoxShape.circle,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Definition of Done

- [ ] EditProfileBridesPage migree
- [ ] AvatarPicker widget
- [ ] Upload avatar fonctionnel
- [ ] Save profile fonctionnel
- [ ] Validation formulaire
- [ ] Tests
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 3
**Complexite** : Faible
**Risque** : Faible

## Dependances

- S03 : Design system
- S12 : Auth - Data (upload avatar)
- S23 : Profile pages

## Stories Dependantes

- Aucune
