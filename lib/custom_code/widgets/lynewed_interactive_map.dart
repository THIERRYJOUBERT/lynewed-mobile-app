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
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LynewedInteractiveMap extends StatefulWidget {
  const LynewedInteractiveMap({
    super.key,
    this.width,
    this.height,
    this.command,
    this.searchTargetMarker,
    this.filters,
    this.userRole,
    this.markers,
    this.weddingPinOverlays, // ignoré visuellement
    this.onDataLoaded,
    this.onMarkerTap,
    this.initialCenter,
    this.initialZoom,
    this.enableMyLocationLayer,
    this.debounceMs,
    this.mapStyle,
    this.enableClustering,
    this.clusterRadiusPx,
    this.minClusterSize,
  });

  final double? width;
  final double? height;
  final MapCommandStruct? command;
  final MapMarkerStruct? searchTargetMarker;
  final QueryFiltersStruct? filters;
  final UserRole? userRole;
  final List<MapMarkerStruct>? markers;
  final List<WeddingPinOverlayStruct>? weddingPinOverlays;
  final Future<dynamic> Function(MapdatabundleStruct data)? onDataLoaded;
  final Future<dynamic> Function(MapMarkerStruct marker)? onMarkerTap;
  final LatLng? initialCenter;
  final double? initialZoom;
  final bool? enableMyLocationLayer;
  final int? debounceMs;
  final MapStyleType? mapStyle;

  final bool? enableClustering; // default: true
  final double? clusterRadiusPx; // default: 56
  final int? minClusterSize; // default: 6

  @override
  State<LynewedInteractiveMap> createState() => _LynewedInteractiveMapState();
}

class _LynewedInteractiveMapState extends State<LynewedInteractiveMap> {
  final Completer<gmaps.GoogleMapController> _controller = Completer();
  Timer? _cameraIdleDebounce;
  Timer? _clusterDebounce;
  String? _lastCommandId;
  bool _isInternalLoading = false;

  bool _isDisposed = false;
  int _gen = 0;

  // Caches
  final Map<String, gmaps.BitmapDescriptor> _iconCache = {};
  final Map<String, gmaps.Marker> _markerCache = {};
  final Map<String, String> _markerStyleSigByKey = {};
  final Map<String, MapMarkerStruct> _markerDataByKey = {};
  Set<String> _visibleMarkerKeys = {};

  // Clusters
  final Map<int, gmaps.BitmapDescriptor> _clusterIconCache = {};
  final Map<String, gmaps.Marker> _clusterMarkerCache = {};
  Set<String> _visibleClusterKeys = {};
  Set<String> _keysInClusters = {};

  DateTime? _lastErrorShownAt;
  String? _filtersSignature;
  int _reconcileSeq = 0;
  double _lastZoom = 12.0;

  // Sizes (x2), cluster = même taille que marqueurs
  static const double _sizePro = 128.0;
  static const double _sizeWeddingPoi = 112.0;
  static const double _sizeAlert = 112.0;
  static const double _sizeCluster = 112.0;

  // Getters
  double get _initialZoom => widget.initialZoom ?? 12.0;
  bool get _enableMyLocationLayer => widget.enableMyLocationLayer ?? true;
  int get _debounceMs => (widget.debounceMs == null || widget.debounceMs! < 0)
      ? 500
      : widget.debounceMs!;
  List<MapMarkerStruct> get _markersProp => widget.markers ?? [];
  bool get _clusteringOn => widget.enableClustering ?? true;
  double get _clusterRadiusPx => widget.clusterRadiusPx ?? 56.0;
  int get _minClusterSize => widget.minClusterSize ?? 6;

  @override
  void initState() {
    super.initState();
    _filtersSignature =
        _computeFiltersSignature(widget.filters, widget.userRole);
  }

  @override
  void didUpdateWidget(covariant LynewedInteractiveMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    _handleCommandIfAny();

    final newSig = _computeFiltersSignature(widget.filters, widget.userRole);
    final markersChanged = oldWidget.markers != widget.markers ||
        oldWidget.searchTargetMarker != widget.searchTargetMarker;

    if (newSig != _filtersSignature) {
      _filtersSignature = newSig;
      _resetCaches();
      _reconcileMarkers();
      _scheduleClusterRebuild();
    } else if (markersChanged) {
      _reconcileMarkers();
      _scheduleClusterRebuild();
    }

    if (oldWidget.mapStyle != widget.mapStyle) {
      if (mounted) setState(() {});
    }

    if (oldWidget.filters != widget.filters ||
        oldWidget.userRole != widget.userRole) {
      _loadDataForCurrentViewport();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cameraIdleDebounce?.cancel();
    _clusterDebounce?.cancel();
    super.dispose();
  }

  void _resetCaches() {
    _markerCache.clear();
    _markerStyleSigByKey.clear();
    _markerDataByKey.clear();
    _visibleMarkerKeys = {};
    _clusterMarkerCache.clear();
    _visibleClusterKeys = {};
    _keysInClusters = {};
    _clusterIconCache.clear();
  }

  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) setState(fn);
  }

  String _computeFiltersSignature(QueryFiltersStruct? f, UserRole? role) {
    final b = StringBuffer();
    b.write('role:${role?.name}');
    if (f != null) {
      b
        ..write('|cur:${f.currency}')
        ..write('|r:${f.radiusKm}')
        ..write(
            '|c:${f.center?.latitude?.toStringAsFixed(5)},${f.center?.longitude?.toStringAsFixed(5)}')
        ..write(
            '|pros:${(f.professions ?? []).map((e) => e.name).toList()..sort()}')
        ..write(
            '|tog:${f.showPros}-${f.showProRecent}-${f.showFixedLocations}-${f.showBridePrivatePoi}-${f.showWeddingPins}-${f.showProAlerts}-${f.showOnlyMyProfessionPins}');
    }
    return b.toString();
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

  Future<gmaps.GoogleMapController?> _controllerOrNull() async {
    if (_isDisposed || !_controller.isCompleted) return null;
    try {
      return await _controller.future;
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleCommandIfAny() async {
    final c = await _controllerOrNull();
    if (c == null) return;
    final cmd = widget.command;
    if (cmd == null || (cmd.id == _lastCommandId)) return;
    _lastCommandId = cmd.id;
    switch (cmd.type) {
      case MapActionType.locateUser:
        await _locateUser(animate: true);
        break;
      case MapActionType.moveToTarget:
        if (cmd.target != null) {
          await c.animateCamera(
            gmaps.CameraUpdate.newLatLngZoom(
              gmaps.LatLng(cmd.target!.latitude, cmd.target!.longitude),
              _initialZoom + 2,
            ),
          );
        }
        break;
      case MapActionType.zoomIn:
        await c.animateCamera(gmaps.CameraUpdate.zoomIn());
        break;
      case MapActionType.zoomOut:
        await c.animateCamera(gmaps.CameraUpdate.zoomOut());
        break;
      case MapActionType.fitBounds:
        if ((cmd.fitBoundsTo ?? []).length >= 2) {
          final first = cmd.fitBoundsTo!.first;
          final last = cmd.fitBoundsTo!.last;
          if (first != null && last != null) {
            final bounds = gmaps.LatLngBounds(
              southwest: gmaps.LatLng(first.latitude, first.longitude),
              northeast: gmaps.LatLng(last.latitude, last.longitude),
            );
            await c.animateCamera(
                gmaps.CameraUpdate.newLatLngBounds(bounds, 60.0));
          }
        }
        break;
      case MapActionType.none:
      case null:
        break;
    }
  }

  Future<void> _locateUser({bool animate = false}) async {
    try {
      final hasPermission = await _ensureLocationPermission();
      if (!hasPermission) return;
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (animate) {
        final c = await _controllerOrNull();
        if (c != null) {
          await c.animateCamera(
            gmaps.CameraUpdate.newLatLngZoom(
              gmaps.LatLng(pos.latitude, pos.longitude),
              _initialZoom + 2,
            ),
          );
        }
      }
    } catch (_) {}
  }

  Future<bool> _ensureLocationPermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return !(perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever);
  }

  Future<void> _fetchAndEmitMapData() async {
    final localGen = ++_gen;
    if (widget.userRole == null || widget.onDataLoaded == null) return;
    _safeSetState(() => _isInternalLoading = true);
    try {
      final c = await _controllerOrNull();
      if (c == null) return;
      final bounds = await c.getVisibleRegion();
      final zoom = await c.getZoomLevel();
      if (_isDisposed || localGen != _gen) return;
      _lastZoom = zoom;

      final center = gmaps.LatLng(
        (bounds.southwest.latitude + bounds.northeast.latitude) / 2,
        (bounds.southwest.longitude + bounds.northeast.longitude) / 2,
      );
      final vp = ViewportinfoStruct(
        centerLat: center.latitude,
        centerLng: center.longitude,
        neLat: bounds.northeast.latitude,
        neLng: bounds.northeast.longitude,
        swLat: bounds.southwest.latitude,
        swLng: bounds.southwest.longitude,
        zoom: zoom,
      );
      final filtersToUse = widget.filters ?? QueryFiltersStruct();
      final mapData =
          await callSearchMapBundleV2(vp, filtersToUse, widget.userRole!);
      if (_isDisposed || localGen != _gen) return;

      await widget.onDataLoaded!(mapData);
      await _reconcileMarkers();
      _scheduleClusterRebuild();
    } catch (e) {
      _showRetrySnackBar(e);
    } finally {
      _safeSetState(() => _isInternalLoading = false);
    }
  }

  void _showRetrySnackBar(Object error) {
    final now = DateTime.now();
    if (_lastErrorShownAt == null ||
        now.difference(_lastErrorShownAt!).inSeconds >= 4) {
      _lastErrorShownAt = now;
      final isFr =
          (FFLocalizations.of(context).languageCode.toLowerCase() == 'fr');
      final msg = isFr
          ? 'Impossible de charger la carte. Vérifiez votre connexion.'
          : 'Failed to load map data. Check your connection.';
      final retry = isFr ? 'Réessayer' : 'Retry';
      if (!_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            action:
                SnackBarAction(label: retry, onPressed: _fetchAndEmitMapData),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _loadDataForCurrentViewport() async {
    _cameraIdleDebounce?.cancel();
    _cameraIdleDebounce = Timer(Duration(milliseconds: _debounceMs), () async {
      if (_isDisposed) return;
      await _fetchAndEmitMapData();
    });
  }

  // ---------------- Reconcilers ----------------

  String _markerKey(MapMarkerStruct m) {
    final t = (m.type ?? MapMarkerType.professional).name;
    final id = m.id ?? '';
    final lat = m.position?.latitude.toStringAsFixed(6) ?? '0';
    final lng = m.position?.longitude.toStringAsFixed(6) ?? '0';
    return '${t}_${id}_${lat}_${lng}';
  }

  String _styleSig(MapMarkerStruct m) {
    final t = (m.type ?? MapMarkerType.professional).name;
    final avatar = m.styleInfo?.avatarUrl ?? '';
    final border = m.styleInfo?.borderColorHex ?? '';
    final own = (m.styleInfo?.isOwn == true) ? '1' : '0';
    final themeColor = Theme.of(context).primaryColor.value.toString();
    return '$t|$avatar|$border|$own|$themeColor';
  }

  Future<void> _ensureMarkerPrepared(
      String key, MapMarkerStruct m, String styleSig) async {
    final needsCreate =
        !_markerCache.containsKey(key) || _markerStyleSigByKey[key] != styleSig;
    if (!needsCreate) {
      _markerDataByKey[key] = m;
      return;
    }

    final icon = await _getMarkerIcon(m);
    if (_isDisposed) return;

    final markerType = m.type ?? MapMarkerType.professional;
    _markerCache[key] = gmaps.Marker(
      markerId: gmaps.MarkerId(key),
      position: gmaps.LatLng(m.position!.latitude, m.position!.longitude),
      icon: icon,
      zIndex: _zIndexForType(markerType),
      onTap: () async {
        if (widget.onMarkerTap != null) await widget.onMarkerTap!(m);
      },
    );

    _markerStyleSigByKey[key] = styleSig;
    _markerDataByKey[key] = m;
  }

  Future<void> _reconcileMarkers() async {
    final int token = ++_reconcileSeq;

    final all = <MapMarkerStruct>[];
    if (widget.searchTargetMarker != null) all.add(widget.searchTargetMarker!);
    if (_markersProp.isNotEmpty)
      all.addAll(_markersProp.where((m) => m.position != null));

    final newKeys = <String>{};
    final tasks = <Future<void>>[];
    for (final m in all) {
      if (m.position == null) continue;
      final key = _markerKey(m);
      if (newKeys.contains(key)) continue;
      newKeys.add(key);
      final sig = _styleSig(m);
      tasks.add(_ensureMarkerPrepared(key, m, sig));
    }
    if (tasks.isNotEmpty) await Future.wait(tasks);
    if (_isDisposed || token != _reconcileSeq) return;

    _safeSetState(() {
      _visibleMarkerKeys = newKeys;

      final toDrop = _markerCache.keys
          .where((k) => !_visibleMarkerKeys.contains(k))
          .toList();
      for (final k in toDrop) {
        _markerCache.remove(k);
        _markerStyleSigByKey.remove(k);
        _markerDataByKey.remove(k);
      }
    });
  }

  // ---------------- Clustering (densité) ----------------

  void _scheduleClusterRebuild() {
    _clusterDebounce?.cancel();
    _clusterDebounce = Timer(const Duration(milliseconds: 80), () async {
      if (_isDisposed) return;
      await _buildDensityClusters();
      if (_isDisposed) return;
      _safeSetState(() {});
    });
  }

  Future<void> _buildDensityClusters() async {
    if (!_clusteringOn) {
      _visibleClusterKeys = {};
      _clusterMarkerCache.clear();
      _keysInClusters = {};
      return;
    }

    final c = await _controllerOrNull();
    if (c == null) return;

    final zoom = await c.getZoomLevel();
    if (_isDisposed) return;
    _lastZoom = zoom;

    // Candidats au clustering: EXCLUT seulement searchTarget et user.
    final candidates = <MapMarkerStruct>[];
    for (final k in _visibleMarkerKeys) {
      final d = _markerDataByKey[k];
      if (d == null || d.position == null) continue;
      final t = d.type ?? MapMarkerType.professional;
      if (t == MapMarkerType.searchTarget || t == MapMarkerType.user) continue;
      // WeddingPin désormais INCLUS
      candidates.add(d);
    }

    if (candidates.isEmpty) {
      _visibleClusterKeys = {};
      _clusterMarkerCache.clear();
      _keysInClusters = {};
      return;
    }

    // Projection mercator
    final scale = 256.0 * math.pow(2.0, zoom);
    ui.Offset _project(LatLng p) {
      final lat = p.latitude.clamp(-85.05112878, 85.05112878);
      final lng = p.longitude;
      final x = (lng + 180.0) / 360.0 * scale;
      final siny = math.sin(lat * math.pi / 180.0);
      final y =
          (0.5 - math.log((1.0 + siny) / (1.0 - siny)) / (4.0 * math.pi)) *
              scale;
      return ui.Offset(x, y);
    }

    gmaps.LatLng _unproject(ui.Offset pt) {
      final lon = pt.dx / scale * 360.0 - 180.0;
      final n = math.pi - 2.0 * math.pi * pt.dy / scale;
      final lat =
          180.0 / math.pi * math.atan(0.5 * (math.exp(n) - math.exp(-n)));
      return gmaps.LatLng(lat, lon);
    }

    final double cell = _clusterRadiusPx;
    final Map<String, List<MapMarkerStruct>> buckets = {};
    final Map<String, List<String>> bucketKeys = {};

    for (final m in candidates) {
      final pt = _project(m.position!);
      final gx = (pt.dx / cell).floor();
      final gy = (pt.dy / cell).floor();
      final key = 'z${zoom.toStringAsFixed(2)}_${gx}_$gy';
      (buckets[key] ??= <MapMarkerStruct>[]).add(m);
      (bucketKeys[key] ??= <String>[]).add(_markerKey(m));
    }

    final newClusterKeys = <String>{};
    final Map<String, gmaps.Marker> newClusterMarkers = {};
    final keysInClusters = <String>{};

    for (final entry in buckets.entries) {
      final members = entry.value;
      if (members.length < _minClusterSize) {
        continue; // faible densité => on laisse les individuels
      }

      // Centroid pixel
      double sx = 0.0, sy = 0.0;
      for (final m in members) {
        final p = _project(m.position!);
        sx += p.dx;
        sy += p.dy;
      }
      final cx = sx / members.length;
      final cy = sy / members.length;
      final center = _unproject(ui.Offset(cx, cy));

      final count = members.length;
      final icon = await _getClusterIcon(count);
      if (_isDisposed) return;

      final clusterId = 'cluster_${entry.key}_$count';
      newClusterKeys.add(clusterId);

      // masquer les membres agrégés
      final memberKeys = bucketKeys[entry.key] ?? const <String>[];
      keysInClusters.addAll(memberKeys);

      newClusterMarkers[clusterId] = gmaps.Marker(
        markerId: gmaps.MarkerId(clusterId),
        position: center,
        icon: icon,
        zIndex: 6.0,
        onTap: () async {
          final ctrl = await _controllerOrNull();
          if (ctrl == null) return;
          // Zoom to bounds
          double minLat = 90.0, maxLat = -90.0, minLng = 180.0, maxLng = -180.0;
          for (final m in members) {
            minLat = math.min(minLat, m.position!.latitude);
            maxLat = math.max(maxLat, m.position!.latitude);
            minLng = math.min(minLng, m.position!.longitude);
            maxLng = math.max(maxLng, m.position!.longitude);
          }
          final bounds = gmaps.LatLngBounds(
            southwest: gmaps.LatLng(minLat, minLng),
            northeast: gmaps.LatLng(maxLat, maxLng),
          );
          await ctrl
              .animateCamera(gmaps.CameraUpdate.newLatLngBounds(bounds, 72));
        },
      );
    }

    _visibleClusterKeys = newClusterKeys;
    _clusterMarkerCache
      ..clear()
      ..addAll(newClusterMarkers);
    _keysInClusters = keysInClusters;
  }

  // ---------------- Icons ----------------

  double _zIndexForType(MapMarkerType type) {
    switch (type) {
      case MapMarkerType.professionalAlert:
        return 5;
      case MapMarkerType.user:
        return 4.5;
      case MapMarkerType.searchTarget:
        return 4;
      case MapMarkerType.weddingPin:
        return 3.5;
      case MapMarkerType.professional:
        return 3;
      case MapMarkerType.fixedLocation:
        return 2;
      case MapMarkerType.proRecent:
        return 1;
      case MapMarkerType.poiPrivate:
        return 0.5;
      default:
        return 0;
    }
  }

  Color _ringColorForType(MapMarkerType t) {
    switch (t) {
      case MapMarkerType.weddingPin:
        return Theme.of(context).primaryColor;
      case MapMarkerType.poiPrivate:
        return const Color(0xFF27AE60);
      case MapMarkerType.professionalAlert:
        return const Color(0xFFD81B60);
      default:
        return Colors.black87;
    }
  }

  Future<gmaps.BitmapDescriptor> _getMarkerIcon(MapMarkerStruct marker) async {
    double size;
    switch (marker.type ?? MapMarkerType.professional) {
      case MapMarkerType.professional:
      case MapMarkerType.fixedLocation:
      case MapMarkerType.proRecent:
        size = _sizePro;
        break;
      case MapMarkerType.weddingPin:
      case MapMarkerType.poiPrivate:
        size = _sizeWeddingPoi;
        break;
      case MapMarkerType.professionalAlert:
        size = _sizeAlert;
        break;
      case MapMarkerType.searchTarget:
        return gmaps.BitmapDescriptor.defaultMarkerWithHue(
            gmaps.BitmapDescriptor.hueViolet);
      default:
        size = _sizeWeddingPoi;
        break;
    }

    final cacheKey = [
      marker.type?.name ?? 'unknown',
      marker.id,
      marker.styleInfo?.avatarUrl ?? '',
      marker.styleInfo?.borderColorHex ?? '',
      Theme.of(context).primaryColor.value.toString(),
      size.toStringAsFixed(0),
    ].join('|');

    if (_iconCache.containsKey(cacheKey)) {
      return _iconCache[cacheKey]!;
    }

    final markerType = marker.type ?? MapMarkerType.professional;
    gmaps.BitmapDescriptor icon;

    switch (markerType) {
      case MapMarkerType.professional:
      case MapMarkerType.fixedLocation:
      case MapMarkerType.proRecent:
      case MapMarkerType.user:
        {
          final ring = marker.styleInfo?.borderColorHex != null
              ? _colorFromHex(marker.styleInfo!.borderColorHex!)
              : _ringColorForType(markerType);
          icon = await _generateAvatarIcon(
            imageUrl: marker.styleInfo?.avatarUrl,
            ringColor: ring,
            size: size,
            fallbackIcon: Icons.person_outline,
          );
          break;
        }
      case MapMarkerType.weddingPin:
        {
          final ring = _ringColorForType(markerType);
          icon = await _generateAvatarIcon(
            imageUrl: marker.styleInfo?.avatarUrl,
            ringColor: ring,
            size: size,
            fallbackIcon: Icons.favorite,
          );
          break;
        }
      case MapMarkerType.poiPrivate:
        {
          final ring = _ringColorForType(markerType);
          icon = await _generateAvatarIcon(
            imageUrl: marker.styleInfo?.avatarUrl,
            ringColor: ring,
            size: size,
            fallbackIcon: Icons.pin_drop,
          );
          break;
        }
      case MapMarkerType.professionalAlert:
        {
          final ring = _ringColorForType(markerType);
          icon = await _generateAvatarIcon(
            imageUrl: marker.styleInfo?.avatarUrl,
            ringColor: ring,
            size: size,
            fallbackIcon: Icons.crisis_alert_rounded,
          );
          break;
        }
      default:
        {
          icon = gmaps.BitmapDescriptor.defaultMarker;
        }
    }

    _iconCache[cacheKey] = icon;
    return icon;
  }

  Color _colorFromHex(String hex) {
    final value = hex.replaceFirst('#', '');
    if (value.length == 6) {
      return Color(int.parse('FF$value', radix: 16));
    } else if (value.length == 8) {
      return Color(int.parse(value, radix: 16));
    }
    return Colors.black;
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

      // ring
      paint.color = ringColor;
      canvas.drawCircle(center, radius, paint);

      // white bg
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
      final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
      if (pngBytes == null) return gmaps.BitmapDescriptor.defaultMarker;
      return gmaps.BitmapDescriptor.fromBytes(pngBytes.buffer.asUint8List());
    } catch (_) {
      return gmaps.BitmapDescriptor.defaultMarker;
    }
  }

  Future<Uint8List?> _fetchImageBytes(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) return response.bodyBytes;
    } catch (_) {}
    return null;
  }

  Future<gmaps.BitmapDescriptor> _getClusterIcon(int count) async {
    final capped = count > 99 ? 99 : count;
    if (_clusterIconCache.containsKey(capped)) {
      return _clusterIconCache[capped]!;
    }

    const double size = _sizeCluster;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;
    final center = ui.Offset(size / 2, size / 2);
    final radius = size / 2;

    // Cercle noir
    paint.color = Colors.black87;
    canvas.drawCircle(center, radius, paint);
    // Contour blanc
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.06
      ..color = Colors.white.withOpacity(0.85);
    canvas.drawCircle(center, radius - paint.strokeWidth / 2, paint);

    // Nombre
    final txt = count > 99 ? '99+' : '$count';
    final tp = TextPainter(
      text: TextSpan(
        text: txt,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 22,
          fontFamily: 'Haas Grot Text Trial',
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    final off = ui.Offset(center.dx - tp.width / 2, center.dy - tp.height / 2);
    tp.paint(canvas, off);

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final png = await img.toByteData(format: ui.ImageByteFormat.png);
    final icon = gmaps.BitmapDescriptor.fromBytes(png!.buffer.asUint8List());
    _clusterIconCache[capped] = icon;
    return icon;
  }

  @override
  Widget build(BuildContext context) {
    final cameraPosition = widget.initialCenter != null
        ? gmaps.CameraPosition(
            target: gmaps.LatLng(widget.initialCenter!.latitude,
                widget.initialCenter!.longitude),
            zoom: _initialZoom,
          )
        : const gmaps.CameraPosition(
            target: gmaps.LatLng(48.8566, 2.3522), zoom: 12.0);

    final allIndividuals = _visibleMarkerKeys
        .map((k) => _markerCache[k])
        .whereType<gmaps.Marker>()
        .toSet();

    // Toujours visibles: searchTarget & user
    final forceNoCluster = <gmaps.Marker>{};
    for (final k in _visibleMarkerKeys) {
      final d = _markerDataByKey[k];
      if (d == null) continue;
      final t = d.type ?? MapMarkerType.professional;
      if (t == MapMarkerType.searchTarget || t == MapMarkerType.user) {
        final m = _markerCache[k];
        if (m != null) forceNoCluster.add(m);
      }
    }

    final clusterMarkers = _visibleClusterKeys
        .map((k) => _clusterMarkerCache[k])
        .whereType<gmaps.Marker>()
        .toSet();

    final individualVisible = allIndividuals.where((m) {
      final key = m.markerId.value;
      return !_keysInClusters.contains(key);
    }).toSet();

    final markersSet = <gmaps.Marker>{}
      ..addAll(individualVisible)
      ..addAll(clusterMarkers)
      ..addAll(forceNoCluster);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          gmaps.GoogleMap(
            mapType: _gmapsTypeFrom(widget.mapStyle),
            initialCameraPosition: cameraPosition,
            onMapCreated: (ctrl) {
              if (!_controller.isCompleted) _controller.complete(ctrl);
              _handleCommandIfAny();
              _loadDataForCurrentViewport();
              _reconcileMarkers();
              _scheduleClusterRebuild();
            },
            myLocationEnabled: _enableMyLocationLayer,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            zoomControlsEnabled: false,
            markers: markersSet,
            circles: const <gmaps.Circle>{}, // aucun overlay
            onCameraIdle: () async {
              if (_isDisposed) return;
              _loadDataForCurrentViewport();
              _scheduleClusterRebuild();
            },
          ),
          if (_isInternalLoading)
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(4),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
