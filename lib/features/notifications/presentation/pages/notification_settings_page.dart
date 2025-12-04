import 'package:flutter/material.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/core/design/design.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '../../domain/entities/notification_type_config.dart';

/// Page de paramètres des notifications - Design System v3.
/// 
/// Affiche les options de notifications selon le rôle de l'utilisateur
/// et son niveau d'abonnement.
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  static const String routeName = 'NotificationSettingsNew';
  static const String routePath = '/notificationSettingsNew';

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final Map<String, bool> _settings = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await SupaFlow.client
          .from('notification_settings')
          .select('notification_type, in_app_enabled')
          .eq('profile_id', currentUserUid);

      final settings = response as List<dynamic>;
      
      for (final setting in settings) {
        final type = setting['notification_type'] as String?;
        final enabled = setting['in_app_enabled'] as bool? ?? true;
        if (type != null) {
          _settings[type] = enabled;
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _updateSetting(String type, bool enabled) async {
    // Mise à jour optimiste
    setState(() {
      _settings[type] = enabled;
    });

    try {
      await actions.upsertNotificationSetting(type, enabled, enabled);
    } catch (e) {
      // Rollback en cas d'erreur
      setState(() {
        _settings[type] = !enabled;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update setting: $e'),
            backgroundColor: LynewedColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRole = FFAppState().currentUserRole;
    final subscriptionTier = FFAppState().selfProSubscription.subscriptionTier;
    
    final visibleTypes = NotificationTypesConfig.getVisibleTypes(
      role: userRole,
      subscriptionTier: subscriptionTier,
    );

    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1, color: LynewedColors.gray200),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildError()
                      : _buildSettingsList(visibleTypes, userRole ?? UserRole.bride),
            ),
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
            Text(
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

  Widget _buildSettingsList(List<NotificationTypeConfig> types, UserRole? userRole) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: types.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        indent: 20,
        endIndent: 20,
        color: LynewedColors.gray200,
      ),
      itemBuilder: (context, index) {
        final config = types[index];
        return _buildSettingTile(config, userRole);
      },
    );
  }

  Widget _buildSettingTile(NotificationTypeConfig config, UserRole? userRole) {
    final isEnabled = _settings[config.type] ?? true;
    
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
                  config.titleKey,
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  config.getDescription(userRole ?? UserRole.bride),
                  style: LynewedTextStyles.bodySmall.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Switch.adaptive(
            value: isEnabled,
            onChanged: (value) => _updateSetting(config.type, value),
            activeColor: LynewedColors.primary,
            activeTrackColor: LynewedColors.primary,
            inactiveTrackColor: LynewedColors.gray200,
            inactiveThumbColor: LynewedColors.surface,
          ),
        ],
      ),
    );
  }
}
