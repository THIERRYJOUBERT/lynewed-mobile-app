// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
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
    _controller = YoutubePlayerController(
      initialVideoId:
          videoId ?? '', // Utilise l'ID, ou une chaîne vide si invalide
      flags: const YoutubePlayerFlags(
        autoPlay: true, // Lance la vidéo automatiquement
        mute: false, // Le son est activé par défaut
        forceHD: true, // Force la haute définition si disponible
        showLiveFullscreenButton:
            false, // Cache le bouton live pour les replays
        loop: false, // La vidéo ne se répète pas
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
    // Le widget YoutubePlayer est au cœur de l'affichage
    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true, // Affiche une barre de chargement
      progressIndicatorColor: FlutterFlowTheme.of(context).primary,
      progressColors: ProgressBarColors(
        playedColor: FlutterFlowTheme.of(context).primary,
        handleColor: FlutterFlowTheme.of(context).primary,
      ),
      onReady: () {
        // Optionnel : actions à effectuer quand le lecteur est prêt
        print('Player is ready.');
      },
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
