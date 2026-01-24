import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import 'lat_lng.dart';

export 'lat_lng.dart';
export 'place.dart';
export 'uploaded_file.dart';
export '../app_state.dart';
export '../app_constants.dart';
export 'flutter_flow_model.dart';
export 'dart:math' show min, max;
export 'dart:typed_data' show Uint8List;
export 'dart:convert' show jsonEncode, jsonDecode;
export 'package:intl/intl.dart';
export 'package:page_transition/page_transition.dart';
export 'internationalization.dart' show FFLocalizations;
export 'nav/nav.dart';

T valueOrDefault<T>(T? value, T defaultValue) =>
    (value is String && value.isEmpty) || value == null ? defaultValue : value;

void _setTimeagoLocales() {
  timeago.setLocaleMessages('en', timeago.EnMessages());
  timeago.setLocaleMessages('en_short', timeago.EnShortMessages());
}

String dateTimeFormat(String format, DateTime? dateTime, {String? locale}) {
  if (dateTime == null) {
    return '';
  }
  if (format == 'relative') {
    _setTimeagoLocales();
    return timeago.format(dateTime, locale: locale, allowFromNow: true);
  }
  return DateFormat(format, locale).format(dateTime);
}

Future launchURL(String url) async {
  var uri = Uri.parse(url);
  try {
    await launchUrl(uri);
  } catch (e) {
    throw 'Could not launch $uri: $e';
  }
}

enum FormatType {
  decimal,
  percent,
  scientific,
  compact,
  compactLong,
  custom,
}

enum DecimalType {
  automatic,
  periodDecimal,
  commaDecimal,
}

String formatNumber(
  num? value, {
  required FormatType formatType,
  DecimalType? decimalType,
  String? currency,
  bool toLowerCase = false,
  String? format,
  String? locale,
}) {
  if (value == null) {
    return '';
  }
  var formattedValue = '';
  switch (formatType) {
    case FormatType.decimal:
      switch (decimalType!) {
        case DecimalType.automatic:
          formattedValue = NumberFormat.decimalPattern().format(value);
          break;
        case DecimalType.periodDecimal:
          if (currency != null) {
            formattedValue = NumberFormat('#,##0.00', 'en_US').format(value);
          } else {
            formattedValue = NumberFormat.decimalPattern('en_US').format(value);
          }
          break;
        case DecimalType.commaDecimal:
          if (currency != null) {
            formattedValue = NumberFormat('#,##0.00', 'es_PA').format(value);
          } else {
            formattedValue = NumberFormat.decimalPattern('es_PA').format(value);
          }
          break;
      }
      break;
    case FormatType.percent:
      formattedValue = NumberFormat.percentPattern().format(value);
      break;
    case FormatType.scientific:
      formattedValue = NumberFormat.scientificPattern().format(value);
      if (toLowerCase) {
        formattedValue = formattedValue.toLowerCase();
      }
      break;
    case FormatType.compact:
      formattedValue = NumberFormat.compact().format(value);
      break;
    case FormatType.compactLong:
      formattedValue = NumberFormat.compactLong().format(value);
      break;
    case FormatType.custom:
      final hasLocale = locale != null && locale.isNotEmpty;
      formattedValue =
          NumberFormat(format, hasLocale ? locale : null).format(value);
  }

  if (formattedValue.isEmpty) {
    return value.toString();
  }

  if (currency != null) {
    final currencySymbol = currency.isNotEmpty
        ? currency
        : NumberFormat.simpleCurrency().format(0.0).substring(0, 1);
    formattedValue = '$currencySymbol$formattedValue';
  }

  return formattedValue;
}

DateTime get getCurrentTimestamp => DateTime.now();

extension DateTimeConversionExtension on DateTime {
  int get secondsSinceEpoch => (millisecondsSinceEpoch / 1000).round();
}

extension DateTimeComparisonOperators on DateTime {
  bool operator <(DateTime other) => isBefore(other);
  bool operator >(DateTime other) => isAfter(other);
  bool operator <=(DateTime other) => this < other || isAtSameMomentAs(other);
  bool operator >=(DateTime other) => this > other || isAtSameMomentAs(other);
}

T? castToType<T>(dynamic value) {
  if (value == null) {
    return null;
  }
  switch (T) {
    case const (double):
      // Doubles may be stored as ints in some cases.
      return value.toDouble() as T;
    case const (int):
      // Likewise, ints may be stored as doubles. If this is the case
      // (i.e. no decimal value), return the value as an int.
      if (value is num && value.toInt() == value) {
        return value.toInt() as T;
      }
      break;
    default:
      break;
  }
  return value as T;
}

bool get isAndroid => !kIsWeb && Platform.isAndroid;
bool get isiOS => !kIsWeb && Platform.isIOS;

LatLng? cachedUserLocation;
Future<LatLng> getCurrentUserLocation(
    {required LatLng defaultLocation, bool cached = false}) async {
  if (cached && cachedUserLocation != null) {
    return cachedUserLocation!;
  }
  return queryCurrentUserLocation().then((loc) {
    if (loc != null) {
      cachedUserLocation = loc;
    }
    return loc ?? defaultLocation;
  }).onError((error, _) {
    return defaultLocation;
  });
}

Future<LatLng?> queryCurrentUserLocation() async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  final position = await Geolocator.getCurrentPosition();
  return position.latitude != 0 && position.longitude != 0
      ? LatLng(position.latitude, position.longitude)
      : null;
}

extension FFTextEditingControllerExt on TextEditingController? {
  String get text => this == null ? '' : this!.text;
  set text(String newText) => this?.text = newText;
}

extension FFStringExt on String {
  String maybeHandleOverflow({int? maxChars, String replacement = ''}) =>
      maxChars != null && length > maxChars
          ? replaceRange(maxChars, null, replacement)
          : this;
}

extension ListFilterExt<T> on Iterable<T?> {
  List<T> get withoutNulls => where((s) => s != null).map((e) => e!).toList();
}

extension MapFilterExtensions<T> on Map<String, T?> {
  Map<String, T> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value as T)),
      );
}

extension ListDivideExt<T extends Widget> on Iterable<T> {
  Iterable<MapEntry<int, Widget>> get enumerate => toList().asMap().entries;

  List<Widget> divide(Widget t, {bool Function(int)? filterFn}) => isEmpty
      ? []
      : (enumerate
          .map((e) => [e.value, if (filterFn == null || filterFn(e.key)) t])
          .expand((i) => i)
          .toList()
        ..removeLast());

  List<Widget> addToStart(Widget t) =>
      enumerate.map((e) => e.value).toList()..insert(0, t);

  List<Widget> addToEnd(Widget t) =>
      enumerate.map((e) => e.value).toList()..add(t);
}

extension StatefulWidgetExtensions on State<StatefulWidget> {
  /// Check if the widget exist before safely setting state.
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      // ignore: invalid_use_of_protected_member
      setState(fn);
    }
  }
}

// For iOS 16 and below, set the status bar color to match the app's theme.
// https://github.com/flutter/flutter/issues/41067
Brightness? _lastBrightness;
void fixStatusBarOniOS16AndBelow(BuildContext context) {
  if (!isiOS) {
    return;
  }
  final brightness = Theme.of(context).brightness;
  if (_lastBrightness != brightness) {
    _lastBrightness = brightness;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: brightness,
        systemStatusBarContrastEnforced: true,
      ),
    );
  }
}

