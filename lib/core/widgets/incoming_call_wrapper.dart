// lib/core/widgets/incoming_call_wrapper.dart
// Widget wrapper qui affiche l'overlay d'appel entrant au-dessus de tout contenu
// Version: 1.0.0
// Created: 2025-12-09

import 'package:flutter/material.dart';

import '/core/services/incoming_call_service.dart';
import '/core/widgets/incoming_call_overlay.dart';

/// Widget qui wrap le contenu de l'app et affiche l'overlay d'appel entrant
/// 
/// Ce widget écoute le ValueNotifier du IncomingCallService et affiche
/// automatiquement l'overlay quand un appel entrant est détecté.
/// 
/// Usage dans main.dart:
/// ```dart
/// MaterialApp(
///   builder: (context, child) => IncomingCallWrapper(child: child!),
/// )
/// ```
class IncomingCallWrapper extends StatelessWidget {
  final Widget child;

  const IncomingCallWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<IncomingCallData?>(
      valueListenable: IncomingCallService.instance.incomingCall,
      builder: (context, callData, _) {
        return Stack(
          children: [
            // Contenu principal de l'app
            child,
            
            // Overlay d'appel entrant (affiché seulement si callData != null)
            if (callData != null)
              IncomingCallOverlay(
                callData: callData,
                onAccept: IncomingCallService.instance.acceptCall,
                onDecline: IncomingCallService.instance.declineCall,
              ),
          ],
        );
      },
    );
  }
}
