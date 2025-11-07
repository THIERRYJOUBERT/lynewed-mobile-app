// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

//
import 'dart:async';

class InstantSearchTextField extends StatefulWidget {
  const InstantSearchTextField({
    super.key,
    this.width,
    this.height,
    this.hintText,
    this.initialValue,
    this.onChanged,
    this.debounceMs,
  });

  final double? width;
  final double? height;
  final String? hintText;
  final String? initialValue;
  final Future<dynamic> Function(String value)? onChanged;
  final int? debounceMs;

  @override
  State<InstantSearchTextField> createState() => _InstantSearchTextFieldState();
}

class _InstantSearchTextFieldState extends State<InstantSearchTextField> {
  late TextEditingController _textController;
  Timer? _debounce;
  bool _isUserTyping = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void didUpdateWidget(covariant InstantSearchTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Ne pas mettre à jour si l'utilisateur est en train de taper
    if (_isUserTyping) return;

    // Normaliser les valeurs pour la comparaison (null = chaîne vide)
    final newValue = widget.initialValue ?? '';
    final oldValue = oldWidget.initialValue ?? '';
    final currentValue = _textController.text;

    // Mettre à jour seulement si la valeur externe a vraiment changé
    // ET qu'elle est différente de la valeur actuelle du champ
    if (newValue != oldValue && newValue != currentValue) {
      // Annuler tout debounce en cours pour éviter les conflits
      _debounce?.cancel();

      // Mettre à jour le texte
      _textController.text = newValue;

      // Positionner le curseur à la fin
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _textController.dispose();
    super.dispose();
  }

  void _onChangedDebounced(String value) {
    // Marquer que l'utilisateur est en train de taper
    _isUserTyping = true;

    if (widget.onChanged == null) return;

    final delay = Duration(milliseconds: widget.debounceMs ?? 350);

    // Annuler le timer précédent
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Créer un nouveau timer
    _debounce = Timer(delay, () {
      // Réinitialiser le flag après l'exécution du callback
      _isUserTyping = false;

      if (value.length >= 2 || value.isEmpty) {
        widget.onChanged!(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: TextFormField(
        controller: _textController,
        onChanged: _onChangedDebounced,
        autofocus: false,
        textInputAction: TextInputAction.search,
        obscureText: false,
        decoration: InputDecoration(
          isDense: false,
          hintText: widget.hintText ?? 'Find an address or city',
          hintStyle: const TextStyle(
            fontFamily: 'Haas Grot Text Trial',
            color: Color(0xFF888888),
            letterSpacing: 0.0,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0x00000000),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(100.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xFFF2F2F2),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(100.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).error,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(100.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).error,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(100.0),
          ),
          filled: true,
          fillColor: const Color(0xFFF2F2F2),
          contentPadding:
              const EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 16.0, 10.0),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF888888),
          ),
        ),
        style: const TextStyle(
          fontFamily: 'Haas Grot Text Trial',
          letterSpacing: 0.0,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.start,
        minLines: 1,
      ),
    );
  }
}
