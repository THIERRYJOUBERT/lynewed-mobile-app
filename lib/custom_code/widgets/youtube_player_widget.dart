// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Importe la librairie nécessaire pour le lecteur YouTube
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerWidget extends StatefulWidget {
  const YoutubePlayerWidget({
    super.key,
    this.width,
    this.height,
    required this.youtubeUrl, // L'URL de la vidéo est un paramètre obligatoire
  });

  final double? width;
  final double? height;
  final String youtubeUrl;

  @override
  State<YoutubePlayerWidget> createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<YoutubePlayerWidget> {
  // Déclare le contrôleur qui va gérer la vidéo
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    // Tente de convertir l'URL YouTube en un ID de vidéo
    final videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl);

    // Initialise le contrôleur avec cet ID
    // Mode "background video": boucle, muet, sans contrôles
    _controller = YoutubePlayerController(
      initialVideoId:
          videoId ?? '', // Utilise l'ID, ou une chaîne vide si invalide
      flags: const YoutubePlayerFlags(
        autoPlay: true, // Lance la vidéo automatiquement
        mute: true, // Muet pour éviter les problèmes d'autoplay
        forceHD: true, // Force la haute définition si disponible
        showLiveFullscreenButton: false, // Cache le bouton live
        loop: true, // La vidéo se répète en boucle
        hideControls: true, // Cache tous les contrôles
        controlsVisibleAtStart: false, // Pas de contrôles au démarrage
        disableDragSeek: true, // Désactive le seek par drag
        enableCaption: false, // Pas de sous-titres
      ),
    );
  }

  @override
  void dispose() {
    // Il est très important de "disposer" le contrôleur pour libérer les ressources
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Le widget YoutubePlayer en mode background (sans contrôles, en boucle)
    return IgnorePointer(
      // Ignore tous les taps pour empêcher toute interaction
      child: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: false, // Pas de barre de progression
        onReady: () {
          debugPrint('YouTube Player is ready (background mode).');
        },
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
