// Address Search Widget - Unified component for address autocomplete
// Created: 26/11/2025
// Updated: 26/11/2025 - Added overlay mode for suggestions display
// Replaces duplicated address search code across multiple screens

import 'dart:async';
import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/schema/structs/index.dart';
import '/custom_code/actions/index.dart' as actions;

/// Unified widget for address search with Google Places autocomplete.
/// 
/// This widget manages its own internal state (predictions, loading, session tokens)
/// and exposes callbacks for parent pages to react to address selection.
/// 
/// Usage:
/// ```dart
/// AddressSearchWidget(
///   hintText: 'Search city or address',
///   locale: 'fr',
///   onAddressSelected: (details) {
///     // Handle selected address with coordinates
///     setState(() {
///       _model.selectedPlace = details;
///     });
///   },
/// )
/// ```
/// Position of suggestions dropdown relative to the search field
enum SuggestionsPosition { below, above }

/// Height calculation for dynamic containers:
/// - 50px: Search field height
/// - 8px: Gap between field and suggestions
/// - 300px: Max suggestions list height (5 items × ~60px each)
/// - 62px: Additional padding for safe area and visual comfort
/// Total: 420px minimum for optimal display

class AddressSearchWidget extends StatefulWidget {
  const AddressSearchWidget({
    super.key,
    this.width,
    this.height,
    this.hintText,
    this.initialValue,
    this.locale,
    this.debounceMs = 300,
    this.maxSuggestions = 5,
    this.enabled = true,
    this.useOverlay = true,
    this.suggestionsPosition = SuggestionsPosition.below,
    this.borderRadius,
    this.onAddressSelected,
    this.onAddressCleared,
    this.onSearchTextChanged,
    this.onLoadingChanged,
    this.onSuggestionsVisibilityChanged,
  });

  /// Width of the widget (defaults to full width)
  final double? width;
  
  /// Height of the text field
  final double? height;
  
  /// Placeholder text for the search field
  final String? hintText;
  
  /// Initial value to display in the text field
  final String? initialValue;
  
  /// Locale for API responses ('fr' or 'en')
  final String? locale;
  
  /// Debounce delay in milliseconds before triggering search
  final int debounceMs;
  
  /// Maximum number of suggestions to display
  final int maxSuggestions;
  
  /// Whether the widget is enabled for input
  final bool enabled;
  
  /// Whether to display suggestions as overlay (true) or inline in Column (false)
  /// Default is true (overlay mode) to prevent layout overflow issues
  final bool useOverlay;
  
  /// Position of suggestions dropdown: below (default) or above the search field
  /// Use 'above' when there's not enough space below (e.g., small bottom sheets)
  final SuggestionsPosition suggestionsPosition;
  
  /// Border radius for the text field (defaults to 100.0 for pill shape)
  /// Use 4.0 for rectangular style matching Design System
  final double? borderRadius;
  
  /// Callback when an address is selected with full details
  final Function(PlaceDetailsDataStruct details)? onAddressSelected;
  
  /// Callback when the search is cleared
  final VoidCallback? onAddressCleared;
  
  /// Callback when search text changes (for external state sync)
  final Function(String text)? onSearchTextChanged;
  
  /// Callback when loading state changes
  final Function(bool isLoading)? onLoadingChanged;
  
  /// Callback when suggestions visibility changes (useful for parent to adjust layout)
  final Function(bool visible)? onSuggestionsVisibilityChanged;

  @override
  State<AddressSearchWidget> createState() => _AddressSearchWidgetState();
}

class _AddressSearchWidgetState extends State<AddressSearchWidget> {
  // Controllers
  late TextEditingController _textController;
  Timer? _debounce;
  
  // Overlay controllers for suggestions display
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();
  
  // Internal state
  List<PlaceSuggestionStruct> _suggestions = [];
  bool _isLoading = false;
  bool _isUserTyping = false;
  String? _sessionToken;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialValue ?? '');
    
    // Listen to focus changes to hide overlay when losing focus
    _focusNode.addListener(_onFocusChange);
  }
  
  void _onFocusChange() {
    if (!_focusNode.hasFocus && widget.useOverlay) {
      _hideOverlay();
    }
  }

  @override
  void didUpdateWidget(covariant AddressSearchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Don't update if user is typing
    if (_isUserTyping) return;
    
    final newValue = widget.initialValue ?? '';
    final oldValue = oldWidget.initialValue ?? '';
    final currentValue = _textController.text;
    
    if (newValue != oldValue && newValue != currentValue) {
      _debounce?.cancel();
      _textController.text = newValue;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _hideOverlay();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }
  
  // Overlay management methods
  void _showOverlay() {
    if (!widget.useOverlay || _overlayEntry != null) return;
    
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }
  
  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    // Always notify parent that suggestions are hidden
    widget.onSuggestionsVisibilityChanged?.call(false);
  }
  
  void _updateOverlay() {
    final shouldShow = widget.useOverlay && _showSuggestions && _suggestions.isNotEmpty;
    
    if (shouldShow) {
      if (_overlayEntry == null) {
        _showOverlay();
        widget.onSuggestionsVisibilityChanged?.call(true);
      } else {
        _overlayEntry!.markNeedsBuild();
      }
    } else {
      _hideOverlay(); // This already calls onSuggestionsVisibilityChanged(false)
    }
  }
  
  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    
    // Calculate offset based on position preference
    final isAbove = widget.suggestionsPosition == SuggestionsPosition.above;
    // For 'above': offset by negative height of suggestions list (~300px max) minus gap
    // For 'below': offset by field height plus gap
    final verticalOffset = isAbove ? -308.0 : size.height + 8;
    
    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, verticalOffset),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12.0),
            child: _buildSuggestionsListContent(context),
          ),
        ),
      ),
    );
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      setState(() => _isLoading = loading);
      widget.onLoadingChanged?.call(loading);
    }
  }

  String _getLocale() {
    if (widget.locale != null) return widget.locale!;
    final appLocale = FFAppState().currentUserPreferences.defaultLocale;
    return appLocale.isNotEmpty ? appLocale : 'en';
  }

  Future<void> _onTextChanged(String value) async {
    _isUserTyping = true;
    widget.onSearchTextChanged?.call(value);
    
    // Cancel previous debounce
    _debounce?.cancel();
    
    // Clear suggestions if text is too short
    if (value.length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      _updateOverlay();
      _isUserTyping = false;
      return;
    }
    
    // Debounce the API call
    _debounce = Timer(Duration(milliseconds: widget.debounceMs), () async {
      await _searchPlaces(value);
      _isUserTyping = false;
    });
  }

  Future<void> _searchPlaces(String query) async {
    if (!mounted) return;
    
    _setLoading(true);
    
    try {
      final result = await actions.getPlacePredictions(
        query,
        _sessionToken,
        _getLocale(),
      );
      
      if (!mounted) return;
      
      setState(() {
        _suggestions = result.suggestions
            .take(widget.maxSuggestions)
            .toList();
        _sessionToken = result.newSessionToken;
        _showSuggestions = _suggestions.isNotEmpty;
      });
      _updateOverlay();
    } catch (e) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      _updateOverlay();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _onSuggestionTap(PlaceSuggestionStruct suggestion) async {
    _setLoading(true);
    
    try {
      final details = await actions.getPlaceDetailsRich(
        suggestion.placeId,
        _sessionToken ?? '',
        _getLocale(),
      );
      
      if (!mounted) return;
      
      if (details != null) {
        // Update text field with selected address
        _textController.text = suggestion.primaryText;
        
        // Clear suggestions and reset session
        setState(() {
          _suggestions = [];
          _showSuggestions = false;
          _sessionToken = null;
        });
        _hideOverlay();
        
        // Notify parent
        widget.onAddressSelected?.call(details);
        widget.onSearchTextChanged?.call(suggestion.primaryText);
      }
    } catch (e) {
      debugPrint('[AddressSearchWidget._selectSuggestion] Error: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _clearSearch() {
    _textController.clear();
    setState(() {
      _suggestions = [];
      _showSuggestions = false;
      _sessionToken = null;
    });
    _hideOverlay();
    widget.onAddressCleared?.call();
    widget.onSearchTextChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    // In overlay mode, we only show the search field
    // Suggestions are displayed via Overlay
    if (widget.useOverlay) {
      return CompositedTransformTarget(
        link: _layerLink,
        child: _buildSearchField(context),
      );
    }
    
    // In inline mode (useOverlay = false), show suggestions in Column
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search TextField
        _buildSearchField(context),
        
        // Suggestions List (inline mode only)
        if (_showSuggestions && _suggestions.isNotEmpty)
          _buildSuggestionsList(context),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height ?? 50.0,
      child: TextFormField(
        controller: _textController,
        focusNode: _focusNode,
        onChanged: _onTextChanged,
        enabled: widget.enabled,
        autofocus: false,
        autocorrect: false,
        enableSuggestions: false,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          isDense: false,
          hintText: widget.hintText ?? 'Search city or address',
          hintStyle: const TextStyle(
            fontFamily: 'Haas Grot Text Trial',
            color: Color(0xFF888888),
            letterSpacing: 0.0,
            fontSize: 14,
            fontWeight: FontWeight.w300,
            height: 1.2,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0x00000000),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 100.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xFFF2F2F2),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 100.0),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0x00000000),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 100.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).error,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 100.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).error,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 100.0),
          ),
          filled: true,
          fillColor: widget.enabled 
              ? const Color(0xFFF2F2F2) 
              : const Color(0xFFE8E8E8),
          contentPadding: const EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 16.0, 10.0),
          prefixIcon: _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF888888),
                    ),
                  ),
                )
              : const Icon(
                  Icons.search,
                  color: Color(0xFF888888),
                ),
          suffixIcon: _textController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Color(0xFF888888),
                    size: 20,
                  ),
                  onPressed: _clearSearch,
                )
              : null,
        ),
        style: TextStyle(
          fontFamily: 'Haas Grot Text Trial',
          letterSpacing: 0.0,
          fontSize: 14,
          fontWeight: FontWeight.w300,
          color: widget.enabled 
              ? FlutterFlowTheme.of(context).primaryText 
              : const Color(0xFF888888),
        ),
        textAlign: TextAlign.start,
        minLines: 1,
      ),
    );
  }

  /// Builds the content of the suggestions list (used by both overlay and inline modes)
  Widget _buildSuggestionsListContent(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          shrinkWrap: true,
          itemCount: _suggestions.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
          itemBuilder: (context, index) {
            final suggestion = _suggestions[index];
            return _AddressPredictionItem(
              suggestion: suggestion,
              onTap: () => _onSuggestionTap(suggestion),
            );
          },
        ),
      ),
    );
  }

  /// Builds the suggestions list for inline mode (with margin)
  Widget _buildSuggestionsList(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      child: _buildSuggestionsListContent(context),
    );
  }
}

/// Individual suggestion item widget
class _AddressPredictionItem extends StatelessWidget {
  const _AddressPredictionItem({
    required this.suggestion,
    required this.onTap,
  });

  final PlaceSuggestionStruct suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primary text (city/place name)
            Text(
              suggestion.primaryText,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Haas Grot Text Trial',
                letterSpacing: 0.0,
                fontWeight: FontWeight.w300,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (suggestion.secondaryText.isNotEmpty) ...[
              const SizedBox(height: 2),
              // Secondary text (full address)
              Text(
                suggestion.secondaryText,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Haas Grot Text Trial',
                  color: FlutterFlowTheme.of(context).accent1,
                  fontSize: 12.0,
                  letterSpacing: 0.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
