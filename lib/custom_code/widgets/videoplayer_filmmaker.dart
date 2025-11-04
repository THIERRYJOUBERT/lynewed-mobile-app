// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:video_player/video_player.dart';

class VideoplayerFilmmaker extends StatefulWidget {
  const VideoplayerFilmmaker({
    super.key,
    this.width,
    this.height,
    required this.videoUrl, // L'URL de la vidéo est le seul paramètre requis
  });

  final double? width;
  final double? height;
  final String videoUrl;

  @override
  _VideoplayerFilmmakerState createState() => _VideoplayerFilmmakerState();
}

class _VideoplayerFilmmakerState extends State<VideoplayerFilmmaker> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // On vérifie que l'URL n'est pas vide avant de tenter de l'initialiser
    if (widget.videoUrl.isNotEmpty) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
        ..initialize().then((_) {
          // Cette partie s'exécute une fois la vidéo chargée
          if (mounted) {
            // Configuration demandée : pas de son, en boucle, et lecture auto
            _controller.setVolume(0.0);
            _controller.setLooping(true);
            _controller.play();
            setState(() {
              _isInitialized = true;
            });
          }
        });
    }
  }

  @override
  void dispose() {
    // Il est crucial de libérer les ressources du contrôleur vidéo
    if (_isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si l'URL est vide ou si la vidéo n'est pas encore initialisée,
    // on affiche un simple conteneur noir avec un indicateur de chargement.
    if (!_isInitialized) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    // Une fois la vidéo prête, on l'affiche.
    // On l'enveloppe dans un SizedBox pour respecter les dimensions passées en paramètre
    // et dans un ClipRRect pour s'assurer qu'elle ne dépasse pas (par exemple si les coins sont arrondis).
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        child: OverflowBox(
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit
                .cover, // Assure que la vidéo remplit l'espace sans se déformer
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
