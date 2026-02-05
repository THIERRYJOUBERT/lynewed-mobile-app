/// Tests for CgvuAcceptanceWidget.
///
/// Verifies CGVU text display, checkbox behavior, and already-accepted state.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/cgvu_acceptance_widget.dart';

void main() {
  group('CgvuAcceptanceWidget', () {
    Widget buildWidget({
      bool hasAccepted = false,
      bool isChecked = false,
      bool alreadyAccepted = false,
      ValueChanged<bool>? onCheckedChanged,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CgvuAcceptanceWidget(
              hasAccepted: hasAccepted,
              isChecked: isChecked,
              onCheckedChanged: onCheckedChanged ?? (_) {},
              alreadyAccepted: alreadyAccepted,
            ),
          ),
        ),
      );
    }

    group('rendering', () {
      testWidgets('should show section title', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        expect(find.text('Terms and Conditions'), findsOneWidget);
      });
    });

    group('new acceptance required', () {
      testWidgets('should show CGVU text when not already accepted',
          (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        // Should show the marketplace buyer CGVU text.
        expect(
          find.textContaining('LYNEWED MARKETPLACE'),
          findsOneWidget,
        );
      });

      testWidgets('should show checkbox when not already accepted',
          (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        expect(find.byType(Checkbox), findsOneWidget);
        expect(
          find.textContaining('I have read and accept'),
          findsOneWidget,
        );
      });

      testWidgets('should call onCheckedChanged when checkbox tapped',
          (tester) async {
        bool? checked;
        await tester.pumpWidget(buildWidget(
          onCheckedChanged: (value) => checked = value,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        expect(checked, isTrue);
      });

      testWidgets('should show checked checkbox when isChecked is true',
          (tester) async {
        await tester.pumpWidget(buildWidget(isChecked: true));
        await tester.pumpAndSettle();

        final checkbox =
            tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, isTrue);
      });
    });

    group('already accepted', () {
      testWidgets('should show already accepted message', (tester) async {
        await tester.pumpWidget(buildWidget(alreadyAccepted: true));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('already accepted'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('should not show checkbox when already accepted',
          (tester) async {
        await tester.pumpWidget(buildWidget(alreadyAccepted: true));
        await tester.pumpAndSettle();

        expect(find.byType(Checkbox), findsNothing);
      });

      testWidgets('should not show CGVU text when already accepted',
          (tester) async {
        await tester.pumpWidget(buildWidget(alreadyAccepted: true));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('LYNEWED MARKETPLACE'),
          findsNothing,
        );
      });
    });
  });
}
