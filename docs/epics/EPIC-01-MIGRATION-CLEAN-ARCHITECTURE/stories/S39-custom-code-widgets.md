# Story S39: Custom Code - Widgets Migration

## Description

En tant que developpeur, je veux migrer les widgets custom de custom_code vers les modules correspondants afin d'eliminer le code legacy.

## Criteres d'Acceptance (Gherkin)

- [ ] Given les widgets dans custom_code When je les migre Then ils sont dans les features

- [ ] Given les imports des widgets When je les mets a jour Then aucune erreur de compilation

- [ ] Given les fonctionnalites When je les teste Then tout fonctionne identiquement

## Fichiers Concernes

### Widgets a Migrer
```
lib/custom_code/widgets/
├── chat_composer_widget.dart     → features/chat/presentation/widgets/
├── chat_message_list.dart        → features/chat/presentation/widgets/
├── audio_player_widget.dart      → features/chat/presentation/widgets/
├── audio_recorder_widget.dart    → features/chat/presentation/widgets/
├── videoplayer_filmmaker.dart    → features/content/presentation/widgets/
├── vimeo_player_widget.dart      → features/content/presentation/widgets/
├── youtube_player_widget.dart    → features/content/presentation/widgets/
├── youtube_player_with_controls.dart → features/content/presentation/widgets/
├── agora_video_view.dart         → features/video_call/presentation/widgets/
├── lynewed_mini_map.dart         → features/map/presentation/widgets/
├── portfolio_grid.dart           → features/feed/presentation/widgets/
├── feed_portfolio_grid.dart      → features/feed/presentation/widgets/
├── wed_article_renderer.dart     → features/content/presentation/widgets/
```

## Notes Techniques

### Migration Pattern
1. Copier le widget vers le module cible
2. Adapter les imports
3. Nettoyer le code (FlutterFlow patterns -> Clean)
4. Mettre a jour les references
5. Supprimer l'original

### Exemple: Audio Player Widget
```dart
// AVANT: lib/custom_code/widgets/audio_player_widget.dart
// Code FlutterFlow avec pattern specifique

// APRES: lib/features/chat/presentation/widgets/audio_player_widget.dart
class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final Duration? duration;

  const AudioPlayerWidget({
    required this.audioUrl,
    this.duration,
    super.key,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _player = AudioPlayer();
    await _player.setUrl(widget.audioUrl);

    _player.positionStream.listen((position) {
      setState(() => _position = position);
    });

    _player.durationStream.listen((duration) {
      setState(() => _duration = duration ?? widget.duration ?? Duration.zero);
    });

    _player.playerStateStream.listen((state) {
      setState(() => _isPlaying = state.playing);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              if (_isPlaying) {
                _player.pause();
              } else {
                _player.play();
              }
            },
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: _position.inMilliseconds.toDouble(),
                  max: _duration.inMilliseconds.toDouble(),
                  onChanged: (value) {
                    _player.seek(Duration(milliseconds: value.toInt()));
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(_position)),
                    Text(_formatDuration(_duration)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
```

### Checklist Migration
| Widget | Source | Destination | Status |
|--------|--------|-------------|--------|
| chat_composer_widget | custom_code | features/chat | TODO |
| chat_message_list | custom_code | features/chat | TODO |
| audio_player_widget | custom_code | features/chat | TODO |
| audio_recorder_widget | custom_code | features/chat | TODO |
| videoplayer_filmmaker | custom_code | features/content | TODO |
| vimeo_player_widget | custom_code | features/content | TODO |
| youtube_player_widget | custom_code | features/content | TODO |
| agora_video_view | custom_code | features/video_call | TODO |
| lynewed_mini_map | custom_code | features/map | TODO |
| portfolio_grid | custom_code | features/feed | TODO |
| feed_portfolio_grid | custom_code | features/feed | TODO |
| wed_article_renderer | custom_code | features/content | TODO |

## Definition of Done

- [ ] Tous les widgets migres
- [ ] Code nettoye (patterns Clean)
- [ ] Imports mis a jour partout
- [ ] Fichiers originaux supprimes
- [ ] Tests widgets
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Faible

## Dependances

- Modules features correspondants

## Stories Dependantes

- S41 : FlutterFlow cleanup
