/// Professional alert entity
/// 
/// Represents a community help alert from a professional.
/// New alert types defined in refactoring plan v1.7.
library;

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

/// Types d'alertes communautaires (entraide, pas rémunération)
enum AlertType {
  /// Besoin d'un remplaçant pour une date
  backupNeeded,
  
  /// Location de matériel urgent
  gearEmergency,
  
  /// Recherche second shooter ou assistant
  teamMember,
  
  /// Urgence événement (problème jour J)
  emergencyHelp;

  /// Label d'affichage
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
    }
  }

  /// Icône associée
  String get iconAsset {
    switch (this) {
      case AlertType.backupNeeded:
        return 'assets/icons/backup.png';
      case AlertType.gearEmergency:
        return 'assets/icons/gear.png';
      case AlertType.teamMember:
        return 'assets/icons/team.png';
      case AlertType.emergencyHelp:
        return 'assets/icons/emergency.png';
    }
  }

  /// Conversion depuis string Supabase
  static AlertType? fromString(String? value) {
    if (value == null) return null;
    // Support ancien motif_code et nouveau alert_type
    switch (value.toLowerCase()) {
      case 'backup_needed':
      case 'backup':
        return AlertType.backupNeeded;
      case 'gear_emergency':
      case 'gear':
        return AlertType.gearEmergency;
      case 'team_member':
      case 'team':
        return AlertType.teamMember;
      case 'emergency_help':
      case 'emergency':
        return AlertType.emergencyHelp;
      default:
        return null;
    }
  }
}

/// Alerte communautaire d'un professionnel
@immutable
class ProfessionalAlert {
  const ProfessionalAlert({
    required this.id,
    required this.professionalId,
    required this.type,
    required this.position,
    required this.eventDate,
    this.title,
    this.description,
    this.createdAt,
    this.expiresAt,
    this.professionalName,
    this.professionalAvatarUrl,
    this.profession,
  });

  /// UUID de l'alerte
  final String id;

  /// UUID du professionnel qui a créé l'alerte
  final String professionalId;

  /// Type d'alerte
  final AlertType type;

  /// Position GPS de l'événement
  final gmaps.LatLng position;

  /// Date de l'événement concerné
  final DateTime eventDate;

  /// Titre optionnel
  final String? title;

  /// Description détaillée
  final String? description;

  /// Date de création
  final DateTime? createdAt;

  /// Date d'expiration automatique (event_date + 1 jour)
  final DateTime? expiresAt;

  /// Nom du professionnel (pour affichage)
  final String? professionalName;

  /// Avatar du professionnel
  final String? professionalAvatarUrl;

  /// Profession du créateur
  final String? profession;

  /// Vérifie si l'alerte est expirée
  bool get isExpired {
    if (expiresAt != null) {
      return DateTime.now().isAfter(expiresAt!);
    }
    // Par défaut, expire 1 jour après l'événement
    return DateTime.now().isAfter(eventDate.add(const Duration(days: 1)));
  }

  /// Vérifie si l'alerte est active
  bool get isActive => !isExpired;

  ProfessionalAlert copyWith({
    String? id,
    String? professionalId,
    AlertType? type,
    gmaps.LatLng? position,
    DateTime? eventDate,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? professionalName,
    String? professionalAvatarUrl,
    String? profession,
  }) {
    return ProfessionalAlert(
      id: id ?? this.id,
      professionalId: professionalId ?? this.professionalId,
      type: type ?? this.type,
      position: position ?? this.position,
      eventDate: eventDate ?? this.eventDate,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      professionalName: professionalName ?? this.professionalName,
      professionalAvatarUrl: professionalAvatarUrl ?? this.professionalAvatarUrl,
      profession: profession ?? this.profession,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfessionalAlert && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ProfessionalAlert($id, $type, $eventDate)';
}
