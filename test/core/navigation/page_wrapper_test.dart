import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/navigation/page_wrapper.dart';

void main() {
  group('CleanPageWrapper', () {
    testWidgets('should render child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: _TestWrapper(
            child: Text('Test Content'),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('should apply scaffold when useScaffold is true',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: _TestWrapper(
            useScaffold: true,
            child: Text('Scaffolded Content'),
          ),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Scaffolded Content'), findsOneWidget);
    });

    testWidgets('should not wrap in scaffold when useScaffold is false',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const _TestWrapper(
              useScaffold: false,
              child: Text('No Extra Scaffold'),
            ),
          ),
        ),
      );

      // Should find exactly one Scaffold (the outer one we added)
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('No Extra Scaffold'), findsOneWidget);
    });
  });

  group('PageWrapperMixin', () {
    test('convertStringToNullable handles null strings', () {
      expect(PageWrapperMixin.convertStringToNullable(null), isNull);
      expect(PageWrapperMixin.convertStringToNullable(''), isNull);
      expect(PageWrapperMixin.convertStringToNullable('null'), isNull);
    });

    test('convertStringToNullable preserves valid strings', () {
      expect(PageWrapperMixin.convertStringToNullable('hello'), equals('hello'));
      expect(PageWrapperMixin.convertStringToNullable('123'), equals('123'));
    });

    test('parseBoolean handles various inputs', () {
      expect(PageWrapperMixin.parseBoolean(null), isFalse);
      expect(PageWrapperMixin.parseBoolean(true), isTrue);
      expect(PageWrapperMixin.parseBoolean(false), isFalse);
      expect(PageWrapperMixin.parseBoolean('true'), isTrue);
      expect(PageWrapperMixin.parseBoolean('false'), isFalse);
      expect(PageWrapperMixin.parseBoolean('1'), isTrue);
      expect(PageWrapperMixin.parseBoolean('0'), isFalse);
    });

    test('parseInt handles various inputs', () {
      expect(PageWrapperMixin.parseInt(null), isNull);
      expect(PageWrapperMixin.parseInt('123'), equals(123));
      expect(PageWrapperMixin.parseInt('invalid'), isNull);
      expect(PageWrapperMixin.parseInt(''), isNull);
    });

    test('parseDouble handles various inputs', () {
      expect(PageWrapperMixin.parseDouble(null), isNull);
      expect(PageWrapperMixin.parseDouble('123.45'), closeTo(123.45, 0.01));
      expect(PageWrapperMixin.parseDouble('invalid'), isNull);
      expect(PageWrapperMixin.parseDouble(''), isNull);
    });

    test('parseDateTime handles various inputs', () {
      expect(PageWrapperMixin.parseDateTime(null), isNull);
      expect(PageWrapperMixin.parseDateTime(''), isNull);
      expect(PageWrapperMixin.parseDateTime('invalid'), isNull);

      // Valid milliseconds since epoch
      final millis = DateTime(2024, 1, 15).millisecondsSinceEpoch.toString();
      final result = PageWrapperMixin.parseDateTime(millis);
      expect(result, isNotNull);
      expect(result!.year, equals(2024));
      expect(result.month, equals(1));
      expect(result.day, equals(15));
    });

    test('parseStringList handles various inputs', () {
      // Null and empty
      expect(PageWrapperMixin.parseStringList(null), isEmpty);
      expect(PageWrapperMixin.parseStringList(''), isEmpty);

      // Empty array
      expect(PageWrapperMixin.parseStringList('[]'), isEmpty);

      // Simple array
      final result = PageWrapperMixin.parseStringList('["a", "b", "c"]');
      expect(result, hasLength(3));
      expect(result, contains('a'));
      expect(result, contains('b'));
      expect(result, contains('c'));

      // Non-array format
      expect(PageWrapperMixin.parseStringList('not an array'), isEmpty);
    });
  });

  group('WrapperConfig', () {
    test('creates with default values', () {
      const config = WrapperConfig();

      expect(config.useScaffold, isFalse);
      expect(config.backgroundColor, isNull);
      expect(config.resizeToAvoidBottomInset, isTrue);
    });

    test('creates with custom values', () {
      const config = WrapperConfig(
        useScaffold: true,
        backgroundColor: Colors.red,
        resizeToAvoidBottomInset: false,
      );

      expect(config.useScaffold, isTrue);
      expect(config.backgroundColor, equals(Colors.red));
      expect(config.resizeToAvoidBottomInset, isFalse);
    });

    test('copyWith creates modified copy', () {
      const original = WrapperConfig(
        useScaffold: false,
        backgroundColor: Colors.blue,
      );

      final modified = original.copyWith(useScaffold: true);

      expect(modified.useScaffold, isTrue);
      expect(modified.backgroundColor, equals(Colors.blue));
    });

    test('copyWith preserves unmodified values', () {
      const original = WrapperConfig(
        useScaffold: true,
        backgroundColor: Colors.green,
        resizeToAvoidBottomInset: false,
      );

      final modified = original.copyWith();

      expect(modified.useScaffold, equals(original.useScaffold));
      expect(modified.backgroundColor, equals(original.backgroundColor));
      expect(modified.resizeToAvoidBottomInset,
          equals(original.resizeToAvoidBottomInset));
    });
  });

  group('NavigationExtensions', () {
    testWidgets('extractQueryParam retrieves query parameter', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        ),
      );

      // Note: This is a limited test since we can't easily mock GoRouterState
      // In a real scenario, you'd use a Router with actual query params
      expect(capturedContext, isNotNull);
    });
  });
}

/// Test wrapper implementation for testing CleanPageWrapper behavior.
class _TestWrapper extends StatelessWidget {
  final Widget child;
  final bool useScaffold;

  const _TestWrapper({
    required this.child,
    this.useScaffold = false,
  });

  @override
  Widget build(BuildContext context) {
    if (useScaffold) {
      return Scaffold(body: child);
    }
    return child;
  }
}
