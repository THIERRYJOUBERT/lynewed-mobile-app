/// Marker icon generation service with caching
/// 
/// Generates custom marker icons with avatars, borders, and labels.
/// - Professionals: Circle with avatar image or initials + colored border
/// - Alerts: Red circle with bell icon (like emergency beacon)
/// - Weddings: Heart-shaped marker
library;

import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:http/http.dart' as http;

import '../../domain/entities/map_marker.dart';
import '../theme/map_theme.dart';

/// Configuration for marker icon generation
class MarkerIconConfig {
  const MarkerIconConfig({
    this.borderWidth = 4.0,
    this.shadowBlur = 4.0,
    this.shadowOffset = const Offset(0, 2),
  });

  final double borderWidth;
  final double shadowBlur;
  final Offset shadowOffset;
}

/// Generates custom marker icons with avatars and styling
class MarkerIconGenerator {
  MarkerIconGenerator({MarkerIconConfig? config})
      : _config = config ?? const MarkerIconConfig(),
        _iconCache = {},
        _imageCache = {};

  final MarkerIconConfig _config;
  final Map<String, gmaps.BitmapDescriptor> _iconCache;
  final Map<String, ui.Image> _imageCache;

  /// Generate marker icon for a given marker
  Future<gmaps.BitmapDescriptor> generateIcon(
    MapMarker marker, {
    double? size,
  }) async {
    final actualSize = size ?? 168.0; // Default for 56px * 3 dpr
    final cacheKey = _generateCacheKey(marker, actualSize);
    
    // Return cached icon if available
    if (_iconCache.containsKey(cacheKey)) {
      return _iconCache[cacheKey]!;
    }

    // Generate new icon based on type
    gmaps.BitmapDescriptor icon;
    switch (marker.type) {
      case MapMarkerType.professionalAlert:
        icon = await _createAlertIcon(marker, actualSize);
        break;
      case MapMarkerType.wedding:
        icon = await _createWeddingIcon(marker, actualSize);
        break;
      case MapMarkerType.proFixedLocation:
      default:
        icon = await _createProIcon(marker, actualSize);
        break;
    }
    
    _iconCache[cacheKey] = icon;
    return icon;
  }

  /// Clear icon cache
  void clearCache() {
    _iconCache.clear();
    _imageCache.clear();
  }

  int get cacheSize => _iconCache.length;

  String _generateCacheKey(MapMarker marker, double size) {
    return '${marker.type.name}|${marker.style.borderColorHex}|${marker.style.avatarUrl}|${marker.style.label}|$size';
  }

  // ============================================================
  // PROFESSIONAL MARKER - Circle with avatar or initials
  // ============================================================
  
  Future<gmaps.BitmapDescriptor> _createProIcon(MapMarker marker, double size) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(size / 2, size / 2);
    final radius = size / 2 - _config.borderWidth;

    // Shadow
    _drawShadow(canvas, center, size);

    // White background circle
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Try to load avatar image
    ui.Image? avatarImage;
    if (marker.style.avatarUrl != null && marker.style.avatarUrl!.isNotEmpty) {
      avatarImage = await _loadImage(marker.style.avatarUrl!);
    }

    if (avatarImage != null) {
      // Draw avatar image clipped to circle
      _drawClippedImage(canvas, center, radius * 0.9, avatarImage);
    } else if (marker.style.label != null && marker.style.label!.isNotEmpty) {
      // Draw initials
      _drawInitials(canvas, center, radius, marker.style.label!, _getBorderColor(marker));
    } else {
      // Draw person icon
      _drawPersonIcon(canvas, center, radius * 0.5);
    }

    // Colored border
    final borderPaint = Paint()
      ..color = _getBorderColor(marker)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _config.borderWidth;
    canvas.drawCircle(center, radius, borderPaint);

    return _finishIcon(recorder, size);
  }

  // ============================================================
  // ALERT MARKER - Red circle with bell icon (emergency beacon style)
  // ============================================================
  
  Future<gmaps.BitmapDescriptor> _createAlertIcon(MapMarker marker, double size) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(size / 2, size / 2);
    final radius = size / 2 - _config.borderWidth;

    // Shadow
    _drawShadow(canvas, center, size);

    // Red background
    final bgPaint = Paint()
      ..color = const Color(0xFFE53935) // Red 600
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // White bell icon
    _drawBellIcon(canvas, center, radius * 0.55);

    // White border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = _config.borderWidth * 0.75;
    canvas.drawCircle(center, radius, borderPaint);

    return _finishIcon(recorder, size);
  }

  // ============================================================
  // WEDDING MARKER - Heart shape or circle with heart
  // ============================================================
  
  Future<gmaps.BitmapDescriptor> _createWeddingIcon(MapMarker marker, double size) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(size / 2, size / 2);
    final radius = size / 2 - _config.borderWidth;

    // Shadow
    _drawShadow(canvas, center, size);

    // Pink/rose background
    final bgPaint = Paint()
      ..color = const Color(0xFFF8BBD9) // Pink 100
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Push pin icon in center - using Flutter's Icons.push_pin
    _drawFlutterIcon(canvas, center, radius * 0.6, Icons.push_pin, const Color(0xFFE91E63));

    // Rose border
    final borderPaint = Paint()
      ..color = const Color(0xFFE91E63) // Pink 500
      ..style = PaintingStyle.stroke
      ..strokeWidth = _config.borderWidth;
    canvas.drawCircle(center, radius, borderPaint);

    return _finishIcon(recorder, size);
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  void _drawShadow(Canvas canvas, Offset center, double size) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, _config.shadowBlur);
    canvas.drawCircle(center + _config.shadowOffset, size / 2 - _config.borderWidth, shadowPaint);
  }

  Future<ui.Image?> _loadImage(String url) async {
    if (_imageCache.containsKey(url)) {
      return _imageCache[url];
    }

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final codec = await ui.instantiateImageCodec(response.bodyBytes);
        final frame = await codec.getNextFrame();
        _imageCache[url] = frame.image;
        return frame.image;
      }
    } catch (e) {
    }
    return null;
  }

  void _drawClippedImage(Canvas canvas, Offset center, double radius, ui.Image image) {
    canvas.save();
    
    // Clip to circle
    final clipPath = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.clipPath(clipPath);
    
    // Draw image scaled to fit
    final srcRect = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final dstRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawImageRect(image, srcRect, dstRect, Paint());
    
    canvas.restore();
  }

  void _drawInitials(Canvas canvas, Offset center, double radius, String name, Color color) {
    final initials = _getInitials(name);
    final textPainter = TextPainter(
      text: TextSpan(
        text: initials,
        style: TextStyle(
          color: color,
          fontSize: radius * 0.7,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, center - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  void _drawPersonIcon(Canvas canvas, Offset center, double size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.fill;
    
    // Head
    canvas.drawCircle(center - Offset(0, size * 0.35), size * 0.3, paint);
    // Body
    canvas.drawOval(
      Rect.fromCenter(center: center + Offset(0, size * 0.25), width: size * 0.7, height: size * 0.5),
      paint,
    );
  }

  void _drawBellIcon(Canvas canvas, Offset center, double size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Bell body (rounded trapezoid shape)
    final bellPath = Path();
    bellPath.moveTo(center.dx - size * 0.35, center.dy + size * 0.2);
    bellPath.quadraticBezierTo(center.dx - size * 0.4, center.dy - size * 0.1, center.dx - size * 0.2, center.dy - size * 0.35);
    bellPath.quadraticBezierTo(center.dx, center.dy - size * 0.5, center.dx + size * 0.2, center.dy - size * 0.35);
    bellPath.quadraticBezierTo(center.dx + size * 0.4, center.dy - size * 0.1, center.dx + size * 0.35, center.dy + size * 0.2);
    bellPath.close();
    canvas.drawPath(bellPath, paint);

    // Bell bottom (clapper area)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center + Offset(0, size * 0.25), width: size * 0.8, height: size * 0.15),
        Radius.circular(size * 0.1),
      ),
      paint,
    );

    // Clapper (small circle at bottom)
    canvas.drawCircle(center + Offset(0, size * 0.4), size * 0.1, paint);
  }

  void _drawFlutterIcon(Canvas canvas, Offset center, double size, IconData icon, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          color: color,
          fontSize: size * 1.5,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, center - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  Color _getBorderColor(MapMarker marker) {
    if (marker.style.borderColorHex != null) {
      try {
        final colorHex = marker.style.borderColorHex!.replaceFirst('#', '');
        return Color(int.parse('FF$colorHex', radix: 16));
      } catch (_) {}
    }
    return MapMarkerColors.forMarkerType(marker.type);
  }

  Future<gmaps.BitmapDescriptor> _finishIcon(ui.PictureRecorder recorder, double size) async {
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    // Use width parameter to display at exactly 44 logical pixels
    return gmaps.BitmapDescriptor.bytes(
      byteData!.buffer.asUint8List(),
      width: 44,
      height: 44,
    );
  }
}

/// Singleton instance for global use
class MarkerIconGeneratorService {
  static MarkerIconGenerator? _instance;
  
  static MarkerIconGenerator get instance {
    _instance ??= MarkerIconGenerator();
    return _instance!;
  }
  
  static void reset() {
    _instance?.clearCache();
    _instance = null;
  }
}
