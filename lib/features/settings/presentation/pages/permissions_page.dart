/// Permissions page.
///
/// Displays device permissions status and allows requesting permissions:
/// - Camera (for taking photos)
/// - Microphone (for audio messages and video calls)
/// - Photos (for selecting images)
/// - Location (for map and nearby searches)
/// - Notifications (for push notifications)
library;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '/core/design/design.dart';
import '../widgets/settings_tile.dart';

/// Enumeration of permission types managed by this page.
enum PermissionType {
  camera,
  microphone,
  photos,
  location,
  notification,
}

/// The permissions page showing device permission status and controls.
///
/// Displays all required app permissions with their current status.
/// Tapping a permission will request it if not granted.
class PermissionsPage extends StatefulWidget {
  /// Route name for navigation.
  static const String routeName = 'permissions';

  /// Route path for navigation.
  static const String routePath = '/permissions';

  /// Creates a permissions page.
  const PermissionsPage({super.key});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage>
    with WidgetsBindingObserver {
  /// Map of permission status for each type.
  Map<PermissionType, PermissionStatus> _permissionStatuses = {};

  /// Whether permissions are being loaded.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh permissions when returning from settings
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  /// Check the status of all permissions.
  Future<void> _checkPermissions() async {
    setState(() => _isLoading = true);

    final statuses = <PermissionType, PermissionStatus>{};

    statuses[PermissionType.camera] = await Permission.camera.status;
    statuses[PermissionType.microphone] = await Permission.microphone.status;
    statuses[PermissionType.photos] = await Permission.photos.status;
    statuses[PermissionType.location] = await Permission.location.status;
    statuses[PermissionType.notification] = await Permission.notification.status;

    if (mounted) {
      setState(() {
        _permissionStatuses = statuses;
        _isLoading = false;
      });
    }
  }

  /// Request a specific permission.
  Future<void> _requestPermission(PermissionType type) async {
    final Permission permission = _getPermission(type);
    final status = await permission.request();

    // If permanently denied, open app settings
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }

    // Refresh statuses
    await _checkPermissions();
  }

  /// Get the Permission object for a permission type.
  Permission _getPermission(PermissionType type) {
    return switch (type) {
      PermissionType.camera => Permission.camera,
      PermissionType.microphone => Permission.microphone,
      PermissionType.photos => Permission.photos,
      PermissionType.location => Permission.location,
      PermissionType.notification => Permission.notification,
    };
  }

  /// Get the icon for a permission type.
  IconData _getIcon(PermissionType type) {
    return switch (type) {
      PermissionType.camera => Icons.camera_alt_outlined,
      PermissionType.microphone => Icons.mic_outlined,
      PermissionType.photos => Icons.photo_library_outlined,
      PermissionType.location => Icons.location_on_outlined,
      PermissionType.notification => Icons.notifications_outlined,
    };
  }

  /// Get the title for a permission type.
  String _getTitle(PermissionType type) {
    return switch (type) {
      PermissionType.camera => 'Camera',
      PermissionType.microphone => 'Microphone',
      PermissionType.photos => 'Photos',
      PermissionType.location => 'Location',
      PermissionType.notification => 'Notifications',
    };
  }

  /// Get the description for a permission type.
  String _getDescription(PermissionType type) {
    return switch (type) {
      PermissionType.camera =>
        'Take photos for your profile, portfolio, or chat',
      PermissionType.microphone =>
        'Record audio messages and use video calls',
      PermissionType.photos =>
        'Select images from your photo library',
      PermissionType.location =>
        'Enable the map and nearby professional searches',
      PermissionType.notification =>
        'Receive alerts for messages and important activities',
    };
  }

  /// Get the trailing widget for a permission status.
  Widget _getTrailingWidget(PermissionStatus? status) {
    if (status == null) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (status.isGranted || status == PermissionStatus.limited) {
      return const Icon(
        Icons.check_circle,
        color: LynewedColors.success,
        size: 20,
      );
    }

    return const Icon(
      Icons.chevron_right,
      color: LynewedColors.textSecondary,
      size: 20,
    );
  }

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
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          LynewedColors.primary,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Device Permissions'),
                          const SizedBox(height: 8.0),
                          Text(
                            'These permissions help the app provide its full functionality.',
                            style: LynewedTextStyles.bodySmall.copyWith(
                              color: LynewedColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          ...PermissionType.values.map(_buildPermissionTile),
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
            'Permissions',
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

  Widget _buildPermissionTile(PermissionType type) {
    final status = _permissionStatuses[type];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SettingsTile(
        icon: _getIcon(type),
        title: _getTitle(type),
        subtitle: _getDescription(type),
        trailing: _getTrailingWidget(status),
        onTap: () => _requestPermission(type),
      ),
    );
  }
}
