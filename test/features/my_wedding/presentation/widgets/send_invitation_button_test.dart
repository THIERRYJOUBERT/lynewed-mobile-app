/// Tests for SendInvitationButton widget.
///
/// Verifies button behavior for different states and interactions.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/core.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/wedding_guest.dart';
import 'package:lynewed_beta/features/my_wedding/domain/usecases/send_guest_invitation.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/widgets/send_invitation_button.dart';
import 'package:mocktail/mocktail.dart';

class MockSendGuestInvitation extends Mock implements SendGuestInvitation {}

class FakeSendInvitationParams extends Fake implements SendInvitationParams {}

void main() {
  late MockSendGuestInvitation mockUseCase;

  setUpAll(() {
    registerFallbackValue(FakeSendInvitationParams());
  });

  setUp(() {
    mockUseCase = MockSendGuestInvitation();
  });

  Widget buildTestWidget({
    String guestId = 'guest-123',
    String weddingId = 'wedding-456',
    String? guestEmail,
    GuestStatus guestStatus = GuestStatus.pending,
    VoidCallback? onSuccess,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SendInvitationButton(
          guestId: guestId,
          weddingId: weddingId,
          guestEmail: guestEmail,
          guestStatus: guestStatus,
          onSuccess: onSuccess,
          sendGuestInvitation: mockUseCase,
        ),
      ),
    );
  }

  group('SendInvitationButton', () {
    group('No email', () {
      testWidgets('should show hint text when email is null', (tester) async {
        await tester.pumpWidget(buildTestWidget(guestEmail: null));

        expect(
          find.text('Ajoutez un email pour envoyer une invitation'),
          findsOneWidget,
        );
        expect(find.byType(ElevatedButton), findsNothing);
      });

      testWidgets('should show hint text when email is empty', (tester) async {
        await tester.pumpWidget(buildTestWidget(guestEmail: ''));

        expect(
          find.text('Ajoutez un email pour envoyer une invitation'),
          findsOneWidget,
        );
      });
    });

    group('With email - pending status', () {
      testWidgets('should display "Envoyer l\'invitation" button',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(
          guestEmail: 'test@example.com',
          guestStatus: GuestStatus.pending,
        ));

        expect(find.text("Envoyer l'invitation"), findsOneWidget);
        expect(find.byIcon(Icons.send), findsOneWidget);
      });
    });

    group('With email - invited status', () {
      testWidgets('should display "Renvoyer l\'invitation" button',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(
          guestEmail: 'test@example.com',
          guestStatus: GuestStatus.invited,
        ));

        expect(find.text("Renvoyer l'invitation"), findsOneWidget);
      });
    });

    group('Interaction', () {
      testWidgets('should show loading state when sending', (tester) async {
        final completer = Completer<Result<void>>();
        when(() => mockUseCase(any())).thenAnswer((_) => completer.future);

        await tester.pumpWidget(buildTestWidget(
          guestEmail: 'test@example.com',
        ));

        await tester.tap(find.text("Envoyer l'invitation"));
        await tester.pump();

        // Should show loading spinner
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Complete the future to finish the test properly
        completer.complete(const Success(null));
        await tester.pumpAndSettle();
      });

      testWidgets('should show success snackbar on success', (tester) async {
        when(() => mockUseCase(any())).thenAnswer(
          (_) async => const Success(null),
        );

        await tester.pumpWidget(buildTestWidget(
          guestEmail: 'test@example.com',
        ));

        await tester.tap(find.text("Envoyer l'invitation"));
        await tester.pumpAndSettle();

        expect(find.text('Invitation envoyée !'), findsOneWidget);
      });

      testWidgets('should call onSuccess callback on success', (tester) async {
        when(() => mockUseCase(any())).thenAnswer(
          (_) async => const Success(null),
        );

        var successCalled = false;
        await tester.pumpWidget(buildTestWidget(
          guestEmail: 'test@example.com',
          onSuccess: () => successCalled = true,
        ));

        await tester.tap(find.text("Envoyer l'invitation"));
        await tester.pumpAndSettle();

        expect(successCalled, isTrue);
      });

      testWidgets('should show error snackbar on failure', (tester) async {
        when(() => mockUseCase(any())).thenAnswer(
          (_) async => const Failure(
            InvitationFailure(message: 'Adresse email invalide'),
          ),
        );

        await tester.pumpWidget(buildTestWidget(
          guestEmail: 'test@example.com',
        ));

        await tester.tap(find.text("Envoyer l'invitation"));
        await tester.pumpAndSettle();

        expect(find.text('Adresse email invalide'), findsOneWidget);
      });

      testWidgets('should pass correct params to use case', (tester) async {
        when(() => mockUseCase(any())).thenAnswer(
          (_) async => const Success(null),
        );

        await tester.pumpWidget(buildTestWidget(
          guestId: 'my-guest-id',
          weddingId: 'my-wedding-id',
          guestEmail: 'test@example.com',
        ));

        await tester.tap(find.text("Envoyer l'invitation"));
        await tester.pumpAndSettle();

        final captured = verify(() => mockUseCase(captureAny())).captured;
        final params = captured.first as SendInvitationParams;
        expect(params.guestId, 'my-guest-id');
        expect(params.weddingId, 'my-wedding-id');
      });
    });
  });
}
