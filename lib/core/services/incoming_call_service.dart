// lib/core/services/incoming_call_service.dart
// Service singleton pour gérer l'affichage des appels entrants
// Version: 2.0.0 - Utilise ValueNotifier pour une approche réactive
// Created: 2025-12-09

import 'dart:async';

import 'package:flutter/material.dart';

import '/utils/secure_logger.dart';

/// Données d'un appel entrant
class IncomingCallData {
  final String videoSessionId;
  final String channelName;
  final String callerProfileId;
  final String callerName;
  final String? callerAvatarUrl;
  final DateTime receivedAt;

  IncomingCallData({
    required this.videoSessionId,
    required this.channelName,
    required this.callerProfileId,
    required this.callerName,
    this.callerAvatarUrl,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  /// Crée depuis le payload FCM
  factory IncomingCallData.fromFcmPayload(Map<String, dynamic> data) {
    return IncomingCallData(
      videoSessionId: data['video_session_id'] as String? ?? '',
      channelName: data['agora_channel_name'] as String? ?? '',
      callerProfileId: data['sender_profile_id'] as String? ?? '',
      callerName: data['sender_full_name'] as String? ?? 'Unknown',
      callerAvatarUrl: data['sender_avatar_url'] as String?,
    );
  }

  /// Vérifie si l'appel est encore valide (< 60 secondes)
  bool get isValid {
    final age = DateTime.now().difference(receivedAt);
    return age.inSeconds < 60;
  }
}

/// Service singleton pour gérer les appels entrants
/// 
/// Utilise un ValueNotifier pour notifier les widgets de l'état de l'appel.
/// Le widget IncomingCallWrapper écoute ce notifier et affiche l'overlay.
class IncomingCallService {
  IncomingCallService._();
  static final IncomingCallService _instance = IncomingCallService._();
  static IncomingCallService get instance => _instance;

  /// ValueNotifier pour l'appel en cours - les widgets écoutent ceci
  final ValueNotifier<IncomingCallData?> incomingCall = ValueNotifier(null);

  /// Timer pour auto-dismiss après 30 secondes
  Timer? _autoDismissTimer;

  /// Callback appelé quand l'utilisateur accepte l'appel
  void Function(IncomingCallData call)? onAccept;

  /// Callback appelé quand l'utilisateur décline l'appel
  void Function(IncomingCallData call)? onDecline;

  /// Callback appelé quand l'appel expire (timeout)
  void Function(IncomingCallData call)? onTimeout;

  /// Vérifie si un appel est actuellement affiché
  bool get isShowing => incomingCall.value != null;

  /// Données de l'appel en cours
  IncomingCallData? get currentCall => incomingCall.value;

  /// Affiche l'overlay d'appel entrant
  /// 
  /// Cette méthode met à jour le ValueNotifier, ce qui déclenche
  /// automatiquement l'affichage de l'overlay via IncomingCallWrapper
  void showIncomingCall(IncomingCallData callData) {
    SecureLogger.info('IncomingCallService: Showing incoming call overlay');

    // Si un appel est déjà affiché, le fermer d'abord
    if (incomingCall.value != null) {
      SecureLogger.debug('Dismissing existing call overlay');
      dismiss();
    }

    // Mettre à jour le notifier - ceci déclenche l'affichage
    incomingCall.value = callData;

    // Démarrer le timer d'auto-dismiss (30 secondes)
    _autoDismissTimer?.cancel();
    _autoDismissTimer = Timer(const Duration(seconds: 30), () {
      SecureLogger.info('IncomingCallService: Call timed out');
      _handleTimeout();
    });

    SecureLogger.debug('Incoming call notifier updated');
  }

  /// Ferme l'overlay d'appel entrant
  void dismiss() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;

    incomingCall.value = null;

    SecureLogger.debug('Incoming call dismissed');
  }

  /// Appelé quand l'utilisateur accepte l'appel
  void acceptCall() {
    final call = incomingCall.value;
    dismiss();

    if (call != null && onAccept != null) {
      SecureLogger.info('IncomingCallService: Call accepted');
      onAccept!(call);
    }
  }

  /// Appelé quand l'utilisateur décline l'appel
  void declineCall() {
    final call = incomingCall.value;
    dismiss();

    if (call != null && onDecline != null) {
      SecureLogger.info('IncomingCallService: Call declined');
      onDecline!(call);
    }
  }

  /// Gère le timeout de l'appel
  void _handleTimeout() {
    final call = incomingCall.value;
    dismiss();

    if (call != null && onTimeout != null) {
      onTimeout!(call);
    }
  }

  /// Nettoie les ressources
  void dispose() {
    dismiss();
    onAccept = null;
    onDecline = null;
    onTimeout = null;
  }
}
