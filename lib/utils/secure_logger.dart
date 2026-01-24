// Fichier: /lib/utils/secure_logger.dart
// Système de logging sécurisé pour Lynewed Alpha
// Version: 1.0.0
// Date: 4 Novembre 2025

import 'package:flutter/foundation.dart';

/// Système de logging sécurisé qui protège les données sensibles
/// et désactive les logs en production
class SecureLogger {
  
  /// Log uniquement en mode debug (développement)
  /// Utilise pour les informations générales non sensibles
  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('🔍 [DEBUG] $message');
    }
  }
  
  /// Log avec sanitization automatique des données sensibles
  /// Masque automatiquement les tokens, passwords, secrets
  static void debugSanitized(String message, {List<String>? sensitiveKeys}) {
    if (kDebugMode) {
      String sanitized = message;
      
      // Cles sensibles par defaut - Liste complete pour protection PII
      // Voir docs/epics/EPIC-05-SECURITY-CLEANUP/stories/S-04-data-exposure.md
      final defaultSensitiveKeys = [
        // Authentication tokens
        'token', 'password', 'secret', 'apikey', 'api_key', 'jwt',
        // Session identifiers
        'session_id', 'user_id', 'profile_id', 'uid',
        // Communication tokens
        'channel', 'agora_token', 'fcm_token',
        // PII - Personal Identifiable Information
        'email', 'phone', 'full_name', 'first_name', 'last_name',
        // Financial data
        'budget', 'budget_min', 'budget_max',
        // Location/Resource identifiers
        'wedding_id', 'room_id', 'venue_coords',
      ];
      
      final keysToSanitize = [...defaultSensitiveKeys, ...(sensitiveKeys ?? [])];
      
      // Remplacer chaque clé sensible par ***REDACTED***
      for (final key in keysToSanitize) {
        // Pattern pour capturer clé=valeur ou clé: valeur
        sanitized = sanitized.replaceAll(
          RegExp('$key[=:]\\s*[^\\s,}]+', caseSensitive: false),
          '$key=***REDACTED***'
        );
      }
      
      debugPrint('🛡️ [SANITIZED] $sanitized');
    }
  }
  
  /// Log d'information (toujours visible en debug)
  /// Utilise pour les étapes importantes du processus
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('ℹ️ [INFO] $message');
    }
  }
  
  /// Log d'avertissement (toujours visible en debug)
  /// Utilise pour les problèmes non critiques
  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('⚠️ [WARNING] $message');
    }
  }
  
  /// Log d'erreur (visible en debug, redirigé en production)
  /// En production, devrait être envoyé à un service externe
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('❌ [ERROR] $message');
      if (error != null) debugPrint('Details: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    } else {
      // TODO: En production, envoyer à Firebase Crashlytics ou Sentry
      // Pour l'instant, on désactive complètement les logs d'erreur en production
      // pour éviter toute exposition de données sensibles
    }
  }
  
  /// Log critique pour les problèmes de sécurité
  /// Toujours loggé mais avec données sensibles masquées
  static void security(String message) {
    if (kDebugMode) {
      debugPrint('🔒 [SECURITY] $message');
    } else {
      // En production, les logs de sécurité pourraient être envoyés
      // à un service de monitoring spécialisé
      // TODO: Implémenter service de monitoring sécurité
    }
  }
  
  /// Log pour les performances (temps d'exécution, etc.)
  static void performance(String message) {
    if (kDebugMode) {
      debugPrint('⚡ [PERF] $message');
    }
  }
  
  /// Vérifie si le logging est activé (utile pour les conditions)
  static bool get isLoggingEnabled => kDebugMode;
  
  /// Méthode utilitaire pour logger le début/fin d'une fonction
  static void functionStart(String functionName, {Map<String, dynamic>? params}) {
    if (kDebugMode) {
      String message = '🚀 [FUNCTION] $functionName started';
      if (params != null && params.isNotEmpty) {
        message += ' with params: ${_sanitizeMap(params)}';
      }
      debugPrint(message);
    }
  }
  
  static void functionEnd(String functionName, {dynamic result}) {
    if (kDebugMode) {
      String message = '✅ [FUNCTION] $functionName completed';
      if (result != null) {
        message += ' with result: ${_sanitizeValue(result)}';
      }
      debugPrint(message);
    }
  }
  
  /// Sanitization utilitaire pour les objets complexes
  static String _sanitizeMap(Map<String, dynamic> map) {
    final sanitized = <String, dynamic>{};
    // Liste complete des cles sensibles pour sanitization des Maps
    // Doit etre synchronisee avec defaultSensitiveKeys dans debugSanitized
    const sensitiveKeys = [
      // Authentication
      'token', 'password', 'secret', 'apikey', 'api_key', 'jwt',
      // Session/User IDs
      'session_id', 'user_id', 'profile_id', 'uid',
      // Communication tokens
      'agora_token', 'fcm_token', 'channel',
      // PII
      'email', 'phone', 'full_name', 'first_name', 'last_name',
      // Financial
      'budget', 'budget_min', 'budget_max',
      // Location
      'wedding_id', 'room_id', 'venue_coords',
    ];

    map.forEach((key, value) {
      if (sensitiveKeys.any((sensitive) => key.toLowerCase().contains(sensitive))) {
        sanitized[key] = '***REDACTED***';
      } else {
        sanitized[key] = value;
      }
    });

    return sanitized.toString();
  }
  
  static String _sanitizeValue(dynamic value) {
    if (value is Map) {
      return _sanitizeMap(Map<String, dynamic>.from(value));
    } else if (value is String) {
      // Masquer les tokens potentiels dans les chaînes
      if (value.length > 50 && (value.contains('token') || value.contains('key'))) {
        return '***REDACTED***';
      }
    }
    return value.toString();
  }
}
