/// App Badge Service - iOS App Icon Badge Management
/// 
/// Singleton service that manages the iOS app icon badge count.
/// Combines unread messages + unread notifications for total badge.
/// 
/// Usage:
/// - Call AppBadgeService.instance.updateBadge() after updating counters
/// - Call AppBadgeService.instance.clearBadge() on logout
library;

import 'dart:io' show Platform;
import 'package:flutter_app_badger/flutter_app_badger.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Global service for managing iOS app icon badge
class AppBadgeService {
  AppBadgeService._();
  
  static final AppBadgeService instance = AppBadgeService._();
  
  bool _isSupported = false;
  bool _checkedSupport = false;

  /// Check if app badging is supported on this device
  Future<bool> _checkSupport() async {
    if (_checkedSupport) return _isSupported;
    
    try {
      // Only supported on iOS and some Android launchers
      if (Platform.isIOS || Platform.isAndroid) {
        _isSupported = await FlutterAppBadger.isAppBadgeSupported();
      }
    } catch (_) {
      _isSupported = false;
    }
    _checkedSupport = true;
    return _isSupported;
  }

  /// Update the app icon badge with total unread count
  /// Combines messages + notifications
  Future<void> updateBadge() async {
    if (!await _checkSupport()) return;
    
    try {
      final messagesCount = FFAppState().unreadMessagesCount;
      final notificationsCount = FFAppState().unreadNotificationsCount;
      final totalCount = messagesCount + notificationsCount;
      
      if (totalCount > 0) {
        await FlutterAppBadger.updateBadgeCount(totalCount);
      } else {
        await FlutterAppBadger.removeBadge();
      }
    } catch (_) {
      // Silently fail - badge is not critical
    }
  }

  /// Update badge with specific count (for manual override)
  Future<void> updateBadgeWithCount(int count) async {
    if (!await _checkSupport()) return;
    
    try {
      if (count > 0) {
        await FlutterAppBadger.updateBadgeCount(count);
      } else {
        await FlutterAppBadger.removeBadge();
      }
    } catch (_) {
      // Silently fail
    }
  }

  /// Clear the app icon badge (call on logout)
  Future<void> clearBadge() async {
    if (!await _checkSupport()) return;
    
    try {
      await FlutterAppBadger.removeBadge();
    } catch (_) {
      // Silently fail
    }
  }
}
