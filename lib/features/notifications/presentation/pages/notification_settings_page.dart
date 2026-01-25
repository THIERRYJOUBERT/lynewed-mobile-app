/// NotificationSettingsPage - Clean Architecture
///
/// Page for managing notification preferences.
/// Uses NotificationRepository for data operations.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../domain/entities/notification_setting.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../data/repositories/notification_repository_impl.dart';

/// Page for managing notification settings.
///
/// Displays notification preferences and allows toggling each setting.
/// Uses Clean Architecture with [NotificationRepository].
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({
    this.repository,
    super.key,
  });

  /// Optional repository for testing.
  final NotificationRepository? repository;

  // Route constants for compatibility
  static const String routeName = 'NotificationSettings';
  static const String routePath = '/notificationSettings';

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  late final NotificationRepository _repository;

  List<NotificationSetting>? _settings;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? NotificationRepositoryImpl();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _repository.getSettings();

    result.fold(
      onSuccess: (settings) {
        setState(() {
          _settings = settings;
          _isLoading = false;
        });
      },
      onFailure: (failure) {
        setState(() {
          _error = failure.message;
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _toggleSetting(NotificationSetting setting) async {
    final newSetting = setting.copyWith(inAppEnabled: !setting.inAppEnabled);

    // Optimistic update
    setState(() {
      final index = _settings?.indexWhere((s) => s.id == setting.id);
      if (index != null && index >= 0 && _settings != null) {
        _settings![index] = newSetting;
      }
    });

    // Persist to backend
    final result = await _repository.updateSetting(newSetting);

    // Rollback on failure
    result.fold(
      onSuccess: (_) {
        // Success - already updated optimistically
      },
      onFailure: (failure) {
        // Rollback
        setState(() {
          final index = _settings?.indexWhere((s) => s.id == setting.id);
          if (index != null && index >= 0 && _settings != null) {
            _settings![index] = setting;
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update setting: ${failure.message}'),
              backgroundColor: LynewedColors.error,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1, color: LynewedColors.gray200),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.chevron_left,
              size: 28,
              color: LynewedColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'NOTIFICATIONS',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildError();
    }

    final settings = _settings;
    if (settings == null || settings.isEmpty) {
      return _buildEmptyState();
    }

    return _buildSettingsList(settings);
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: LynewedColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load settings',
              style: LynewedTextStyles.bodyLarge,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadSettings,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.settings_outlined,
              size: 64,
              color: LynewedColors.gray200,
            ),
            const SizedBox(height: 16),
            Text(
              'No settings available.',
              style: LynewedTextStyles.bodyLarge.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList(List<NotificationSetting> settings) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: settings.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        indent: 20,
        endIndent: 20,
        color: LynewedColors.gray200,
      ),
      itemBuilder: (context, index) {
        final setting = settings[index];
        return _buildSettingTile(setting);
      },
    );
  }

  Widget _buildSettingTile(NotificationSetting setting) {
    final title = _getTitleForType(setting.notificationType);
    final description = _getDescriptionForType(setting.notificationType);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: LynewedTextStyles.bodySmall.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Switch.adaptive(
            value: setting.inAppEnabled,
            onChanged: (_) => _toggleSetting(setting),
            activeColor: LynewedColors.primary,
            activeTrackColor: LynewedColors.primary,
            inactiveTrackColor: LynewedColors.gray200,
            inactiveThumbColor: LynewedColors.surface,
          ),
        ],
      ),
    );
  }

  String _getTitleForType(String type) {
    switch (type) {
      case 'chatMessage':
        return 'Messages';
      case 'connectionRequest':
        return 'Contact Requests';
      case 'connectionRequestAccepted':
        return 'Accepted Requests';
      case 'wishlistAdd':
        return 'Wishlist Updates';
      case 'videoIncoming':
        return 'Video Calls';
      case 'wedPublished':
        return 'Wedding of the Week';
      case 'replayPublished':
        return 'Replays';
      default:
        return type;
    }
  }

  String _getDescriptionForType(String type) {
    switch (type) {
      case 'chatMessage':
        return 'Receive notifications for new messages';
      case 'connectionRequest':
        return 'Receive notifications for new contact requests';
      case 'connectionRequestAccepted':
        return 'Receive notifications when your requests are accepted';
      case 'wishlistAdd':
        return 'Receive notifications when added to a wishlist';
      case 'videoIncoming':
        return 'Receive notifications for incoming video calls';
      case 'wedPublished':
        return 'Receive notifications for new Wedding of the Week';
      case 'replayPublished':
        return 'Receive notifications for new replays';
      default:
        return 'Notification preferences for $type';
    }
  }
}

/// Alias for testing - NotificationSettingsPageRefactored
/// This is the same as NotificationSettingsPage but with explicit repository param
typedef NotificationSettingsPageRefactored = NotificationSettingsPage;
