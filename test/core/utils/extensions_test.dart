import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/utils/extensions.dart';

void main() {
  group('Extensions', () {
    group('valueOrDefault', () {
      test('should return value when not null', () {
        expect(valueOrDefault<int>(42, 0), 42);
        expect(valueOrDefault<String>('hello', ''), 'hello');
      });

      test('should return default when value is null', () {
        expect(valueOrDefault<int>(null, 0), 0);
        expect(valueOrDefault<String>(null, 'default'), 'default');
      });

      test('should return default when string is empty', () {
        expect(valueOrDefault<String>('', 'default'), 'default');
      });
    });

    group('castToType', () {
      test('should return null for null input', () {
        expect(castToType<int>(null), isNull);
        expect(castToType<double>(null), isNull);
      });

      test('should convert int to double', () {
        expect(castToType<double>(42), 42.0);
      });

      test('should convert double to int when no decimal', () {
        expect(castToType<int>(42.0), 42);
      });

      test('should return value as-is for matching type', () {
        expect(castToType<String>('hello'), 'hello');
        expect(castToType<bool>(true), true);
      });
    });

    group('DateTimeConversionExtension', () {
      test('should calculate seconds since epoch', () {
        final dateTime = DateTime.fromMillisecondsSinceEpoch(5000);
        expect(dateTime.secondsSinceEpoch, 5);
      });
    });

    group('DateTimeComparisonOperators', () {
      test('should compare dates with < operator', () {
        final earlier = DateTime(2023, 1, 1);
        final later = DateTime(2023, 12, 31);

        expect(earlier < later, isTrue);
        expect(later < earlier, isFalse);
      });

      test('should compare dates with > operator', () {
        final earlier = DateTime(2023, 1, 1);
        final later = DateTime(2023, 12, 31);

        expect(later > earlier, isTrue);
        expect(earlier > later, isFalse);
      });

      test('should compare dates with <= operator', () {
        final date1 = DateTime(2023, 1, 1);
        final date2 = DateTime(2023, 1, 1);
        final date3 = DateTime(2023, 12, 31);

        expect(date1 <= date2, isTrue);
        expect(date1 <= date3, isTrue);
        expect(date3 <= date1, isFalse);
      });

      test('should compare dates with >= operator', () {
        final date1 = DateTime(2023, 1, 1);
        final date2 = DateTime(2023, 1, 1);
        final date3 = DateTime(2023, 12, 31);

        expect(date1 >= date2, isTrue);
        expect(date3 >= date1, isTrue);
        expect(date1 >= date3, isFalse);
      });
    });

    group('TextEditingControllerExtension', () {
      test('should return empty string for null controller', () {
        const TextEditingController? controller = null;
        expect(controller.text, '');
      });

      test('should return text for non-null controller', () {
        final controller = TextEditingController(text: 'hello');
        expect(controller.text, 'hello');
      });

      test('should set text on controller', () {
        final controller = TextEditingController();
        controller.text = 'new text';
        expect(controller.text, 'new text');
      });
    });

    group('StringExtension', () {
      test('should truncate string with overflow', () {
        const str = 'Hello World';
        expect(str.maybeHandleOverflow(maxChars: 5), 'Hello');
        expect(str.maybeHandleOverflow(maxChars: 5, replacement: '...'), 'Hello...');
      });

      test('should not modify string when under limit', () {
        const str = 'Hello';
        expect(str.maybeHandleOverflow(maxChars: 10), 'Hello');
      });

      test('should not modify string when maxChars is null', () {
        const str = 'Hello World';
        expect(str.maybeHandleOverflow(), 'Hello World');
      });
    });

    group('ListFilterExtension', () {
      test('should filter out null values', () {
        final list = [1, null, 2, null, 3];
        expect(list.withoutNulls, [1, 2, 3]);
      });

      test('should return empty list when all nulls', () {
        final list = [null, null, null];
        expect(list.withoutNulls, isEmpty);
      });
    });

    group('MapFilterExtension', () {
      test('should filter out null values from map', () {
        final map = {'a': 1, 'b': null, 'c': 3};
        expect(map.withoutNulls, {'a': 1, 'c': 3});
      });

      test('should return empty map when all values are null', () {
        final map = <String, int?>{'a': null, 'b': null};
        expect(map.withoutNulls, isEmpty);
      });
    });

    group('ListDivideExtension', () {
      test('should enumerate list with index', () {
        final widgets = [const Text('a'), const Text('b'), const Text('c')];
        final enumerated = widgets.enumerate.toList();

        expect(enumerated.length, 3);
        expect(enumerated[0].key, 0);
        expect(enumerated[1].key, 1);
        expect(enumerated[2].key, 2);
      });

      test('should divide list with separator', () {
        final widgets = [const Text('a'), const Text('b'), const Text('c')];
        final divider = Container();
        final divided = widgets.divide(divider);

        // Expected: [Text('a'), Divider, Text('b'), Divider, Text('c')]
        expect(divided.length, 5);
      });

      test('should return empty list when dividing empty list', () {
        final List<Text> widgets = [];
        final divided = widgets.divide(Container());
        expect(divided, isEmpty);
      });

      test('should add widget to start', () {
        final widgets = [const Text('a'), const Text('b')];
        final header = const Text('header');
        final result = widgets.addToStart(header);

        expect(result.length, 3);
        expect(result.first, header);
      });

      test('should add widget to end', () {
        final widgets = [const Text('a'), const Text('b')];
        final footer = const Text('footer');
        final result = widgets.addToEnd(footer);

        expect(result.length, 3);
        expect(result.last, footer);
      });
    });

    group('FormatType', () {
      test('should have all format types', () {
        expect(FormatType.values, contains(FormatType.decimal));
        expect(FormatType.values, contains(FormatType.percent));
        expect(FormatType.values, contains(FormatType.scientific));
        expect(FormatType.values, contains(FormatType.compact));
        expect(FormatType.values, contains(FormatType.compactLong));
        expect(FormatType.values, contains(FormatType.custom));
      });
    });

    group('DecimalType', () {
      test('should have all decimal types', () {
        expect(DecimalType.values, contains(DecimalType.automatic));
        expect(DecimalType.values, contains(DecimalType.periodDecimal));
        expect(DecimalType.values, contains(DecimalType.commaDecimal));
      });
    });

    group('formatNumber', () {
      test('should return empty string for null value', () {
        expect(
          formatNumber(null, formatType: FormatType.decimal, decimalType: DecimalType.automatic),
          '',
        );
      });

      test('should format decimal with automatic type', () {
        final result = formatNumber(
          1234.56,
          formatType: FormatType.decimal,
          decimalType: DecimalType.automatic,
        );
        expect(result, isNotEmpty);
      });

      test('should format percent', () {
        final result = formatNumber(0.5, formatType: FormatType.percent);
        expect(result, contains('50'));
      });

      test('should format compact', () {
        final result = formatNumber(1000000, formatType: FormatType.compact);
        expect(result, isNotEmpty);
        // Compact format should shorten the number
        expect(result.length, lessThan(8));
      });

      test('should add currency symbol', () {
        final result = formatNumber(
          100,
          formatType: FormatType.decimal,
          decimalType: DecimalType.periodDecimal,
          currency: '\$',
        );
        expect(result, contains('\$'));
      });
    });

    group('dateTimeFormat', () {
      test('should return empty string for null dateTime', () {
        expect(dateTimeFormat('yyyy-MM-dd', null), '');
      });

      test('should format with standard pattern', () {
        final date = DateTime(2023, 6, 15);
        expect(dateTimeFormat('yyyy-MM-dd', date), '2023-06-15');
      });

      test('should format with relative time', () {
        final recentDate = DateTime.now().subtract(const Duration(hours: 1));
        final result = dateTimeFormat('relative', recentDate);
        expect(result, isNotEmpty);
      });
    });

    group('getCurrentTimestamp', () {
      test('should return current DateTime', () {
        final before = DateTime.now();
        final current = getCurrentTimestamp;
        final after = DateTime.now();

        expect(current.isAfter(before) || current.isAtSameMomentAs(before), isTrue);
        expect(current.isBefore(after) || current.isAtSameMomentAs(after), isTrue);
      });
    });
  });
}
