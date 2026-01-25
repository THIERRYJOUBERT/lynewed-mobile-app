import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/core.dart';
import 'package:lynewed_beta/features/auth/domain/entities/entities.dart';
import 'package:lynewed_beta/features/auth/domain/repositories/auth_repository.dart';
import 'package:lynewed_beta/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:lynewed_beta/features/auth/presentation/bloc/auth_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late StreamController<AuthUser?> authStateController;

  setUp(() {
    mockRepository = MockAuthRepository();
    authStateController = StreamController<AuthUser?>.broadcast();
    when(() => mockRepository.watchAuthState())
        .thenAnswer((_) => authStateController.stream);
  });

  tearDown(() {
    authStateController.close();
  });

  group('AC-5: Provider integration', () {
    testWidgets('AuthCubit should be accessible from widget tree',
        (tester) async {
      AuthCubit? capturedCubit;

      await tester.pumpWidget(
        BlocProvider(
          create: (context) => AuthCubit(repository: mockRepository),
          child: Builder(
            builder: (context) {
              capturedCubit = context.read<AuthCubit>();
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedCubit, isNotNull);
      expect(capturedCubit, isA<AuthCubit>());

      // Clean up
      await capturedCubit?.close();
    });

    testWidgets('AuthCubit state should be watchable via BlocBuilder',
        (tester) async {
      final testUser = AuthUser(
        id: 'test-id',
        email: 'test@example.com',
        createdAt: DateTime(2024),
      );
      final testProfile = UserProfile(
        id: 'profile-id',
        authUserId: 'test-id',
        role: UserRole.bride,
        isOnboardingComplete: true,
        createdAt: DateTime(2024),
      );

      when(() => mockRepository.getCurrentProfile())
          .thenAnswer((_) async => Success(testProfile));

      late AuthCubit cubit;

      await tester.pumpWidget(
        BlocProvider(
          create: (context) {
            cubit = AuthCubit(repository: mockRepository);
            return cubit;
          },
          child: MaterialApp(
            home: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                return Text(
                  switch (state) {
                    AuthInitial() => 'initial',
                    AuthLoading() => 'loading',
                    Authenticated() => 'authenticated',
                    Unauthenticated() => 'unauthenticated',
                    AuthError() => 'error',
                  },
                );
              },
            ),
          ),
        ),
      );

      // Initial state
      expect(find.text('initial'), findsOneWidget);

      // Simulate auth change
      authStateController.add(testUser);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Should show authenticated
      expect(find.text('authenticated'), findsOneWidget);

      // Simulate logout
      authStateController.add(null);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Should show unauthenticated
      expect(find.text('unauthenticated'), findsOneWidget);

      // Clean up
      await cubit.close();
    });

    testWidgets('AuthCubit should be accessible from nested widgets',
        (tester) async {
      AuthCubit? capturedCubit;

      await tester.pumpWidget(
        BlocProvider(
          create: (context) => AuthCubit(repository: mockRepository),
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Builder(
                    builder: (context) {
                      capturedCubit = context.read<AuthCubit>();
                      return const Text('Nested Widget');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(capturedCubit, isNotNull);
      expect(capturedCubit, isA<AuthCubit>());

      // Clean up
      await capturedCubit?.close();
    });

    testWidgets('Multiple widgets can listen to same AuthCubit', (tester) async {
      final testUser = AuthUser(
        id: 'test-id',
        email: 'test@example.com',
        createdAt: DateTime(2024),
      );

      when(() => mockRepository.getCurrentProfile())
          .thenAnswer((_) async => const Success(null));

      late AuthCubit cubit;

      await tester.pumpWidget(
        BlocProvider(
          create: (context) {
            cubit = AuthCubit(repository: mockRepository);
            return cubit;
          },
          child: MaterialApp(
            home: Column(
              children: [
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) =>
                      Text('Widget1: ${state.runtimeType}'),
                ),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) =>
                      Text('Widget2: ${state.runtimeType}'),
                ),
              ],
            ),
          ),
        ),
      );

      // Both widgets should show initial state
      expect(find.text('Widget1: AuthInitial'), findsOneWidget);
      expect(find.text('Widget2: AuthInitial'), findsOneWidget);

      // Trigger auth change
      authStateController.add(testUser);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Both widgets should update
      expect(find.text('Widget1: Authenticated'), findsOneWidget);
      expect(find.text('Widget2: Authenticated'), findsOneWidget);

      // Clean up
      await cubit.close();
    });
  });
}
