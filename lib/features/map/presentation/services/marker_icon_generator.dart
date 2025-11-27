/// Marker icon generation service with caching
/// 
/// Generates custom marker icons with avatars, borders, and labels.
/// Optimized for performance with bitmap caching and async generation.
library;

import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

import '../../domain/entities/map_marker.dart';
import '../theme/map_theme.dart';

/// Configuration for marker icon generation
class MarkerIconConfig {
  const MarkerIconConfig({
    this.defaultSize = 44.0,
    this.avatarSizeRatio = 0.6,
    this.borderWidthRatio = 0.05,
    this.shadowBlur = 2.0,
    this.shadowOffset = const Offset(0, 1),
  });

  final double defaultSize;
  final double avatarSizeRatio;
  final double borderWidthRatio;
  final double shadowBlur;
  final Offset shadowOffset;
}

/// Generates custom marker icons with avatars and styling
class MarkerIconGenerator {
  MarkerIconGenerator({MarkerIconConfig? config})
      : _config = config ?? const MarkerIconConfig(),
        _iconCache = {};

  final MarkerIconConfig _config;
  final Map<String, gmaps.BitmapDescriptor> _iconCache;

  /// Generate marker icon for a given marker
  Future<gmaps.BitmapDescriptor> generateIcon(
    MapMarker marker, {
    double? size,
  }) async {
    final cacheKey = _generateCacheKey(marker, size);
    
    // Return cached icon if available
    if (_iconCache.containsKey(cacheKey)) {
      return _iconCache[cacheKey]!;
    }

    // Generate new icon
    final icon = await _createMarkerIcon(marker, size ?? _config.defaultSize);
    _iconCache[cacheKey] = icon;
    
    return icon;
  }

  /// Clear icon cache (useful for memory management)
  void clearCache() {
    _iconCache.clear();
  }

  /// Get cache size for debugging
  int get cacheSize => _iconCache.length;

  /// Generate unique cache key for marker
  String _generateCacheKey(MapMarker marker, double? size) {
    final parts = [
      marker.type.name,
      marker.style.borderColorHex ?? 'transparent',
      marker.style.avatarUrl ?? 'no-avatar',
      marker.style.label ?? 'no-label',
      size?.toString() ?? 'default',
    ];
    return parts.join('|');
  }

  /// Create marker icon bitmap
  Future<gmaps.BitmapDescriptor> _createMarkerIcon(
    MapMarker marker,
    double size,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(size / 2, size / 2);

    // Draw shadow
    _drawShadow(canvas, center, size);

    // Draw background circle
    _drawBackground(canvas, center, size, marker);

    // Draw avatar placeholder or default icon
    if (marker.style.avatarUrl != null || marker.style.label != null) {
      _drawAvatarPlaceholder(canvas, center, size, marker);
    } else {
      _drawDefaultIcon(canvas, center, size, marker.type);
    }

    // Draw border
    _drawBorder(canvas, center, size, marker);

    // Convert to bitmap descriptor
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return gmaps.BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  /// Draw shadow under marker
  void _drawShadow(Canvas canvas, Offset center, double size) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, _config.shadowBlur);

    final shadowRect = Rect.fromCenter(
      center: center + _config.shadowOffset,
      width: size * 0.8,
      height: size * 0.8,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(shadowRect, Radius.circular(size * 0.4)),
      shadowPaint,
    );
  }

  /// Draw background circle
  void _drawBackground(Canvas canvas, Offset center, double size, MapMarker marker) {
    final bgPaint = Paint()
      ..color = _getBackgroundColor(marker)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, size / 2, bgPaint);
  }

  /// Draw avatar placeholder or cached image
  /// 
  /// NOTE: Direct network image loading in canvas is complex and unreliable.
  /// For production, pre-load avatars via ImageCache and pass ui.Image directly.
  /// This implementation draws a colored placeholder with initials.
  void _drawAvatarPlaceholder(
    Canvas canvas,
    Offset center,
    double size,
    MapMarker marker,
  ) {
    final avatarSize = size * _config.avatarSizeRatio;
    
    // Draw colored circle as placeholder
    final bgPaint = Paint()
      ..color = _getBorderColor(marker).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, avatarSize / 2, bgPaint);
    
    // Draw initials if label available
    final label = marker.style.label;
    if (label != null && label.isNotEmpty) {
      final initials = _getInitials(label);
      final textPainter = TextPainter(
        text: TextSpan(
          text: initials,
          style: TextStyle(
            color: _getBorderColor(marker),
            fontSize: avatarSize * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        center - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    } else {
      // Fallback to type icon
      _drawDefaultIcon(canvas, center, size, marker.type);
    }
  }
  
  /// Extract initials from name
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  /// Draw default icon when no avatar
  void _drawDefaultIcon(Canvas canvas, Offset center, double size, MapMarkerType type) {
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final iconSize = size * 0.3;
    
    switch (type) {
      case MapMarkerType.proFixedLocation:
        _drawPersonIcon(canvas, center, iconSize, iconPaint);
        break;
      case MapMarkerType.professionalAlert:
        _drawAlertIcon(canvas, center, iconSize, iconPaint);
        break;
      case MapMarkerType.wedding:
        _drawHeartIcon(canvas, center, iconSize, iconPaint);
        break;
      case MapMarkerType.poiPrivate:
        _drawLocationIcon(canvas, center, iconSize, iconPaint);
        break;
    }
  }

  /// Draw border around marker
  void _drawBorder(Canvas canvas, Offset center, double size, MapMarker marker) {
    final borderPaint = Paint()
      ..color = _getBorderColor(marker)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * _config.borderWidthRatio;

    canvas.drawCircle(center, size / 2 - size * _config.borderWidthRatio / 2, borderPaint);
  }

  /// Get background color for marker type
  Color _getBackgroundColor(MapMarker marker) {
    switch (marker.type) {
      case MapMarkerType.proFixedLocation:
        return Colors.white;
      case MapMarkerType.professionalAlert:
        return MapMarkerColors.alert.withValues(alpha: 0.1);
      case MapMarkerType.wedding:
        return Colors.white;
      case MapMarkerType.poiPrivate:
        return Colors.white;
    }
  }

  /// Get border color for marker
  Color _getBorderColor(MapMarker marker) {
    if (marker.style.borderColorHex != null) {
      try {
        final colorHex = marker.style.borderColorHex!.replaceFirst('#', '');
        return Color(int.parse('FF$colorHex', radix: 16));
      } catch (_) {
        // Fallback to type color
      }
    }
    
    return MapMarkerColors.forMarkerType(marker.type);
  }

  // Icon drawing methods
  void _drawPersonIcon(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    // Head
    path.addOval(Rect.fromCircle(center: center - Offset(0, size * 0.3), radius: size * 0.2));
    // Body
    path.addOval(Rect.fromCircle(center: center + Offset(0, size * 0.1), radius: size * 0.25));
    canvas.drawPath(path, paint);
  }

  void _drawAlertIcon(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.drawCircle(center, size * 0.4, paint);
    final textPainter = TextPainter(
      text: TextSpan(
        text: '!',
        style: TextStyle(
          color: Colors.red,
          fontSize: size * 0.6, // Relative to marker size
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _drawHeartIcon(Canvas canvas, Offset center, double size, Paint paint) {
    // Simple heart shape using circles and triangle
    final heartSize = size * 0.35;
    final topOffset = size * 0.15;
    
    // Left circle of heart
    canvas.drawCircle(
      center - Offset(heartSize * 0.3, topOffset),
      heartSize * 0.35,
      paint,
    );
    
    // Right circle of heart
    canvas.drawCircle(
      center + Offset(heartSize * 0.3, -topOffset),
      heartSize * 0.35,
      paint,
    );
    
    // Bottom triangle
    final path = Path();
    path.moveTo(center.dx - heartSize * 0.5, center.dy - topOffset);
    path.lineTo(center.dx + heartSize * 0.5, center.dy - topOffset);
    path.lineTo(center.dx, center.dy + heartSize * 0.4);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawLocationIcon(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size * 0.3);
    path.lineTo(center.dx - size * 0.25, center.dy + size * 0.2);
    path.lineTo(center.dx + size * 0.25, center.dy + size * 0.2);
    path.close();
    canvas.drawPath(path, paint);
    
    // Inner circle
    canvas.drawCircle(center, size * 0.1, paint);
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
