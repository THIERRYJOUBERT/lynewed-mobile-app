import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Returns [value] if not null and not empty (for strings), otherwise [defaultValue].
///
/// Example:
/// ```dart
/// valueOrDefault<String>(null, 'default') // 'default'
/// valueOrDefault<String>('', 'default')   // 'default'
/// valueOrDefault<String>('value', 'default') // 'value'
/// valueOrDefault<int>(null, 0) // 0
/// valueOrDefault<int>(42, 0) // 42
/// ```
T valueOrDefault<T>(T? value, T defaultValue) =>
    (value is String && value.isEmpty) || value == null ? defaultValue : value;

/// Safely casts [value] to type [T], handling common numeric conversions.
///
/// - For double: converts int to double if needed
/// - For int: converts double to int if it has no decimal part
/// - For other types: returns value as-is or null
///
/// Example:
/// ```dart
/// castToType<double>(42) // 42.0
/// castToType<int>(42.0) // 42
/// castToType<int>(42.5) // null (has decimal part)
/// ```
T? castToType<T>(dynamic value) {
  if (value == null) {
    return null;
  }
  switch (T) {
    case const (double):
      return (value as num).toDouble() as T;
    case const (int):
      if (value is num && value.toInt() == value) {
        return value.toInt() as T;
      }
      return null;
    default:
      return value as T;
  }
}

/// Returns the current timestamp.
DateTime get getCurrentTimestamp => DateTime.now();

/// Format types for number formatting.
enum FormatType {
  /// Standard decimal format (e.g., 1,234.56)
  decimal,

  /// Percentage format (e.g., 50%)
  percent,

  /// Scientific notation (e.g., 1.23E+3)
  scientific,

  /// Compact format (e.g., 1.2M)
  compact,

  /// Compact long format (e.g., 1.2 million)
  compactLong,

  /// Custom format with specified pattern
  custom,
}

/// Decimal separator types for number formatting.
enum DecimalType {
  /// Automatic based on locale
  automatic,

  /// Period as decimal separator (e.g., 1,234.56)
  periodDecimal,

  /// Comma as decimal separator (e.g., 1.234,56)
  commaDecimal,
}

void _setTimeagoLocales() {
  timeago.setLocaleMessages('en', timeago.EnMessages());
  timeago.setLocaleMessages('en_short', timeago.EnShortMessages());
}

/// Formats a [DateTime] according to the specified [format].
///
/// If [format] is 'relative', returns a relative time string (e.g., "2 hours ago").
/// Otherwise, uses the format string with [DateFormat].
///
/// Returns empty string if [dateTime] is null.
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

/// Formats a number according to the specified options.
///
/// Returns empty string if [value] is null.
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
        case DecimalType.periodDecimal:
          if (currency != null) {
            formattedValue = NumberFormat('#,##0.00', 'en_US').format(value);
          } else {
            formattedValue = NumberFormat.decimalPattern('en_US').format(value);
          }
        case DecimalType.commaDecimal:
          if (currency != null) {
            formattedValue = NumberFormat('#,##0.00', 'es_PA').format(value);
          } else {
            formattedValue = NumberFormat.decimalPattern('es_PA').format(value);
          }
      }
    case FormatType.percent:
      formattedValue = NumberFormat.percentPattern().format(value);
    case FormatType.scientific:
      formattedValue = NumberFormat.scientificPattern().format(value);
      if (toLowerCase) {
        formattedValue = formattedValue.toLowerCase();
      }
    case FormatType.compact:
      formattedValue = NumberFormat.compact().format(value);
    case FormatType.compactLong:
      formattedValue = NumberFormat.compactLong().format(value);
    case FormatType.custom:
      final hasLocale = locale != null && locale.isNotEmpty;
      formattedValue = NumberFormat(format, hasLocale ? locale : null).format(value);
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

/// Extension on [DateTime] for epoch conversion.
extension DateTimeConversionExtension on DateTime {
  /// Returns the number of seconds since epoch.
  int get secondsSinceEpoch => (millisecondsSinceEpoch / 1000).round();
}

/// Extension on [DateTime] for comparison operators.
extension DateTimeComparisonOperators on DateTime {
  /// Returns true if this date is before [other].
  bool operator <(DateTime other) => isBefore(other);

  /// Returns true if this date is after [other].
  bool operator >(DateTime other) => isAfter(other);

  /// Returns true if this date is before or at the same moment as [other].
  bool operator <=(DateTime other) => this < other || isAtSameMomentAs(other);

  /// Returns true if this date is after or at the same moment as [other].
  bool operator >=(DateTime other) => this > other || isAtSameMomentAs(other);
}

/// Extension on nullable [TextEditingController] for safe text access.
extension TextEditingControllerExtension on TextEditingController? {
  /// Returns the text or empty string if controller is null.
  String get text => this == null ? '' : this!.text;

  /// Sets the text if controller is not null.
  set text(String newText) => this?.text = newText;
}

/// Extension on [String] for text overflow handling.
extension StringExtension on String {
  /// Truncates the string to [maxChars] and appends [replacement] if needed.
  ///
  /// Example:
  /// ```dart
  /// 'Hello World'.maybeHandleOverflow(maxChars: 5) // 'Hello'
  /// 'Hello World'.maybeHandleOverflow(maxChars: 5, replacement: '...') // 'Hello...'
  /// ```
  String maybeHandleOverflow({int? maxChars, String replacement = ''}) =>
      maxChars != null && length > maxChars
          ? replaceRange(maxChars, null, replacement)
          : this;
}

/// Extension on [Iterable] for filtering null values.
extension ListFilterExtension<T> on Iterable<T?> {
  /// Returns a list with all null values removed.
  List<T> get withoutNulls => where((s) => s != null).map((e) => e!).toList();
}

/// Extension on [Map] for filtering null values.
extension MapFilterExtension<T> on Map<String, T?> {
  /// Returns a map with all null values removed.
  Map<String, T> get withoutNulls => Map.fromEntries(
        entries.where((e) => e.value != null).map((e) => MapEntry(e.key, e.value as T)),
      );
}

/// Extension on [Iterable] of widgets for layout operations.
extension ListDivideExtension<T extends Widget> on Iterable<T> {
  /// Returns an enumerated iterable with indices.
  Iterable<MapEntry<int, Widget>> get enumerate => toList().asMap().entries;

  /// Inserts [t] between each element.
  ///
  /// Optional [filterFn] can exclude dividers at certain indices.
  List<Widget> divide(Widget t, {bool Function(int)? filterFn}) => isEmpty
      ? []
      : (enumerate
          .map((e) => [e.value, if (filterFn == null || filterFn(e.key)) t])
          .expand((i) => i)
          .toList()
        ..removeLast());

  /// Returns a new list with [t] added at the start.
  List<Widget> addToStart(Widget t) => enumerate.map((e) => e.value).toList()..insert(0, t);

  /// Returns a new list with [t] added at the end.
  List<Widget> addToEnd(Widget t) => enumerate.map((e) => e.value).toList()..add(t);
}

/// Extension on [State] for safe setState calls.
extension StatefulWidgetExtensions on State<StatefulWidget> {
  /// Calls [setState] only if the widget is still mounted.
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      // ignore: invalid_use_of_protected_member
      setState(fn);
    }
  }
}
