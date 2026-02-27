/// Marker icon generation service with caching
/// 
/// Generates custom marker icons with avatars, borders, and labels.
/// - Professionals: Circle with avatar image or initials + colored border
/// - Alerts: Red circle with bell icon (like emergency beacon)
/// - Weddings: Heart-shaped marker
library;

import 'dart:async';
import 'dart:collection';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:http/http.dart' as http;
import 'package:synchronized/synchronized.dart';

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

/// Generates custom marker icons with avatars and styling.
///
/// Uses LRU caching with [LinkedHashMap] and thread-safe access via [Lock].
/// Cache limits: 200 icons (~4 MB), 100 images (~20 MB) = ~24 MB total.
class MarkerIconGenerator {
  MarkerIconGenerator({
    MarkerIconConfig? config,
    int maxIconCacheSize = 200,
    int maxImageCacheSize = 100,
  })  : _config = config ?? const MarkerIconConfig(),
        _maxIconCacheSize = maxIconCacheSize,
        _maxImageCacheSize = maxImageCacheSize,
        _iconCache = LinkedHashMap<String, gmaps.BitmapDescriptor>(),
        _imageCache = LinkedHashMap<String, ui.Image>(),
        _cacheLock = Lock();

  final MarkerIconConfig _config;
  final int _maxIconCacheSize;
  final int _maxImageCacheSize;
  final LinkedHashMap<String, gmaps.BitmapDescriptor> _iconCache;
  final LinkedHashMap<String, ui.Image> _imageCache;
  final Lock _cacheLock;

  /// Generate marker icon for a given marker.
  ///
  /// Uses LRU cache: recently accessed entries are kept, oldest evicted.
  /// Thread-safe via [Lock] to prevent race conditions on parallel calls.
  Future<gmaps.BitmapDescriptor> generateIcon(
    MapMarker marker, {
    double? size,
  }) async {
    final actualSize = size ?? 168.0; // Default for 56px * 3 dpr
    final cacheKey = _generateCacheKey(marker, actualSize);

    // Fast path: check cache (thread-safe)
    final cached = await _cacheLock.synchronized(() {
      if (_iconCache.containsKey(cacheKey)) {
        // LRU: remove and re-insert to move to end (most recently used)
        final icon = _iconCache.remove(cacheKey)!;
        _iconCache[cacheKey] = icon;
        return icon;
      }
      return null;
    });
    if (cached != null) return cached;

    // Slow path: generate icon (outside lock to allow parallelism)
    gmaps.BitmapDescriptor icon;
    switch (marker.type) {
      case MapMarkerType.professionalAlert:
        icon = await _createAlertIcon(marker, actualSize);
        break;
      case MapMarkerType.wedding:
        icon = await _createWeddingIcon(marker, actualSize);
        break;
      case MapMarkerType.proFixedLocation:
        icon = await _createProIcon(marker, actualSize);
        break;
      case MapMarkerType.marketplaceItem:
        icon = await _createMarketplaceIcon(marker, actualSize);
        break;
    }

    // Insert into cache (thread-safe, with LRU eviction)
    await _cacheLock.synchronized(() {
      // Another call might have inserted while we were generating
      if (_iconCache.containsKey(cacheKey)) {
        _iconCache.remove(cacheKey);
      }
      // Evict LRU entry if at capacity
      while (_iconCache.length >= _maxIconCacheSize) {
        _iconCache.remove(_iconCache.keys.first);
      }
      _iconCache[cacheKey] = icon;
    });

    return icon;
  }

  /// Clear both icon and image caches.
  void clearCache() {
    _iconCache.clear();
    _imageCache.clear();
  }

  /// Number of entries in the icon cache.
  int get cacheSize => _iconCache.length;

  /// Number of entries in the image cache.
  int get imageCacheSize => _imageCache.length;

  /// Check if a specific cache key exists (for testing).
  bool hasInCache(String cacheKey) => _iconCache.containsKey(cacheKey);

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

  Future<gmaps.BitmapDescriptor> _createWeddingIcon(
      MapMarker marker, double size) async {
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

    // Diamond icon in center - unified wedding icon
    _drawFlutterIcon(canvas, center, radius * 0.6, Icons.diamond_outlined,
        const Color(0xFFE91E63));

    // Rose border
    final borderPaint = Paint()
      ..color = const Color(0xFFE91E63) // Pink 500
      ..style = PaintingStyle.stroke
      ..strokeWidth = _config.borderWidth;
    canvas.drawCircle(center, radius, borderPaint);

    return _finishIcon(recorder, size);
  }

  // ============================================================
  // MARKETPLACE MARKER - Product thumbnail with purple border (EPIC-14)
  // Fallback: purple circle with dress/shoes icon
  // ============================================================

  Future<gmaps.BitmapDescriptor> _createMarketplaceIcon(
      MapMarker marker, double size) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(size / 2, size / 2);
    final radius = size / 2 - _config.borderWidth;

    // Shadow
    _drawShadow(canvas, center, size);

    // White background circle (visible behind image as loading state)
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Try to load product thumbnail image
    ui.Image? thumbnailImage;
    if (marker.style.avatarUrl != null && marker.style.avatarUrl!.isNotEmpty) {
      thumbnailImage = await _loadImage(marker.style.avatarUrl!);
    }

    if (thumbnailImage != null) {
      // Draw product photo clipped to circle
      _drawClippedImage(canvas, center, radius - 1, thumbnailImage);
    } else {
      // Fallback: purple background with category icon
      final fallbackBg = Paint()
        ..color = const Color(0xFFE1BEE7) // Purple 100
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, fallbackBg);

      final category = marker.metadata['category'] as String? ?? 'dress';
      final icon = category == 'shoes'
          ? Icons.shopping_bag_outlined
          : Icons.checkroom_outlined;
      _drawFlutterIcon(
          canvas, center, radius * 0.6, icon, const Color(0xFF7B1FA2));
    }

    // Purple border (always visible, frames the photo)
    final borderPaint = Paint()
      ..color = const Color(0xFF7B1FA2) // Purple 700
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
    // Fast path: check image cache (thread-safe, LRU)
    final cached = await _cacheLock.synchronized(() {
      if (_imageCache.containsKey(url)) {
        final img = _imageCache.remove(url)!;
        _imageCache[url] = img; // Move to end (most recently used)
        return img;
      }
      return null;
    });
    if (cached != null) return cached;

    // Slow path: load image from network
    ui.Image? img;
    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final codec = await ui.instantiateImageCodec(response.bodyBytes);
        final frame = await codec.getNextFrame();
        img = frame.image;
      }
    } catch (e) {
      debugPrint('[MarkerIconGenerator._loadImage] Error: $e');
      return null;
    }

    if (img == null) return null;
    final loadedImg = img;

    // Insert into image cache (thread-safe, with LRU eviction)
    await _cacheLock.synchronized(() {
      while (_imageCache.length >= _maxImageCacheSize) {
        _imageCache.remove(_imageCache.keys.first);
      }
      _imageCache[url] = loadedImg;
    });

    return loadedImg;
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
