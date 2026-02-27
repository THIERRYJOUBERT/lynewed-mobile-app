/// Tests for MessagesPage - Tab visibility based on user role.
///
/// Verifies that the Marketplace chip is hidden for professional users
/// and visible for bride users.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/design/widgets/lynewed_chip.dart';
import 'package:lynewed_beta/features/auth/domain/entities/entities.dart';
import 'package:lynewed_beta/features/auth/domain/repositories/auth_repository.dart';
import 'package:lynewed_beta/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:lynewed_beta/features/auth/presentation/bloc/auth_state.dart';
import 'package:lynewed_beta/features/chat/domain/repositories/chat_repository.dart';
import 'package:lynewed_beta/features/chat/domain/repositories/contact_repository.dart';
import 'package:lynewed_beta/features/chat/presentation/bloc/conversations_cubit.dart';
import 'package:lynewed_beta/features/chat/presentation/bloc/conversations_state.dart';
import 'package:lynewed_beta/features/chat/presentation/pages/messages_page.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockChatRepository extends Mock implements ChatRepository {}

class MockContactRepository extends Mock implements ContactRepository {}

/// Finds a LynewedChip with a specific label text.
Finder findChipWithLabel(String label) {
  return find.ancestor(
    of: find.text(label),
    matching: find.byType(LynewedChip),
  );
}

void main() {
  late MockAuthRepository mockAuthRepository;
  late StreamController<AuthUser?> authStateController;

  final testUser = AuthUser(
    id: 'test-user-id',
    email: 'test@example.com',
    createdAt: DateTime(2024, 1, 1),
  );

  final brideProfile = UserProfile(
    id: 'profile-1',
    authUserId: 'test-user-id',
    role: UserRole.bride,
    displayName: 'Sarah Johnson',
    isOnboardingComplete: true,
    createdAt: DateTime(2024, 1, 1),
  );

  final proProfile = UserProfile(
    id: 'profile-2',
    authUserId: 'test-user-id',
    role: UserRole.professional,
    displayName: 'Jean Photography',
    isOnboardingComplete: true,
    createdAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authStateController = StreamController<AuthUser?>.broadcast();

    when(() => mockAuthRepository.watchAuthState())
        .thenAnswer((_) => authStateController.stream);
  });

  tearDown(() {
    authStateController.close();
  });

  ConversationsNotifier createLoadedNotifier() {
    final notifier = ConversationsNotifier(
      chatRepository: MockChatRepository(),
      contactRepository: MockContactRepository(),
    );
    notifier.testState = const ConversationsLoaded(
      conversations: [],
      pendingRequests: [],
      blockedUsers: [],
    );
    return notifier;
  }

  Widget buildTestWidget({
    required AuthCubit authCubit,
    required ConversationsNotifier notifier,
  }) {
    return MaterialApp(
      home: BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: MessagesPage(notifier: notifier),
      ),
    );
  }

  group('MessagesPage - Tab Visibility', () {
    testWidgets('should hide Marketplace chip for professional user',
        (tester) async {
      final authCubit = AuthCubit(repository: mockAuthRepository);
      authCubit.emit(Authenticated(user: testUser, profile: proProfile));

      final notifier = createLoadedNotifier();

      await tester.pumpWidget(buildTestWidget(
        authCubit: authCubit,
        notifier: notifier,
      ));
      await tester.pump();

      expect(findChipWithLabel('Marketplace'), findsNothing);
      expect(findChipWithLabel('Messages'), findsOneWidget);
      expect(findChipWithLabel('Wedding'), findsOneWidget);

      authCubit.close();
      notifier.dispose();
    });

    testWidgets('should show Marketplace chip for bride user',
        (tester) async {
      final authCubit = AuthCubit(repository: mockAuthRepository);
      authCubit.emit(Authenticated(user: testUser, profile: brideProfile));

      final notifier = createLoadedNotifier();

      await tester.pumpWidget(buildTestWidget(
        authCubit: authCubit,
        notifier: notifier,
      ));
      await tester.pump();

      expect(findChipWithLabel('Marketplace'), findsOneWidget);
      expect(findChipWithLabel('Messages'), findsOneWidget);
      expect(findChipWithLabel('Wedding'), findsOneWidget);

      authCubit.close();
      notifier.dispose();
    });

    testWidgets('should show all 3 chips when auth state is initial',
        (tester) async {
      final authCubit = AuthCubit(repository: mockAuthRepository);

      final notifier = createLoadedNotifier();

      await tester.pumpWidget(buildTestWidget(
        authCubit: authCubit,
        notifier: notifier,
      ));
      await tester.pump();

      expect(findChipWithLabel('Marketplace'), findsOneWidget);
      expect(findChipWithLabel('Messages'), findsOneWidget);
      expect(findChipWithLabel('Wedding'), findsOneWidget);

      authCubit.close();
      notifier.dispose();
    });
  });
}
