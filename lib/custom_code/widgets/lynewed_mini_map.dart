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

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/painting.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:http/http.dart' as http;

class LynewedMiniMap extends StatefulWidget {
  const LynewedMiniMap({
    super.key,
    this.width,
    this.height,
    required this.center,
    this.initialZoom,
    this.radiusKm, // Ignoré pour l'affichage (pas de cercle)
    this.markerStyle,
    this.borderRadius,
    this.onTap,
    this.useLiteMode,
    this.mapStyle,
  });

  final double? width;
  final double? height;
  final LatLng center;
  final double? initialZoom;
  final double? radiusKm; // non affiché
  final MarkerStyleInfoStruct? markerStyle;
  final double? borderRadius;
  final Future<dynamic> Function()? onTap;
  final bool? useLiteMode;
  final MapStyleType? mapStyle;

  @override
  State<LynewedMiniMap> createState() => _LynewedMiniMapState();
}

class _LynewedMiniMapState extends State<LynewedMiniMap> {
  final Completer<gmaps.GoogleMapController> _controller = Completer();
  double get _zoom => widget.initialZoom ?? 12.0;
  double get _borderRadius => widget.borderRadius ?? 8.0;
  bool get _liteModeEnabled => widget.useLiteMode ?? false;

  // Anti-flicker cache
  gmaps.Marker? _cachedMarker;
  String? _markerSig;
  final Map<String, gmaps.BitmapDescriptor> _iconCache = {};

  bool _tapGuard = false;

  static const double _markerSize = 112.0; // x2

  @override
  void initState() {
    super.initState();
    _prepareMarkerIfNeeded();
  }

  @override
  void didUpdateWidget(covariant LynewedMiniMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.center != widget.center && _controller.isCompleted) {
      _animateToNewCenter();
    }
    if (oldWidget.mapStyle != widget.mapStyle) {
      setState(() {});
    }
    _prepareMarkerIfNeeded();
  }

  gmaps.MapType _gmapsTypeFrom(MapStyleType? style) {
    switch (style) {
      case MapStyleType.satellite:
        return gmaps.MapType.satellite;
      case MapStyleType.terrain:
        return gmaps.MapType.terrain;
      case MapStyleType.hybrid:
        return gmaps.MapType.hybrid;
      case MapStyleType.normal:
      default:
        return gmaps.MapType.normal;
    }
  }

  Future<void> _animateToNewCenter() async {
    try {
      final c = await _controller.future;
      await c.animateCamera(
        gmaps.CameraUpdate.newLatLngZoom(
          gmaps.LatLng(widget.center.latitude, widget.center.longitude),
          await c.getZoomLevel(),
        ),
      );
    } catch (_) {}
  }

  Future<void> _handleTap() async {
    if (_tapGuard) return;
    _tapGuard = true;
    try {
      if (widget.onTap != null) await widget.onTap!();
    } finally {
      Future.delayed(
          const Duration(milliseconds: 250), () => _tapGuard = false);
    }
  }

  void _prepareMarkerIfNeeded() {
    final sig = [
      widget.center.latitude.toStringAsFixed(6),
      widget.center.longitude.toStringAsFixed(6),
      widget.markerStyle?.avatarUrl ?? '',
      widget.markerStyle?.borderColorHex ?? '',
      _markerSize.toStringAsFixed(0),
    ].join('|');

    if (_markerSig == sig && _cachedMarker != null) return;
    _markerSig = sig;

    _getMarkerIcon().then((icon) {
      _cachedMarker = gmaps.Marker(
        markerId: const gmaps.MarkerId('mini-map-marker'),
        position: gmaps.LatLng(widget.center.latitude, widget.center.longitude),
        icon: icon,
        zIndex: 2.0,
      );
      if (mounted) setState(() {});
    });
  }

  Future<gmaps.BitmapDescriptor> _getMarkerIcon() async {
    final style = widget.markerStyle;
    final cacheKey =
        '${style?.avatarUrl ?? ''}|${style?.borderColorHex ?? ''}|$_markerSize';
    if (_iconCache.containsKey(cacheKey)) return _iconCache[cacheKey]!;

    final icon = await _generateAvatarIcon(
      imageUrl: style?.avatarUrl,
      ringColor: _colorFromHex(style?.borderColorHex ?? '#6A1B9A'),
      size: _markerSize,
      fallbackIcon: Icons.person_outline,
    );
    _iconCache[cacheKey] = icon;
    return icon;
  }

  Color _colorFromHex(String hex) {
    final v = hex.replaceFirst('#', '');
    if (v.length == 6) return Color(int.parse('FF$v', radix: 16));
    if (v.length == 8) return Color(int.parse(v, radix: 16));
    return Colors.black87;
  }

  Future<gmaps.BitmapDescriptor> _generateAvatarIcon({
    required String? imageUrl,
    required Color ringColor,
    required double size,
    required IconData fallbackIcon,
  }) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..isAntiAlias = true;
      final center = ui.Offset(size / 2, size / 2);
      final radius = size / 2;

      // Ring
      paint.color = ringColor;
      canvas.drawCircle(center, radius, paint);

      // White bg
      final ringWidth = size * 0.08;
      paint.color = Colors.white;
      canvas.drawCircle(center, radius - ringWidth, paint);

      bool drewImage = false;
      if ((imageUrl ?? '').isNotEmpty) {
        final bytes = await _fetchImageBytes(imageUrl!);
        if (bytes != null) {
          final codec = await ui.instantiateImageCodec(
            bytes,
            targetWidth: (size - ringWidth * 2).toInt(),
            targetHeight: (size - ringWidth * 2).toInt(),
          );
          final frame = await codec.getNextFrame();
          final image = frame.image;
          final avatarRect =
              ui.Rect.fromCircle(center: center, radius: radius - ringWidth);
          canvas.clipPath(ui.Path()..addOval(avatarRect));
          final srcRect = ui.Rect.fromLTWH(
              0, 0, image.width.toDouble(), image.height.toDouble());
          canvas.drawImageRect(image, srcRect, avatarRect, Paint());
          drewImage = true;
        }
      }

      if (!drewImage) {
        final tp = TextPainter(
          text: TextSpan(
            text: String.fromCharCode(fallbackIcon.codePoint),
            style: TextStyle(
              fontFamily: 'MaterialIcons',
              fontSize: size * 0.48,
              color: Colors.black87,
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        final off =
            ui.Offset(center.dx - tp.width / 2, center.dy - tp.height / 2);
        tp.paint(canvas, off);
      }

      final picture = recorder.endRecording();
      final img = await picture.toImage(size.toInt(), size.toInt());
      final png = await img.toByteData(format: ui.ImageByteFormat.png);
      return gmaps.BitmapDescriptor.fromBytes(png!.buffer.asUint8List());
    } catch (_) {
      return gmaps.BitmapDescriptor.defaultMarker;
    }
  }

  Future<Uint8List?> _fetchImageBytes(String url) async {
    try {
      final r = await http.get(Uri.parse(url));
      if (r.statusCode == 200) return r.bodyBytes;
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cameraPosition = gmaps.CameraPosition(
      target: gmaps.LatLng(widget.center.latitude, widget.center.longitude),
      zoom: _zoom,
    );

    final markers = <gmaps.Marker>{};
    if (_cachedMarker != null) markers.add(_cachedMarker!);

    return ClipRRect(
      borderRadius: BorderRadius.circular(_borderRadius),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          children: [
            gmaps.GoogleMap(
              mapType: _gmapsTypeFrom(widget.mapStyle),
              initialCameraPosition: cameraPosition,
              onMapCreated: (ctrl) {
                if (!_controller.isCompleted) _controller.complete(ctrl);
              },
              markers: markers,
              circles: const <gmaps.Circle>{}, // pas de cercle/rayon
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              zoomGesturesEnabled: false,
              scrollGesturesEnabled: false,
              tiltGesturesEnabled: false,
              rotateGesturesEnabled: false,
              liteModeEnabled: _liteModeEnabled,
              onTap: (_) => _handleTap(),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _handleTap,
                  splashColor: Theme.of(context).primaryColor.withOpacity(0.12),
                  highlightColor:
                      Theme.of(context).primaryColor.withOpacity(0.06),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
