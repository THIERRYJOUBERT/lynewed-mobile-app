/// Tests for UpgradeConfirmationDialog widget.
///
/// Verifies dialog display and interaction.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/guest/presentation/widgets/upgrade_confirmation_dialog.dart';

void main() {
  group('UpgradeConfirmationDialog', () {
    Widget buildTestWidget({VoidCallback? onConfirm}) {
      return MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => UpgradeConfirmationDialog(
                  onConfirm: onConfirm ?? () {},
                ),
              ),
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );
    }

    group('Display', () {
      testWidgets('should display title', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('Passer en compte Mariée'), findsOneWidget);
      });

      testWidgets('should display warning message', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('cette action est irréversible'),
          findsOneWidget,
        );
      });

      testWidgets('should display preservation info', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Vous conserverez vos photos'),
          findsOneWidget,
        );
      });

      testWidgets('should display cancel button', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('Annuler'), findsOneWidget);
      });

      testWidgets('should display confirm button', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('Je confirme'), findsOneWidget);
      });

      testWidgets('should display warning icon', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      });
    });

    group('Interaction', () {
      testWidgets('should close dialog when cancel tapped', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('Passer en compte Mariée'), findsOneWidget);

        await tester.tap(find.text('Annuler'));
        await tester.pumpAndSettle();

        expect(find.text('Passer en compte Mariée'), findsNothing);
      });

      testWidgets('should call onConfirm when confirm tapped', (tester) async {
        var confirmCalled = false;
        await tester.pumpWidget(buildTestWidget(
          onConfirm: () => confirmCalled = true,
        ));

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Je confirme'));
        await tester.pumpAndSettle();

        expect(confirmCalled, isTrue);
      });
    });
  });
}
