/// Alert details entity for map marker details
/// 
/// Complete alert data for display in details sheet.
/// Replaces FlutterFlow's AlertItemDataStruct with clean, immutable class.
library;

import 'package:flutter/foundation.dart';
import 'professional_details.dart';

/// Alert details for map marker sheet
@immutable
class AlertDetails {
  const AlertDetails({
    required this.id,
    required this.alertType,
    this.motifCode,
    this.motifLabel,
    this.message,
    this.locationLabel,
    this.startAt,
    this.endAt,
    required this.authorId,
    this.authorAvatarUrl,
    this.authorFullName,
    this.authorProfession,
    this.isOwn = false,
    this.isContactable = false,
  });

  final String id;
  final AlertType alertType;
  final String? motifCode;
  final String? motifLabel;
  final String? message;
  final String? locationLabel;
  final DateTime? startAt;
  final DateTime? endAt;
  final String authorId;
  final String? authorAvatarUrl;
  final String? authorFullName;
  final Profession? authorProfession;
  final bool isOwn;
  final bool isContactable;

  /// Display title (motif label or alert type)
  String get displayTitle => motifLabel ?? alertType.displayName;

  /// Is active (not expired)
  bool get isActive {
    if (endAt == null) return true;
    return DateTime.now().isBefore(endAt!);
  }

  /// Is expired
  bool get isExpired => !isActive;

  /// Time remaining formatted
  String? get timeRemaining {
    if (endAt == null) return null;
    final remaining = endAt!.difference(DateTime.now());
    if (remaining.isNegative) return 'Expired';
    if (remaining.inDays > 0) return '${remaining.inDays}d remaining';
    if (remaining.inHours > 0) return '${remaining.inHours}h remaining';
    return '${remaining.inMinutes}m remaining';
  }

  /// Factory from Supabase RPC response
  factory AlertDetails.fromJson(Map<String, dynamic> json) {
    return AlertDetails(
      id: json['alertId']?.toString() ?? '',
      alertType: AlertType.fromString(json['alertType']?.toString() ?? json['motifCode']?.toString()),
      motifCode: json['motifCode']?.toString(),
      motifLabel: json['motifLabel']?.toString(),
      message: json['message']?.toString(),
      locationLabel: json['locationLabel']?.toString(),
      startAt: _parseDateTime(json['startAt']),
      endAt: _parseDateTime(json['endAt']),
      authorId: json['authorProfileId']?.toString() ?? '',
      authorAvatarUrl: json['authorAvatarUrl']?.toString(),
      authorFullName: json['authorFullName']?.toString(),
      authorProfession: json['authorProfession'] != null
          ? Profession.fromString(json['authorProfession'].toString())
          : null,
      isOwn: json['isOwn'] == true,
      isContactable: json['isContactable'] == true,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      final normalized = value.replaceAll('"', '').trim();
      if (normalized.isEmpty) return null;
      return DateTime.tryParse(normalized);
    }
    return DateTime.tryParse(value.toString());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AlertDetails && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Alert type enum (clean version matching plan v1.7)
enum AlertType {
  backupNeeded,
  gearEmergency,
  teamMember,
  emergencyHelp,
  other;

  String get displayName {
    switch (this) {
      case AlertType.backupNeeded:
        return 'Backup Needed';
      case AlertType.gearEmergency:
        return 'Gear Emergency';
      case AlertType.teamMember:
        return 'Team Member';
      case AlertType.emergencyHelp:
        return 'Emergency Help';
      case AlertType.other:
        return 'Other';
    }
  }

  String get description {
    switch (this) {
      case AlertType.backupNeeded:
        return 'Looking for a replacement for a date';
      case AlertType.gearEmergency:
        return 'Need to rent equipment';
      case AlertType.teamMember:
        return 'Looking for a second shooter or assistant';
      case AlertType.emergencyHelp:
        return 'Urgent help needed at event';
      case AlertType.other:
        return 'Other assistance needed';
    }
  }

  String get iconAsset {
    switch (this) {
      case AlertType.backupNeeded:
        return 'assets/icons/backup.svg';
      case AlertType.gearEmergency:
        return 'assets/icons/gear.svg';
      case AlertType.teamMember:
        return 'assets/icons/team.svg';
      case AlertType.emergencyHelp:
        return 'assets/icons/emergency.svg';
      case AlertType.other:
        return 'assets/icons/alert.svg';
    }
  }

  static AlertType fromString(String? value) {
    if (value == null) return AlertType.other;
    final normalized = value.toLowerCase().replaceAll('_', '');
    switch (normalized) {
      case 'backupneeded':
      case 'backup':
        return AlertType.backupNeeded;
      case 'gearemergency':
      case 'gear':
        return AlertType.gearEmergency;
      case 'teammember':
      case 'team':
        return AlertType.teamMember;
      case 'emergencyhelp':
      case 'emergency':
        return AlertType.emergencyHelp;
      default:
        return AlertType.other;
    }
  }
}
