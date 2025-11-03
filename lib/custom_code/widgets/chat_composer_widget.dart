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

import '/custom_code/actions/index.dart'; // Imports other custom actions

import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart'; // AudioRecorderWidget
import 'dart:typed_data';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ChatComposerWidget extends StatefulWidget {
  const ChatComposerWidget({
    Key? key,
    this.width,
    this.height,
    this.viewerRole,
    required this.isPublic,
    this.pendingRequestId,
    this.roomId,
    this.targetProfileId,
    this.onRoomCreated,
    this.onError,
    // Nouveaux paramètres pour la logique de premier contact
    this.isRoomEmpty,
    this.firstMessageTextOnly,
  }) : super(key: key);

  final double? width;
  final double? height;
  final UserRole? viewerRole;
  final bool isPublic;
  final String? pendingRequestId;
  final String? roomId;
  final String? targetProfileId;
  final Future<dynamic> Function(String? newRoomId, String? newRequestId)?
      onRoomCreated;
  final Future<dynamic> Function(String message)? onError;
  // Nouveaux paramètres
  final bool? isRoomEmpty;
  final bool? firstMessageTextOnly;

  @override
  State<ChatComposerWidget> createState() => _ChatComposerWidgetState();
}

class _ChatComposerWidgetState extends State<ChatComposerWidget> {
  final _textCtl = TextEditingController();
  final _textFocus = FocusNode();

  final ImagePicker _picker = ImagePicker();
  List<FFUploadedFile> _pendingImages = [];

  bool _isSelectingImages = false;
  bool _isRecordingAudio = false;
  FFUploadedFile? _audioPreviewFile;

  bool _isSending = false;
  bool _hasFocus = false;

  UserRole get _role => widget.viewerRole ?? UserRole.bride;
  bool get _hasRoom => (widget.roomId != null && widget.roomId!.isNotEmpty);
  bool get _hasText => _textCtl.text.trim().isNotEmpty;
  bool get _hasImages => _pendingImages.isNotEmpty;
  bool get _hasAudio => (_audioPreviewFile?.bytes?.isNotEmpty ?? false);

  // *** LOGIQUE DE VERROUILLAGE MISE A JOUR ***
  // Le widget est verrouillé si la conversation est publique pour un Pro,
  // OU si une demande de contact est en attente.
  bool get _locked {
    if (widget.isPublic && _role != UserRole.bride) return true;
    if (widget.pendingRequestId != null && widget.pendingRequestId!.isNotEmpty)
      return true;
    return false;
  }

  bool get _isRoomEmptyFlag => widget.isRoomEmpty == true;
  bool get _firstTextOnly => widget.firstMessageTextOnly == true;

  bool get _hasAnyContent => _hasAudio || _hasImages || _hasText;

  @override
  void initState() {
    super.initState();
    _textFocus.addListener(() {
      if (mounted) setState(() => _hasFocus = _textFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _textFocus.dispose();
    _textCtl.dispose();
    super.dispose();
  }

  String _i18n(String en, String fr) {
    final isFr = FFLocalizations.of(context).languageCode.toLowerCase() == 'fr';
    return isFr ? fr : en;
  }

  Future<void> _emitError(String msg) async {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: FlutterFlowTheme.of(context).accent2,
      ),
    );
    if (widget.onError != null) {
      await widget.onError!(msg);
    }
  }

  Future<void> _pickImages() async {
    if (_isSelectingImages || _locked || _isRecordingAudio) return;

    // *** NOUVELLE REGLE ***
    // Si la room est vide et que le premier message doit être du texte, on bloque la sélection d'images.
    if (_hasRoom && _isRoomEmptyFlag && _firstTextOnly) {
      await _emitError(_i18n(
        'First message must be text only.',
        'Le premier message doit être un texte uniquement.',
      ));
      return;
    }

    setState(() => _isSelectingImages = true);
    try {
      final List<XFile> picked = await _picker.pickMultiImage(imageQuality: 85);
      if (picked.isNotEmpty) {
        final files = <FFUploadedFile>[];
        for (final x in picked) {
          final bytes = await x.readAsBytes();
          files.add(FFUploadedFile(name: x.name, bytes: bytes));
        }
        setState(() => _pendingImages.addAll(files));
      }
    } catch (_) {
      await _emitError(
          _i18n('Failed to select images.', 'Échec de la sélection d’images.'));
    } finally {
      if (mounted) setState(() => _isSelectingImages = false);
    }
  }

  void _removePendingImage(FFUploadedFile f) {
    setState(() => _pendingImages.remove(f));
  }

  void _clearAfterSend({
    bool clearText = false,
    bool clearImages = false,
    bool clearAudio = false,
  }) {
    if (clearText) _textCtl.clear();
    if (clearImages) _pendingImages = [];
    if (clearAudio) {
      _audioPreviewFile = null;
      _isRecordingAudio = false;
    }
    setState(() {});
  }

  // *** LOGIQUE D'ENVOI ENTIEREMENT REFAITE ***
  Future<void> _handleSend() async {
    if (_isSending || _locked) return;
    if (!_hasAnyContent) return;

    // Appliquer la règle "texte seulement" pour le premier message
    if (_hasRoom && _isRoomEmptyFlag && _firstTextOnly) {
      if (!_hasText || _hasImages || _hasAudio) {
        await _emitError(_i18n(
          'First message must be text only.',
          'Le premier message doit être un texte uniquement.',
        ));
        return;
      }
    }

    setState(() => _isSending = true);

    try {
      if (!_hasRoom) {
        await _emitError(_i18n('Room not found. Please go back and try again.',
            'Conversation introuvable. Veuillez revenir en arrière et réessayer.'));
        return;
      }

      // La logique est maintenant plus simple : on envoie toujours dans un `roomId` existant.
      if (_hasAudio) {
        final ok = await actions.uploadAndSendAudioAction(
            widget.roomId!, _audioPreviewFile!);
        if (!ok)
          await _emitError(
              _i18n('Failed to send audio.', 'Échec de l’envoi de l’audio.'));
        _clearAfterSend(clearAudio: true);
        return;
      }

      if (_hasImages) {
        final ok = await actions.uploadAndSendImagesAction(
          widget.roomId!,
          _pendingImages,
          80,
          1440,
          _hasText ? _textCtl.text.trim() : null,
        );
        if (!ok)
          await _emitError(
              _i18n('Failed to send images.', 'Échec de l’envoi des images.'));
        _clearAfterSend(clearText: true, clearImages: true);
        return;
      }

      if (_hasText) {
        final ok = await actions.sendTextMessageAction(
            widget.roomId!, _textCtl.text.trim());
        if (!ok) {
          await _emitError(
              _i18n('Failed to send message.', 'Échec de l’envoi du message.'));
        } else {
          // *** LOGIQUE CRUCIALE (ancienne Étape 9.4) ***
          // Si on vient d'envoyer le premier message d'un Pro vers une Bride...
          if (_isRoomEmptyFlag &&
              _role == UserRole.professional &&
              widget.targetProfileId != null) {
            // ...le trigger a créé une `connection_request`. On doit rafraîchir le contexte
            // pour récupérer le nouveau `requestId`.
            final ctx = await actions
                .openOrPrepareContactAction(widget.targetProfileId!);
            // Si le statut est bien passé à `requestPending`...
            if (ctx.status == ChatEntryStatus.requestPending &&
                (ctx.requestId?.isNotEmpty ?? false)) {
              // ...on notifie la page `ChatDetails` pour qu'elle se mette à jour.
              if (widget.onRoomCreated != null) {
                await widget.onRoomCreated!(widget.roomId, ctx.requestId);
              }
            }
          }
          _clearAfterSend(clearText: true);
        }
      }
    } catch (e) {
      await _emitError(_i18n('An unexpected error occurred: ${e.toString()}',
          'Une erreur inattendue est survenue : ${e.toString()}'));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // Le reste du code (build methods) est inchangé par rapport à votre version.
  Widget _buildPendingImagesStrip() {
    if (_pendingImages.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 108,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ListView.separated(
          padding: EdgeInsets.zero,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (_, i) {
            final f = _pendingImages[i];
            final bytes = f.bytes ?? Uint8List.fromList([]);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    bytes,
                    width: 112,
                    height: 92,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: -6,
                  top: -8,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _removePendingImage(f),
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Colors.black87,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child:
                              Icon(Icons.close, color: Colors.white, size: 13),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemCount: _pendingImages.length,
        ),
      ),
    );
  }

  Widget _buildAudioPreviewChip() {
    if (_audioPreviewFile == null || _isRecordingAudio)
      return const SizedBox.shrink();
    final theme = FlutterFlowTheme.of(context);
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.mic, color: Colors.redAccent, size: 18),
          const SizedBox(width: 8),
          Text(
            _i18n('Voice ready', 'Audio prêt'),
            style: theme.bodyMedium,
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () {
              _audioPreviewFile = null;
              setState(() {});
            },
            customBorder: const CircleBorder(),
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.close, color: Colors.white, size: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final double h = (widget.height ?? 230).clamp(180, 280).toDouble();
    final double w = widget.width ?? MediaQuery.sizeOf(context).width;

    final bool canSend =
        !_locked && !_isSending && (_hasAnyContent || _hasFocus);
    final bool showMic = !_locked &&
        !_isSending &&
        !_isRecordingAudio &&
        !_hasAudio &&
        !_hasImages &&
        !_hasText &&
        !_hasFocus;

    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_pendingImages.isNotEmpty) _buildPendingImagesStrip(),
                    if (_audioPreviewFile != null && !_isRecordingAudio) ...[
                      const SizedBox(height: 8),
                      _buildAudioPreviewChip(),
                    ],
                    const SizedBox(height: 8),
                    if (!_locked) // On cache tout le composer si la conversation est verrouillée
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F2F2),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 48),
                              child: Stack(
                                children: [
                                  if (!_isRecordingAudio)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          48, 8, 48, 8),
                                      child: TextFormField(
                                        controller: _textCtl,
                                        focusNode: _textFocus,
                                        autofocus: false,
                                        readOnly: _hasAudio,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: _i18n('Send a message...',
                                              'Envoyer un message...'),
                                          hintStyle: theme.labelMedium.copyWith(
                                            color: const Color(0xFF888888),
                                            height: 1.2,
                                          ),
                                          isDense: true,
                                          counterText: '',
                                        ),
                                        style: theme.bodyMedium,
                                        maxLines: 6,
                                        minLines: 1,
                                        maxLength: 13000,
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                  if (_isRecordingAudio)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6),
                                      child: SizedBox(
                                        height: 48,
                                        child: AudioRecorderWidget(
                                          width: double.infinity,
                                          height: 48,
                                          maxDurationSeconds: 120,
                                          onAudioReady: (audioFile) async {
                                            _audioPreviewFile = audioFile;
                                            _isRecordingAudio = false;
                                            if (mounted) setState(() {});
                                          },
                                          onCancel: () async {
                                            _audioPreviewFile = null;
                                            _isRecordingAudio = false;
                                            if (mounted) setState(() {});
                                          },
                                        ),
                                      ),
                                    ),
                                  if (!_isRecordingAudio)
                                    Positioned(
                                      left: 6,
                                      top: 6,
                                      bottom: 6,
                                      child: IconButton(
                                        splashRadius: 22,
                                        onPressed: _pickImages,
                                        icon: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF2F2F2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Icon(Icons.add,
                                                color: theme.secondaryText,
                                                size: 20),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (!_isRecordingAudio && showMic)
                                    Positioned(
                                      right: 6,
                                      top: 6,
                                      bottom: 6,
                                      child: IconButton(
                                        splashRadius: 22,
                                        onPressed: (_isSelectingImages ||
                                                _hasText ||
                                                _hasImages ||
                                                _locked)
                                            ? null
                                            : () => setState(
                                                () => _isRecordingAudio = true),
                                        icon: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF2F2F2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Icon(Icons.mic_none,
                                                color: theme.secondaryText,
                                                size: 20),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (!_isRecordingAudio && !showMic)
                                    Positioned(
                                      right: 6,
                                      top: 6,
                                      bottom: 6,
                                      child: GestureDetector(
                                        onTap: canSend ? _handleSend : null,
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: const BoxDecoration(
                                            color: Colors.transparent,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: !_isSending
                                                ? FaIcon(
                                                    FontAwesomeIcons
                                                        .arrowCircleUp,
                                                    color: theme.primaryText,
                                                    size: 24,
                                                  )
                                                : SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: theme.primaryText,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
