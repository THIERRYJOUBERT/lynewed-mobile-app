# Story S24: Shared - Settings Pages

## Description

En tant que developpeur, je veux migrer les pages de settings vers Clean Architecture afin d'avoir une gestion des parametres coherente.

## Criteres d'Acceptance (Gherkin)

- [ ] Given `PreferenceWidget` When je la migre Then elle utilise le nouveau module settings

- [ ] Given `SettingsPermissionsWidget` When je la migre Then les permissions sont gerees proprement

- [ ] Given les settings When je les modifie Then ils sont sauvegardes correctement

- [ ] Given le logout When je clique Then l'utilisateur est deconnecte

## Fichiers Concernes

### Pages Legacy a Migrer
- `lib/pages/shared/preference/preference_widget.dart`
- `lib/pages/shared/preference/preference_model.dart`
- `lib/pages/shared/settings_permissions/settings_permissions_widget.dart`
- `lib/pages/shared/settings_permissions/settings_permissions_model.dart`

### A Creer
- `lib/features/settings/settings.dart` - Barrel export
- `lib/features/settings/presentation/pages/settings_page.dart`
- `lib/features/settings/presentation/pages/permissions_page.dart`
- `lib/features/settings/presentation/widgets/settings_tile.dart`

### Actions Custom Code a Integrer
- `lib/custom_code/actions/save_user_preferences.dart`

## Notes Techniques

### Structure Module Settings
```
lib/features/settings/
├── settings.dart                  # Barrel
├── domain/
│   ├── entities/
│   │   └── user_preferences.dart
│   └── repositories/
│       └── settings_repository.dart
├── data/
│   └── repositories/
│       └── settings_repository_impl.dart
└── presentation/
    ├── bloc/
    │   ├── settings_cubit.dart
    │   └── settings_state.dart
    ├── pages/
    │   ├── settings_page.dart
    │   └── permissions_page.dart
    └── widgets/
        └── settings_tile.dart
```

### Settings Page
```dart
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const routeName = 'SettingsPage';
  static const routePath = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account Section
          _buildSection(
            context,
            title: 'Account',
            children: [
              SettingsTile(
                icon: Icons.person,
                title: 'Edit Profile',
                onTap: () => _navigateToEditProfile(context),
              ),
              SettingsTile(
                icon: Icons.lock,
                title: 'Change Password',
                onTap: () => context.pushNamed(ResetPasswordPage.routeName),
              ),
            ],
          ),
          // Notifications Section
          _buildSection(
            context,
            title: 'Notifications',
            children: [
              SettingsTile(
                icon: Icons.notifications,
                title: 'Push Notifications',
                onTap: () => context.pushNamed(NotificationSettingsPage.routeName),
              ),
            ],
          ),
          // Privacy Section
          _buildSection(
            context,
            title: 'Privacy',
            children: [
              SettingsTile(
                icon: Icons.phonelink_lock,
                title: 'App Permissions',
                onTap: () => context.pushNamed(PermissionsPage.routeName),
              ),
              SettingsTile(
                icon: Icons.block,
                title: 'Blocked Users',
                onTap: () => BlockedUsersSheet.show(context),
              ),
            ],
          ),
          // Support Section
          _buildSection(
            context,
            title: 'Support',
            children: [
              SettingsTile(
                icon: Icons.help,
                title: 'Help & Support',
                onTap: () => context.pushNamed(SupportPage.routeName),
              ),
              SettingsTile(
                icon: Icons.description,
                title: 'Terms of Service',
                onTap: () => _openTerms(context),
              ),
              SettingsTile(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                onTap: () => _openPrivacyPolicy(context),
              ),
            ],
          ),
          // Danger Zone
          _buildSection(
            context,
            title: 'Account Actions',
            children: [
              SettingsTile(
                icon: Icons.logout,
                title: 'Log Out',
                isDestructive: false,
                onTap: () => _confirmLogout(context),
              ),
              SettingsTile(
                icon: Icons.delete_forever,
                title: 'Delete Account',
                isDestructive: true,
                onTap: () => _confirmDeleteAccount(context),
              ),
            ],
          ),
          // App Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Version ${_getAppVersion()}',
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colors.secondaryText,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    final state = context.read<AuthCubit>().state;
    if (state is Authenticated) {
      if (state.profile?.isBride == true) {
        context.pushNamed(EditProfileBridesPage.routeName);
      } else {
        context.pushNamed(EditProfileProPage.routeName);
      }
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthCubit>().signOut();
      context.goNamed(AuthWelcomePage.routeName);
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action is irreversible. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Implement delete account
      final authRepo = getIt<AuthRepository>();
      final result = await authRepo.deleteAccount();
      result.when(
        success: (_) {
          context.goNamed(AuthWelcomePage.routeName);
        },
        failure: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        },
      );
    }
  }
}
```

### Permissions Page
```dart
class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});

  static const routeName = 'PermissionsPage';
  static const routePath = '/settings/permissions';

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  Map<Permission, PermissionStatus> _permissions = {};

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final permissions = {
      Permission.camera: await Permission.camera.status,
      Permission.microphone: await Permission.microphone.status,
      Permission.photos: await Permission.photos.status,
      Permission.location: await Permission.location.status,
      Permission.notification: await Permission.notification.status,
    };
    setState(() => _permissions = permissions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Permissions'),
      ),
      body: ListView(
        children: [
          _buildPermissionTile(
            icon: Icons.camera_alt,
            title: 'Camera',
            subtitle: 'For taking photos and video calls',
            permission: Permission.camera,
          ),
          _buildPermissionTile(
            icon: Icons.mic,
            title: 'Microphone',
            subtitle: 'For voice messages and video calls',
            permission: Permission.microphone,
          ),
          _buildPermissionTile(
            icon: Icons.photo_library,
            title: 'Photo Library',
            subtitle: 'For accessing and uploading photos',
            permission: Permission.photos,
          ),
          _buildPermissionTile(
            icon: Icons.location_on,
            title: 'Location',
            subtitle: 'For finding nearby professionals',
            permission: Permission.location,
          ),
          _buildPermissionTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'For receiving messages and updates',
            permission: Permission.notification,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Permission permission,
  }) {
    final status = _permissions[permission];
    final isGranted = status?.isGranted ?? false;

    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isGranted
          ? const Icon(Icons.check_circle, color: Colors.green)
          : TextButton(
              onPressed: () => _requestPermission(permission),
              child: const Text('Enable'),
            ),
    );
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    _checkPermissions();
  }
}
```

## Definition of Done

- [ ] SettingsPage migree et fonctionnelle
- [ ] PermissionsPage migree et fonctionnelle
- [ ] Logout fonctionnel
- [ ] Delete account fonctionnel
- [ ] Links vers Terms/Privacy
- [ ] Tests
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Faible

## Dependances

- S03 : Design system
- S04 : Navigation
- S13 : Auth - Presentation

## Stories Dependantes

- Aucune
